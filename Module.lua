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
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if 0<bd then bl=1 else be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,(((table.create or function(cs,ct)local cu={};for cv=1,cs do cu[cv]=ct;end;return cu;end))or tostring)end else if bd==2 then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if bk==1 then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if bk>4 then cx=1 else for bj=0,cv-1 do cw[bj]=bg(bj)end end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if 1==bj then cx=cx+1 else da=bh(be(bi,cx,((cx+cz)-1)),36)end end else if bj<=3 then cx=cx+cz else if 5~=bj then return da else break end end end bj=bj+1 end end else if bk~=8 then cs=bg(cy())else cu[1]=cs end end else if bk<=9 then while(cx<#bi and#a==d)do local a=cy()if cw[a]then ct=cw[a]else ct=(cs..be(cs,1,1))end cw[cv]=cs..be(ct,1,1)cu[#cu+1],cs,cv=ct,ct,(cv+1)end else if bk~=11 then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if 5~=bd then bo={}else c={s,q,l,y,i,x,w,u,m,k,j,o,nil};end else if bd<=6 then bp=v else if bd<8 then bq=bp(bo)else br,bs=1,((-14030+(function()local a,b,c,d,q=0 while true do if a<=0 then b,c,d,q=0 else if 1<a then break else while true do if(b<=1)then if not(b==1)then c,d=0,1 else q=(function(s,v,w)local x,y=0 while true do if x<=0 then y=0 else if x>1 then break else while true do if(1~=y)then s(w(w,s,s),s(v,s,(w and w)),v(v,s,w))else break end y=y+1 end end end x=x+1 end end)(function(s,v,w)local x,y=0 while true do if x<=0 then y=0 else if x~=2 then while true do if(y==2 or y<2)then if(y==0 or y<0)then if(c>360)then return w end else if(1==y)then c=c+1 else d=((((d*859))%42067))end end else if y<=3 then if(((d%1654)>827))then return v(v(s and s,s,s),s(w,v,s),s(v,v,v))else return v end else if not(4~=y)then return w else break end end end y=y+1 end else break end end x=x+1 end end,function(s,v,w)local x,y=0 while true do if x<=0 then y=0 else if 1==x then while true do if(y<2 or y==2)then if(y<=0)then if(c>253)then return w end else if 2~=y then c=(c+1)else d=(d+567)%15985 end end else if y<=3 then if((((d%1330))<665 or((d%1330))==665))then return v else return v(((v(v,v,s)and w(v,w,(w and s)))),s(v,w,w),(s(s,v,(w and v))and v(w,s,s)))end else if(5>y)then return v(s(w,w,v),s(((v and w)),w,w),s((s and s),s,v))else break end end end y=(y+1)end else break end end x=x+1 end end,function(s,v,w)local x,y=0 while true do if x<=0 then y=0 else if x==1 then while true do if(y<=2)then if(y<0 or y==0)then if((c>412))then return s end else if(y>1)then d=(((d+46)%47770))else c=c+1 end end else if(y==3 or y<3)then if((d%664)<332)then d=(((d*916)%22621))return v else return w(s(s,(v and w),s),(s(s,s,s)and w(s,w,w)),(v(w,w,s)and s(v,v and v,w)))end else if 4==y then return s(v(s,s,s),v(s,(s and s),w),(s(s and s,w,v)and v(s,w,s)))else break end end end y=y+1 end else break end end x=x+1 end end)end else if not(2~=b)then return d;else break end end b=b+1 end end end a=a+1 end end)()))end end end end else if bd<=12 then if bd<=10 then if 10>bd then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if 0==c then d=0 else for q=0,31 do local s=a%2 local v=(b%2)if not(s~=0)then if not(v~=1)then b=b-1 d=d+2^q end else a=(a-1)if(v==0)then d=(d+2^q)else b=(b-1)end end b=b/2 a=a/2 end end else if 3~=c then return d else break end end c=c+1 end end end else if 11<bd then bw=function()local a,b,c=0 while true do if a<=1 then if a~=1 then b,c=h(bn,br,br+2)else b,c=bu(b,bs),bu(c,bs);end else if a<=2 then br=br+2;else if 4>a then return((bv(c,8))+b);else break end end end a=a+1 end end else bv=function(a,b)local c=0 while true do if 1>c then return((a*2^b));else break end c=c+1 end end end end else if bd<=14 then if 14~=bd then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if c>0 then break else return p(a/2^b);end c=c+1 end end else if bd==16 then bz=(2^32-1)else ca=function(a,b)local c=0 while true do if c~=1 then return((a+b)-bu(a,b))/2 else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if 18==bd then cb=bw()else cc=function(a,b)local c=0 while true do if 1~=c then return(bz-ca((bz-a),(bz-b)))else break end c=c+1 end end end else if bd==20 then cd=function(a,b,c)local d=0 while true do if 1~=d then if c then local c=((a/2^(b-1))%(2^((c-1)-(b-1)+1)))return c-c%1 else local b=2^(b-1)return(a%(b+b)>=b)and 1 or 0 end else break end d=d+1 end end else ce=bw()end end else if bd<=23 then if bd==22 then cf=function()local a,b,c,d,p=0 while true do if a<=1 then if 1~=a then b,c,d,p=h(bn,br,(br+3))else b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);end else if a<=2 then br=br+4;else if 4~=a then return(((bv(p,24)+bv(d,16))+bv(c,8))+b);else break end end end a=a+1 end end else cg=function()local a,b=0 while true do if a<=1 then if a~=1 then b=bu(h(bn,br,br),cb)else br=(br+1);end else if a<3 then return b;else break end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if bd~=26 then ch=(-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)());else ci=(-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 while true do if a<=0 then b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 else if a==1 then while true do if(b==10 or b<10)then if(b<=4)then if(b==1 or b<1)then if not(b==1)then c=40425 else d=236 end else if b<=2 then p=960 else if 4>b then q=1920 else s=33223 end end end else if b<=7 then if(b<=5)then v=2 else if not(7==b)then w=894 else x=201 end end else if b<=8 then y=3 else if(b~=10)then be=1330 else bf=5906 end end end end else if(b==15 or b<15)then if(b<12 or b==12)then if 11<b then bh=665 else bg=617 end else if b<=13 then bi=211 else if not(b~=14)then bj=33389 else bk=787 end end end else if(b<18 or b==18)then if b<=16 then bs=1 else if(18>b)then bw=0 else by,bz=bw,bs end end else if(b<=19)then ca=(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if cs~=2 then while true do if(ct==0)then ce(ce(cc,cc),cc(ce,ce))else break end ct=(ct+1)end else break end end cs=cs+1 end end)(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if cs>1 then break else while true do if(ct<=2)then if(ct<=0)then if(by>bi)then local bi=bw while true do bi=(bi+bs)if not(bi~=bs)then return ce else break end end end else if not(1~=ct)then by=(by+bs)else bz=((bz-bk)%bj)end end else if(ct<3 or ct==3)then if(bz%be)<bh then local be=bw while true do be=((be+bs))if(not(be~=bs)or be<bs)then bz=(bz*bg)%bf else if not((be~=y))then break else return ce(ce(ce,ce),(cc(ce,ce)and ce(cc,ce)))end end end else local be=bw while true do be=(be+bs)if not(not(be==v))then break else return ce end end end else if ct<5 then return ce else break end end end ct=ct+1 end end end cs=cs+1 end end,function(be,bf)local bg,bh=0 while true do if bg<=0 then bh=0 else if 1==bg then while true do if(bh<=2)then if(bh==0 or bh<0)then if((by>x))then local x=bw while true do x=(x+bs)if not(not((x==v)))then break else return bf end end end else if bh==1 then by=((by+bs))else bz=(((bz+w))%s)end end else if bh<=3 then if((((bz%q))>p))then local p=bw while true do p=((p+bs))if(p<bs or p==bs)then bz=((bz*d)%c)else if not(not((p==y)))then break else return bf(be(be,(bf and be)),bf(bf,be))end end end else local c=bw while true do c=(c+bs)if c>bs then break else return be end end end else if(5~=bh)then return be else break end end end bh=bh+1 end else break end end bg=bg+1 end end)else if 20==b then return bz;else break end end end end end b=(b+1)end else break end end a=a+1 end end)());end end end end else if bd<=31 then if bd<=28 then if 28~=bd then cj=((-1671+(function()local a=409;local b=818;local c=28939;local d=222;local p=389;local q=38485;local s=1166;local v=583;local w=9454;local x=425;local y=4509;local be=442;local bf=292;local bg=3;local bh=1696;local bi=848;local bj=579;local bk=10108;local bs=252;local bw=908;local by=5205;local bz=470;local ca=746;local cc=1816;local ce=18568;local cs=2;local ct=1;local cu=421;local cv=0;local cw,cx=cv,ct;local a=(function(cy,cz,da,db)cy(cz(db,db,da,db),da(cz,cy,cz,db),da(da,cz,da,da),db(cz and cy,db,da,da))end)(function(cy,cz,da,db)if(cw>cu)then local cu=cv while true do cu=(cu+ct)if(cu<cs)then return cz else break end end end cw=cw+ct cx=(cx+ca)%ce if((cx%cc)==bw or(cx%cc)>bw)then local bw=cv while true do bw=bw+ct if(bw==ct or bw<ct)then cx=(cx-bz)%by else if not(bw~=cs)then return cz(cy(da,cy,cy,(cz and da)),da(cz,cz,cy,(da and db)),da(cy,db,cy,da),(cy(da,(db and cz),cz and da,cy)and cy((da and db),da and cy,db,da)))else break end end end else local bw=cv while true do bw=bw+ct if not(bw~=cs)then break else return cy end end end return cz end,function(bw,by,ca,cc)if cw>bs then local bs=cv while true do bs=bs+ct if not(bs~=cs)then break else return bw end end end cw=cw+ct cx=((cx-bj)%bk)if((cx%bh)==bi or(cx%bh)>bi)then local bh=cv while true do bh=bh+ct if(bh==cs or bh>cs)then if(bh<bg)then return ca else break end else cx=(cx*bf)%y end end else local y=cv while true do y=(y+ct)if(y<cs)then return bw(by(cc and by,bw and by,(ca and bw),bw),(cc(by,cc,by,(ca and cc))and ca(ca,cc,ca,ca)),ca(cc,bw and cc,bw,cc)and by(bw,bw and bw,ca,by),ca(ca,cc,(by and cc),ca))else break end end end return bw(ca(ca,by,ca and bw,cc),cc(ca,ca,cc,bw),bw(cc,cc,by,bw),by(bw,(bw and bw),ca,cc))end,function(y,bf,bh,bi)if(cw>be)then local be=cv while true do be=be+ct if be<cs then return bi else break end end end cw=cw+ct cx=((cx+x)%w)if((cx%s)>v or(cx%s)==v)then local s=cv while true do s=(s+ct)if(s<ct or s==ct)then cx=((cx-bz)%q)else if not(s~=bg)then break else return bi end end end else local q=cv while true do q=(q+ct)if not(q~=cs)then break else return bh(y(bh,(y and bh),bf,bi),(bi(bh,y,bf,bh)and bf(bi,bi and bh,bf,bh and bi)),bh(bf,bh,y,bh),bf(bf,bi,bf,bf))end end end return y(bh(bf and bi,bf,bf and y,(bi and bh)),bi(y,bh,bi,bh),bi(bi and bh,(bh and bh),bf,bh),y(bh,bi,bf,bi))end,function(q,s,v,w)if cw>p then local p=cv while true do p=p+ct if p<cs then return w else break end end end cw=cw+ct cx=(cx*d)%c if((cx%b)>a)then local a=cv while true do a=a+ct if(a<cs)then return q(v(w,q,q,(s and v)),q(q,v,s,(s and q))and w(s,w,w,s),s(q,w,q,(v and q)),v(q,v,q,v)and q(s,v,q,(q and w)))else break end end else local a=cv while true do a=a+ct if not(a~=cs)then break else return s end end end return w end)return cx;end)()));else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if 1~=a then b,c=cf(),cf()else if b==0 and c==0 then return 0;end;end else if 2==a then d=1 else p=(cd(c,1,20)*(2^32))+b end end else if a<=5 then if a~=5 then q=cd(c,21,31)else s=(((-1)^cd(c,32)))end else if a<=6 then if(not(q~=0))then if(p==0)then return(s*0);else q=1;d=0;end;elseif(q==2047)then if(not(p~=0))then return(s*(1/0));else return s*((0/0));end;end;else if a<8 then return(s*2^(q-1023)*(d+(p/(2^52))))else break end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if 30==bd then cm=function()local a,b,c=0 while true do if a<=1 then if a~=1 then b,c=h(bn,br,br+2)else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=(br+2);else if a~=4 then return((bv(c,8))+b);else break end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if 33~=bd then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if a<2 then c=157 else d=0 end end else if a<=3 then p={}else if a>4 then break else while d<8 do d=(d+1);while d<707 and c%1622<811 do c=(((c*35)))local q=d+c if(((c%16522)<8261))then c=((c*19))while(((d<828)and(c%658)<329))do c=(((c+60)))local q=d+c if(((c%18428))==9214 or((c%18428))<9214)then c=(((c-50)))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(not(q==0))then return g;end;b=j(bn,br,(br+q-1));br=((br+q));return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if 0<v then break else return i(h(q))end v=v+1 end end end s=s+1 end end);end elseif((c%4~=0))then c=((c-67))local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if not(v==1)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=(c*88)d=d+1 local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if 1>v then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=((d+1));end elseif not(not(c%4~=0))then c=((c-48))while(((d<859))and(c%1392)<696)do c=((c*39))local q=(d+c)if((c%58)<29)then c=((c+5))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1<s then break else while true do if v>0 then break else return i(h(q))end v=(v+1)end end end s=s+1 end end);end elseif not(not(c%4~=0))then c=(c*56)local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if(v>0)then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end else c=((c*9))d=(d+1)local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if(1~=v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=(d+1);end else c=(((c-51)))d=((d+1))while(((d<663))and(((c%936)<468)))do c=(((c*12)))local q=(d+c)if(((c%18532)>9266 or(c%18532)==9266))then c=((c*71))local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if v>0 then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif not(not(c%4~=0))then c=(c-18)local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if not(1==v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=((c*35))d=((d+1))local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if p>1 then break else while true do if not(q~=0)then return i(h(b))else break end q=q+1 end end end p=p+1 end end);end end;d=d+1;end end;d=(d+1);end c=((c-494))if((d>43))then break;end;end;end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if 0==a then return{...},n("\35",...)else break end a=a+1 end end else if 35<bd then break else cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if a>3 then w=0 else v=490 end end end else if a<=6 then if 5<a then while w<3 do w=(w+1);while(w<481 and(v%320)<160)do v=((v*62))local d=(w+v)if(v%916)>458 then v=((v-88))while(w<318)and v%702<351 do v=(((v*8)))local d=((w+v))if((v%14064)>7032)then v=((v*81))local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4)==0)then v=((v*37))local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(v+10)w=((w+1))local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(j~=2))then s[d]=nil;elseif(not(not(j==0)))then s[d]=(not(cg()==0));elseif(((j==1)))then s[d]=ck();elseif(not(j~=3))then s[d]=co();end;end;q[cj]=s;end end;w=w+1;end elseif not(((v%4)==0))then v=(((v*65)))while((w<615)and v%618<309)do v=((v-33))local d=(w+v)if((v%15582)>7791)then v=((v*14))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(not((v%4)~=0))then v=(((v+51)))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+53)))w=((w+1))local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end else v=(v+7)w=w+1 while((w<127)and v%1548<774)do v=((v-37))local d=(w+v)if(((v%19188))>9594)then v=(((v*61)))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(not(v%4~=0))then v=(v+25)local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+42))w=(w+1)local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end end;w=(w+1);end v=((v*482))if(w>56)then break;end;end;else x={}end else if a<=7 then for d=1,cf()do c[d-1]=cr();end;else if 8==a then v=225 else w=0 end end end end else if a<=14 then if a<=11 then if a==10 then x={}else while(w<5)do w=w+1;while(w<642 and v%824<412)do v=((v-37))local c=(w+v)if((v%18064)>9032)then v=((v+3))while(w<514)and(v%140<70)do v=((v*18))local c=(w+v)if(not(((v%2014))~=1007)or((((v%2014)))>1007))then v=((v*73))local c=68651 if not x[c]then x[c]=1;local c=1;local d=2;local j=3;local p=4;for p=1,cf()do local y=cg();local bb=cd(y,c,c);if(not(((bb~=0))))then local y,bb,be=cd(y,d,j),cd(y,4,6),m({[545]=cm(),[189]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(y,d,j);end,})if(((y==0)or(not(y~=c))))then be[591]=cf();if(not((y~=0)))then be[893]=cf();end;elseif(((y==d)or(y==j)))then be[591]=((cf()-(e)));if((not(not(y==j))))then be[893]=cm();end;end;if(not(not(cd(bb,c,c)==c)))then be[189]=s[be[189]];end;if(not(cd(bb,d,d)~=c))then be[591]=s[be[591]];end;if((not(not(cd(bb,j,j)==c))))then be[893]=s[be[893]];end;b[p]=be;end;end;end elseif not(((v%4)==0))then v=(v*80)local b=45673 if not x[b]then x[b]=1;end else v=(v-1)w=((w+1))local b=84088 if not x[b]then x[b]=1;end end;w=(w+1);end elseif v%4~=0 then v=(((v-40)))while((w<818))and(v%1502<751)do v=((v+22))local b=(w+v)if((v%4030)<2015)then v=((v*45))local b=15986 if not x[b]then x[b]=1;end elseif(not((v%4)==0))then v=((v-8))local b=95219 if not x[b]then x[b]=1;end else v=((v*31))w=((w+1))local b=3382 if not x[b]then x[b]=1;end end;w=w+1;end else v=((v*43))w=(w+1)while(w<963 and v%1734<867)do v=((v*31))local b=w+v if((v%12958)>6479)then v=((v+58))local b=61305 if not x[b]then x[b]=1;end elseif(not(v%4==0))then v=(v-74)local b=63656 if not x[b]then x[b]=1;end else v=((v*55))w=(w+1)local b=74653 if not x[b]then x[b]=1;end end;w=w+1;end end;w=((w+1));end v=((v*62))if(w>73)then break;end;end;end else if a<=12 then q[481]=cg();else if 13<a then v=550 else do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[189],b[591],b[893]if not(not(bp(c)==f))then c=z(c,cl,function(j,p,p)local p,s=0 while true do if p<=0 then s=0 else if 2~=p then while true do if not(1==s)then return i(bu(h(j),cb))else break end s=s+1 end else break end end p=p+1 end end)b[189]=c end if bp(d)==f then d=z(d,cl,function(c,j,j)local j,p=0 while true do if j<=0 then p=0 else if 1==j then while true do if p<1 then return i(bu(h(c),cb))else break end p=(p+1)end else break end end j=j+1 end end)b[591]=d end if not(not((bp(e)==f)))then e=z(e,cl,function(c,d)local d,j=0 while true do if d<=0 then j=0 else if d~=2 then while true do if not(j==1)then return i(bu(h(c),cb))else break end j=(j+1)end else break end end d=d+1 end end)b[893]=e end;end;q[cj]=nil;end;end end end else if a<=16 then if a~=16 then w=0 else x={}end else if a<=17 then while w<3 do w=((w+1));while(w<114 and v%468<234)do v=((v*90))local b=(w+v)if((((v%1516))>758 or((v%1516))==758))then v=(((v+35)))while(w<262)and((v%1028)<514)do v=(v*49)local b=(w+v)if((v%438)<219 or(v%438)==219)then v=((v*58))local b=36449 if not x[b]then x[b]=1;end elseif(v%4~=0)then v=((v-67))local b=52444 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if b~=2 then while true do if c<=2 then if c<=0 then d=n(1,...)else if 1<c then do for d=0,#e do if not(bp(e[d])~=bq)then for i,i in o,e[d]do if((bp(i)==bp(g)))then t(bo,i)end end else t(bo,e[d])end end end else e=({...})end end else if c<=3 then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if 1<i then break else while true do if(j==1 or j<1)then if 1>j then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if not(2~=j)then return false else break end end j=j+1 end end end i=i+1 end end else if(c~=5)then for d=0,#e do if bp(e[d])==bq then return h(e[d])end end else break end end end c=(c+1)end else break end end b=b+1 end end end else v=((v-11))w=(w+1)local b=92935 if not x[b]then x[b]=1;return q end end;w=(w+1);end elseif not(not(v%4~=0))then v=(((v*90)))while((w<771 and v%754<377))do v=((v+62))local b=((w+v))if((v%6058)>3029)then v=(((v+57)))local b=39829 if not x[b]then x[b]=1;return q end elseif(v%4~=0)then v=((v+29))local b=86446 if not x[b]then x[b]=1;return q end else v=(v-98)w=((w+1))local b=30659 if not x[b]then x[b]=1;return q end end;w=w+1;end else v=((v*94))w=((w+1))while((w<578 and(((v%670)<335))))do v=(v+41)local b=(w+v)if((((v%15580))<7790))then v=((v+64))local b=44096 if not x[b]then x[b]=1;end elseif(not((v%4)==0))then v=(v*88)local b=90761 if not x[b]then x[b]=1;return q end else v=(((v*21)))w=(w+1)local b=49098 if not x[b]then x[b]=1;return q end end;w=((w+1));end end;w=w+1;end v=(v-219)if w>6 then break;end;end;else if a>18 then break else return q;end end end end end a=a+1 end end end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[545];if 192>=z then if z<=95 then if z<=47 then if(z<23 or z==23)then if(11>z or 11==z)then if(5==z or 5>z)then if z<=2 then if 0>=z then local ba,bb=0 while true do if(ba<8 or ba==8)then if(ba<3 or ba==3)then if(ba<=1)then if(ba>0)then w[y[189]]=w[y[591]][y[893]];else bb=nil end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if(ba>4)then n=(n+1);else w[y[189]]=w[y[591]][y[893]];end else if(ba<=6)then y=f[n];else if(7<ba)then n=(n+1);else w[y[189]]=w[y[591]][y[893]];end end end end else if(ba<=13)then if(ba==10 or ba<10)then if ba<10 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if ba<=11 then n=n+1;else if(12<ba)then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end else if ba<=15 then if(15~=ba)then n=n+1;else y=f[n];end else if(ba<16 or ba==16)then bb=y[189]else if ba==17 then w[bb]=w[bb](w[(bb+1)])else break end end end end end ba=ba+1 end elseif(z<2)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[189]]=h[y[591]];end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if 4==ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if 6==ba then y=f[n];else w[y[189]]=y[591];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if 11>ba then w[y[189]]=y[591];else n=n+1;end end else if ba<=13 then if ba==12 then y=f[n];else bb=y[189]end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[591]))else break end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[189]]=h[y[591]];else n=n+1;end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[189]]=w[y[591]][w[y[893]]];else if 13==ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 16>ba then bd=y[189]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18<ba then break else for be=bd,y[893]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end end;elseif(3>=z)then local ba,bb=0 while true do if ba<=79 then if ba<=39 then if ba<=19 then if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else w[y[189]]=h[y[591]];end else if ba<=2 then n=n+1;else if ba<4 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if ba<=6 then if ba<6 then n=n+1;else y=f[n];end else if ba<=7 then w[y[189]]=h[y[591]];else if 9~=ba then n=n+1;else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 11>ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=12 then y=f[n];else if 14~=ba then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end end end else if ba<=16 then if ba==15 then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=17 then n=n+1;else if ba==18 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end end else if ba<=29 then if ba<=24 then if ba<=21 then if 20==ba then n=n+1;else y=f[n];end else if ba<=22 then w[y[189]]=h[y[591]];else if ba==23 then n=n+1;else y=f[n];end end end else if ba<=26 then if 26~=ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=27 then y=f[n];else if ba~=29 then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end end end end else if ba<=34 then if ba<=31 then if ba>30 then w[y[189]]=h[y[591]];else y=f[n];end else if ba<=32 then n=n+1;else if ba>33 then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end else if ba<=36 then if 36~=ba then n=n+1;else y=f[n];end else if ba<=37 then w[y[189]]=h[y[591]];else if ba==38 then n=n+1;else y=f[n];end end end end end end else if ba<=59 then if ba<=49 then if ba<=44 then if ba<=41 then if ba==40 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=42 then y=f[n];else if ba~=44 then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end end end else if ba<=46 then if 46>ba then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=47 then n=n+1;else if 49>ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if ba<=54 then if ba<=51 then if 51~=ba then n=n+1;else y=f[n];end else if ba<=52 then w[y[189]]=h[y[591]];else if ba<54 then n=n+1;else y=f[n];end end end else if ba<=56 then if 56~=ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=57 then y=f[n];else if ba>58 then n=n+1;else w[y[189]][w[y[591]]]=w[y[893]];end end end end end else if ba<=69 then if ba<=64 then if ba<=61 then if ba~=61 then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=62 then n=n+1;else if ba>63 then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end else if ba<=66 then if ba~=66 then n=n+1;else y=f[n];end else if ba<=67 then w[y[189]]=h[y[591]];else if 69~=ba then n=n+1;else y=f[n];end end end end else if ba<=74 then if ba<=71 then if ba>70 then n=n+1;else w[y[189]]=w[y[591]][y[893]];end else if ba<=72 then y=f[n];else if 74~=ba then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end end end else if ba<=76 then if 76>ba then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=77 then n=n+1;else if 78==ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end end end end else if ba<=119 then if ba<=99 then if ba<=89 then if ba<=84 then if ba<=81 then if ba==80 then n=n+1;else y=f[n];end else if ba<=82 then w[y[189]]=h[y[591]];else if ba>83 then y=f[n];else n=n+1;end end end else if ba<=86 then if 85<ba then n=n+1;else w[y[189]]=w[y[591]][y[893]];end else if ba<=87 then y=f[n];else if ba==88 then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end end end end else if ba<=94 then if ba<=91 then if ba~=91 then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=92 then n=n+1;else if 94~=ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if ba<=96 then if 95==ba then n=n+1;else y=f[n];end else if ba<=97 then w[y[189]]=h[y[591]];else if ba<99 then n=n+1;else y=f[n];end end end end end else if ba<=109 then if ba<=104 then if ba<=101 then if 100==ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=102 then y=f[n];else if ba~=104 then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end end end else if ba<=106 then if ba<106 then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=107 then n=n+1;else if 108==ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if ba<=114 then if ba<=111 then if 111>ba then n=n+1;else y=f[n];end else if ba<=112 then w[y[189]]=h[y[591]];else if ba>113 then y=f[n];else n=n+1;end end end else if ba<=116 then if ba~=116 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=117 then y=f[n];else if ba~=119 then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end end end end end end else if ba<=139 then if ba<=129 then if ba<=124 then if ba<=121 then if 120<ba then w[y[189]]=h[y[591]];else y=f[n];end else if ba<=122 then n=n+1;else if ba~=124 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if ba<=126 then if 126~=ba then n=n+1;else y=f[n];end else if ba<=127 then w[y[189]]=h[y[591]];else if ba>128 then y=f[n];else n=n+1;end end end end else if ba<=134 then if ba<=131 then if ba>130 then n=n+1;else w[y[189]]=w[y[591]][y[893]];end else if ba<=132 then y=f[n];else if ba<134 then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end end end else if ba<=136 then if ba~=136 then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=137 then n=n+1;else if ba==138 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end end else if ba<=149 then if ba<=144 then if ba<=141 then if 140<ba then y=f[n];else n=n+1;end else if ba<=142 then w[y[189]]=h[y[591]];else if 144>ba then n=n+1;else y=f[n];end end end else if ba<=146 then if ba==145 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=147 then y=f[n];else if ba~=149 then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end end end end else if ba<=154 then if ba<=151 then if ba>150 then w[y[189]]=j[y[591]];else y=f[n];end else if ba<=152 then n=n+1;else if 153==ba then y=f[n];else w[y[189]]=w[y[591]];end end end else if ba<=156 then if ba~=156 then n=n+1;else y=f[n];end else if ba<=157 then bb=y[189]else if ba==158 then w[bb]=w[bb](w[bb+1])else break end end end end end end end end ba=ba+1 end elseif 4<z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[189]]=w[y[591]][y[893]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[189]]=h[y[591]];else n=n+1;end else if ba<=6 then y=f[n];else if ba>7 then n=n+1;else w[y[189]]=w[y[591]][y[893]];end end end end else if ba<=13 then if ba<=10 then if ba>9 then w[y[189]]=y[591];else y=f[n];end else if ba<=11 then n=n+1;else if ba~=13 then y=f[n];else w[y[189]]=y[591];end end end else if ba<=15 then if ba~=15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[189]else if 18>ba then w[bb]=w[bb](r(w,bb+1,y[591]))else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=16 then if ba<=7 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[189]]=w[y[591]][y[893]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba<5 then w[y[189]]=h[y[591]];else n=n+1;end else if 6==ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if ba<=11 then if ba<=9 then if 9>ba then n=n+1;else y=f[n];end else if ba==10 then w[y[189]]={};else n=n+1;end end else if ba<=13 then if 12<ba then w[y[189]]=h[y[591]];else y=f[n];end else if ba<=14 then n=n+1;else if ba~=16 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end end else if ba<=24 then if ba<=20 then if ba<=18 then if 18>ba then n=n+1;else y=f[n];end else if ba~=20 then w[y[189]]=h[y[591]];else n=n+1;end end else if ba<=22 then if 21==ba then y=f[n];else w[y[189]]={};end else if ba<24 then n=n+1;else y=f[n];end end end else if ba<=28 then if ba<=26 then if 26>ba then w[y[189]]=h[y[591]];else n=n+1;end else if ba==27 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if ba<=30 then if ba~=30 then n=n+1;else y=f[n];end else if ba<=31 then bb=y[189]else if 33>ba then w[bb]=w[bb]()else break end end end end end end ba=ba+1 end end;elseif 8>=z then if(z<6 or z==6)then local ba,bb=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then w={};else bb=nil end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if 3<ba then y=f[n];else n=n+1;end end end else if ba<=6 then if ba>5 then n=n+1;else w[y[189]]=y[591];end else if ba<=7 then y=f[n];else if 8==ba then w[y[189]]=h[y[591]];else n=n+1;end end end end else if ba<=14 then if ba<=11 then if 11>ba then y=f[n];else w[y[189]]=#w[y[591]];end else if ba<=12 then n=n+1;else if ba<14 then y=f[n];else w[y[189]]=y[591];end end end else if ba<=17 then if ba<=15 then n=n+1;else if ba==16 then y=f[n];else bb=y[189];end end else if ba<=18 then w[bb]=w[bb]-w[bb+2];else if ba==19 then n=y[591];else break end end end end end ba=ba+1 end elseif(z==7)then w[y[189]]=#w[y[591]];else local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then w[y[189]]={};else n=n+1;end else if ba<=2 then y=f[n];else if ba~=4 then w[y[189]]={};else n=n+1;end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[189]]={};end else if ba<=7 then n=n+1;else if 8<ba then w[y[189]]={};else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[189]]={};else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then w[y[189]]=y[591];else n=n+1;end else if ba<=17 then y=f[n];else if ba<19 then w[y[189]]=w[y[591]][w[y[893]]];else break end end end end end ba=ba+1 end end;elseif(9==z or 9>z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[189]]=h[y[591]];end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[189]]=w[y[591]][w[y[893]]];else if 14>ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[189]end else if ba<=17 then bb=0;else if ba<19 then for be=bd,y[893]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif z>10 then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[189]]=w[y[591]][y[893]];else if ba>1 then y=f[n];else n=n+1;end end else if ba<=4 then if ba==3 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba~=6 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[189]][y[591]]=w[y[893]];end end else if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba~=13 then n=y[591];else break end end end end ba=ba+1 end else if not w[y[189]]then n=n+1;else n=y[591];end;end;elseif(17>=z)then if(not(z~=14)or(z<14))then if((12==z)or 12>z)then w[y[189]]=false;n=(n+1);elseif not(not(13==z))then local ba,bb,bc,bd=0 while true do if(ba<9 or ba==9)then if ba<=4 then if(ba<=1)then if not(ba==1)then bb=nil else bc=nil end else if(ba==2 or ba<2)then bd=nil else if not(4==ba)then w[y[189]]=h[y[591]];else n=n+1;end end end else if(ba<=6)then if(ba>5)then w[y[189]]=h[y[591]];else y=f[n];end else if ba<=7 then n=n+1;else if not(9==ba)then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if(ba<14 or ba==14)then if(ba==11 or ba<11)then if 11~=ba then n=(n+1);else y=f[n];end else if(ba==12 or ba<12)then w[y[189]]=w[y[591]][w[y[893]]];else if(13<ba)then y=f[n];else n=(n+1);end end end else if ba<=16 then if(15<ba)then bc={w[bd](w[bd+1])};else bd=y[189]end else if(ba<17 or ba==17)then bb=0;else if(ba==18)then for be=bd,y[893]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if(ba==10 or ba<10)then if(ba==4 or ba<4)then if(ba<1 or ba==1)then if 0==ba then bb=nil else w[y[189]]=j[y[591]];end else if(ba==2 or ba<2)then n=(n+1);else if ba~=4 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if(ba==7 or ba<7)then if ba<=5 then n=(n+1);else if(ba>6)then w[y[189]]=y[591];else y=f[n];end end else if ba<=8 then n=n+1;else if not(10==ba)then y=f[n];else w[y[189]]=y[591];end end end end else if(ba<15 or ba==15)then if(ba<12 or ba==12)then if not(ba==12)then n=n+1;else y=f[n];end else if ba<=13 then w[y[189]]=y[591];else if ba<15 then n=(n+1);else y=f[n];end end end else if ba<=18 then if(ba<16 or ba==16)then w[y[189]]=y[591];else if ba>17 then y=f[n];else n=(n+1);end end else if ba<=19 then bb=y[189]else if(ba>20)then break else w[bb]=w[bb](r(w,(bb+1),y[591]))end end end end end ba=(ba+1)end end;elseif(not(15~=z)or 15>z)then local ba,bb,bc,bd=0 while true do if ba<=10 then if(ba<=4)then if(ba<1 or ba==1)then if not(0~=ba)then bb=nil else bc=nil end else if(ba<2 or ba==2)then bd=nil else if not(4==ba)then w[y[189]]=h[y[591]];else n=(n+1);end end end else if(ba==7 or ba<7)then if(ba==5 or ba<5)then y=f[n];else if ba~=7 then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end end else if ba<=8 then y=f[n];else if ba~=10 then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end end end end else if ba<=16 then if(ba<13 or ba==13)then if ba<=11 then y=f[n];else if not(12~=ba)then w[y[189]]=h[y[591]];else n=n+1;end end else if(ba<=14)then y=f[n];else if 16~=ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end else if(ba==19 or ba<19)then if(ba<17 or ba==17)then y=f[n];else if not(18~=ba)then bd=y[591];else bc=y[893];end end else if ba<=20 then bb=k(w,g,bd,bc);else if ba<22 then w[y[189]]=bb;else break end end end end end ba=(ba+1)end elseif(16<z)then local ba,bb=0 while true do if(ba==7 or ba<7)then if(ba<=3)then if(ba<1 or ba==1)then if(ba~=1)then bb=nil else w[y[189]]=j[y[591]];end else if ba>2 then y=f[n];else n=(n+1);end end else if ba<=5 then if ba<5 then w[y[189]]=y[591];else n=(n+1);end else if 6<ba then w[y[189]]=w[y[591]][w[y[893]]];else y=f[n];end end end else if(ba<=11)then if(ba<=9)then if 9~=ba then n=n+1;else y=f[n];end else if not(ba==11)then w[y[189]]=w[y[591]];else n=(n+1);end end else if(ba<=13)then if not(12~=ba)then y=f[n];else bb=y[189]end else if ba>14 then break else w[bb]=w[bb](w[bb+1])end end end end ba=ba+1 end else local ba=0 while true do if(ba<=8)then if ba<=3 then if(ba<1 or ba==1)then if(0<ba)then for bb=0,u,1 do if(bb<o)then w[bb]=s[bb+1];else break;end;end;else w={};end else if ba>2 then y=f[n];else n=n+1;end end else if(ba==5 or ba<5)then if not(5==ba)then w[y[189]]=h[y[591]];else n=n+1;end else if(ba<=6)then y=f[n];else if not(ba==8)then w[y[189]]=w[y[591]]+y[893];else n=n+1;end end end end else if ba<=12 then if(ba==10 or ba<10)then if not(10==ba)then y=f[n];else h[y[591]]=w[y[189]];end else if 12>ba then n=(n+1);else y=f[n];end end else if(ba<=14)then if not(ba~=13)then w[y[189]]=h[y[591]];else n=n+1;end else if(ba<15 or ba==15)then y=f[n];else if ba<17 then w[y[189]]();else break end end end end end ba=ba+1 end end;elseif 20>=z then if(18==z or 18>z)then local ba,bb,bc,bd,be=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc,bd=nil end else if ba<=2 then be=nil else if ba>3 then n=n+1;else w[y[189]]=w[y[591]];end end end else if ba<=6 then if ba>5 then w[y[189]]=y[591];else y=f[n];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[189]]=y[591];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[189]]=y[591];else if 14>ba then n=n+1;else y=f[n];end end end else if ba<=17 then if ba<=15 then be=y[189]else if 16<ba then p=bd+be-1 else bc,bd=i(w[be](r(w,be+1,y[591])))end end else if ba<=18 then bb=0;else if ba<20 then for bd=be,p do bb=bb+1;w[bd]=bc[bb];end;else break end end end end end ba=ba+1 end elseif(20>z)then do return w[y[189]]end else w[y[189]]=true;end;elseif(z<21 or z==21)then w[y[189]]=y[591]*w[y[893]];elseif(z==22)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[189]]=j[y[591]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba==4 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=6 then y=f[n];else if 8~=ba then w[y[189]]=y[591];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba~=10 then y=f[n];else w[y[189]]=y[591];end else if ba<=11 then n=n+1;else if ba<13 then y=f[n];else w[y[189]]=y[591];end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[189]else if ba==17 then w[bb]=w[bb](r(w,bb+1,y[591]))else break end end end end end ba=ba+1 end else local ba=y[189];local bb=w[y[591]];w[ba+1]=bb;w[ba]=bb[y[893]];end;elseif(z<35 or z==35)then if(29>=z)then if(z<26 or z==26)then if(24>z or 24==z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if(ba==4 or ba<4)then if(ba<=1)then if(0==ba)then bb=nil else bc=nil end else if(ba<2 or ba==2)then bd=nil else if(ba~=4)then w[y[189]]=h[y[591]];else n=(n+1);end end end else if(ba<=6)then if(ba<6)then y=f[n];else w[y[189]]=h[y[591]];end else if(ba==7 or ba<7)then n=(n+1);else if 8<ba then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end end else if(ba<14 or ba==14)then if(ba<=11)then if not(11==ba)then n=(n+1);else y=f[n];end else if(ba<12 or ba==12)then w[y[189]]=w[y[591]][w[y[893]]];else if(ba~=14)then n=n+1;else y=f[n];end end end else if(ba<=16)then if not(16==ba)then bd=y[189]else bc={w[bd](w[bd+1])};end else if(ba<17 or ba==17)then bb=0;else if(ba>18)then break else for be=bd,y[893]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=(ba+1)end elseif not(z==26)then local ba=0 while true do if(ba==7 or ba<7)then if(ba<=3)then if(ba<1 or ba==1)then if(0<ba)then n=(n+1);else w[y[189]]=w[y[591]][y[893]];end else if(2<ba)then w[y[189]][y[591]]=w[y[893]];else y=f[n];end end else if ba<=5 then if ba==4 then n=(n+1);else y=f[n];end else if not(ba==7)then w[y[189]]=h[y[591]];else n=n+1;end end end else if ba<=11 then if(ba==9 or ba<9)then if 9>ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if not(ba==11)then n=n+1;else y=f[n];end end else if ba<=13 then if not(12~=ba)then w[y[189]][y[591]]=w[y[893]];else n=n+1;end else if(ba==14 or ba<14)then y=f[n];else if(ba>15)then break else do return w[y[189]]end end end end end end ba=ba+1 end else local ba,bb=0 while true do if(ba==7 or ba<7)then if(ba==3 or ba<3)then if(ba<1 or ba==1)then if(ba<1)then bb=nil else w[y[189]][y[591]]=w[y[893]];end else if not(3==ba)then n=n+1;else y=f[n];end end else if(ba<5 or ba==5)then if 5~=ba then w[y[189]]={};else n=(n+1);end else if not(ba==7)then y=f[n];else w[y[189]][y[591]]=y[893];end end end else if(ba<11 or ba==11)then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if(ba>10)then n=n+1;else w[y[189]][y[591]]=w[y[893]];end end else if(ba==13 or ba<13)then if not(13==ba)then y=f[n];else bb=y[189]end else if(14==ba)then w[bb]=w[bb](r(w,(bb+1),y[591]))else break end end end end ba=ba+1 end end;elseif(27>z or(27==z))then w[y[189]][w[y[591]]]=w[y[893]];elseif z~=29 then local ba=y[189]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[893]do bc=bc+1;w[bd]=bb[bc];end else local ba,bb=0 while true do if(ba==7 or ba<7)then if(ba==3 or ba<3)then if(ba<1 or ba==1)then if 0==ba then bb=nil else w[y[189]]=j[y[591]];end else if(ba>2)then y=f[n];else n=n+1;end end else if(ba==5 or ba<5)then if ba~=5 then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end else if 6==ba then y=f[n];else w[y[189]]=h[y[591]];end end end else if ba<=11 then if(ba<=9)then if ba>8 then y=f[n];else n=n+1;end else if 10<ba then n=n+1;else w[y[189]]=w[y[591]][y[893]];end end else if(ba==13 or ba<13)then if ba>12 then bb=y[189]else y=f[n];end else if not(ba~=14)then w[bb]=w[bb](w[(bb+1)])else break end end end end ba=(ba+1)end end;elseif(z<=32)then if(z==30 or z<30)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba~=4 then w[y[189]]=h[y[591]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[189]]=w[y[591]][w[y[893]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if 15==ba then bd=y[189]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[893]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif(z<32)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[189]]=w[y[591]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba~=5 then w[y[189]]=y[591];else n=n+1;end else if ba==6 then y=f[n];else w[y[189]]=y[591];end end end else if ba<=11 then if ba<=9 then if 9>ba then n=n+1;else y=f[n];end else if ba==10 then w[y[189]]=y[591];else n=n+1;end end else if ba<=13 then if 12==ba then y=f[n];else bb=y[189]end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[591]))else break end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[189]]=w[y[591]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if 5~=ba then w[y[189]]=y[591];else n=n+1;end else if 7>ba then y=f[n];else w[y[189]]=y[591];end end end else if ba<=11 then if ba<=9 then if 9>ba then n=n+1;else y=f[n];end else if ba~=11 then w[y[189]]=y[591];else n=n+1;end end else if ba<=13 then if 13>ba then y=f[n];else bb=y[189]end else if ba<15 then w[bb]=w[bb](r(w,bb+1,y[591]))else break end end end end ba=ba+1 end end;elseif(33>z or 33==z)then local ba,bb=0 while true do if ba<=16 then if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[189]]=w[y[591]][y[893]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba~=5 then w[y[189]]=h[y[591]];else n=n+1;end else if ba==6 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if ba<=11 then if ba<=9 then if ba<9 then n=n+1;else y=f[n];end else if ba~=11 then w[y[189]]={};else n=n+1;end end else if ba<=13 then if 13>ba then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=14 then n=n+1;else if 15<ba then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end end end else if ba<=24 then if ba<=20 then if ba<=18 then if ba==17 then n=n+1;else y=f[n];end else if ba<20 then w[y[189]]=h[y[591]];else n=n+1;end end else if ba<=22 then if ba~=22 then y=f[n];else w[y[189]]={};end else if 23<ba then y=f[n];else n=n+1;end end end else if ba<=28 then if ba<=26 then if 25<ba then n=n+1;else w[y[189]]=h[y[591]];end else if 27==ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if ba<=30 then if 29==ba then n=n+1;else y=f[n];end else if ba<=31 then bb=y[189]else if 33>ba then w[bb]=w[bb]()else break end end end end end end ba=ba+1 end elseif not(z~=34)then local ba,bb,bc,bd,be=0 while true do if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba==1 then bc,bd=nil else be=nil end end else if ba<=3 then w[y[189]]=j[y[591]];else if ba~=5 then n=n+1;else y=f[n];end end end else if ba<=8 then if ba<=6 then w[y[189]]=w[y[591]];else if 8~=ba then n=n+1;else y=f[n];end end else if ba<=9 then w[y[189]]=y[591];else if ba<11 then n=n+1;else y=f[n];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then w[y[189]]=y[591];else if 14>ba then n=n+1;else y=f[n];end end else if ba<=15 then w[y[189]]=y[591];else if ba>16 then y=f[n];else n=n+1;end end end else if ba<=20 then if ba<=18 then be=y[189]else if 19<ba then p=bd+be-1 else bc,bd=i(w[be](r(w,be+1,y[591])))end end else if ba<=21 then bb=0;else if 23>ba then for bd=be,p do bb=bb+1;w[bd]=bc[bb];end;else break end end end end end ba=ba+1 end else local ba=y[189]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[893]do bc=(bc+1);w[bd]=bb[bc];end end;elseif z<=41 then if 38>=z then if(z<=36)then local ba,bb,bc,bd=0 while true do if(ba<9 or ba==9)then if(ba<=4)then if ba<=1 then if not(0~=ba)then bb=nil else bc=nil end else if(ba<=2)then bd=nil else if not(ba==4)then w[y[189]]=h[y[591]];else n=(n+1);end end end else if(ba<=6)then if ba~=6 then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=7 then n=(n+1);else if not(9==ba)then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if(ba==14 or ba<14)then if(ba==11 or ba<11)then if not(11==ba)then n=(n+1);else y=f[n];end else if(ba==12 or ba<12)then w[y[189]]=w[y[591]][w[y[893]]];else if 13==ba then n=n+1;else y=f[n];end end end else if(ba<=16)then if not(ba==16)then bd=y[189]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if(19~=ba)then for be=bd,y[893]do bb=(bb+1);w[be]=bc[bb];end else break end end end end end ba=(ba+1)end elseif not(not(37==z))then local ba,bb,bc,bd=0 while true do if(ba<9 or ba==9)then if(ba<4 or ba==4)then if(ba<1 or ba==1)then if ba~=1 then bb=nil else bc=nil end else if(ba<=2)then bd=nil else if 4~=ba then w[y[189]]=h[y[591]];else n=(n+1);end end end else if ba<=6 then if 5<ba then w[y[189]]=h[y[591]];else y=f[n];end else if ba<=7 then n=n+1;else if not(ba==9)then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if(ba<=14)then if ba<=11 then if not(11==ba)then n=n+1;else y=f[n];end else if(ba<=12)then w[y[189]]=w[y[591]][w[y[893]]];else if 14>ba then n=n+1;else y=f[n];end end end else if(ba==16 or ba<16)then if ba<16 then bd=y[189]else bc={w[bd](w[bd+1])};end else if(ba<17 or ba==17)then bb=0;else if not(19==ba)then for be=bd,y[893]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=(ba+1)end else local ba=y[189];p=((ba+x)-1);for bb=ba,p do local ba=q[(bb-ba)];w[bb]=ba;end;end;elseif(39>z or 39==z)then local ba,bb,bc,bd=0 while true do if ba<=15 then if(ba<=7)then if(ba<=3)then if(ba<=1)then if ba<1 then bb=nil else bc=nil end else if ba>2 then w[y[189]]=h[y[591]];else bd=nil end end else if ba<=5 then if ba<5 then n=n+1;else y=f[n];end else if 6==ba then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end end end else if(ba<=11)then if(ba<9 or ba==9)then if not(ba==9)then y=f[n];else w[y[189]]=h[y[591]];end else if not(ba==11)then n=n+1;else y=f[n];end end else if(ba<13 or ba==13)then if ba~=13 then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end else if not(15==ba)then y=f[n];else w[y[189]]=w[y[591]][w[y[893]]];end end end end else if(ba<=23)then if(ba<=19)then if(ba<17 or ba==17)then if ba<17 then n=(n+1);else y=f[n];end else if(19>ba)then w[y[189]]=h[y[591]];else n=(n+1);end end else if(ba<21 or ba==21)then if ba==20 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if not(ba==23)then n=(n+1);else y=f[n];end end end else if ba<=27 then if ba<=25 then if(ba~=25)then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if(ba<27)then y=f[n];else bd=y[591];end end else if(ba<29 or ba==29)then if 29~=ba then bc=y[893];else bb=k(w,g,bd,bc);end else if(31>ba)then w[y[189]]=bb;else break end end end end end ba=(ba+1)end elseif(41>z)then local ba,bb=0 while true do if(ba==7 or ba<7)then if(ba<=3)then if(ba<=1)then if not(1==ba)then bb=nil else w[y[189]]=w[y[591]];end else if not(ba~=2)then n=(n+1);else y=f[n];end end else if(ba==5 or ba<5)then if not(5==ba)then w[y[189]]=y[591];else n=n+1;end else if ba~=7 then y=f[n];else w[y[189]]=y[591];end end end else if(ba==11 or ba<11)then if(ba<9 or ba==9)then if(9>ba)then n=(n+1);else y=f[n];end else if ba>10 then n=n+1;else w[y[189]]=y[591];end end else if ba<=13 then if not(12~=ba)then y=f[n];else bb=y[189]end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[591]))else break end end end end ba=ba+1 end else local ba,bb=0 while true do if(ba<7 or ba==7)then if(ba<3 or ba==3)then if(ba<1 or ba==1)then if ba~=1 then bb=nil else w[y[189]]=w[y[591]][y[893]];end else if ba~=3 then n=(n+1);else y=f[n];end end else if(ba<5 or ba==5)then if(ba<5)then w[y[189]]=y[591];else n=(n+1);end else if ba<7 then y=f[n];else w[y[189]]=y[591];end end end else if(ba<11 or ba==11)then if(ba==9 or ba<9)then if(8<ba)then y=f[n];else n=(n+1);end else if ba<11 then w[y[189]]=y[591];else n=n+1;end end else if(ba==13 or ba<13)then if(12==ba)then y=f[n];else bb=y[189]end else if(ba>14)then break else w[bb]=w[bb](r(w,(bb+1),y[591]))end end end end ba=ba+1 end end;elseif(44>z or 44==z)then if(z==42 or z<42)then local ba=0 while true do if(ba<=14)then if(ba<=6)then if(ba<=2)then if(ba==0 or ba<0)then w={};else if 1==ba then for bb=0,u,1 do if(bb<o)then w[bb]=s[bb+1];else break;end;end;else n=n+1;end end else if(ba==4 or ba<4)then if(4>ba)then y=f[n];else w[y[189]]=h[y[591]];end else if(5<ba)then y=f[n];else n=n+1;end end end else if ba<=10 then if(ba<=8)then if not(ba==8)then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end else if ba~=10 then y=f[n];else w[y[189]]=h[y[591]];end end else if(ba==12 or ba<12)then if(ba>11)then y=f[n];else n=n+1;end else if(14>ba)then w[y[189]]={};else n=(n+1);end end end end else if(ba<21 or ba==21)then if(ba<17 or ba==17)then if(ba==15 or ba<15)then y=f[n];else if(17>ba)then w[y[189]]={};else n=(n+1);end end else if(ba<19 or ba==19)then if not(ba==19)then y=f[n];else w[y[189]][y[591]]=w[y[893]];end else if(ba<21)then n=n+1;else y=f[n];end end end else if ba<=25 then if ba<=23 then if not(23==ba)then w[y[189]]=j[y[591]];else n=(n+1);end else if 25>ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if ba<=27 then if(ba<27)then n=n+1;else y=f[n];end else if 28<ba then break else if w[y[189]]then n=n+1;else n=y[591];end;end end end end end ba=ba+1 end elseif 44>z then w[y[189]]=true;else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[189]]=w[y[591]][y[893]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=6 then y=f[n];else if 8~=ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if ba<=15 then if ba~=15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[189]else if 17==ba then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end end;elseif(z==45 or z<45)then local ba=y[189];w[ba]=(w[ba]-w[(ba+2)]);n=y[591];elseif 46<z then local ba=d[y[591]];local bb={};local bc={};for bd=1,y[893]do n=(n+1);local be=f[n];if not(be[545]~=76)then bc[bd-1]={w,be[591],nil,nil};else bc[bd-1]={h,be[591],nil,nil,nil};end;v[(#v+1)]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(bd,bd)local bd=bc[bd];return bd[1][bd[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bd,bd,be)local bc=bc[bd]bc[1][bc[2]]=be;end;});w[y[189]]=b(ba,bb,j);else w[y[189]]=w[y[591]]*y[893];end;elseif 71>=z then if 59>=z then if z<=53 then if 50>=z then if(48==z or 48>z)then local ba=w[y[893]];if not ba then n=n+1;else w[y[189]]=ba;n=y[591];end;elseif(z<50)then local ba,bb,bc,bd=0 while true do if(ba<15 or ba==15)then if(ba==7 or ba<7)then if(ba<3 or ba==3)then if(ba<1 or ba==1)then if 1>ba then bb=nil else bc=nil end else if(ba<3)then bd=nil else w[y[189]]=w[y[591]][y[893]];end end else if(ba<=5)then if(ba==4)then n=(n+1);else y=f[n];end else if 7~=ba then w[y[189]]=w[y[591]];else n=n+1;end end end else if(ba<11 or ba==11)then if(ba<9 or ba==9)then if(8<ba)then w[y[189]]=h[y[591]];else y=f[n];end else if not(10~=ba)then n=(n+1);else y=f[n];end end else if(ba==13 or ba<13)then if(ba<13)then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end else if(ba>14)then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end end else if(ba==23 or ba<23)then if(ba<=19)then if(ba<=17)then if not(ba~=16)then n=(n+1);else y=f[n];end else if(18<ba)then n=n+1;else w[y[189]]=h[y[591]];end end else if(ba<=21)then if(ba>20)then w[y[189]]=w[y[591]][y[893]];else y=f[n];end else if ba>22 then y=f[n];else n=(n+1);end end end else if ba<=27 then if(ba<25 or ba==25)then if not(25==ba)then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end else if not(26~=ba)then y=f[n];else bd=y[591];end end else if(ba<29 or ba==29)then if(ba<29)then bc=y[893];else bb=k(w,g,bd,bc);end else if(ba~=31)then w[y[189]]=bb;else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if(ba==8 or ba<8)then if(ba==3 or ba<3)then if(ba<=1)then if not(ba==1)then bb=nil else w[y[189]]=w[y[591]][y[893]];end else if 3>ba then n=(n+1);else y=f[n];end end else if(ba<5 or ba==5)then if ba~=5 then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end else if(ba<6 or ba==6)then y=f[n];else if(ba>7)then n=(n+1);else w[y[189]]=w[y[591]][y[893]];end end end end else if(ba<13 or ba==13)then if ba<=10 then if ba<10 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if(ba<=11)then n=n+1;else if not(ba==13)then y=f[n];else w[y[189]]=false;end end end else if(ba<=15)then if(15~=ba)then n=n+1;else y=f[n];end else if ba<=16 then bb=y[189]else if 17==ba then w[bb](w[(bb+1)])else break end end end end end ba=ba+1 end end;elseif(z==51 or z<51)then local ba=y[189];w[ba]=(w[ba]-w[ba+2]);n=y[591];elseif(z~=53)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[189]]=h[y[591]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[189]]=y[591];else n=n+1;end else if ba==6 then y=f[n];else w[y[189]]=y[591];end end end else if ba<=11 then if ba<=9 then if 8==ba then n=n+1;else y=f[n];end else if 10==ba then w[y[189]]=y[591];else n=n+1;end end else if ba<=13 then if 13~=ba then y=f[n];else bb=y[189]end else if ba<15 then w[bb]=w[bb](r(w,bb+1,y[591]))else break end end end end ba=ba+1 end else if(w[y[189]]~=y[893])then n=(n+1);else n=y[591];end;end;elseif 56>=z then if 54>=z then local ba;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))elseif z<56 then w[y[189]]=w[y[591]]-y[893];else local ba;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba]()end;elseif z<=57 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3==ba then w[y[189]]=h[y[591]];else n=n+1;end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[189]]=w[y[591]][w[y[893]]];else if 14>ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[189]end else if ba<=17 then bb=0;else if ba>18 then break else for be=bd,y[893]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end elseif z>58 then local ba=y[189];do return r(w,ba,p)end;else local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))end;elseif 65>=z then if z<=62 then if z<=60 then local ba;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))elseif z>61 then local ba=y[189]local bb={w[ba](r(w,ba+1,y[591]))};local bc=0;for bd=ba,y[893]do bc=bc+1;w[bd]=bb[bc];end;else w[y[189]]=j[y[591]];end;elseif 63>=z then local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if 2==ba then y=f[n];else w[y[189]][y[591]]=w[y[893]];end end else if ba<=5 then if 5~=ba then n=n+1;else y=f[n];end else if 6==ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if 8==ba then y=f[n];else w[y[189]]=h[y[591]];end else if ba>10 then y=f[n];else n=n+1;end end else if ba<=13 then if 12<ba then n=n+1;else w[y[189]]=w[y[591]][y[893]];end else if ba<=14 then y=f[n];else if 16>ba then if(w[y[189]]~=w[y[893]])then n=n+1;else n=y[591];end;else break end end end end end ba=ba+1 end elseif z==64 then a(c,e);else if w[y[189]]then n=n+1;else n=y[591];end;end;elseif 68>=z then if 66>=z then if(w[y[189]]<=w[y[893]])then n=y[591];else n=n+1;end;elseif z~=68 then w[y[189]]=w[y[591]]+y[893];else local ba=y[189]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;end;elseif z<=69 then w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];n=y[591];elseif 70==z then local ba;w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]][y[591]]=y[893];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))else local ba;local bb;w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]={r({},1,y[591])};n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];bb=y[189];ba=w[bb];for bc=bb+1,y[591]do t(ba,w[bc])end;end;elseif 83>=z then if(z<=77)then if(74>z or 74==z)then if 72>=z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[189]]=w[y[591]][w[y[893]]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[189]]=w[y[591]];end else if ba<=6 then y=f[n];else if 8~=ba then w[y[189]]=y[591];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[189]]=y[591];end else if ba<=11 then n=n+1;else if 13~=ba then y=f[n];else w[y[189]]=y[591];end end end else if ba<=15 then if 14<ba then y=f[n];else n=n+1;end else if ba<=16 then bb=y[189]else if ba==17 then w[bb]=w[bb](r(w,bb+1,y[591]))else break end end end end end ba=ba+1 end elseif not(z==74)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[189]]=w[y[591]][y[893]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba~=5 then w[y[189]]=h[y[591]];else n=n+1;end else if ba<=6 then y=f[n];else if 8>ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[189]]=y[591];end else if ba<=11 then n=n+1;else if 13~=ba then y=f[n];else w[y[189]]=y[591];end end end else if ba<=15 then if ba~=15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[189]else if ba<18 then w[bb]=w[bb](r(w,bb+1,y[591]))else break end end end end end ba=ba+1 end else w[y[189]]=y[591];end;elseif z<=75 then w[y[189]]=w[y[591]][y[893]];elseif(77>z)then w[y[189]]=w[y[591]];else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[189]]=h[y[591]];end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[189]]=w[y[591]][w[y[893]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[189]end else if ba<=17 then bb=0;else if ba<19 then for be=bd,y[893]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(z<80 or z==80)then if(78==z or 78>z)then if(w[y[189]]<w[y[893]]or w[y[189]]==w[y[893]])then n=n+1;else n=y[591];end;elseif 79<z then local ba=y[189]w[ba](w[ba+1])else local ba=y[189]w[ba]=w[ba](w[ba+1])end;elseif(81>=z)then w[y[189]]=w[y[591]][w[y[893]]];elseif not(82~=z)then local ba,bb=0 while true do if ba<=29 then if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 2>ba then w[y[189]]={};else n=n+1;end end else if ba<=4 then if 4~=ba then y=f[n];else w[y[189]]=y[591];end else if ba>5 then y=f[n];else n=n+1;end end end else if ba<=10 then if ba<=8 then if ba==7 then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end else if ba>9 then w[y[189]]=y[591];else y=f[n];end end else if ba<=12 then if ba==11 then n=n+1;else y=f[n];end else if ba<14 then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end end end end else if ba<=21 then if ba<=17 then if ba<=15 then y=f[n];else if 17>ba then w[y[189]]=y[591];else n=n+1;end end else if ba<=19 then if 18<ba then w[y[189]][w[y[591]]]=w[y[893]];else y=f[n];end else if 21~=ba then n=n+1;else y=f[n];end end end else if ba<=25 then if ba<=23 then if ba==22 then w[y[189]]=y[591];else n=n+1;end else if ba>24 then w[y[189]][w[y[591]]]=w[y[893]];else y=f[n];end end else if ba<=27 then if ba>26 then y=f[n];else n=n+1;end else if ba==28 then w[y[189]]=y[591];else n=n+1;end end end end end else if ba<=44 then if ba<=36 then if ba<=32 then if ba<=30 then y=f[n];else if ba~=32 then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end end else if ba<=34 then if ba~=34 then y=f[n];else w[y[189]]=y[591];end else if ba==35 then n=n+1;else y=f[n];end end end else if ba<=40 then if ba<=38 then if 38~=ba then w[y[189]][w[y[591]]]=w[y[893]];else n=n+1;end else if 40~=ba then y=f[n];else w[y[189]]={};end end else if ba<=42 then if ba>41 then y=f[n];else n=n+1;end else if 43<ba then n=n+1;else w[y[189]]=y[591];end end end end else if ba<=52 then if ba<=48 then if ba<=46 then if 46~=ba then y=f[n];else w[y[189]][w[y[591]]]=w[y[893]];end else if 47==ba then n=n+1;else y=f[n];end end else if ba<=50 then if ba>49 then n=n+1;else w[y[189]]=j[y[591]];end else if ba==51 then y=f[n];else w[y[189]]=w[y[591]];end end end else if ba<=56 then if ba<=54 then if 54~=ba then n=n+1;else y=f[n];end else if 55==ba then w[y[189]]=w[y[591]];else n=n+1;end end else if ba<=58 then if 57<ba then bb=y[189]else y=f[n];end else if 59<ba then break else w[bb](r(w,bb+1,y[591]))end end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[189]]=h[y[591]];else n=n+1;end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[189]]=w[y[591]][w[y[893]]];else if 13==ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then bd=y[189]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[893]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif 89>=z then if z<=86 then if z<=84 then local ba;local bb;local bc;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];bc=y[189]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[893]do ba=ba+1;w[bd]=bb[ba];end elseif 85<z then w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if(w[y[189]]~=w[y[893]])then n=n+1;else n=y[591];end;else w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if(w[y[189]]~=w[y[893]])then n=n+1;else n=y[591];end;end;elseif 87>=z then local ba;local bb;local bc;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];bc=y[189]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[893]do ba=ba+1;w[bd]=bb[ba];end elseif z<89 then w[y[189]]=false;else local ba=y[189];local bb,bc,bd=w[ba],w[ba+1],w[ba+2];local bb=bb+bd;w[ba]=bb;if bd>0 and bb<=bc or bd<0 and bb>=bc then n=y[591];w[ba+3]=bb;end;end;elseif z<=92 then if(z<90 or z==90)then local ba=y[189];do return w[ba](r(w,(ba+1),y[591]))end;elseif 91==z then w[y[189]]=(not w[y[591]]);else w[y[189]]=(w[y[591]]-y[893]);end;elseif z<=93 then w[y[189]]=w[y[591]]%w[y[893]];elseif 95>z then w[y[189]]=w[y[591]]*y[893];else local ba;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](w[ba+1])end;elseif z<=143 then if z<=119 then if 107>=z then if z<=101 then if(98>z or 98==z)then if(z<=96)then if not w[y[189]]then n=(n+1);else n=y[591];end;elseif(z>97)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[189]]=w[y[591]][y[893]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba<5 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=6 then y=f[n];else if 8~=ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if ba<=15 then if ba==14 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[189]else if ba<18 then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end else local ba=y[189]w[ba](r(w,(ba+1),p))end;elseif(z<99 or z==99)then w[y[189]]=y[591]*w[y[893]];elseif not(101==z)then w[y[189]]=y[591];else local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba~=2 then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if 4==ba then y=f[n];else w[y[189]]=h[y[591]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if ba>7 then w[y[189]]=j[y[591]];else y=f[n];end end else if ba<=10 then if 9<ba then y=f[n];else n=n+1;end else if 11<ba then n=n+1;else w[y[189]]=w[y[591]][y[893]];end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if ba~=15 then w[y[189]]=y[591];else n=n+1;end end else if ba<=16 then y=f[n];else if 18>ba then w[y[189]]=y[591];else n=n+1;end end end else if ba<=21 then if ba<=19 then y=f[n];else if ba<21 then w[y[189]]=y[591];else n=n+1;end end else if ba<=23 then if 23>ba then y=f[n];else bb=y[189]end else if 24<ba then break else w[bb]=w[bb](r(w,bb+1,y[591]))end end end end end ba=ba+1 end end;elseif z<=104 then if 102>=z then w[y[189]]=(not w[y[591]]);elseif z<104 then w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];else local ba;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=false;n=n+1;y=f[n];ba=y[189]w[ba](w[ba+1])end;elseif 105>=z then w[y[189]]=h[y[591]];elseif 106==z then local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))else local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))end;elseif 113>=z then if z<=110 then if z<=108 then w[y[189]][y[591]]=w[y[893]];elseif 109<z then for ba=y[189],y[591],1 do w[ba]=nil;end;else if(w[y[189]]~=y[893])then n=y[591];else n=n+1;end;end;elseif z<=111 then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then w[y[189]]=w[y[591]][y[893]];else bb=nil end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[189]]=h[y[591]];else n=n+1;end else if ba<=6 then y=f[n];else if 8>ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[189]]=h[y[591]];end else if ba<=11 then n=n+1;else if ba<13 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if ba<=15 then if ba==14 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[189]else if ba~=18 then w[bb]=w[bb](r(w,bb+1,y[591]))else break end end end end end ba=ba+1 end elseif 113>z then local ba=y[189]w[ba]=w[ba]()else w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];if(w[y[189]]~=y[893])then n=n+1;else n=y[591];end;end;elseif z<=116 then if z<=114 then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[189]]=w[y[591]][y[893]];end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=6 then y=f[n];else if ba<8 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba~=10 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if ba<=11 then n=n+1;else if ba==12 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if ba<=15 then if 14<ba then y=f[n];else n=n+1;end else if ba<=16 then bb=y[189]else if 17<ba then break else w[bb]=w[bb](w[bb+1])end end end end end ba=ba+1 end elseif z~=116 then local ba;local bb;local bc;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];bc=y[189]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[893]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;local bc;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];bc=y[591];bb=y[893];ba=k(w,g,bc,bb);w[y[189]]=ba;end;elseif 117>=z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))elseif z==118 then local ba;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]]*y[893];n=n+1;y=f[n];w[y[189]]=w[y[591]]+w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]]+w[y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))else local ba;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](w[ba+1])end;elseif 131>=z then if z<=125 then if z<=122 then if 120>=z then local ba;local bb,bc;local bd;w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];bd=y[189]bb,bc=i(w[bd](r(w,bd+1,y[591])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;elseif z~=122 then local ba=y[189]w[ba]=w[ba](r(w,ba+1,p))else local ba;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))end;elseif 123>=z then local ba;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=false;n=n+1;y=f[n];ba=y[189]w[ba](w[ba+1])elseif z~=125 then local ba;local bb;local bc;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];bc=y[189]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[893]do ba=ba+1;w[bd]=bb[ba];end else j[y[591]]=w[y[189]];end;elseif z<=128 then if 126>=z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 3==ba then w[y[189]]=j[y[591]];else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[189]]=w[y[591]][y[893]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if ba==15 then bd=y[189]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba<19 then for be=bd,y[893]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif z>127 then w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if w[y[189]]then n=n+1;else n=y[591];end;else w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if(w[y[189]]~=w[y[893]])then n=n+1;else n=y[591];end;end;elseif 129>=z then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[189]]=w[y[591]][y[893]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba==4 then w[y[189]]=w[y[591]];else n=n+1;end else if 7>ba then y=f[n];else w[y[189]]=h[y[591]];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if ba>10 then n=n+1;else w[y[189]]=w[y[591]][y[893]];end end else if ba<=13 then if 12<ba then bb=y[189]else y=f[n];end else if 14==ba then w[bb]=w[bb](r(w,bb+1,y[591]))else break end end end end ba=ba+1 end elseif z>130 then local ba=y[189];local bb=w[ba];for bc=ba+1,p do t(bb,w[bc])end;else local ba;local bb;local bc;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];bc=y[591];bb=y[893];ba=k(w,g,bc,bb);w[y[189]]=ba;end;elseif z<=137 then if 134>=z then if z<=132 then n=y[591];elseif z>133 then w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];if(w[y[189]]~=y[893])then n=n+1;else n=y[591];end;else for ba=y[189],y[591],1 do w[ba]=nil;end;end;elseif 135>=z then w[y[189]][y[591]]=y[893];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];elseif z==136 then w[y[189]]=w[y[591]]-w[y[893]];else local ba;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]]*y[893];n=n+1;y=f[n];w[y[189]]=w[y[591]]+w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]]+w[y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))end;elseif 140>=z then if(138>=z)then h[y[591]]=w[y[189]];elseif(140~=z)then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then w[y[189]]=w[y[591]]/y[893];else n=n+1;end else if ba<=2 then y=f[n];else if ba<4 then w[y[189]]=w[y[591]]-w[y[893]];else n=n+1;end end end else if ba<=6 then if 5<ba then w[y[189]]=w[y[591]]/y[893];else y=f[n];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[189]]=w[y[591]]*y[893];end end end end else if ba<=14 then if ba<=11 then if ba>10 then y=f[n];else n=n+1;end else if ba<=12 then w[y[189]]=w[y[591]];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba==15 then w[y[189]]=w[y[591]];else n=n+1;end else if ba<=17 then y=f[n];else if ba<19 then n=y[591];else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[189]]=w[y[591]][y[893]];end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if 5~=ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if ba<=6 then y=f[n];else if 7==ba then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 9==ba then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if ba<=11 then n=n+1;else if 12<ba then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end else if ba<=15 then if 14==ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[189]else if 17<ba then break else w[bb]=w[bb](w[bb+1])end end end end end ba=ba+1 end end;elseif z<=141 then if(w[y[189]]~=w[y[893]])then n=n+1;else n=y[591];end;elseif 142<z then local ba;w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba]()else local ba;local bb;local bc;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];bc=y[189]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[893]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=167 then if z<=155 then if 149>=z then if 146>=z then if 144>=z then local ba=y[189];local bb=w[ba];for bc=ba+1,y[591]do t(bb,w[bc])end;elseif z<146 then local ba;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))else local ba;local bb;local bc;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];bc=y[591];bb=y[893];ba=k(w,g,bc,bb);w[y[189]]=ba;end;elseif 147>=z then local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))elseif 149>z then if(w[y[189]]~=w[y[893]])then n=n+1;else n=y[591];end;else local ba;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))end;elseif 152>=z then if 150>=z then w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];elseif 151==z then w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if w[y[189]]then n=n+1;else n=y[591];end;else local ba;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](w[ba+1])end;elseif z<=153 then local ba=y[189]w[ba]=w[ba]()elseif z<155 then local ba;local bb;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];bb=y[189];ba=w[bb];for bc=bb+1,y[591]do t(ba,w[bc])end;else a(c,e);n=n+1;y=f[n];w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];end;elseif z<=161 then if 158>=z then if 156>=z then local ba=y[189]w[ba]=w[ba](r(w,ba+1,p))elseif 157<z then w[y[189]]=w[y[591]]%y[893];else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]]+y[893];n=n+1;y=f[n];h[y[591]]=w[y[189]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;end;elseif 159>=z then local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))elseif 160==z then w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if w[y[189]]then n=n+1;else n=y[591];end;else w[y[189]]=false;n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];if(w[y[189]]~=y[893])then n=n+1;else n=y[591];end;end;elseif 164>=z then if z<=162 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if w[y[189]]then n=n+1;else n=y[591];end;elseif z~=164 then local ba;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))else local ba;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))end;elseif z<=165 then local ba;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];ba=y[189]w[ba]=w[ba](r(w,ba+1,y[591]))elseif z<167 then local ba=y[189];p=ba+x-1;for x=ba,p do local q=q[x-ba];w[x]=q;end;else local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];q=y[189]w[q]=w[q](r(w,q+1,y[591]))end;elseif z<=179 then if(z<173 or z==173)then if((z<170)or z==170)then if(168==z or 168>z)then w={};for q=0,u,1 do if(q<o)then w[q]=s[(q+1)];else break;end;end;elseif(z>169)then local q,x=0 while true do if(q==8 or q<8)then if(q<=3)then if(q==1 or q<1)then if 1~=q then x=nil else w[y[189]]=w[y[591]][y[893]];end else if not(3==q)then n=n+1;else y=f[n];end end else if q<=5 then if q>4 then n=(n+1);else w[y[189]]=w[y[591]][y[893]];end else if q<=6 then y=f[n];else if not(7~=q)then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end end end end else if(q==13 or q<13)then if(q<=10)then if 9==q then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if(q<=11)then n=(n+1);else if 12<q then w[y[189]]=false;else y=f[n];end end end else if(q<=15)then if not(q==15)then n=(n+1);else y=f[n];end else if(q<16 or q==16)then x=y[189]else if(18>q)then w[x](w[(x+1)])else break end end end end end q=q+1 end else local q=y[189];local x=w[q];for ba=q+1,p do t(x,w[ba])end;end;elseif(z<171 or z==171)then w[y[189]]=(w[y[591]]+w[y[893]]);elseif 173>z then local q=0 while true do if q<=9 then if(q<4 or q==4)then if(q<1 or q==1)then if not(q==1)then w={};else for x=0,u,1 do if x<o then w[x]=s[(x+1)];else break;end;end;end else if(q<2 or q==2)then n=n+1;else if(4~=q)then y=f[n];else w[y[189]]=y[591];end end end else if(q==6 or q<6)then if(5<q)then y=f[n];else n=(n+1);end else if(q<7 or q==7)then w[y[189]]=h[y[591]];else if(9>q)then n=n+1;else y=f[n];end end end end else if q<=14 then if q<=11 then if(q<11)then w[y[189]]=h[y[591]];else n=n+1;end else if(q<12 or q==12)then y=f[n];else if q<14 then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end end end else if(q<17 or q==17)then if q<=15 then y=f[n];else if not(17==q)then w[y[189]]=w[y[591]][w[y[893]]];else n=(n+1);end end else if q<=18 then y=f[n];else if not(q~=19)then if(w[y[189]]~=y[893])then n=n+1;else n=y[591];end;else break end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if(q<=9)then if q<=4 then if(q==1 or q<1)then if(q<1)then x=nil else ba=nil end else if(q<2 or q==2)then bb=nil else if(3<q)then n=(n+1);else w[y[189]]=j[y[591]];end end end else if(q<6 or q==6)then if q==5 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if(q<7 or q==7)then n=(n+1);else if q>8 then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end end else if(q<=14)then if(q<=11)then if not(q==11)then n=n+1;else y=f[n];end else if(q<12 or q==12)then w[y[189]]=w[y[591]][y[893]];else if not(14==q)then n=(n+1);else y=f[n];end end end else if q<=16 then if 16~=q then bb=y[189]else ba={w[bb](w[bb+1])};end else if(q==17 or q<17)then x=0;else if not(q~=18)then for bc=bb,y[893]do x=x+1;w[bc]=ba[x];end else break end end end end end q=(q+1)end end;elseif 176>=z then if((z<174)or not(z~=174))then local q=0 while true do if(q<15 or q==15)then if(q<7 or not(q~=7))then if(q==3 or q<3)then if(q<=1)then if not(q==1)then w[y[189]]=y[591];else n=(n+1);end else if(3>q)then y=f[n];else w[y[189]]=w[y[591]][w[y[893]]];end end else if(q==5 or q<5)then if(not(q~=4))then n=n+1;else y=f[n];end else if(q<7)then w[y[189]]=j[y[591]];else n=(n+1);end end end else if((q<11)or(q==11))then if(not(q~=9)or q<9)then if(q>8)then w[y[189]]=y[591];else y=f[n];end else if(10<q)then y=f[n];else n=(n+1);end end else if(q==13 or q<13)then if not(not(not(q~=12)))then w[y[189]]=w[y[591]][w[y[893]]];else n=(n+1);end else if(14<q)then w[y[189]]=y[591];else y=f[n];end end end end else if(q<23 or q==23)then if(q<19 or q==19)then if(q==17 or q<17)then if not(not(16==q))then n=(n+1);else y=f[n];end else if not(not(q==18))then w[y[189]]=w[y[591]][w[y[893]]];else n=(n+1);end end else if(q==21 or q<21)then if(21>q)then y=f[n];else w[y[189]]=j[y[591]];end else if(22<q)then y=f[n];else n=(n+1);end end end else if(q<27 or not(q~=27))then if((q<25)or(q==25))then if(24==q)then w[y[189]]=y[591];else n=(n+1);end else if not(not(q~=27))then y=f[n];else w[y[189]]=w[y[591]][w[y[893]]];end end else if(q<29 or(q==29))then if not(not(29~=q))then n=(n+1);else y=f[n];end else if not(30~=q)then for x=y[189],y[591],1 do w[x]=nil;end;else break end end end end end q=(q+1)end elseif not(z==176)then local q,x=0 while true do if(q<8 or q==8)then if(q<=3)then if(q<=1)then if q<1 then x=nil else w[y[189]]=j[y[591]];end else if not(2~=q)then n=(n+1);else y=f[n];end end else if(q==5 or q<5)then if(4<q)then n=(n+1);else w[y[189]]=w[y[591]][y[893]];end else if(q<6 or q==6)then y=f[n];else if q==7 then w[y[189]]=y[591];else n=(n+1);end end end end else if q<=13 then if(q<=10)then if not(9~=q)then y=f[n];else w[y[189]]=y[591];end else if(q<11 or q==11)then n=(n+1);else if q==12 then y=f[n];else w[y[189]]=y[591];end end end else if(q<15 or q==15)then if q>14 then y=f[n];else n=(n+1);end else if q<=16 then x=y[189]else if(18~=q)then w[x]=w[x](r(w,(x+1),y[591]))else break end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if(q<9 or q==9)then if(q<=4)then if(q<1 or q==1)then if(1>q)then x=nil else ba=nil end else if(q<2 or q==2)then bb=nil else if(4>q)then w[y[189]]=h[y[591]];else n=n+1;end end end else if q<=6 then if(6~=q)then y=f[n];else w[y[189]]=h[y[591]];end else if(q==7 or q<7)then n=n+1;else if(8<q)then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end end else if(q<14 or q==14)then if(q==11 or q<11)then if 11>q then n=n+1;else y=f[n];end else if(q<12 or q==12)then w[y[189]]=w[y[591]][w[y[893]]];else if(14>q)then n=n+1;else y=f[n];end end end else if(q<=16)then if 16>q then bb=y[189]else ba={w[bb](w[bb+1])};end else if(q<17 or q==17)then x=0;else if(q~=19)then for bc=bb,y[893]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end end;elseif(z==177 or z<177)then local q,x=0 while true do if(q<12 or q==12)then if q<=5 then if(q<=2)then if(q==0 or q<0)then x=nil else if(1==q)then w={};else for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;end end else if(q<=3)then n=n+1;else if(q>4)then w[y[189]]=h[y[591]];else y=f[n];end end end else if(q<8 or q==8)then if(q<=6)then n=(n+1);else if not(q~=7)then y=f[n];else w[y[189]]=j[y[591]];end end else if(q==10 or q<10)then if not(q~=9)then n=(n+1);else y=f[n];end else if(11<q)then n=(n+1);else w[y[189]]=w[y[591]][y[893]];end end end end else if(q==18 or q<18)then if(q==15 or q<15)then if(q==13 or q<13)then y=f[n];else if 14<q then n=n+1;else w[y[189]]=y[591];end end else if(q<16 or q==16)then y=f[n];else if(17==q)then w[y[189]]=y[591];else n=(n+1);end end end else if(q==21 or q<21)then if(q<=19)then y=f[n];else if 20==q then w[y[189]]=y[591];else n=n+1;end end else if(q<=23)then if 23>q then y=f[n];else x=y[189]end else if 25~=q then w[x]=w[x](r(w,(x+1),y[591]))else break end end end end end q=(q+1)end elseif(178<z)then local q=y[189]local x={w[q](w[q+1])};local ba=0;for bb=q,y[893]do ba=(ba+1);w[bb]=x[ba];end else local q=0 while true do if q<=6 then if q<=2 then if q<=0 then w[y[189]]=w[y[591]][y[893]];else if 2~=q then n=n+1;else y=f[n];end end else if q<=4 then if 4~=q then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if 6>q then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if q<=9 then if q<=7 then n=n+1;else if q~=9 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if q<=11 then if q==10 then n=n+1;else y=f[n];end else if q>12 then break else if w[y[189]]then n=n+1;else n=y[591];end;end end end end q=q+1 end end;elseif z<=185 then if 182>=z then if z<=180 then local q;w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]][y[591]]=y[893];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];q=y[189]w[q]=w[q](r(w,q+1,y[591]))elseif z==181 then local q;w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];q=y[189]w[q]=w[q](r(w,q+1,y[591]))else if(y[189]<w[y[893]])then n=n+1;else n=y[591];end;end;elseif z<=183 then local q;local x;local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];ba=y[189]x={w[ba](w[ba+1])};q=0;for bb=ba,y[893]do q=q+1;w[bb]=x[q];end elseif 185~=z then local q;local x;local ba;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[189]x={w[ba](w[ba+1])};q=0;for bb=ba,y[893]do q=q+1;w[bb]=x[q];end else local q=y[189]w[q](w[q+1])end;elseif 188>=z then if z<=186 then local q;local x;local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];ba=y[189]x={w[ba](w[ba+1])};q=0;for bb=ba,y[893]do q=q+1;w[bb]=x[q];end elseif z>187 then local q=y[189]w[q](r(w,q+1,y[591]))else w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];n=y[591];end;elseif 190>=z then if z>189 then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if w[y[189]]then n=n+1;else n=y[591];end;else do return end;end;elseif z~=192 then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];q=y[189]w[q](w[q+1])else local q;w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];q=y[189]w[q]=w[q]()end;elseif 288>=z then if z<=240 then if 216>=z then if 204>=z then if 198>=z then if 195>=z then if 193>=z then local q;w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];q=y[189]w[q]=w[q](r(w,q+1,y[591]))elseif z==194 then local q;local x;local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];ba=y[189]x={w[ba](w[ba+1])};q=0;for bb=ba,y[893]do q=q+1;w[bb]=x[q];end else w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if w[y[189]]then n=n+1;else n=y[591];end;end;elseif 196>=z then local q;local x;local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];ba=y[189]x={w[ba](w[ba+1])};q=0;for bb=ba,y[893]do q=q+1;w[bb]=x[q];end elseif 198>z then w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if w[y[189]]then n=n+1;else n=y[591];end;else local q;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];q=y[189]w[q]=w[q](r(w,q+1,y[591]))end;elseif z<=201 then if z<=199 then local q;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];q=y[189]w[q]=w[q](r(w,q+1,y[591]))elseif 200<z then local q;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];q=y[189]w[q](r(w,q+1,y[591]))else w[y[189]]=false;end;elseif z<=202 then if(w[y[189]]<w[y[893]])then n=(n+1);else n=y[591];end;elseif 203==z then local q;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];q=y[189]w[q]=w[q](r(w,q+1,y[591]))else local q;local x;local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];ba=y[189]x={w[ba](w[ba+1])};q=0;for bb=ba,y[893]do q=q+1;w[bb]=x[q];end end;elseif z<=210 then if 207>=z then if z<=205 then local q;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];q=y[189];do return w[q](r(w,q+1,y[591]))end;n=n+1;y=f[n];q=y[189];do return r(w,q,p)end;elseif z<207 then do return w[y[189]]end else w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];for q=y[189],y[591],1 do w[q]=nil;end;n=n+1;y=f[n];n=y[591];end;elseif z<=208 then local q;local x;local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];ba=y[189]x={w[ba](w[ba+1])};q=0;for bb=ba,y[893]do q=q+1;w[bb]=x[q];end elseif z>209 then w[y[189]]=w[y[591]];else local q;local x;local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];ba=y[189]x={w[ba](w[ba+1])};q=0;for bb=ba,y[893]do q=q+1;w[bb]=x[q];end end;elseif 213>=z then if(211==z or 211>z)then w[y[189]]=w[y[591]]%y[893];elseif not(z==213)then j[y[591]]=w[y[189]];else local q,x=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1~=q then x=nil else w[y[189]]=w[y[591]][y[893]];end else if q<=2 then n=n+1;else if q==3 then y=f[n];else w[y[189]]=y[591];end end end else if q<=6 then if q>5 then y=f[n];else n=n+1;end else if q<=7 then w[y[189]]=h[y[591]];else if 9>q then n=n+1;else y=f[n];end end end end else if q<=14 then if q<=11 then if 11>q then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if q<=12 then y=f[n];else if 14~=q then x=y[189];else do return w[x](r(w,x+1,y[591]))end;end end end else if q<=16 then if 16~=q then n=n+1;else y=f[n];end else if q<=17 then x=y[189];else if 19~=q then do return r(w,x,p)end;else break end end end end end q=q+1 end end;elseif 214>=z then local q=y[189];do return w[q],w[q+1]end elseif z<216 then local q;local x;local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[591];x=y[893];q=k(w,g,ba,x);w[y[189]]=q;else w[y[189]][y[591]]=w[y[893]];end;elseif 228>=z then if z<=222 then if(z<=219)then if(z<=217)then local q,x,ba=0 while true do if q<=24 then if q<=11 then if q<=5 then if q<=2 then if q<=0 then x=nil else if q>1 then w[y[189]]={};else ba=nil end end else if q<=3 then n=n+1;else if q<5 then y=f[n];else w[y[189]]=h[y[591]];end end end else if q<=8 then if q<=6 then n=n+1;else if q==7 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if q<=9 then n=n+1;else if 10<q then w[y[189]]=h[y[591]];else y=f[n];end end end end else if q<=17 then if q<=14 then if q<=12 then n=n+1;else if 13==q then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if q<=15 then n=n+1;else if q>16 then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end else if q<=20 then if q<=18 then n=n+1;else if 19<q then w[y[189]]={};else y=f[n];end end else if q<=22 then if q==21 then n=n+1;else y=f[n];end else if q~=24 then w[y[189]]={};else n=n+1;end end end end end else if q<=37 then if q<=30 then if q<=27 then if q<=25 then y=f[n];else if 26<q then n=n+1;else w[y[189]]=h[y[591]];end end else if q<=28 then y=f[n];else if 30~=q then w[y[189]][y[591]]=w[y[893]];else n=n+1;end end end else if q<=33 then if q<=31 then y=f[n];else if q>32 then n=n+1;else w[y[189]]=h[y[591]];end end else if q<=35 then if 34<q then w[y[189]][y[591]]=w[y[893]];else y=f[n];end else if q>36 then y=f[n];else n=n+1;end end end end else if q<=43 then if q<=40 then if q<=38 then w[y[189]][y[591]]=w[y[893]];else if 39<q then y=f[n];else n=n+1;end end else if q<=41 then w[y[189]]={r({},1,y[591])};else if 42<q then y=f[n];else n=n+1;end end end else if q<=46 then if q<=44 then w[y[189]]=w[y[591]];else if 45<q then y=f[n];else n=n+1;end end else if q<=48 then if q~=48 then ba=y[189];else x=w[ba];end else if q>49 then break else for bb=ba+1,y[591]do t(x,w[bb])end;end end end end end end q=q+1 end elseif not(z==219)then local q,x=0 while true do if q<=12 then if q<=5 then if q<=2 then if q<=0 then x=nil else if q==1 then w={};else for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;end end else if q<=3 then n=n+1;else if 5>q then y=f[n];else w[y[189]]=false;end end end else if q<=8 then if q<=6 then n=n+1;else if 8~=q then y=f[n];else w[y[189]]=j[y[591]];end end else if q<=10 then if q==9 then n=n+1;else y=f[n];end else if q<12 then for ba=y[189],y[591],1 do w[ba]=nil;end;else n=n+1;end end end end else if q<=18 then if q<=15 then if q<=13 then y=f[n];else if 14<q then n=n+1;else w[y[189]]=h[y[591]];end end else if q<=16 then y=f[n];else if q<18 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end else if q<=21 then if q<=19 then y=f[n];else if 20<q then n=n+1;else w[y[189]]=w[y[591]];end end else if q<=23 then if q>22 then x=y[189]else y=f[n];end else if 25>q then w[x]=w[x](w[x+1])else break end end end end end q=q+1 end else local q=0 while true do if q<=9 then if q<=4 then if q<=1 then if q==0 then w={};else for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;end else if q<=2 then n=n+1;else if 4>q then y=f[n];else w[y[189]]=y[591];end end end else if q<=6 then if 5<q then y=f[n];else n=n+1;end else if q<=7 then w[y[189]]=h[y[591]];else if q~=9 then n=n+1;else y=f[n];end end end end else if q<=14 then if q<=11 then if q>10 then n=n+1;else w[y[189]]=h[y[591]];end else if q<=12 then y=f[n];else if q<14 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end else if q<=17 then if q<=15 then y=f[n];else if 17>q then w[y[189]]=w[y[591]][w[y[893]]];else n=n+1;end end else if q<=18 then y=f[n];else if q~=20 then if(w[y[189]]~=y[893])then n=n+1;else n=y[591];end;else break end end end end end q=q+1 end end;elseif(z==220 or z<220)then if(w[y[189]]<=w[y[893]])then n=n+1;else n=y[591];end;elseif 221<z then local q=y[189]local x={}for ba=1,#v do local bb=v[ba]for bc=1,#bb do local bb=bb[bc]local bc,bc=bb[1],bb[2]if(bc>=q)then x[bc]=w[bc]bb[1]=x v[ba]=nil;end end end else w[y[189]][y[591]]=y[893];end;elseif 225>=z then if 223>=z then w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];elseif 224==z then w[y[189]]={r({},1,y[591])};else w[y[189]]=w[y[591]]+y[893];end;elseif 226>=z then w[y[189]]=w[y[591]]/y[893];elseif 228~=z then local q;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]]*y[893];n=n+1;y=f[n];w[y[189]]=w[y[591]]+w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]]+w[y[893]];n=n+1;y=f[n];q=y[189]w[q]=w[q](r(w,q+1,y[591]))else local q;local x;local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[591];x=y[893];q=k(w,g,ba,x);w[y[189]]=q;end;elseif z<=234 then if z<=231 then if z<=229 then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 0<q then w[y[189]][y[591]]=w[y[893]];else x=nil end else if q>2 then y=f[n];else n=n+1;end end else if q<=5 then if 4<q then n=n+1;else w[y[189]]={};end else if 7>q then y=f[n];else w[y[189]][y[591]]=y[893];end end end else if q<=11 then if q<=9 then if 8==q then n=n+1;else y=f[n];end else if 11>q then w[y[189]][y[591]]=w[y[893]];else n=n+1;end end else if q<=13 then if 12<q then x=y[189]else y=f[n];end else if 14<q then break else w[x]=w[x](r(w,x+1,y[591]))end end end end q=q+1 end elseif 230<z then if(w[y[189]]<w[y[893]])then n=n+1;else n=y[591];end;else local q;local x;local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];ba=y[189]x={w[ba](w[ba+1])};q=0;for bb=ba,y[893]do q=q+1;w[bb]=x[q];end end;elseif 232>=z then local q;w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];q=y[189]w[q]=w[q]()elseif 233==z then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];q=y[189]w[q](w[q+1])else local q=y[189];local x=y[893];local ba=q+2;local bb={w[q](w[q+1],w[ba])};for bc=1,x do w[ba+bc]=bb[bc];end local q=w[q+3];if q then w[ba]=q;n=y[591];else n=n+1 end;end;elseif 237>=z then if 235>=z then local q=y[189]local x={}for ba=1,#v do local bb=v[ba]for bc=1,#bb do local bb=bb[bc]local bc,bc=bb[1],bb[2]if bc>=q then x[bc]=w[bc]bb[1]=x v[ba]=nil;end end end elseif 236==z then local q;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=false;n=n+1;y=f[n];q=y[189]w[q](w[q+1])else if(w[y[189]]<=w[y[893]])then n=y[591];else n=n+1;end;end;elseif z<=238 then local q;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];q=y[189]w[q]=w[q]()elseif z==239 then local q;local x;w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]={r({},1,y[591])};n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];x=y[189];q=w[x];for ba=x+1,y[591]do t(q,w[ba])end;else local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];q=y[189]w[q]=w[q](r(w,q+1,y[591]))end;elseif z<=264 then if z<=252 then if 246>=z then if 243>=z then if(z<=241)then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q>0 then ba=nil else x=nil end else if q<=2 then bb=nil else if 3==q then w[y[189]]=h[y[591]];else n=n+1;end end end else if q<=6 then if q~=6 then y=f[n];else w[y[189]]=h[y[591]];end else if q<=7 then n=n+1;else if q<9 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if q<=14 then if q<=11 then if q<11 then n=n+1;else y=f[n];end else if q<=12 then w[y[189]]=w[y[591]][w[y[893]]];else if q~=14 then n=n+1;else y=f[n];end end end else if q<=16 then if 16>q then bb=y[189]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q==18 then for bc=bb,y[893]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end elseif not(z~=242)then local q,x=0 while true do if q<=14 then if q<=6 then if q<=2 then if q<=0 then x=nil else if 1<q then n=n+1;else w[y[189]]=w[y[591]][y[893]];end end else if q<=4 then if 3<q then w[y[189]]=w[y[591]][y[893]];else y=f[n];end else if 5<q then y=f[n];else n=n+1;end end end else if q<=10 then if q<=8 then if q~=8 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if q<10 then y=f[n];else w[y[189]]=w[y[591]]*y[893];end end else if q<=12 then if q==11 then n=n+1;else y=f[n];end else if q>13 then n=n+1;else w[y[189]]=w[y[591]]+w[y[893]];end end end end else if q<=22 then if q<=18 then if q<=16 then if 15==q then y=f[n];else w[y[189]]=j[y[591]];end else if 17==q then n=n+1;else y=f[n];end end else if q<=20 then if 20>q then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if q~=22 then y=f[n];else w[y[189]]=w[y[591]];end end end else if q<=26 then if q<=24 then if q~=24 then n=n+1;else y=f[n];end else if 25==q then w[y[189]]=w[y[591]]+w[y[893]];else n=n+1;end end else if q<=28 then if q==27 then y=f[n];else x=y[189]end else if q~=30 then w[x]=w[x](r(w,x+1,y[591]))else break end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1~=q then x=nil else ba=nil end else if q<=2 then bb=nil else if 4~=q then w[y[189]]=h[y[591]];else n=n+1;end end end else if q<=6 then if q<6 then y=f[n];else w[y[189]]=h[y[591]];end else if q<=7 then n=n+1;else if 8==q then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if q<=14 then if q<=11 then if q>10 then y=f[n];else n=n+1;end else if q<=12 then w[y[189]]=w[y[591]][w[y[893]]];else if q<14 then n=n+1;else y=f[n];end end end else if q<=16 then if 15<q then ba={w[bb](w[bb+1])};else bb=y[189]end else if q<=17 then x=0;else if q<19 then for bc=bb,y[893]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end end;elseif(244>=z)then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if 1~=q then x=nil else w[y[189]]=w[y[591]][w[y[893]]];end else if 3>q then n=n+1;else y=f[n];end end else if q<=5 then if q<5 then w[y[189]]=w[y[591]];else n=n+1;end else if q<=6 then y=f[n];else if 8~=q then w[y[189]]=y[591];else n=n+1;end end end end else if q<=13 then if q<=10 then if 9<q then w[y[189]]=y[591];else y=f[n];end else if q<=11 then n=n+1;else if q==12 then y=f[n];else w[y[189]]=y[591];end end end else if q<=15 then if q<15 then n=n+1;else y=f[n];end else if q<=16 then x=y[189]else if 18>q then w[x]=w[x](r(w,x+1,y[591]))else break end end end end end q=q+1 end elseif 246~=z then w[y[189]]={};else local q,x=0 while true do if q<=12 then if q<=5 then if q<=2 then if q<=0 then x=nil else if 1==q then w={};else for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;end end else if q<=3 then n=n+1;else if 4<q then w[y[189]]=h[y[591]];else y=f[n];end end end else if q<=8 then if q<=6 then n=n+1;else if q~=8 then y=f[n];else w[y[189]]=j[y[591]];end end else if q<=10 then if q<10 then n=n+1;else y=f[n];end else if 11==q then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end end else if q<=18 then if q<=15 then if q<=13 then y=f[n];else if q~=15 then w[y[189]]=y[591];else n=n+1;end end else if q<=16 then y=f[n];else if 17<q then n=n+1;else w[y[189]]=y[591];end end end else if q<=21 then if q<=19 then y=f[n];else if 21>q then w[y[189]]=y[591];else n=n+1;end end else if q<=23 then if 22<q then x=y[189]else y=f[n];end else if q~=25 then w[x]=w[x](r(w,x+1,y[591]))else break end end end end end q=q+1 end end;elseif z<=249 then if 247>=z then local q,x=0 while true do if(q<8 or q==8)then if q<=3 then if(q==1 or q<1)then if not(1==q)then x=nil else w[y[189]]=w[y[591]][y[893]];end else if(2==q)then n=(n+1);else y=f[n];end end else if(q<=5)then if q==4 then w[y[189]]=h[y[591]];else n=(n+1);end else if q<=6 then y=f[n];else if(q<8)then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end end else if(q<13 or q==13)then if(q==10 or q<10)then if(9==q)then y=f[n];else w[y[189]]=y[591];end else if(q==11 or q<11)then n=n+1;else if not(13==q)then y=f[n];else w[y[189]]=y[591];end end end else if q<=15 then if 14==q then n=(n+1);else y=f[n];end else if q<=16 then x=y[189]else if(q<18)then w[x]=w[x](r(w,x+1,y[591]))else break end end end end end q=(q+1)end elseif not(z~=248)then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 1>q then x=nil else w[y[189]][y[591]]=w[y[893]];end else if 3~=q then n=n+1;else y=f[n];end end else if q<=5 then if q==4 then w[y[189]]={};else n=n+1;end else if 6==q then y=f[n];else w[y[189]][y[591]]=y[893];end end end else if q<=11 then if q<=9 then if 9>q then n=n+1;else y=f[n];end else if 10<q then n=n+1;else w[y[189]][y[591]]=w[y[893]];end end else if q<=13 then if 12<q then x=y[189]else y=f[n];end else if 15>q then w[x]=w[x](r(w,x+1,y[591]))else break end end end end q=q+1 end else if(y[189]==w[y[893]]or y[189]<w[y[893]])then n=n+1;else n=y[591];end;end;elseif 250>=z then if(w[y[189]]~=w[y[893]])then n=y[591];else n=n+1;end;elseif 252~=z then local q;local x;w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]={r({},1,y[591])};n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];x=y[189];q=w[x];for ba=x+1,y[591]do t(q,w[ba])end;else w[y[189]][y[591]]=y[893];end;elseif z<=258 then if 255>=z then if z<=253 then n=y[591];elseif z~=255 then local q;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];q=y[189]w[q]=w[q](r(w,q+1,y[591]))else w[y[189]]=w[y[591]]+w[y[893]];end;elseif z<=256 then local q;local x;local ba;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];ba=y[591];x=y[893];q=k(w,g,ba,x);w[y[189]]=q;elseif 258~=z then a(c,e);else w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];n=y[591];end;elseif 261>=z then if z<=259 then local a;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];a=y[189]w[a]=w[a]()elseif 260<z then local a;w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))else w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if(w[y[189]]~=w[y[893]])then n=n+1;else n=y[591];end;end;elseif z<=262 then w[y[189]]=b(d[y[591]],nil,j);elseif z<264 then w[y[189]]=j[y[591]];else local a=y[189];local c,e,q=w[a],w[a+1],w[a+2];local c=c+q;w[a]=c;if q>0 and c<=e or q<0 and c>=e then n=y[591];w[a+3]=c;end;end;elseif 276>=z then if z<=270 then if(z==267 or z<267)then if(z<=265)then local a,c=0 while true do if a<=17 then if a<=8 then if(a<=3)then if(a<=1)then if a<1 then c=nil else w={};end else if not(a~=2)then for e=0,u,1 do if(e<o)then w[e]=s[(e+1)];else break;end;end;else n=n+1;end end else if a<=5 then if a<5 then y=f[n];else w[y[189]]={};end else if(a<6 or a==6)then n=(n+1);else if(8>a)then y=f[n];else w[y[189]]=h[y[591]];end end end end else if(a==12 or a<12)then if(a<=10)then if a<10 then n=n+1;else y=f[n];end else if a~=12 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end else if(a==14 or a<14)then if 13==a then y=f[n];else w[y[189]]=h[y[591]];end else if a<=15 then n=n+1;else if 17>a then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end end else if(a<26 or a==26)then if(a<=21)then if(a<19 or a==19)then if(a>18)then y=f[n];else n=(n+1);end else if a~=21 then w[y[189]]={};else n=(n+1);end end else if(a<=23)then if(a>22)then w[y[189]]=y[591];else y=f[n];end else if(a<=24)then n=n+1;else if a>25 then w[y[189]]=y[591];else y=f[n];end end end end else if(a<=30)then if(a<=28)then if(a>27)then y=f[n];else n=(n+1);end else if 29==a then w[y[189]]=y[591];else n=(n+1);end end else if a<=32 then if 31<a then c=y[189];else y=f[n];end else if(a<33 or a==33)then w[c]=w[c]-w[c+2];else if a==34 then n=y[591];else break end end end end end end a=(a+1)end elseif(267~=z)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[189]]=w[y[591]][y[893]];end else if 2==a then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[189]]=h[y[591]];else n=n+1;end else if a<=6 then y=f[n];else if 8~=a then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end end else if a<=13 then if a<=10 then if a~=10 then y=f[n];else w[y[189]]=y[591];end else if a<=11 then n=n+1;else if a~=13 then y=f[n];else w[y[189]]=y[591];end end end else if a<=15 then if a==14 then n=n+1;else y=f[n];end else if a<=16 then c=y[189]else if 17<a then break else w[c]=w[c](r(w,c+1,y[591]))end end end end end a=a+1 end else local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then w[y[189]]=h[y[591]];else n=n+1;end else if a<=2 then y=f[n];else if a==3 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end else if a<=6 then if a<6 then y=f[n];else w[y[189]]=h[y[591]];end else if a<=7 then n=n+1;else if 8<a then w[y[189]]=h[y[591]];else y=f[n];end end end end else if a<=14 then if a<=11 then if 10==a then n=n+1;else y=f[n];end else if a<=12 then w[y[189]]=w[y[591]][y[893]];else if a==13 then n=n+1;else y=f[n];end end end else if a<=16 then if 15<a then n=n+1;else w[y[189]]=w[y[591]][w[y[893]]];end else if a<=17 then y=f[n];else if a~=19 then if(w[y[189]]~=y[893])then n=n+1;else n=y[591];end;else break end end end end end a=a+1 end end;elseif(268>=z)then local a=y[189];do return w[a],w[a+1]end elseif not(z~=269)then local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then w[y[189]][y[591]]=y[893];else n=n+1;end else if a<=2 then y=f[n];else if 3<a then n=n+1;else w[y[189]]={};end end end else if a<=6 then if a~=6 then y=f[n];else w[y[189]][y[591]]=w[y[893]];end else if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[189]]=h[y[591]];end end end end else if a<=14 then if a<=11 then if a==10 then n=n+1;else y=f[n];end else if a<=12 then w[y[189]]=w[y[591]][y[893]];else if a<14 then n=n+1;else y=f[n];end end end else if a<=16 then if a>15 then n=n+1;else w[y[189]][y[591]]=w[y[893]];end else if a<=17 then y=f[n];else if a<19 then w[y[189]][y[591]]=w[y[893]];else break end end end end end a=a+1 end else local a=y[189]local c={w[a](r(w,a+1,p))};local e=0;for q=a,y[893]do e=(e+1);w[q]=c[e];end end;elseif(z==273 or z<273)then if(271==z or 271>z)then if(w[y[189]]~=w[y[893]])then n=y[591];else n=(n+1);end;elseif 272==z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1>a then c=nil else w[y[189]]=h[y[591]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if 7~=a then y=f[n];else w[y[189]]=y[591];end end end else if a<=11 then if a<=9 then if 9>a then n=n+1;else y=f[n];end else if 11~=a then w[y[189]]=y[591];else n=n+1;end end else if a<=13 then if a~=13 then y=f[n];else c=y[189]end else if 15~=a then w[c]=w[c](r(w,c+1,y[591]))else break end end end end a=a+1 end else local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[189]]=w[y[591]][y[893]];else if 1==a then n=n+1;else y=f[n];end end else if a<=4 then if 3<a then n=n+1;else w[y[189]]=w[y[591]][y[893]];end else if a>5 then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end else if a<=9 then if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[189]][y[591]]=w[y[893]];end end else if a<=11 then if 10<a then y=f[n];else n=n+1;end else if 13~=a then n=y[591];else break end end end end a=a+1 end end;elseif(274>=z)then if(w[y[189]]~=y[893])then n=(n+1);else n=y[591];end;elseif z<276 then local a=y[189]w[a]=w[a](r(w,(a+1),y[591]))else local a,c,e,q=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0<a then e=nil else c=nil end else if a<=2 then q=nil else if a>3 then n=n+1;else w[y[189]]=h[y[591]];end end end else if a<=6 then if 5<a then w[y[189]]=h[y[591]];else y=f[n];end else if a<=7 then n=n+1;else if 8<a then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end end else if a<=14 then if a<=11 then if 11>a then n=n+1;else y=f[n];end else if a<=12 then w[y[189]]=w[y[591]][w[y[893]]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if a~=16 then q=y[189]else e={w[q](w[q+1])};end else if a<=17 then c=0;else if 19~=a then for x=q,y[893]do c=c+1;w[x]=e[c];end else break end end end end end a=a+1 end end;elseif 282>=z then if z<=279 then if z<=277 then local a;w[y[189]]={};n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];a=y[189]w[a]=w[a]()elseif 278==z then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=true;n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))else local a;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))end;elseif 280>=z then local a;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))elseif 281<z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if w[y[189]]then n=n+1;else n=y[591];end;else w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if not w[y[189]]then n=n+1;else n=y[591];end;end;elseif 285>=z then if z<=283 then local a=y[189];local c=y[893];local e=a+2;local q={w[a](w[a+1],w[e])};for x=1,c do w[e+x]=q[x];end local a=w[a+3];if a then w[e]=a;n=y[591];else n=n+1 end;elseif z~=285 then w[y[189]][y[591]]=y[893];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;end;elseif 286>=z then w[y[189]]=w[y[591]]-w[y[893]];elseif 288>z then w[y[189]]=w[y[591]]/y[893];else w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];n=y[591];end;elseif z<=336 then if 312>=z then if 300>=z then if(z<294 or z==294)then if((291>z)or not(291~=z))then if(z==289 or z<289)then local a=y[189];do return w[a](r(w,(a+1),y[591]))end;elseif not(z~=290)then local a=0 while true do if(a==9 or a<9)then if(a<4 or a==4)then if(a==1 or a<1)then if 0==a then w[y[189]][y[591]]=y[893];else n=(n+1);end else if(a==2 or a<2)then y=f[n];else if(not(a~=3))then w[y[189]]={};else n=(n+1);end end end else if(a<6 or a==6)then if not(a==6)then y=f[n];else w[y[189]][y[591]]=w[y[893]];end else if(a<7 or a==7)then n=(n+1);else if(8<a)then w[y[189]]=h[y[591]];else y=f[n];end end end end else if(a==14 or a<14)then if(a==11 or(a<11))then if(10<a)then y=f[n];else n=n+1;end else if(a==12 or a<12)then w[y[189]]=w[y[591]][y[893]];else if not(a==14)then n=(n+1);else y=f[n];end end end else if((a<16)or not(a~=16))then if(16>a)then w[y[189]][y[591]]=w[y[893]];else n=n+1;end else if(a<=17)then y=f[n];else if(a<19)then w[y[189]][y[591]]=w[y[893]];else break end end end end end a=(a+1)end else local a=y[189]w[a](r(w,(a+1),p))end;elseif(292==z or 292>z)then local a=0 while true do if((a==9)or a<9)then if(a<=4)then if(a<1 or a==1)then if not(a==1)then w[y[189]][y[591]]=y[893];else n=(n+1);end else if(a<=2)then y=f[n];else if not(a==4)then w[y[189]]={};else n=n+1;end end end else if(a==6 or a<6)then if(a<6)then y=f[n];else w[y[189]][y[591]]=w[y[893]];end else if(a<7 or a==7)then n=(n+1);else if(8<a)then w[y[189]]=h[y[591]];else y=f[n];end end end end else if(a==14 or a<14)then if(a<11 or not(a~=11))then if(a<11)then n=(n+1);else y=f[n];end else if(a<12 or a==12)then w[y[189]]=w[y[591]][y[893]];else if(13==a)then n=(n+1);else y=f[n];end end end else if(not(a~=16)or(a<16))then if not(16==a)then w[y[189]][y[591]]=w[y[893]];else n=(n+1);end else if(not(a~=17)or a<17)then y=f[n];else if(a>18)then break else w[y[189]][y[591]]=w[y[893]];end end end end end a=(a+1)end elseif(z<294)then local a,c=0 while true do if(a==16 or a<16)then if(a<7 or(a==7))then if(a<=3)then if(a==1 or a<1)then if(a<1)then c=nil else w[y[189]]=w[y[591]][y[893]];end else if not(not(3~=a))then n=(n+1);else y=f[n];end end else if(a==5 or a<5)then if 4<a then n=(n+1);else w[y[189]]=h[y[591]];end else if a>6 then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end else if(a==11 or a<11)then if((a==9)or a<9)then if not(not(8==a))then n=(n+1);else y=f[n];end else if(a<11)then w[y[189]]={};else n=n+1;end end else if(a==13 or a<13)then if(12==a)then y=f[n];else w[y[189]]=h[y[591]];end else if(not(a~=14)or(a<14))then n=(n+1);else if(not(a==16))then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end end else if(a==24 or a<24)then if(a<20 or not(a~=20))then if(a==18 or a<18)then if(17<a)then y=f[n];else n=(n+1);end else if(20>a)then w[y[189]]=h[y[591]];else n=(n+1);end end else if(a<22 or a==22)then if(22>a)then y=f[n];else w[y[189]]={};end else if not(not(a~=24))then n=(n+1);else y=f[n];end end end else if((a<28)or(a==28))then if(a<26 or a==26)then if 25<a then n=(n+1);else w[y[189]]=h[y[591]];end else if(a>27)then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end else if a<=30 then if(30>a)then n=(n+1);else y=f[n];end else if(a<31 or a==31)then c=y[189]else if not(not(a==32))then w[c]=w[c]()else break end end end end end end a=(a+1)end else local a=0 while true do if(a<14 or a==14)then if a<=6 then if(a==2 or a<2)then if(a<0 or a==0)then w={};else if(2>a)then for c=0,u,1 do if(c<o)then w[c]=s[c+1];else break;end;end;else n=(n+1);end end else if((a<4)or a==4)then if(4~=a)then y=f[n];else w[y[189]]=h[y[591]];end else if(a<6)then n=(n+1);else y=f[n];end end end else if(a==10 or a<10)then if(a<=8)then if not(a~=7)then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if(9<a)then w[y[189]]=h[y[591]];else y=f[n];end end else if(a<12 or a==12)then if(a>11)then y=f[n];else n=n+1;end else if(13<a)then n=(n+1);else w[y[189]]={};end end end end else if(a<21 or a==21)then if(a<17 or a==17)then if(a==15 or a<15)then y=f[n];else if not(a==17)then w[y[189]]={};else n=(n+1);end end else if(a==19 or a<19)then if(19>a)then y=f[n];else w[y[189]][y[591]]=w[y[893]];end else if(a~=21)then n=n+1;else y=f[n];end end end else if(a==25 or a<25)then if(a<=23)then if not(not(a==22))then w[y[189]]=j[y[591]];else n=n+1;end else if not(not(a==24))then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if(a<27 or a==27)then if(a==26)then n=(n+1);else y=f[n];end else if(not(28~=a))then if w[y[189]]then n=(n+1);else n=y[591];end;else break end end end end end a=(a+1)end end;elseif(297==z or 297>z)then if(295==z or(295>z))then local a,c,e,q=0 while true do if(a==15 or a<15)then if(a<=7)then if a<=3 then if(a==1 or a<1)then if not(1==a)then c=nil else e=nil end else if(a==2)then q=nil else w[y[189]]=h[y[591]];end end else if a<=5 then if(4<a)then y=f[n];else n=(n+1);end else if not(6~=a)then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end end end else if(a==11 or a<11)then if a<=9 then if 9~=a then y=f[n];else w[y[189]]=h[y[591]];end else if(11>a)then n=n+1;else y=f[n];end end else if(a==13 or a<13)then if(a~=13)then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end else if(a>14)then w[y[189]]=w[y[591]][w[y[893]]];else y=f[n];end end end end else if(a<=23)then if(a<=19)then if a<=17 then if not(16~=a)then n=(n+1);else y=f[n];end else if(18<a)then n=(n+1);else w[y[189]]=h[y[591]];end end else if(a<21 or a==21)then if not(21==a)then y=f[n];else w[y[189]]=w[y[591]][y[893]];end else if(22<a)then y=f[n];else n=n+1;end end end else if(a<27 or a==27)then if a<=25 then if not(25==a)then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end else if not(26~=a)then y=f[n];else q=y[591];end end else if a<=29 then if(28<a)then c=k(w,g,q,e);else e=y[893];end else if not(30~=a)then w[y[189]]=c;else break end end end end end a=a+1 end elseif not(z~=296)then local a,c=0 while true do if a<=13 then if a<=6 then if a<=2 then if(a<=0)then c=nil else if(a==1)then w[y[189]]={};else n=(n+1);end end else if(a==4 or a<4)then if not(a~=3)then y=f[n];else w[y[189]]=h[y[591]];end else if(5<a)then y=f[n];else n=(n+1);end end end else if(a<9 or a==9)then if(a<=7)then w[y[189]]=w[y[591]][y[893]];else if(9~=a)then n=n+1;else y=f[n];end end else if(a<11 or a==11)then if a<11 then w[y[189]][y[591]]=w[y[893]];else n=(n+1);end else if(a<13)then y=f[n];else w[y[189]]=j[y[591]];end end end end else if(a==20 or a<20)then if(a<16 or a==16)then if a<=14 then n=(n+1);else if(a>15)then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end else if(a<=18)then if a<18 then n=n+1;else y=f[n];end else if(a>19)then n=n+1;else w[y[189]]=j[y[591]];end end end else if a<=23 then if(a<21 or a==21)then y=f[n];else if(23>a)then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end else if(a<25 or a==25)then if(25>a)then y=f[n];else c=y[189]end else if not(a~=26)then w[c]=w[c]()else break end end end end end a=a+1 end else local a,c=0 while true do if(a<12 or a==12)then if a<=5 then if(a==2 or a<2)then if(a<0 or a==0)then c=nil else if a==1 then w={};else for e=0,u,1 do if(e<o)then w[e]=s[(e+1)];else break;end;end;end end else if(a==3 or a<3)then n=(n+1);else if 5~=a then y=f[n];else w[y[189]]=h[y[591]];end end end else if a<=8 then if(a<6 or a==6)then n=(n+1);else if a>7 then w[y[189]]=j[y[591]];else y=f[n];end end else if a<=10 then if not(a==10)then n=(n+1);else y=f[n];end else if a>11 then n=n+1;else w[y[189]]=w[y[591]][y[893]];end end end end else if a<=18 then if(a<15 or a==15)then if a<=13 then y=f[n];else if(15>a)then w[y[189]]=y[591];else n=(n+1);end end else if(a<16 or a==16)then y=f[n];else if a<18 then w[y[189]]=y[591];else n=(n+1);end end end else if(a<=21)then if(a<=19)then y=f[n];else if 21~=a then w[y[189]]=y[591];else n=(n+1);end end else if(a<23 or a==23)then if not(a~=22)then y=f[n];else c=y[189]end else if 24<a then break else w[c]=w[c](r(w,c+1,y[591]))end end end end end a=a+1 end end;elseif(298>z or 298==z)then local a=y[189];local c=w[y[591]];w[a+1]=c;w[a]=c[w[y[893]]];elseif(not(300==z))then local a=y[189]local c,e=i(w[a](w[(a+1)]))p=((e+a)-1)local e=0;for q=a,p do e=e+1;w[q]=c[e];end;else local a,c,e=0 while true do if(a<24 or a==24)then if(a<11 or a==11)then if(a==5 or a<5)then if(a<2 or a==2)then if(a==0 or a<0)then c=nil else if(1<a)then w[y[189]]={};else e=nil end end else if a<=3 then n=n+1;else if 5>a then y=f[n];else w[y[189]]=h[y[591]];end end end else if(a<=8)then if(a==6 or a<6)then n=(n+1);else if(8>a)then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if(a<=9)then n=n+1;else if a>10 then w[y[189]]=h[y[591]];else y=f[n];end end end end else if(a<=17)then if(a<14 or a==14)then if(a<12 or a==12)then n=(n+1);else if a<14 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if(a<15 or a==15)then n=(n+1);else if 17>a then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if(a<20 or a==20)then if(a<=18)then n=(n+1);else if 19==a then y=f[n];else w[y[189]]={};end end else if(a<22 or a==22)then if(a<22)then n=(n+1);else y=f[n];end else if not(a==24)then w[y[189]]={};else n=(n+1);end end end end end else if(a<37 or a==37)then if(a==30 or a<30)then if(a<=27)then if(a==25 or a<25)then y=f[n];else if not(a==27)then w[y[189]]=h[y[591]];else n=(n+1);end end else if(a==28 or a<28)then y=f[n];else if(a==29)then w[y[189]][y[591]]=w[y[893]];else n=n+1;end end end else if(a<=33)then if a<=31 then y=f[n];else if(a>32)then n=n+1;else w[y[189]]=h[y[591]];end end else if(a<35 or a==35)then if not(34~=a)then y=f[n];else w[y[189]][y[591]]=w[y[893]];end else if(a<37)then n=n+1;else y=f[n];end end end end else if a<=43 then if(a<=40)then if(a<38 or a==38)then w[y[189]][y[591]]=w[y[893]];else if(a<40)then n=(n+1);else y=f[n];end end else if(a<=41)then w[y[189]]={r({},1,y[591])};else if 42<a then y=f[n];else n=(n+1);end end end else if(a<46 or a==46)then if(a<=44)then w[y[189]]=w[y[591]];else if not(a==46)then n=n+1;else y=f[n];end end else if(a<=48)then if a>47 then c=w[e];else e=y[189];end else if 49<a then break else for q=(e+1),y[591]do t(c,w[q])end;end end end end end end a=(a+1)end end;elseif(z==306 or z<306)then if(z<303 or z==303)then if(301==z or 301>z)then local a=y[189];do return r(w,a,p)end;elseif not(z==303)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1>a then c=nil else w[y[189]]=w[y[591]][y[893]];end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[189]]=y[591];else n=n+1;end else if 6==a then y=f[n];else w[y[189]]=y[591];end end end else if a<=11 then if a<=9 then if a>8 then y=f[n];else n=n+1;end else if 11>a then w[y[189]]=y[591];else n=n+1;end end else if a<=13 then if a<13 then y=f[n];else c=y[189]end else if 15>a then w[c]=w[c](r(w,c+1,y[591]))else break end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0==a then c=nil else w[y[189]]=w[y[591]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[189]]=w[y[591]];else n=n+1;end else if a<7 then y=f[n];else w[y[189]]=w[y[591]];end end end else if a<=11 then if a<=9 then if 8==a then n=n+1;else y=f[n];end else if a>10 then n=n+1;else w[y[189]]=w[y[591]];end end else if a<=13 then if 13>a then y=f[n];else c=y[189]end else if 14==a then w[c]=w[c](r(w,c+1,y[591]))else break end end end end a=a+1 end end;elseif(304>=z)then do return end;elseif z<306 then w[y[189]]();else local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if 1>a then c=nil else w[y[189]]=h[y[591]];end else if a<=2 then n=n+1;else if a~=4 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if a<=7 then if a<=5 then n=n+1;else if a>6 then w[y[189]]=h[y[591]];else y=f[n];end end else if a<=8 then n=n+1;else if 10~=a then y=f[n];else w[y[189]]=w[y[591]][w[y[893]]];end end end end else if a<=15 then if a<=12 then if a==11 then n=n+1;else y=f[n];end else if a<=13 then w[y[189]]=h[y[591]];else if a<15 then n=n+1;else y=f[n];end end end else if a<=18 then if a<=16 then w[y[189]]=w[y[591]][y[893]];else if a~=18 then n=n+1;else y=f[n];end end else if a<=19 then c=y[189]else if a~=21 then w[c]=w[c](r(w,c+1,y[591]))else break end end end end end a=a+1 end end;elseif(309>z or 309==z)then if(z<307 or z==307)then local a,c,e,q=0 while true do if(a<9 or a==9)then if a<=4 then if(a==1 or a<1)then if not(1==a)then c=nil else e=nil end else if a<=2 then q=nil else if not(a~=3)then w[y[189]]=h[y[591]];else n=n+1;end end end else if(a<6 or a==6)then if not(a~=5)then y=f[n];else w[y[189]]=h[y[591]];end else if(a==7 or a<7)then n=n+1;else if not(a==9)then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if a<=14 then if(a<=11)then if(10==a)then n=n+1;else y=f[n];end else if(a==12 or a<12)then w[y[189]]=w[y[591]][w[y[893]]];else if not(14==a)then n=n+1;else y=f[n];end end end else if a<=16 then if not(a==16)then q=y[189]else e={w[q](w[q+1])};end else if(a<17 or a==17)then c=0;else if(a<19)then for x=q,y[893]do c=c+1;w[x]=e[c];end else break end end end end end a=a+1 end elseif not(z~=308)then local a,c=0 while true do if(a==9 or a<9)then if(a==4 or a<4)then if(a==1 or a<1)then if not(a~=0)then c=nil else w={};end else if(a==2 or a<2)then for e=0,u,1 do if(e<o)then w[e]=s[e+1];else break;end;end;else if a<4 then n=(n+1);else y=f[n];end end end else if(a==6 or a<6)then if(a~=6)then w[y[189]]=j[y[591]];else n=n+1;end else if(a<=7)then y=f[n];else if a<9 then w[y[189]]=w[y[591]][y[893]];else n=(n+1);end end end end else if a<=14 then if a<=11 then if a<11 then y=f[n];else w[y[189]]=h[y[591]];end else if(a<=12)then n=n+1;else if not(a~=13)then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if a<=16 then if 15==a then n=n+1;else y=f[n];end else if(a<=17)then c=y[189]else if(18==a)then w[c]=w[c](w[c+1])else break end end end end end a=a+1 end else local a,c,e,q=0 while true do if(a<9 or a==9)then if a<=4 then if(a<1 or a==1)then if(0<a)then e=nil else c=nil end else if(a==2 or a<2)then q=nil else if a>3 then n=n+1;else w[y[189]]=h[y[591]];end end end else if a<=6 then if(5<a)then w[y[189]]=h[y[591]];else y=f[n];end else if a<=7 then n=n+1;else if not(8~=a)then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if a<=14 then if(a<=11)then if not(a==11)then n=(n+1);else y=f[n];end else if(a<=12)then w[y[189]]=w[y[591]][w[y[893]]];else if 14>a then n=(n+1);else y=f[n];end end end else if a<=16 then if not(16==a)then q=y[189]else e={w[q](w[q+1])};end else if(a==17 or a<17)then c=0;else if 19~=a then for x=q,y[893]do c=(c+1);w[x]=e[c];end else break end end end end end a=a+1 end end;elseif z<=310 then local a,c=0 while true do if a<=13 then if a<=6 then if a<=2 then if a<=0 then c=nil else if a~=2 then w[y[189]]={};else n=n+1;end end else if a<=4 then if a~=4 then y=f[n];else w[y[189]]=h[y[591]];end else if 6~=a then n=n+1;else y=f[n];end end end else if a<=9 then if a<=7 then w[y[189]]=w[y[591]][y[893]];else if a==8 then n=n+1;else y=f[n];end end else if a<=11 then if 11>a then w[y[189]][y[591]]=w[y[893]];else n=n+1;end else if a~=13 then y=f[n];else w[y[189]]=j[y[591]];end end end end else if a<=20 then if a<=16 then if a<=14 then n=n+1;else if 16>a then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if a<=18 then if 18>a then n=n+1;else y=f[n];end else if 19==a then w[y[189]]=j[y[591]];else n=n+1;end end end else if a<=23 then if a<=21 then y=f[n];else if a~=23 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end else if a<=25 then if a<25 then y=f[n];else c=y[189]end else if a~=27 then w[c]=w[c]()else break end end end end end a=a+1 end elseif 312>z then local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then w[y[189]]=j[y[591]];else c=nil end else if a<=2 then n=n+1;else if a==3 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if a<=7 then if a<=5 then n=n+1;else if 7>a then y=f[n];else w[y[189]]=y[591];end end else if a<=8 then n=n+1;else if a~=10 then y=f[n];else w[y[189]]=y[591];end end end end else if a<=15 then if a<=12 then if 11<a then y=f[n];else n=n+1;end else if a<=13 then w[y[189]]=y[591];else if a>14 then y=f[n];else n=n+1;end end end else if a<=18 then if a<=16 then w[y[189]]=y[591];else if a~=18 then n=n+1;else y=f[n];end end else if a<=19 then c=y[189]else if 21>a then w[c]=w[c](r(w,c+1,y[591]))else break end end end end end a=a+1 end else local a=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then w={};else if 1<a then n=n+1;else for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;end end else if a<=4 then if 3<a then w[y[189]]=h[y[591]];else y=f[n];end else if a>5 then y=f[n];else n=n+1;end end end else if a<=10 then if a<=8 then if a==7 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if a<10 then y=f[n];else w[y[189]]=h[y[591]];end end else if a<=12 then if a~=12 then n=n+1;else y=f[n];end else if 14~=a then w[y[189]]={};else n=n+1;end end end end else if a<=21 then if a<=17 then if a<=15 then y=f[n];else if a>16 then n=n+1;else w[y[189]]={};end end else if a<=19 then if 18==a then y=f[n];else w[y[189]][y[591]]=w[y[893]];end else if a~=21 then n=n+1;else y=f[n];end end end else if a<=25 then if a<=23 then if 23>a then w[y[189]]=j[y[591]];else n=n+1;end else if 25>a then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if a<=27 then if a==26 then n=n+1;else y=f[n];end else if a~=29 then if w[y[189]]then n=n+1;else n=y[591];end;else break end end end end end a=a+1 end end;elseif(z==324 or z<324)then if(z==318 or z<318)then if 315>=z then if(313==z or 313>z)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[189]]=j[y[591]];end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[189]]=w[y[591]][y[893]];end else if a<=6 then y=f[n];else if a<8 then w[y[189]]=y[591];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9==a then y=f[n];else w[y[189]]=y[591];end else if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[189]]=y[591];end end end else if a<=15 then if a~=15 then n=n+1;else y=f[n];end else if a<=16 then c=y[189]else if 17==a then w[c]=w[c](r(w,c+1,y[591]))else break end end end end end a=a+1 end elseif z<315 then if(y[189]<w[y[893]])then n=n+1;else n=y[591];end;else w[y[189]][w[y[591]]]=w[y[893]];end;elseif(316==z or 316>z)then local a=y[189]local c,e=i(w[a](r(w,a+1,y[591])))p=(e+a-1)local e=0;for q=a,p do e=e+1;w[q]=c[e];end;elseif 317<z then w[y[189]]=w[y[591]][y[893]];else local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if 0==a then c=nil else w[y[189]]=j[y[591]];end else if a<=2 then n=n+1;else if a>3 then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end else if a<=7 then if a<=5 then n=n+1;else if a~=7 then y=f[n];else w[y[189]]=y[591];end end else if a<=8 then n=n+1;else if 9<a then w[y[189]]=y[591];else y=f[n];end end end end else if a<=15 then if a<=12 then if a==11 then n=n+1;else y=f[n];end else if a<=13 then w[y[189]]=y[591];else if 15>a then n=n+1;else y=f[n];end end end else if a<=18 then if a<=16 then w[y[189]]=y[591];else if 17<a then y=f[n];else n=n+1;end end else if a<=19 then c=y[189]else if 20==a then w[c]=w[c](r(w,c+1,y[591]))else break end end end end end a=a+1 end end;elseif(321>z or 321==z)then if(z==319 or z<319)then local a,c,e,q=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then c=nil else e=nil end else if a<=2 then q=nil else if a>3 then n=n+1;else w[y[189]]=j[y[591]];end end end else if a<=6 then if 5<a then w[y[189]]=w[y[591]][y[893]];else y=f[n];end else if a<=7 then n=n+1;else if a>8 then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<=12 then w[y[189]]=w[y[591]][y[893]];else if 14>a then n=n+1;else y=f[n];end end end else if a<=16 then if 15<a then e={w[q](w[q+1])};else q=y[189]end else if a<=17 then c=0;else if 19~=a then for x=q,y[893]do c=c+1;w[x]=e[c];end else break end end end end end a=a+1 end elseif(320==z)then local a=y[189]w[a]=w[a](w[(a+1)])else w[y[189]]={};end;elseif(322>=z)then local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[189]]=w[y[591]][y[893]];else if a~=2 then n=n+1;else y=f[n];end end else if a<=4 then if 4>a then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if 5==a then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if a<=9 then if a<=7 then n=n+1;else if 9~=a then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if a<=11 then if 11>a then n=n+1;else y=f[n];end else if 13>a then if w[y[189]]then n=n+1;else n=y[591];end;else break end end end end a=a+1 end elseif(323<z)then local a,c=0 while true do if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if a~=2 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end else if a<=3 then y=f[n];else if 5~=a then w[y[189]]=h[y[591]];else n=n+1;end end end else if a<=8 then if a<=6 then y=f[n];else if a>7 then n=n+1;else w[y[189]]=w[y[591]][y[893]];end end else if a<=9 then y=f[n];else if 10<a then n=n+1;else w[y[189]]=h[y[591]];end end end end else if a<=17 then if a<=14 then if a<=12 then y=f[n];else if 14>a then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end else if a<=15 then y=f[n];else if a==16 then w[y[189]]=h[y[591]];else n=n+1;end end end else if a<=20 then if a<=18 then y=f[n];else if 19==a then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end else if a<=22 then if 22>a then y=f[n];else c=y[189]end else if 23<a then break else w[c]=w[c](r(w,c+1,y[591]))end end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[189]]=w[y[591]][y[893]];end else if 3~=a then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[189]]=h[y[591]];else n=n+1;end else if a<=6 then y=f[n];else if a<8 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end end end else if a<=13 then if a<=10 then if a==9 then y=f[n];else w[y[189]]=y[591];end else if a<=11 then n=n+1;else if 12==a then y=f[n];else w[y[189]]=y[591];end end end else if a<=15 then if 15~=a then n=n+1;else y=f[n];end else if a<=16 then c=y[189]else if a<18 then w[c]=w[c](r(w,c+1,y[591]))else break end end end end end a=a+1 end end;elseif(330>=z)then if(327>=z)then if(z==325 or z<325)then local a,c,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then c=nil else e=nil end else if a<=2 then w={};else if a>3 then n=n+1;else for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;end end end else if a<=6 then if 5==a then y=f[n];else w[y[189]]=j[y[591]];end else if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[189]]=j[y[591]];end end end end else if a<=14 then if a<=11 then if 11>a then n=n+1;else y=f[n];end else if a<=12 then w[y[189]]=w[y[591]][y[893]];else if a~=14 then n=n+1;else y=f[n];end end end else if a<=16 then if 15<a then c=w[y[591]];else e=y[189];end else if a<=17 then w[e+1]=c;else if a~=19 then w[e]=c[y[893]];else break end end end end end a=a+1 end elseif(z>326)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[189]]=w[y[591]][y[893]];end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[189]]=w[y[591]];else n=n+1;end else if 7>a then y=f[n];else w[y[189]]=h[y[591]];end end end else if a<=11 then if a<=9 then if a>8 then y=f[n];else n=n+1;end else if 10<a then n=n+1;else w[y[189]]=w[y[591]][y[893]];end end else if a<=13 then if a~=13 then y=f[n];else c=y[189]end else if 15~=a then w[c]=w[c](r(w,c+1,y[591]))else break end end end end a=a+1 end else local a=d[y[591]];local c={};local e={};for o=1,y[893]do n=n+1;local q=f[n];if not(q[545]~=76)then e[o-1]={w,q[591],nil};else e[o-1]={h,q[591],nil};end;v[(#v+1)]=e;end;m(c,{['\95\95\105\110\100\101\120']=function(m,m)local m=e[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,o)local e=e[m]e[1][e[2]]=o;end;});w[y[189]]=b(a,c,j);end;elseif 328>=z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then w[y[189]]=j[y[591]];else c=nil end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if a<5 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if a~=7 then y=f[n];else w[y[189]]=h[y[591]];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if a==10 then w[y[189]]=w[y[591]][y[893]];else n=n+1;end end else if a<=13 then if a==12 then y=f[n];else c=y[189]end else if a==14 then w[c]=w[c](w[c+1])else break end end end end a=a+1 end elseif z>329 then local a=y[189]w[a](r(w,(a+1),y[591]))else local a=y[189]local c={w[a](r(w,a+1,y[591]))};local e=0;for m=a,y[893]do e=(e+1);w[m]=c[e];end;end;elseif 333>=z then if(331==z or 331>z)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then c=nil else e=nil end else if a<=2 then m=nil else if a==3 then w[y[189]]=h[y[591]];else n=n+1;end end end else if a<=6 then if a~=6 then y=f[n];else w[y[189]]=h[y[591]];end else if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if a<=14 then if a<=11 then if a>10 then y=f[n];else n=n+1;end else if a<=12 then w[y[189]]=w[y[591]][w[y[893]]];else if a~=14 then n=n+1;else y=f[n];end end end else if a<=16 then if a<16 then m=y[189]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if a==18 then for o=m,y[893]do c=c+1;w[o]=e[c];end else break end end end end end a=a+1 end elseif 332<z then local a=y[591];local c=y[893];local a=k(w,g,a,c);w[y[189]]=a;else w[y[189]]=h[y[591]];end;elseif(z<334 or z==334)then w[y[189]]();elseif(335==z)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1>a then c=nil else e=nil end else if a<=2 then m=nil else if a>3 then n=n+1;else w[y[189]]=h[y[591]];end end end else if a<=6 then if a==5 then y=f[n];else w[y[189]]=h[y[591]];end else if a<=7 then n=n+1;else if a<9 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end end else if a<=14 then if a<=11 then if a==10 then n=n+1;else y=f[n];end else if a<=12 then w[y[189]]=w[y[591]][w[y[893]]];else if 14>a then n=n+1;else y=f[n];end end end else if a<=16 then if a<16 then m=y[189]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if a>18 then break else for o=m,y[893]do c=c+1;w[o]=e[c];end end end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 0==a then c=nil else w[y[189]]=j[y[591]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[189]]=w[y[591]][y[893]];else n=n+1;end else if a<=6 then y=f[n];else if 8~=a then w[y[189]]=y[591];else n=n+1;end end end end else if a<=13 then if a<=10 then if a~=10 then y=f[n];else w[y[189]]=y[591];end else if a<=11 then n=n+1;else if a==12 then y=f[n];else w[y[189]]=y[591];end end end else if a<=15 then if a~=15 then n=n+1;else y=f[n];end else if a<=16 then c=y[189]else if a>17 then break else w[c]=w[c](r(w,c+1,y[591]))end end end end end a=a+1 end end;elseif 360>=z then if z<=348 then if 342>=z then if z<=339 then if z<=337 then w[y[189]]=false;n=n+1;elseif z>338 then local a=y[591];local c=y[893];local a=k(w,g,a,c);w[y[189]]=a;else w[y[189]]={r({},1,y[591])};end;elseif 340>=z then local a;w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];a=y[189]w[a](r(w,a+1,y[591]))elseif z~=342 then local a;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))else local a;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]]*y[893];n=n+1;y=f[n];w[y[189]]=w[y[591]]+w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]]+w[y[893]];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))end;elseif z<=345 then if z<=343 then local a;w[y[189]]=w[y[591]]%w[y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]]+y[893];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))elseif 344<z then local a;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))else local a=w[y[189]]+y[893];w[y[189]]=a;if(a<=w[y[189]+1])then n=y[591];end;end;elseif 346>=z then w[y[189]]=w[y[591]]%w[y[893]];elseif 348~=z then local a=y[189]w[a]=w[a](r(w,a+1,y[591]))else local a;local c;local e;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];e=y[189]c={w[e](w[e+1])};a=0;for g=e,y[893]do a=a+1;w[g]=c[a];end end;elseif z<=354 then if z<=351 then if z<=349 then if(w[y[189]]~=y[893])then n=y[591];else n=n+1;end;elseif z>350 then local a;local c;local e;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];e=y[189]c={w[e](w[e+1])};a=0;for g=e,y[893]do a=a+1;w[g]=c[a];end else local a;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))end;elseif 352>=z then local a;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))elseif z~=354 then w[y[189]][y[591]]=y[893];n=n+1;y=f[n];w[y[189]]={};n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];else local a;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=false;n=n+1;y=f[n];a=y[189]w[a](w[a+1])end;elseif 357>=z then if z<=355 then local a;local c;local e;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];e=y[189]c={w[e](w[e+1])};a=0;for g=e,y[893]do a=a+1;w[g]=c[a];end elseif z<357 then local a;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))else local a;local c;local e;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];e=y[189]c={w[e](w[e+1])};a=0;for g=e,y[893]do a=a+1;w[g]=c[a];end end;elseif 358>=z then local a;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];a=y[189]w[a]=w[a](w[a+1])elseif 359==z then local a;local c;local e;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];e=y[189]c={w[e](w[e+1])};a=0;for g=e,y[893]do a=a+1;w[g]=c[a];end else local a;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]]*y[893];n=n+1;y=f[n];w[y[189]]=w[y[591]]+w[y[893]];n=n+1;y=f[n];w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]]+w[y[893]];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))end;elseif z<=372 then if z<=366 then if z<=363 then if z<=361 then w[y[189]]=#w[y[591]];elseif z<363 then local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then c=nil else w[y[189]]=w[y[591]][y[893]];end else if a<=2 then n=n+1;else if a>3 then w[y[189]]=h[y[591]];else y=f[n];end end end else if a<=7 then if a<=5 then n=n+1;else if a>6 then w[y[189]]=h[y[591]];else y=f[n];end end else if a<=8 then n=n+1;else if 9==a then y=f[n];else w[y[189]]=h[y[591]];end end end end else if a<=15 then if a<=12 then if a>11 then y=f[n];else n=n+1;end else if a<=13 then w[y[189]]=h[y[591]];else if 14<a then y=f[n];else n=n+1;end end end else if a<=18 then if a<=16 then w[y[189]]=w[y[591]];else if 18~=a then n=n+1;else y=f[n];end end else if a<=19 then c=y[189]else if a==20 then w[c](r(w,c+1,y[591]))else break end end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[189]]=w[y[591]][w[y[893]]];end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[189]]=w[y[591]];else n=n+1;end else if a<=6 then y=f[n];else if 8>a then w[y[189]]=y[591];else n=n+1;end end end end else if a<=13 then if a<=10 then if a<10 then y=f[n];else w[y[189]]=y[591];end else if a<=11 then n=n+1;else if 13~=a then y=f[n];else w[y[189]]=y[591];end end end else if a<=15 then if a<15 then n=n+1;else y=f[n];end else if a<=16 then c=y[189]else if 17==a then w[c]=w[c](r(w,c+1,y[591]))else break end end end end end a=a+1 end end;elseif(364>=z)then local a,c,e=0 while true do if(a<24 or a==24)then if(a<=11)then if(a==5 or a<5)then if a<=2 then if a<=0 then c=nil else if a>1 then w[y[189]]={};else e=nil end end else if(a<3 or a==3)then n=(n+1);else if 4==a then y=f[n];else w[y[189]]=h[y[591]];end end end else if(a==8 or a<8)then if(a<6 or a==6)then n=n+1;else if(7==a)then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if(a<=9)then n=(n+1);else if a>10 then w[y[189]]=h[y[591]];else y=f[n];end end end end else if(a<17 or a==17)then if(a<=14)then if(a<=12)then n=n+1;else if(13==a)then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end else if(a<15 or a==15)then n=n+1;else if a<17 then y=f[n];else w[y[189]]=w[y[591]][y[893]];end end end else if(a==20 or a<20)then if(a<=18)then n=n+1;else if(20>a)then y=f[n];else w[y[189]]={};end end else if a<=22 then if 21<a then y=f[n];else n=(n+1);end else if 23<a then n=n+1;else w[y[189]]={};end end end end end else if(a<37 or a==37)then if(a<30 or a==30)then if(a<=27)then if a<=25 then y=f[n];else if(27>a)then w[y[189]]=h[y[591]];else n=(n+1);end end else if a<=28 then y=f[n];else if not(a~=29)then w[y[189]][y[591]]=w[y[893]];else n=(n+1);end end end else if a<=33 then if a<=31 then y=f[n];else if 32==a then w[y[189]]=h[y[591]];else n=(n+1);end end else if a<=35 then if(a<35)then y=f[n];else w[y[189]][y[591]]=w[y[893]];end else if(37>a)then n=n+1;else y=f[n];end end end end else if(a<43 or a==43)then if a<=40 then if a<=38 then w[y[189]][y[591]]=w[y[893]];else if not(40==a)then n=n+1;else y=f[n];end end else if a<=41 then w[y[189]]={r({},1,y[591])};else if(42<a)then y=f[n];else n=n+1;end end end else if a<=46 then if(a<44 or a==44)then w[y[189]]=w[y[591]];else if(a>45)then y=f[n];else n=n+1;end end else if a<=48 then if 48~=a then e=y[189];else c=w[e];end else if(a==49)then for g=e+1,y[591]do t(c,w[g])end;else break end end end end end end a=a+1 end elseif not(366==z)then local a=y[189];local c=w[y[591]];w[a+1]=c;w[a]=c[w[y[893]]];else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[189]]=w[y[591]][y[893]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if a<5 then w[y[189]]=y[591];else n=n+1;end else if 6<a then w[y[189]]=y[591];else y=f[n];end end end else if a<=11 then if a<=9 then if a<9 then n=n+1;else y=f[n];end else if a<11 then w[y[189]]=y[591];else n=n+1;end end else if a<=13 then if a==12 then y=f[n];else c=y[189]end else if a>14 then break else w[c]=w[c](r(w,c+1,y[591]))end end end end a=a+1 end end;elseif(z<=369)then if(z<367 or z==367)then local a=y[189];local c=w[y[591]];w[(a+1)]=c;w[a]=c[y[893]];elseif 369>z then local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if 1>a then c=nil else w[y[189]]=w[y[591]][y[893]];end else if a<=2 then n=n+1;else if a~=4 then y=f[n];else w[y[189]]=y[591];end end end else if a<=7 then if a<=5 then n=n+1;else if 7~=a then y=f[n];else w[y[189]]=h[y[591]];end end else if a<=8 then n=n+1;else if a>9 then w[y[189]]=w[y[591]][y[893]];else y=f[n];end end end end else if a<=16 then if a<=13 then if a<=11 then n=n+1;else if a~=13 then y=f[n];else c=y[189];end end else if a<=14 then do return w[c](r(w,c+1,y[591]))end;else if a~=16 then n=n+1;else y=f[n];end end end else if a<=19 then if a<=17 then c=y[189];else if a==18 then do return r(w,c,p)end;else n=n+1;end end else if a<=20 then y=f[n];else if a==21 then n=y[591];else break end end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then w[y[189]]=h[y[591]];else c=nil end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if 5~=a then w[y[189]]=y[591];else n=n+1;end else if 6==a then y=f[n];else w[y[189]]=y[591];end end end else if a<=11 then if a<=9 then if a>8 then y=f[n];else n=n+1;end else if a>10 then n=n+1;else w[y[189]]=y[591];end end else if a<=13 then if a~=13 then y=f[n];else c=y[189]end else if a~=15 then w[c]=w[c](r(w,c+1,y[591]))else break end end end end a=a+1 end end;elseif(z<370 or z==370)then w[y[189]]=w[y[591]][w[y[893]]];elseif 371<z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0==a then c=nil else w[y[189]][y[591]]=w[y[893]];end else if 3~=a then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[189]]={};else n=n+1;end else if 7~=a then y=f[n];else w[y[189]][y[591]]=y[893];end end end else if a<=11 then if a<=9 then if 8==a then n=n+1;else y=f[n];end else if a<11 then w[y[189]][y[591]]=w[y[893]];else n=n+1;end end else if a<=13 then if 12<a then c=y[189]else y=f[n];end else if 14==a then w[c]=w[c](r(w,c+1,y[591]))else break end end end end a=a+1 end else if w[y[189]]then n=(n+1);else n=y[591];end;end;elseif z<=378 then if z<=375 then if 373>=z then w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]][y[591]]=w[y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];if(w[y[189]]~=w[y[893]])then n=n+1;else n=y[591];end;elseif 375>z then local a;local c;local e;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];e=y[189]c={w[e](w[e+1])};a=0;for g=e,y[893]do a=a+1;w[g]=c[a];end else local a;w[y[189]]=j[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];a=y[189]w[a]=w[a](w[a+1])end;elseif z<=376 then local a=w[y[893]];if not a then n=n+1;else w[y[189]]=a;n=y[591];end;elseif z==377 then local a;w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))else h[y[591]]=w[y[189]];end;elseif z<=381 then if 379>=z then w[y[189]]=b(d[y[591]],nil,j);elseif z<381 then local a;local c;local d;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];d=y[189]c={w[d](w[d+1])};a=0;for e=d,y[893]do a=a+1;w[e]=c[a];end else local a;local c;local d;w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=h[y[591]];n=n+1;y=f[n];w[y[189]]=w[y[591]][y[893]];n=n+1;y=f[n];w[y[189]]=w[y[591]][w[y[893]]];n=n+1;y=f[n];d=y[189]c={w[d](w[d+1])};a=0;for e=d,y[893]do a=a+1;w[e]=c[a];end end;elseif 383>=z then if z~=383 then local a=y[189];local c=w[a];for d=a+1,y[591]do t(c,w[d])end;else local a=y[189]local c,d=i(w[a](r(w,a+1,y[591])))p=d+a-1 local d=0;for e=a,p do d=d+1;w[e]=c[d];end;end;elseif z==384 then if(y[189]<=w[y[893]])then n=n+1;else n=y[591];end;else local a;w[y[189]]=w[y[591]];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];w[y[189]]=y[591];n=n+1;y=f[n];a=y[189]w[a]=w[a](r(w,a+1,y[591]))end;n=n+1;end;end;end;return b(cr(),{},l())();end)('25V1O23A1O1F25M25N25N27927A27D27A25K25Q27D25725524I24L25B27G27D25B24Q24P24N24U25K25P27D24O24K24L24O24Q27N27W27A25425B27K24L24S25K25R27X24J24Q25528B27D24M28224J25K25L27D24K25427O27A24V24U24P25A28A28C27A27Q25424G25K25E27X24K25524K25A25B27L27U28Y25N24T27L24V25K25O27D24S24U25B24T24U24L25927V27D25A24L25724Q24O29227H27A25728124N24N29I29K29M27L24T24K28H27A2A92AB25J27D25429M24M29M28227R27T25K25K27D25524U2572AP2AH25A24P28R25N28J25B24O28L25F27P28P28727L28A28425N27L2AI25527N29D24S2542AX25K27C25N21X2BM27D24123V25K24J27D21U1R24526U21Y24Q21526523V25Q21T21B23D1N1T25R1L24T2702151Z21121T26326W1823725I24R22C23B25326S26K24221T1726W21U22425I23L25D22M23Q25G22I25Z21426T21N25G26X2151Q22522N22Q26G21026A21N22I22G25G23G21G25V23N26L26E2681226C1H24726324B22I1I24822125822T23J26V23O22Y22B23N1V26E2351P23C24921E23E1G25325N1A22O26A2AC25N21A23226S23N2BL27D21A2EY27A1H2F125N21D2AV27A1P22G2AP2BM112F42102F725N22V23J25A2ES21023226Z24525K25C27D1A23326923Q1L25R22J24R26A24T2FF25G27D1M23I26L23M1525E22024P26024R21F22H1G23823C25K26227D1N22W26O25Y1026021S25426D24Q21E23F1M23423E24J23425K26627D1G23I26U24921625H22J27127124N21E22I1O23F23224B23E25M24B21X21Y25K25D27D1423826F2451Z26K2GU26F24Q25K25V2HV22X27024321425Q22I27125K24H21921S1B21W23524M23525K23Y22Y22422121A2AY2A025N1L23727023M1Z25K24A27D2162FU23Q21H2401626Q26X24V21I111U23I22X24N22O25R23T22I21Y22F1Y25024623G1M24O26723E1K26024925F25C1W22X24C2191X24326Q24K21825W24L1Z26W23C23R22A24Y24822L23J111I1Z24N1L25P22E21N21D24Q22B21V25726I24923N23W22Z24722T26Q25B25121I22V26X25K2AG27A1S21Q26E26423223O1426S24U25922Z1B28M27D22V21625K26527D1822026225422U25Q22425A26C24Q21421T1U21J23F24U23G25D2492251P152H52FS22725D24M22U26022424S27224R21E22J22H23523G24M23D25K2481J132AQ27D2A627A1G23E26K25A21325O22B29S27A1A23826W24F1Z2612AZ1D23026Z24321G2N925N1123826223L2142FY2FQ27D1I2I823K21326622423X26F25721E2NW2O62702O82OA25K25I27D23D23427024A21623U22525426L24V21G21V1D25K2B52NJ23226W24721425H21S28G2I627A1C2382512421Z25O22024O26F25622P22N1L23A22S24Q22V23X24A21Y22E22321126Y2OL2ON2OP2OR23U22H24V26A2541W22J1S2I527D2PD25123Q21G25F22N25827324R2PN2PP2PR2PT2PV2PX2PZ2GL2Q22OQ2OS2Q62Q82QA1S22V23525622U25K25U2QE2PE2QH2QJ2QL24R22Y1F1923F23G25223426726422722422821B25B2NP2OM27A2OO2QX23U22224Y26C25521B2222LR2PB25N2QF24521525H22M24Z26M2582QO2PQ2PS2PU2PW2PY2Q02FR2RV2Q32OS2C026D2GF2LW2R925124921D25G22424V24R25A2192261023623326N23725E23T21Z21Z142LD2QW2Q421T24Y26E24N21022K25K2642SV24E21525J2GU26W26M21D21V1O23223C25921H25N24322K22521T22O2Q12RV23126Y24F1Y2OT2OV2OX2OZ25K2632FS2P42P62P825526124H21A22J21523A2332AU2RU25N23D2UD2UF2Q52Q72Q92QB2QV2UC2UE2UG2QZ2V72R22R42R62V02V22VB2RY2S02S22S42O42VA2V42SR2ST2LE2V12V32UG2TJ2TL2TN2UB2V12OP2452192UH2OW2OY2P026827D1R23826825Y21826722I24P24R24P2UU22H23G23824S23I2N31921X22F21A25226023G1R24J23V21F1M26224125O26M22P21P23W21C1Z24Q26L26Z2W12RW2W42V52R02V82GM2SO2702XJ2VD2R12R32R52XH2W32W52RZ2S12S32LR2SN2W22XP2W52VS21F2TG2XO2XJ2VY2TM2TO2VU23D23D26S2482M32242KZ25721922J25K24R2WB2WD25Y21A25N22N25424R24S2102221N21J22X24Q23C26524322J21U22F2142532O11H24N25H21M1I25V26225O25L1J22Q2HZ21124O26G24V21L24M24M21N255182412262522KK2371Y21D2FA1G2631D22Y23C24Z1P22925426O25P25W25C22U23P22W26C26Z24U23E23E26V21O25Q1M22N25I25922221Q26I2352431523G1B28G2HU27A22Q2GP2S925G22524U24R2432Y82V12YG2YI26222J25027124V21H2222UL2ON311M22U311O311Q311S2222RH22W258311K2YF2YH22U25L21Y24Y27024G21022L2HT311W31282SB2SD31252Y231272YI25E21Y24W26A2MV25K25H2ON23B26Y24421025V1925526M24O1W22I1L22R2V925N2H826D24A21B25L2GC26M24Q1I22J1M22T23G24O2H429J27A1W23I26P23L21326022I2W11123B2I921426622P2582GW2192VO2G427A2G626X24321I2HD24P26724H1D21S1R23922S312V312X312Z31311924T26X24N21J2261D23625K261314S31303132314W314Y315023623124J22O266314R2RV312Y3156192M624H21I21T1S22T3126315I314U312C312E312G2VI315S313225126C24J2142221A313B23D22W27123N21E25Q2SR26M2112221V23A22W24J22P31663168316A316C24Q26D2TX22L1G22P23G2572H42H62RV316N316B316D21D316T316V316X26524022K228316M31693172316Q26M1Y21S1M22O2372PS25K314C2V13171316P316R21A22G1N2T7311V3170317D317R26M21521S1K23I23C31252UM315H26S24121025N22225224R24Q2102211O22Q2352AU31882V123B318A318C318E2T221F21Y1F23A2Z425K267312X318R318D318F25A318V318X2Z422T25D2JM317X318P3193318T24T21A21S1E23D2U2315G319E318B319424R315M315O315Q317O23D318Q319P318T24M21A21U1G23623225K2602ON23J26O23P21E26021Y24K26E24V21D1F1T2362MD22O25D23S2P127D1023E26E2431M25N22J2AY31A72RV31A931AB31AD31AF31AH2RG22T2382552382612492TP31A831AA31AC31AE31AG31AI1931B831BA31BC22H2272282OF31B02V131B231BH31B531AI1Q23C23625423F2IO316631BV31B431BJ1F317J317L22V315331BF31B331BI31B61H23C23424M234315F318O23D23326F2HB25I2T0318G318I318K318M25K23L2J42J62J82JA2JC2JE2JG2JI2JK2JM2JO2JQ2JS2JU2JW2JY2K02K22K42K62K82KA2KC2KE22Z24A22E24P24821Z23I21Q2341F23T22523W1K21A21624R1G22G2S031AP23W23B23P319D31CP31CR21631CT2T13196318W318Y2I431912RV31CQ31CS31CU31EJ319824Q319A319C31CO31EP31EG31CU319H319J319L29R312W31EO31EF31EH319R315N315P317N2ON31EY31F831A031A231A431662I82W431AD24X26F316E316G316I316K31CZ31D12FV31D32JB2JD2JF2JH2JJ2JL2JN2JP2JR2JT2JV2JX2JZ2K12K32K52K72K92KB2KD26W31DP31DR31DT31DV31DX31DZ31E121421D24N1N21Y25826N23L25K31EA31EC2XN2V131FK21931FM31FO3174316U316W316Y2ON31H231H4316S31H731773179317B31H023D31HB21Y31FN317G317I317K317M319V31HK31HM317T317V23331ED31HS31FO31823184318631ED23C27124F21I25J22024Z31CV318J318L2AU23M31FU2J72J931FX31D631G031D931G331DC31G631DF31G931DI31GC31DL31GF31DO31DQ31DS31DU31DW31DY31E01K21L21C24T1C22H24Y26L25F23U245313A31CO31I431I631I831IA31ES31EL31902ON31JG31I731I9318U31EK3199319B314031JF31I531JP31IA31F1319K319M31F52V131JO31JI31F9319T31FC2RV31K531JQ31FG31A331A531K323D22R26K24A1Z25U313331353137313931GX31IG31FW31D531FZ31D831G231DB31G531DE31G831DH31GB31DK31GE31DN31GH31IX31GK31J031GN1K1Y1X24O1P22427126N24823R319N31KH31KJ31KL314V314X314Z315131CD2RV31KI31KK31KM315831LS315B315D315F31KG31LW31LP315L31FA315Q2YE31M531KM315U312F2XH31MB1931603162316431K92V123526Y23P21B25N21T31LI24R2132261C23F22X25K23N31KS31II31KU31D731G131DA31G431DD31G731DG31GA31DJ31GD31DM31GG31GI31IY31GL31J131E121C21J2531L22D25724T23L24331GW319V31MN31MP31MR27126Z25821422H1O22R2GK31BT23D31NX31MQ31MS31O131O331O523C25B23D26023Z31ML31O931MO31OB27126G2UT317U317W2VI31OA31NZ2XZ2VO31KG31OV31MS26B24H21821Y1S314Q319V23H26F2431Z25S31LH26N31MU31MW31MY31OL31P931PB31PD31O031O231O431O631A62ON31PK31PC31LH31OD31PP31OG31OI31OK31P831PA31PU31OP31OR31HV2XH31PT31PM31OX2LR31KG31Q831LH31P231P431P631662FN24021G25R22424N26M31FP316H316J316L31HI31QJ31QL31QN31QP31H6317631H92RV31QV31QM31QO31HD31R03178317A31QI26Z31QK31R431QP317H31CA31HQ2ON31R331QX26M31HU317W31CO31RJ31R531I03185312531KG23C26F24721H25E31KN31363138313A31RU31RW31RY31LQ315931LT315431KA31S531RZ31LZ315A315C315E31LM31RV31RX31RZ31M731K82YE31SJ31S631MD315W31JN31SC31MH316131633165319V23D26K31QK25H21Z31MT31MV31MX31MZ2VU2NY31PA31AW318E26I24P2W0313S2NX2HX2431126721S312H27A152322702KD26022N25026G24R29327D31CI31Q225G23224O2ER2IV1422X26S24B2J12BB1623I314F21E25R25K23R2YR26823O22U318D2M625721B2MX23J23G25821H25R2492242251521125A2442311724J25R2381H26023Q25O26C21422W2441Z21K24V26N24M23I26H24X21426V23G24022124P23U1923921723J21J24B21T25E22L21H21626C31LG24J26N23M23Z24422Z23U23A28G31SZ31T121G31T331PN31OE31PQ31O831T031T231T431PW31OF31OH31OJ31OL31WS31WM31T431OQ31RM31HW2VI31X031WN31QA31LM31X731T431QF31P5314Q31KG22W26924321325I31S031KP31S32ON31XH31XJ31XL31SE31S931XP31XI31XK31S731M031SG31M331XV31XR315K26C319S31FB2YE31XQ31XX31SR2XH31Y931XL31MI31SX31RA24F21425C2M527331QQ31FR31QT31RI26Z31YI31YK25A31YM31QZ31H82ML31R231YR31YJ31YL31R631H831R831HH31YQ31YS31Z231RF31HP31CC319V2FN31Z831YU31RL31OS31HW31RO31Z031YT31YM31RR31I2319V23326Y2411X31CT31T531PH31MZ2V01D22Z26924F2152D524F27225621H21S1N2W1219320132032D525B32073209320B31ZQ31ZS31ZU31PV31PO31OF31PR31EO320M31ZV31WV31O631WX31Q031FD320T31LH31X331ZI2XH31ZR31ZT31ZV31X931KG3215320N27131XD31QH31Y82IZ2YJ2YL2YN312622W321G311Z311R311T31ED321L23M311Y311P321O312223F3124321K321G312A31YB311A317P321G312K2SE2VP3224321S312Q312S312U31KG2FN31MP26631XM31S231LM322F21B322H31XT315231SA2V1322L322N31LR31SF31M2322K26Z322G31Y431Y631M931YQ322Z31YB2VI322S31SV31MJ31652VI31CQ31I62W62UJ2P0323B26F323D2XR2XM31FD323I21I2XK2VE2XT2VH323M323D2XY2VN2Y1323T323O2Y63126323C323O2YB2W031HR26O23K1Z2BN31ZW31T7319N1322325S25Y14313223Z26I253192261V23131OL22X3247324921X31WO31PX320R31H1324T324A320V31PY31WY32463248324A321231Q62VI324S3256324V321831HA3250324V321D314Q2TQ2NA23826V24A21525U23F25426Z24I21422431OF24R21Y2612Z821U21U2FF32231922525G25C23527323F2492562702R72G52G72G92GB24P2CN21E22K1O23423C24F22V25E23W22422922921425A2BS29D1K23E26D311J2V021722W25123N21H25F21Z25624R23Z1H22Y2FA29427A21E2O72O922424X26Q31AQ311B31A924021326721X2AY2BM22Q2FG21C313V2NW22P23H26R25I23A24A1P2NI25N21931U92481X31UI31TH328726R25D23I328C328E21N31UF325O265328623I24G2401W328Q2IV211324S2IA328621724L328Z328Q29D1W23B268311J328L3297328A25O227328E21E23226F23Q216328K27D22P23D24T328A25K2F329D21E23626Z24D32863288329I329K2IV329C26S2W4329624L328A329127D21H2IY2J032A426R328Z329J2ES1X22Q2YH32AC32AM329K2V022Q23626E25Y1726Y230271272259312F2FA29D21I23E26Q31EC2P225N324E324G1J26X23031OK25X27D21N2YS313Y31LH26D315M31B731B931BB24921X22I151Y24Z24923G1724V25H2Y72BM2GK2V023I23H26Y24821E2VL26F24H21F1I22M31JM27A22T21125Q2531M26N1923S26023V1J23621X21K23F24G23F26131RZ2FG32CO25Q31TZ27A1V213256240320422L26B31TY325K25N32D832CR32CT23X26123R1N23221922A21S26R21M2U521Z22F1R316L2S632DM32CS1932DP32DR32DT22A21I24221523M2PV22522923J2XG32E432CP2511923R22W23X25Q26M1E23C21J22A22732ED32EF21Y32EH32EJ31YY32DL32CP32DN1924226423K1423H21021721E24P23E25F23S1N2N625Y27D26K26T24023N23O23Q23M23Y24826J23O23X26J23U24B23Y21N22C22B21X24626V26C2AA27M26T26J25K32BL27A32FP24024924Q24Y23N24Q24T24X26J23X24U24M24P24K24Y32G522H22F32G932GB27Z25B32GE327T25N24424D23Y24924823M23O31EC2IV24N24K25824U28G29D24423Y23P24D2BM223317U1F23U2BP27A21N26S2ES25828E2BG27D24V25A24M2AU31TH24424429G24U24Z31TO32H824424L24U25832ID32IF32IA24429W24I25528Q32BD32IB24I32IQ32IS328E32IV25B32HL32IG32IB25B2B728824S32HX25N26U327129K24Q2AK32IG23W29M24832HL25924I24O24U32J926T23V32J926S2BS2BB25428E2AS29H322325924Q25724U29P29A25B24Y2NW24B24N32GM32HL28Q2Y223R24K2A332KA32KC25532J923Z32JR27E25N22332KN32J923Y32KO27E22332KU25K25T27D24C24J24I32J124N24I28623X29U24O29A27Z25423U2AS32L924L24L32K82VU32JH25B32L232L424U32L62862W123S24Q24L23U25B27Q29Y24E2BE32HX1B24032KV27D22324732M627A23V24632MA27A24532ME1B32MG32HX22324432ME26J24R32ME22332MP32HX21732MS32KP23V24Q32ME22Z32MY32J924P32ME2WK32MH32N332HX26J24O32MQ32NA32MT32NC32MW24V32MZ32NG32N824U32MZ32NK32N824T32MZ32NO32N824S32MZ32NS32HX24R2X132N824I32ME21732NZ32HX22Z24H32N424G32MN24N32N432O932O332OB32KP21732OD27E26J24M32N432OJ32O332OL32KP25N24L32N432OQ32M332OS32KP26J24K32MQ32OX32MT32OZ32OV25732ME24B32P332MK32P632KP23F32P827E21732PB27D26325632ME23V32PH32HX25732PK32KP22Z32PN27E1R32PQ27E25532ME26Z32PV32NV32PY32KP22J32Q027E311832ME2ZY32MN25432P432Q932MK32QB32P932QD32PC32QF32PF25B32PI32QJ32PL32QL32PO32QN32PR32QP27E327032HX26Z32QT32KP2T232ME22J32QW32Q432R132BM32R327A26J25932P432R832MK32RA32P932RC32PR32RE32BM32RG27A26325832PW32RL32HX24B32RN32KP25732RQ27E22J32RT27D23F32RW27A1R32RZ25N21N32S226324Z32PW32S732RO32S932RR32SB32RU32SD32RX32SF32S032SH32S332SJ26J24X32P424W32MQ25332ME23F25232O025132ME25F22332ME25V32SZ32HX26B32T232KP26R32T527E23N32T827D24332TB27A24J32TE25N24Z32TH21V32TH22B32TH22R32TH23732TH324E32ME1Z32TH25F22232ME26B32TY32HX23N32U132KP24J32U427E21V32U727D22B32UA27A22R32UD25N23732UG1332UG1J32UG1Z32UG21F32UG25F22132T032UT32T332UV32T632UX32T932UZ32TC32V132TF32V332TI32V521V32V522B32V522R32V51332V51Z32V525F22032TZ32VJ32U232VJ31ML32L732KJ24Y32HL23U2A432HJ24U24V32HX24J32VN2IV25429W25824L313B23O24L23M28024K24M2B923Q24U25425424Q29L25K21V27D32VT24Q25426F26J32L426J32K232K328F25426J25B32I332WY24J24U32X129732WF32OW24T32WT24S27Z24Y26J28E25932X324P24U24T24Q2A429P32OI24U32WQ32LV24V32X132X32AI24L32WH32LC32XV32N929832IS2B932X429824S24J32OI32XC32XH32Y228F32X332ID25424O27K24P2AN32XC32IE32YF25A24O24I2822B926D2ES24P24Y32J122V27D2BM2FG27032Z027E28N27D22R32OO32OO26Z27C32J927A32Z325N2ES32IJ24Z27N25W27D32Z024T25A32YE28229626J26U26J2AI32YF29M26J32GW29724L24I28T32R727027E2V025N1432Z627E31SA28N32J92N7330827A28C29D27E330H2B527925P25G25M27W330K27B25N25R21I27D330Q25N31A727H32ZC27E25P1X25N28N27H27928N330T27D331627A2263314331E32Z631A728N331027E32Z827A32ZA25L32ZC32J932HZ2NW2AI32WZ24K24K24G331127E22E330E332132OV330832ZA332232YX3326332529D331Q26S332532ZA2BS26H32L132X032IE29X25B24N32XC32YB26J24Y29832WY25524Y32Y232J532ZS32K427E26N27E32Z5332126124V331E2BM333432ZD331F25N25H26P25M28N31912BM331927A333G333B333D333F330R279333I25N333K26J1O330S32KP330D333T25N331B27F27D25P21Y333V2AG27927H333Q334627A22O3339330D331032WL2BB330F27D26J21S25N27W2BB330D27D29J2BM2IV26J27A29J31TH333X32ZB333A334P331M25N31TH330E334H27D330H2AQ330L1127D2TQ279333P330U27A335D2F8332732OO333C333E25N332G333H335G335O330R333Y330H333927A335M28N32FN333P330S335R3360334B334D27D334F333Z32KP29D26J21533692IV333X26D331E32ZC334P1P331A32Z6333Q335I330X3339331J27D331L330R32OO25L334O330D2BJ2AY29D2B328F332D32OE32P132KP331R32GH25N23Y24Z24O32ZM32X32AK32ZS32IR32WQ32WZ32L732WR25424L26K25B26J24B24824E336H27D26C27E25E3325333W3326335V32OH334I332A32OO2IV32OO334U336E336732OO33563309334V335W25N31SA2B529D31SA2942IV28Y29J2UM27C336L2FR338927E336L2AG322332MW25M2FR32ZC331025S334M25N32232Y225N339627W2Y2322325R25F25M29J2FR338T3353333A330933352B5338929J327L32Z633382HU338P26E25N2B526A335T24725N2AG2Y2338924C25M2AG2VU2BM338B33AA336M32KP2OM3381333B333V330E317O330E2UM339A32OO2GM33AP32KP312W31H0331032KL312W2BB31K325N26C25M2G4338427E2UM335433AQ33A4333333BA33AL338J338D2AR33B3339727A33AM24025M2OM317O33AW33BM33BI25N330533962AQ2Y22V0339G25M2B52LX27C23R33BZ339N338X25N294335127D26I33C4339T32KP26E33C4330E336U32ZA32IG3375337832I029D32K732K32AZ32B9325N1Z32J92BR2BT2BV2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2ER29D32ZF28327D21D323C21425P328E2BD32HL27N337Y27A23N32X324V330032WR25B26I26J33ET32ZW24Y29W32WG32VW32XS26J29P32YF33F332J132XR27Y32XV27Q27M2GV32ZC2VU32H732J528632J733CL27E331R29D29F24L29H2IV27J27L32ZH27D21I23731AA1Z23U22024V31QP21E318323621P24M23F26624D21Z21Y32BZ2JR23F172ZG1W1433CV2BS2BU27A2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ2FG2AS25732HS32HU23U2F421X2AZ2A232XK24N27E23S3331332226125O25M335E33C6336S27E32JR331733BF338J3335331I27E33C333C927E29J2AQ33J5333828C330D25R339Y28N26S336V33C327W32ZA26J1C33972BB338433B832Z632BD330E2B532BD338W339732BD32ZC25P254330O25N33JG335Q27D33K4338J33IR27W338922G339M33IV338K33BR338N339M27A31SA2HU33JS338H322332ZC26J2TQ334W27D339T3338294339026V339I33C7330826G33K227E333733K9336927D33KC29J33KE27A2B52Y233KH31TH33KK339Z32OO29J33KO334J33KR33KI33L033KJ333533KW27E33KY339S33L133L3335K336227D2GM27933IQ33K22IV33K033K226T336V33LZ27A33M833M233L633KB33KD339U33LC33KG27A29433LG27A33KL33LJ339833IZ33KQ339M31TH33KU33LR33MQ27D33LU33LP32OO33L2335633L533M427E33L933C533KJ33MI33LE33MK33LO33LH33KM339M33LL32R633LN33MU27D33KV33MX27A33MZ33CD27E33N232KP33K527A26L336V33CI336N339H28N29427C1333N827E331H33O525N33NY32OO33A933LY33NT32OO33FR27P33F327U2BB33EJ323I33EL33GQ33CX33GT33CZ33GW33D233GZ33D533H233D833H533DB33H833DE33HB33DH33HE33DK33HH33DN33HK33DQ33HN33DT33HQ33DW33HT33DZ33HW33E233HZ33E533I233E833I533EB33I831U627I28833FZ27A33G133G333G533G726M33G91K33GB33GD33GF33GH33GJ24633GL33GN2TF330D33IB33ID1N32HV33IG25K23X27D24F32X226J23W2AS28226J23R25A24Q32FY24P32ZL32ZN32XX26J23Z32I725728632HL32GS32IR24U26P26J23Q32XC23X24Q24I24N25A2AS32WY24K33QY33R026J32ZK32ZM28132J525527E23Y331Y33BB333O336W332633J232OO31SA2AQ32ZC28Y27933IN33MD25M27H334P33JI332132KL334N335733IW33S7333A331033SA32ZA333829J338M339P33L733J033L0334H33BL27W339T33JZ330N27H33S53397333Q33SZ25N33C333JW32PU33SG338P3342330N27A33SZ3348335R33SZ33M327H335433KC33JJ33MH339M32BD33KF2IV33KH338F33SU33MR2TQ33SD33NC33LQ33LI33KX33K233NF27A33L2338W33N433TH33N6339733SK338H33NB33LI33TP33NC33TR33N033KP33TU33BR33MV33TY33LT33U033LW33U43357335R2H633S633U627A33M627H23T33M9333Q33UY33UT33LO25N33TJ33M9338G33TM33NL33MI33UD33SR338E33UG33LM33JN33KT33NL33SO33TZ330P33UO33OE33KJ33IR33UU27A33V533U9339M33UB339Q33V933VC32KP33TS334Z33NI33VG33TW33SQ2B533VK33LI32Z633U333VN33MA25N26933NX32Z933NZ33IS33U827A33OA33NT24233IO332233C333AI23133O833U233WI33L427E21Q33V632OO33WS33IV27D22Q33WZ333733J133V633J733WZ33TX28C33S233JE33O9330R33M327W334P32KL334R33AF32MB33K2339433J333KZ33SK33SO33SN33L033TP33352HU33SS33KZ33NH334M330N27W2WA27933SM335R33Y533K833K2335433XK33M93389331D33JU336N335R26B33XG33IR2FR336K33BA339033SF339333IZ33T333OC33XS33BS33W833SQ312W33XW25N2G433XZ2AG33BO33T9339225N33YK2792AG333Q33ZA27A33C333YS338A26T33Z82Y233CD33C32AG33J525N336L2OM33YQ27D23B25N2FR2V02BM331233972R833IY333Q340233WC26Z33JH33XO32Z626J33ZJ33TV33N033YU33X932Z632KL330W33SP25N33ZV33VL3352330F33O033ZW330R25P337Y331P335W24I33SE32Z6340X33W132OO341033XA334M337Y3359330R32Z3341333B52BC33OD33VI333V2BP29J334032KP333827W33XD333V24C33YL33C433XJ25M33O2334Q33SF2B533XP27D33C3341T33RZ33XX33AK33SQ338V341E2AG33XZ2942VU33SW33C431D0279294333Q342D335J341W330832KL342033V324B33LI340V330F335R341O33S62B5341R342M335432JR342J341133YU342M339O33MQ33TN3335342533TX342727E33BL342933IZ330M33C4342T33L0333Q343H33ZQ33LI33ZP342L33M93354342O343033UZ339H28C26V33WF340O33OB2N822J27D32M133R32B833F6332W32I632I833RL27033QV33RO29626F25I319B29933F832XF332T32WY24I2AK32WQ32WS27J24K32XF32XR24S33QN32J125526D344G33QJ32X327Y33012AS28J29B32XR24K24P32YE33RF32X332XQ33RH28W24J344F25D23Z32XI332U28932WT2A432WT32LY32GU25725B32WP32X133QO25832WO33F824L32Y424J337W34313332332133WL33WB331S29M24J331V331X33YT346633CH33WG32Z6336J29D34482AU24F27D26H23M337R337M3461337R32X232X532WX32WZ33QO28J24G32X332L328629624Y32WQ28V346V32L733RP32XC346Z337R347132X6346W24K32WF26D26H26J26E26J23L28P2AT32Y624827Q32L624L27E33JS23833263326338B343Z33OE33AI33RY332433M933X2342Q33WK346I33RW343Y32BM32I026K341Y24U24Q347232XR23T29627Z330032X325926Z26D27032ZS32Y032JN33R732HI24Q24V33FN2B933J633B634813322348333WB349833WW33222BM2BP346827E336F33FW33PR332B33IA2AT33QC33QE339T32WC32YF32HJ24Q32XF27E33B0346G339U33IR33IT33UV33K133ZB33UZ335R334A33M334A233ZF335N3308340B335N341X25N33MS3487330D33JA342325N33KY331833LW32HX33NU33RV3349343X341433M931FT27A23M32X8332Q25A32WT33RG2AI24U332V347432XN32WG32WI32XO332P332R332O344R32YH27S347D332T332V33RI346M344A344C32ZO33RQ340Y32UE332633WS33AI33CF33AI349H27D26F2N832IU32HA32HC32HE32HG27D32HI32HK32KL32Z62BS31TH29L29A24L2AA2ES2AE349M2Y2337E2552AS27M347W32JO32OO2672BS2Y234CS28T33FT32VW3325311K331T2AK27Q27Q27S27U349K33FY32J925V2BS33QA349O32M733IE2ES32IE32L432J925Z32ME34AH34DO26H34DO26N34DO26L34DO26B34DO26932JC27A32I228232J926F34DO26D34DO26Z34E025N346M33II2A324N32J926Y34DO26X34DO26W2BS339T28729X28U29X29Z28I2822B332J927334DO27234DO27134DO27034DO26R34DO26Q34DO26P34DO26O34DO26V2BS31K324932JM32Y632W227Z29L32GW24P29D334O29D34CL34CD32J925F34CE2A734CH2AA32J92632BS34DA27M27E31EN34BU33WP33AI33M627A334A342R27D34GB33C3348F334J33IC348433BE341833RW33IV338B34AJ330833X2338333O6340834GG32R61U336N33VX33IY32KP34873385336I33XM34H1349C32Z7348D3469344127A3443255332S24I344634BN33RK33RM33QW344E344G23T344I2LO32HL347D344N34BD344Q297344T26J344V348K344X344Z25D345132XZ345432GU33RC32IJ3458345A34CO345D33FU345F32Y5345I345K24T345M24S345O24N345Q32J132I8345U337K32X0345Y32WX29P34623464339N349Z32Z634C0343Y32GG27D337C337E2AI32XN337I25534IS337M32L7337P337R337T337V32Z233WO346734H934JJ27F346L33R025K25Z27D23M24M26J25529U32ZZ345N298337R24K32X8348R345Z32X224N257347Y27E348034H7340A34883485332134H2343Z2BM348A33OD34J232KQ2BM1H34KD33TL34AA338D34GR338I338A3341334E32OO28C33AI33S133YT33C334L1340A33ZJ330G2N833Z72AQ33AH333V333Q34LD333R341D33UV341633272N731UK3322341333X23413332534L533O534AE34L9334I33UV2YQ28C3405335F27D340533YU33XC34L725M34LW33SP33M628C1G34A62H7340S2YQ27A23W34AT335R34MJ33M2333528C334H33T434KW349627H33T5341K33BR33JD333V33RS339L342V330822A33LI34KK334J33ZJ33YH338H27D26X341S34LU33NC339T33842HU33ZP33MN33NN33JQ339K34KE340R2Y233NF2942Y233KP33ZJ2HU339T339T25H22325M2HU34N033MQ333Q34O325P23P33MQ34O3338L335R34O333M32FR339A33ZN34AM33XQ2OM33T5340L340R33ZY33NL33YM33BC34AB34GB32OV33ZJ33AE27A2V033MS34OW33AJ33TX312W33AM33KY2AG33B033NR33Z8349D33WC26W34082FR338F34AH33ZJ34OF32PF27E26Y33Z8349F33UQ27D26O330R34O534PR336L27A21G21G28N25P34MH25N33UY2AQ34PW25R34PU25N34PW34PY34Q023Z333934PW25P340732R6330R34Q4343U34AH34PR335R34K9330L33K12A134ME34QQ34MN333V34MQ33SG33ZP341H340K341E340D34MY28C24K336V336L34N232Z634N4340J33SI34ND34GN24Y34ND339T33JW34NI33212HU322334NM3414338B34PI27A31H033VH34NT33C634NW32Z634NZ34O125N34R42792HU333Q34S0334M34O82HU34S434OB28O341P34RP34OS34OI341Y33BQ34OL33ZV33ZX33LY34OE34OR33YU34OT32OH34OV34OR322Q34OZ34OR31K3333834P333UM34P633LW33AP34AS2YQ34M232TF34QL34SA333P34Q634Q8334M34Q033IL34Q331QL34T934PX34TB27D347X34TE34QE27D34O827934QI34M825N34TO334M34QP25N32Z534AS34TX33SQ34MP33XQ33S8330834QY34MV333534R1339Y28C34BW34AB343S32OH34RE34N934QZ33L034NJ33L0339T33JQ2HU33JK34NK322331BT330V33NN34RB343334N734RF27D34G5343F2B521Z330R342F335R34V233C233C434GN34N833YY2IV25L24W34ND2BP33C334UN34M734RK27D316Z27A33BL33W634L434VF34M7294339T2LX33UV330N2B534UB34V427D34UB33M333LD33XQ342F330834VH34UH27A33ZV34VP343Y34W334OR33M62B522C34QR25N34WI34V734R733MP34UG3311334429J34WL33LI333Q34WT34WE2VU343234RN33ZJ34VT335C33VF34X2335X341E2FR34P434ND33AS33WU33KM34AS344134T434WK34T627A34UB34Q527D34TA34PZ27D22W34QC34TF34XM34TH34XO27A23234XR34TM34E134QH31QL34QJ25834XI313C33XG34MO33BR33YU34U332Z634U5339U34U734MX34U925N34KQ34WM34LU34VA32BD330H341Z34MS33BG34X533V3342Z33SH34UW34UG2S634WZ33JK34X133N02R834VW33C41B34V333WC34Z634YK34V933C434YN336734VE294331034YU34AG34AE34YX34W534X034UX27A32L034Z42B534YJ343I335R34ZT34WE34OG34ND341B34W834SH33UL34WD33IR2B52VU34WG25N333U34AS350A34UC34YQ338H34WP334234WR3509330R34S927A350C34WX34ZM34Z034ZO339B34X433N034SV343733Z233UM34NS33LW34XD34PO27A1F34Y5350C333Q34ZT34XL34PV34XU34Q01S34XR351934Q7351B2O534XY34QF25N31UO34TP34Y234TR351M34AB341B34PG34TR29D34JS34A334TR21C34WJ351Z34QT34U134SF34YB33MP34MU34YE33W3330S34YH21D341P2B532FN34LJ34UI330R2N73413330E341333ZP34LN33V327E34JS343S339T350821E34WJ352V33S62HU34ZY2FR350033OC35022HU33AB34OP34RY34WY33ZG34ZN34SC337A33MS34SC350V33YX34X934SJ33W934RY34PA333Q21N34Y521F336V1W352P330I34QJ31MQ34V734M633ZI351U33XM34MB25N25Y33WV33WC3544339L33JB34N3341F34VQ330Z340A343W352727A33VB340D341U34UO33MT27D32ZI32KP33VQ34RB27W33JQ27A34PL33TK343Y3343333V35473369333Q355033XH340R34SF33SM34W733C43502340N33V633SA33U125N354V33M934AS26233WI3554350733K127W355034GC27A355333L6353933XR34M733KS34QG33W2355X34P133SQ29434X933LV353K33N33512338J33WV34LT34ZB34M926I334233K128C2503545333Q356I34QO27C24B356J335R356O353X330E33QY354027A332G354P34NE338C354H33VD34GN33UV33BR356E32KP33XL34KX354M33U2338833LO331034N4341I354R34ZN340D333027D33BL3523339N34MR34ZB354G25N357627A357F348933XQ354S3308355G34PN34SF34PF32R623W33K22BB356X34MT3321340J34H334UG26M33VD33JY350H333V356L33T0335R358J355434ZY355732Z633C333VW32Z6340M33YY34VG33UN32Z6358033LY33T1355K355T356F33K2358J355Q25N358M3593355634ZN356033NW355Z33LO353G356333UM356533N133LX343Y333Q23Z33WI356K356A34TR34GN34R434M93384354D3579357R357T334234RN35742BB348I336A33BR34RB341I34SP33T727D33YK33BG34M9338934N434L6343134MR34AD33ZJ357R3588343L33XI354A354W333A34AE340D335433C3357834OU33KZ31TH33A1357L33SG31TH357H354T355F33K2358134AB358334AH3585340D35AP338H351S34N534NO34UG33WE33VZ33YY33JZ334427W358J33TD27D359933K2358O34SE350D355A358V357X33YY32KP358Z359N335R34A433YA27W355M3595356P35BV359233K2355U35AZ35AB35602WA359F31TH359H350X33MY33KZ33NQ27D33NS353M335R25B33WV34KN33FK322323W25A24I23R24I24P25528F32K834VM23O24P24H24U32LB25433QJ28232LU24L23T24U248349V34D132OO23V34DE32WM25724I2NW23Y24L2AN32VW2ES33FT29H34Z325N23X27K29P349335D628624F32IE25B23S32IR24O27T35EC27N322335DD35DF32LB35EL2ES23P32JE27U31H035EO35DG25B35EL35DZ35E132VX32KP32SZ34FV27A34CG29O29Q27E35BN27A23933IP334Z33AC334Z34AG34LA34AD34KY35FK34JJ336J334J35FI34BT34GO333A33M5334Z348I34AS35FX34AB330B340A27134H4357433N9333935FH33663411338B33J8341U355Y35GC34LX34QK35G933YY338B335V35CT34AP341133M628N339634AS35GR33YA341732R622L35GI33KP35FM34NA35GH35GF342335GB338I33ZT28N34KZ351X27933NW34AS35HC34TU335N35HE359735HE33M335GV34AH1K35GY34L0356T338627D33AS35H3336B35H035H4334Z330D338933O733X2331D34KI27D35I1330834J225L339T35E329G32JG35D435D635D835DA32F435EX35DH35DJ35EG32LV35DN35DP344T326G27A24F28F34CG25435EL35EE32ZG35EH25535EJ24U35ER330D23U35DW32IG35IJ35EZ347B35ES35EU32W635DE35EY35F035E034D829H33ER25N33F133EV32XR32L433EZ33F132YT33F42AI32XR32WZ32X333F9332T345T33F633FE28632LV345U34IY34G525N25A34983381338B34AA333735FR355Y34GP35KH333A35HV35G433SP35FT33JZ35FQ34MS33JQ27935H935HF33M234WJ315433S6348726J35GX35KI35GH348735KL3487334T35KG35C43352348B336Q34H034H834GV27B334X32BD23N32I732LV24K3300328E33ET32XK32WZ34D2339T23S32JX332K32J234VV35E729G23X32IR28635LV33RD24V32LO2B323M32LE32J923U34G133PQ33FY27E34RR34J035B034AR34UW34AA32ZC335M34LC34MK27D34LD34AE32HX336B24233WI334S35KQ331J338434NJ35H5330D338F35KT33YT24T33RV34L0335R2G427C34SO34CU35NA32OO31A735LE32KP34J225M318O328E23S24K32HI25526W2NW24T29724M23N24832A335D235IE35D735D9332T35II35JF35IK32I335DL35IO35DQ35F332KW35MD2FG35J635DX330D35LK34CT32KP23T35DU27A35DP35CY35F435OO2AZ24D32XK25A27U32BD33FM2B828932DA25N35EE32JE35NQ35NS32J923S35ME33TB35NR29632YS32YU24U27E34IY26533AI34LI348E332135HL32Z635N735GO35C9334U34AS35PV33YA34AA26J1635NH32ZC330A338I35KO34BT34LA354L35H333JW35L335Q635G535L4333A33MM35GI35N435Q7334I354L34M933NF35HU35KQ35H32BB35QJ33W431SA3549355Y359W357C354L357R33ZT35AG35KQ34M935QS35HR27A33AS3361330E338134A934OR34AE331J330533IX34YV34SF35G1353Z348731K3354Y27933WE3403335R35RR351T32HX34OY33ZJ34AA317O333Q34C235NE34AW333J35NH32KP35NJ33O835NM29D2ES24S35JD31TH23N32LY25732LM32MK35PB32YZ32Z134US32Z433IP33IR343Y33MS35PO33YU34GR35RF335027E33CB343127E33CF332234KN336J322323L24832HF345K345327U354O25N34HK344D34HE32ZR32ZT2AS337R32ZX348Q3301259330335GD34G6332134GF356T32DK34PA35SV34AW35T033O835T334JL35LG35GH32ZD35P032J62B9328E34HD23M35OE34GJ27D23X32MQ35UH25L33II33RC32IS32J923W2BS32ZC330034DC32MQ35UP32J923N32MQ35UX32J934CV32J923M32MQ35V332J923L34DO34G032MK35V732J923K32MQ35VD34FT34DO23R32MQ35VI32J923Q34DO25N32MQ35VM32J923P32MQ35VS332B32J923O2BS35JL35JN33EW35JQ33F032XG33F332WO35JV33F735JZ33FB35K232LD33FG35K627E34N435SP333334A133M935SX34JN33XN35LE35Q333X7334P25C25M35N335HW338435AJ330834OL35GH357R33JW35R333NV334I336427W3552341P28C335425933SG34G835HQ352933NF357R338F353Y34MX335R35GT34AE29432BD352T330N29435GT34XG35GT333828N339034YP35AM35WT33N02Y235X8330L331328C333K3318335R333K26L246335N272352I33WC35YG356S34LS33SG35Y1357R34WY32KL35X325N26L35YG28C35YJ358K27D35YW33M335XA27E35XC35AA33VD35FL35293305357135FV35A735KP359734PC27935XO33YY35XR34ND35ZE34Y535ZK35XX356134WZ35Y12AQ339T35S0335R35YW340028C35S2331E35S1330R35YD335N23Q35YH333Q360435YK355835WZ34AE357R318O25N35YQ34232IV35YT333V360735YX27A360K35Z033V335Z335S434Y93323352934RR35Z935A235ZB360X33WC23K335T34Z135XQ33Z7294361133IT333Q361733SQ28N322Q35ZP34M735ZR35I53568360K35ZW25N34QB35RS27D361M35YS35YE28N35PI35N7333Q361T351R34AW35AL34M7357R35K8360F29D360H35YU25N361W35X7335R361W360O35XB35XD332135BD338B340D34VM336M35ZA330I333A33JO335R24O361234ND361434Z4294362Q3618362P34Y7331E35LZ361E353Z361G335H3568362835Y725N33A3361N27A363A361Q335N2523605335R363G3608358Q35YM362033SP34YY362333XM360I28C363J360L25N363U362C35Z2362E335535XF340D35E6362K360Z33SE35ZC33WC24W362R35XP33VH362U25N364A362X27D364G361B25N34ZQ34AB35CT34UW3634350S3597363U361K25B34GL333Q364V35HB361R25N22M363H27D3652363K32OO361Z353Z357R351W27A363Q357133NV36263655363V365H363Y27D360Q35XE35Z6340D352F349I34MA35HP3648333Q33KC35ZF3613364D33Y234ND365W34Y5366235ZN337A363235B0364Q35TE333Q365H361K34V635ZZ34V534R5333V33X2336L352532KP25J34TR33ZP35NM35E633FP27A22335VX35UK33FW35UM34TV27E24B35UQ27D35LO35U8349435P32BB35UC35UE330V32PI367132MK367D33OF332C32KP1B367F32KP24A35VN32PI367M32MK367P32OO35V9367I367R32KP24934DO35V132MW367X32MK368132OO34DD346A29N29P25927E22N27E32YW33RU34GV35PM333634NO3487336S35MN27D359E27932L0361U335R368P35PY34AM35XC34KV334135Q9338I35QB35SY33OE35FP35972I6365X33N535QE33M3356033YU34UD34YW33YY33JS32JR33LA343E33Y325N3695339M333Q369L333833W4336Q35T133UV331327935ND366F27D369W33YU33AI33C335RL35B03487339032KL368L365F330R26X365327A36AB33S635RA27A368V332635PQ35QQ338I33AS35L3332736933406362R33KA360Z369933V3358R34YL34ZC35SO33XN369H35GO369J340733Y636AR34QT34GA34GT369S334M369U25N35FZ35YA32FO340836A1335N350Q3487330536A7357W36A9279342H2AQ342G341P36AG25N36AI332236AK35GE338I34P735KM33C935LE33JC335R31N1369636AT369833IR369A36AX34ZB34UG369F33KZ34AG343F27W36C9369M36C8362Z33BJ36BA33O5340027933K736BG27A33K736A035TU36BK34M73487360D36BO34N636BQ25N24P36AC36D936BV368U34AC35PP35A335GI360V36C4343Z36AQ333Q34T3351T36CB33KG36CD36AW34V834M736CH33SF36B2362N369J36DO33Y727D36DO369P34GK27A31BT33IV36CU25N343H36CX36EB36BI36D136A335AB348734UR36D633IZ360I27924X36DB36EP36AF36DE368W35G734NO35H335K835L936C5369133WC24Z36AS365S33VO35B133XQ369C32R634YM36B035VO36CJ369I33K236F336B6333Q36FH33SQ27A362J36E832Z636EA34S436ED34S436D0330E36A234ZN3487363136EL341136EN25N22H36DB36G436ES330H36BY36DG368Y330D35TX36EZ36DL35FN333Q34XF36DP36F533YA36CE36DU353Z36DW27D369G35RJ366027W36GI36E227A36GI36E534YY36FO338E36BD224364W335R36H427C36H135LF34AW35E633FL35U9367734422BE35UD366S25N1B367X366W27I366Y32J924836722AD367A32HY367H33IW36HR32MK36HY34FS367I36I032KP24F34DO34FU32HX23V36I532MK36IA367S32MH36IC32KP24E367Y32PI36IH32MK36IK368435F625N331T346C331W27E331D35WH330E35RD33AC33ZJ331J34ZH33WI34AG35ZN334P256350E35A735QM342335N2338I29D359E2AQ340535BU27A340535HK34Y935XC35BJ357135R033SP33JQ35YR34LA32ZC338P335R335I34ZK33LO32BD34V025N335I34XG335I35ZN34NG335R340534002AQ35KY369X33N934V734UJ34LT350Q34M936A635Y233JC368M35YG2AQ339Y334733WC36KQ35GU36JL34TR332235Z4355Y357R33AS36JS334136JU356833Y936JY31TH36K034VX25N33Y934XG33Y935ZN2VU333Q36KT36KA35YS36H5368M340836KG34TR36KI342336BN36KL34BT360I2AQ23U330R36JH25N36LX33S62AQ334H36JM332636KY35X033SP36C336L2336R33XM333Q33K736L736B036K133K734XG33K735ZN35ZT32WM340S33132AQ26P36LL27A36MS36KF36D135WX35AB34M936D536LT35GG36LV25N24E36LY33WC36N636M236KV36JN336936JP2IV36DJ36MB34L3365E33WC248362R2B536L833Z72B536NL364H35OQ362Z361C356836N936BC333934TT36ED34TT33YU36LO36MY34UW34M936EK36N2342336N4340X36KR333Q36OC36KU36M436KW332136M7338B362135HP362432OO36NI33SP333Q24S36NM36JZ36NP25N36OT36NS36OX36NU25N34VM36OE36MP333936DA363B36DC36MW36FV36LP34M734M936FZ36O936JD36KO363W36N7333Q363X33IR36M3363Z36NC36OK360W363535A736OO338236L43597364J36MG33MI34ZR364F35MR27A364J35ZN2S636PL36P52AQ368936P836QC34AB36OQ32KP34N435HL33JZ33UY28N22136DB36QN35S334UJ319136C036E736MC34J134JM331M366R34KF27D1B36IH36HN2A136HP32OO24D36HS2BC29H367535P22BA36HG32HL36HI32OO36I732MW36R832MK36RL36IN32M336RN32KP24C36II36I836RS32MK36RV36ID32M336RX32KP24334DO32HZ36I836S232MK36S634CD35P4349S297345Y349W27D368B2LT35FF34LI368G36EH35N036GS332736D736LK330R368S36BT368R36DD36G836DF330E36QT35QT34UH36AO35LB36GG335R369L35AV36GK36AV35AX36GN35B036GP36B136GS36CL369K330R36GW36TH36B8340E36H9331136BD369W36ED369Z33WQ36EG36FX333A36KK36A835YS35YW36AE3339333Q36U135RD36SW36EU36SZ35HW36AN36F136AP36T4336T36F4362L36T936F836AY36TD36FD36DY342B27W36B536CO36UE36TL34WY36TN334236BD36BF33WC35FZ36FU355836SL36FA34AF35MS33T636TY36G236BS33WC342H36U5363Z36U736DH35H336C336T234GL3341359736CN36T736UG36DS36TA36F9351T36UK36GR36CK369J36CN36TJ36CN36E533AM36UU369T330R36CW33WC36CZ36TT36PB36V2351T36D436V636BP36TZ330R36P736U2335R36WH36VC365L36SX330836U836DI34GM35FN36UC36VK33WC36DO36VN36AU36VP36UI36CG369E36DX36TF36E036TI36WV36CQ36E6369R36CT36BD36EC33WC343K36W836V136TV32ZC36O836V735YW36ER36WI27D36XN36WL36AH36WN32Z636WP36EX36WR36WU36WT36JC335R36FK36WX36CC36F734SF36VR36JY32BD36CI36UM33Z727W36FK36TJ36FK36E536FN33YT36UV330R36FR33WC36FT36XG363L36WA35SX32ZC36PF36XL330R36G636XO27A36YX36XR36BX36XT36OP36VF338I36GD36DK369236UD36GX36UF36WY36Y5350D36X136Y936X336VV33K236GV33WC36GY333527A36H036YJ36W327936H736KD25N36ZU36XA33X234KN36HC36RC32J735UB36HH36HU341D1B36S236R425N32IX366Z27D24236R935US367G36I8370F32MK370K36I132Q4370M32KP2BR35VG36I8370R35F4370U32KP367T32Q4370W343B36RT32MW32M532MK371436IN33II33PR36IT34JK330836IX34UW36J033SF35WO341E35H827E36J634UJ35QL34NO35QY338236KM35X4333936JG33WC36JJ36PN36NB36M636DH357R36JR360G36Z436PX33WC36JX34VA36NO36Q236K3372636P136K734M336QA33BE36P836KC36O336MX34ZN36KJ33T635QP36A936KP36PK335R36KT36JK36OH36PQ372033SP36L1372336PW36MD33Y836OU372936602B536LC33WC36LE33X736LG372T372G35HE36ED35HH33J4372L36LQ29D36LS372P36WF36LW372S36MO36NA372W371Z36NE27D36MA373127E36OQ36JV33K6373536MH36LA36MJ36W636P136MN27A36M136NY36MR36MT25N36MV36QF373K36PD342336N1373O36N436NX36LZ36NX372V36PP373V34NO357R36NG373Z36JT373327D36NR36VS36OV36Q2375234XG375235ZN322Q333Q36NX36LJ36O033WC36O2373J36PB36O536V336O7372O36JC36KN333936OF36LZ36OF374S36WM372X373W35S536PU34H536L3375035F7374436Q1373736P036OZ36OY364K36P3335R36OF36LJ36WH36ED36WH372K375I372M342336PF374N36PI363U36LZ36PM35Y2373U36KX372Y2IV36Z736NH35FU356836PZ3728374533C4364J34XG36Q633X736Q8363I372G36QE36ED36QE372K33X236QI36WE25P36QL25N36QP36YY377K336V33ZO332136QS34AW31A736QG331K36QX35LH2N8366X35M335SC35SE27D32VQ32KD32JG29M378432IY364M32LO32L5347B32LH32LB24I32LD32LF24U32LH32LJ311K32LM378B32LQ35JB35A633T3348K348M26J348O32ZY348R32R7348U348W254348Y33R626J3491349336RD34G433RR33AI31SA34AA35Q435GZ36Z835QF33S227E268335N33ZP25H354536WU333Q369W3554334T33UI2BB334H34R634W925N23M358X33LO36TG369Z33WC369Z330Y36XB350K374F330W331D34KT34GT35NK377V35LG34P934AW35P435LV28F35LX28G34VM35M233FU35M232IS35EG32L324N24V23O24T23S32KB32WG32J932M9322837AL28935DO34D629C34J524L32I7313B35LK28J34613300347U28224U24F33OI2ES345K3492371834DB32MW37B4378R23R378T33F6378W35TO348S3790348X33RF348Z379524K3492367636OT27D363135MJ32KP35TV371C333534KT32KV36CK34TV33M1356837CM35MU34H633W234AA33S935Y2350Q373O25N33BL35PS35AU372B36NJ375T351T35H331TH34AE35H333JS33ZV37CZ34AS33US368T33ZM36D235RM36TW367036VJ33V634KN2Y2349M35LU35LW32LB32J237AP35M135M337AU35M637AY37B035W632M337B42Y237B629L37BJ32J12ES35DZ37BD31H037BF35LM37BI37B937BM33CQ29D37BP33FV35MF27M32J932MD25K35VZ33EU35W133EY35W333F235JU344633QK35W935K133FD35WC35K52GV27E37CC332637CF352837CI27C37CK27C37CM359737CO35RY37CQ34AH37D134KW373J37CV375N35B437CZ33UH35NH33TP371X35QS33ZJ37D5364P338I37D935YH35C734VL36DD37DF36YR36IZ37DI378337DK349G377W3555341434EM27D37AL35D937DR37AO35UG37DU37AT35M537AW37DY37B1370D32KQ37EO37E328E37B737E637BA27A37E924M37BE35LL37BH24V37GY37EG37GZ361L348K37EK2A1349L367I37EO36EP356W33QJ337M32ZU282345C348X24T32J134I932Y732XD348K2BF32X732ZS32J532IJ26D26J24833QK33EV33F6345E32IL32WZ37HT34HE37I432XR24M32XC37B1337R345Y25534JV29O378P28932WX2AA34HE24J37H432L424Y347L26J26S347P347R257347T347V27L37F5371B3558333337CH33V637CJ343E37CL34WJ37FG379O37D035NH37CT36SZ37FW37FO34VN33WI35KU33MS34AA37FT376R37FY330D37D637JJ330D37G037DB356837DD35RD37G536XI27D3390342O35LE37GB35U537DN36RI37GF33TB37DQ344X32F437AQ24V37AS35M437AV37AX37AZ37GR36I832MG37B537GW37E537B937E837BC37H237EB37H435LN37H637EF37BN37EI37HB37BR37EM35F437KQ35TE35TG34BR32ZQ332X32ZU35TM348P32ZZ35TP35TR27A37F634G737J635S637J935PT37FD37JC362R32HX37FR37CS33XQ37JI36PG343B37JM33TT37FS353736PO36V337FX37M737FZ27E37DA338I37DC37G433XQ37G636V434NK37G937K737AG34AW37KA370X37KC25N37GH37AN37KG37GM37KK37DX37KN37E032OO32MM37KR32LV37KT37BK37KV37EA27D37EC37H537H737L3361O37L534G235OS33IW37N12BB24Z33IJ2A437J336IV36PB37LO37FA341133JZ37JB355I37LU37FI37JO34AX37LY34ZN37CW37CY338I37LW33YE37M533BR37D7338I37JU36O937JX37MD37JZ37MF35RK37K337MJ27A37K6333A37K837MN34LI34CV37AK37KE37DS37GL37AR37DV37GO37KM37DZ37B2367I37N137GV37N337B837N529D37H137H337BG37L037NB37EH37ND37BQ37NF32J932MP2ES337334BS37LL37J4363L37NQ37J837FB37JA37LS37NV369637LV33VF37LX34SF37LZ37O237M235GA37FK37JQ37M637D437OA37JS36FC37MC330D37ME36ES37K236BL37G837OK37GA37MM3325317O35LT37GG37OS28G2VU24C33RC25B23X29637OX36I837PI2BB23S35E835EU35VV37KB2NW24D35EY29635NU330D32IJ25832KM2LR29D345Y34DL24W26722T23W21624X22732I037PG32QX37PI34HB36N52BE34HF34HH26J34BO37LB33RP345I34HO337R34HQ344L29A344O33EX26J344R34HX34HZ37BK344Y345033QK35TC34JW34I7345732OW34IB37HN345E32J5345G34IH345L32YA345P28234IP345T345V347E26J34IU346034IX27E35AP37CD33XQ37PP2BP37LQ362N34TV33643597336437CP35WM34AI37NZ34SF375J351T371P37JL35GN35AU37JJ372534AL2BB333833VQ34MW33JO34YH35XW350535GJ24L36AZ35QU33NC35KF33MQ322331SA34NN32KP34W43431334C37D832PF1J331E336F353737UF356234SM343R37OM335734QJ338S33WC356E36ES330536FW37QG35MO37DJ37ML336T37GC37QM367G37OR37AM37GJ311K37QS32L437QV25537QX32PO37QZ37GG37R22AK35VG37R637R835NT2FG37RC36HJ361L37RF27D37RH35CY37RJ37RL37RN37RP37L637NG36R137RT36RF34HE344535JW34HI344937S134HM344H37S5344K34HS37S934HV344S33F637SE34I137SH345224K34I6345637HR3459345B33RG37SQ346237ST34IJ37SV34IN37SX345S34IR345W37IG345Z34IW345G34IY37T737F7379B37J737TB37PR37LR355R34WJ37TH37FH37TJ2TQ36A337CT37TN34LV36JA37M137TR34NU35Y237TU34Y833X6336937TW34YF333H37U1352D33LO26J37U536TD33KH33KU34UP33VX2FR35CT37UO331037UH37MA32RJ37UK331535FN34ZX341E343D37G9343S333H37UU34Y537UX368T37UZ37DG36A4333A33B037OL35LC34KN318O332E37V937GI37KF37QR37QT37VF37VH32KP32MY35NP37VL35OM33FQ36HW347Y36IO37R732LB37R937VR32IK37VT23Z37VV34E137QT25M37VZ37RM37RO37RQ37EL37W432R637ZI346O356W346R337N37Y924K346V32HL347J346Y32X0347G32XD347B34763478344I3474347C37X732OI348L347H380G347K347M347O347Q2AI37IZ37I137J1347X346P37PN365737XF37LP37XI37TD27C37TF354637NW37XO368H36XY36KH374K29D330H33BL37XW37FY37XZ34QU341E37TY34YF37U0333V37U237U634AH37YA35ZH33VX33LS35G6352Z37YF33NN34US34RT27D37YK37JW37UJ37UL37YP37U32VU33NM330537UR348B33BY28C37UV333Q37YY35RD33B037V036D3333A33AM37Z534KM37GC31K337VN37DP37VA37ZC32L137ZE37QW37KL32NV37ZI37R037ZK349M31TH37ZQ33RP37RA34TJ37ZU36R0361O37ZX25N37VX380037RK380237W237RR32KW32MY37T6381737CE381937NR36TF37TE37XL381G37M337XQ33XQ37XS34L837XU35B4381P37M9381R357N37TX33M937TZ335737Y6342U37Y8382136ZH35G634YS33LH37UB35R8340E33NA33YT382C36B026337YN33SP34AK37U333LE33MW34WY382L359037YW34XG382R35WJ37Z037MH35RN37V337US37V535U537Z836ID37ZA37MT37ZD37VE383835M632M3383B37VK35D937VM370I37R5383F37VP383I27A37VS383L27A37ZW32I137ZZ380137W1380437HD37BS32PC37ZI37RU34HD37RX37WA37RZ34HJ344B33RN34BR37S334HP37WH344M37WJ337R37SC37WM344W32HL34I234I437SJ345534I833F637WV34IC32WT34IE37SR34IG344G34II34IK34IM34IO37X537T034IT37X9346137XB383X37NO37J536IW37XG33SF37NS359437XK34AS37XM37JE37FR384737TM376J381M37XV342337XX3741341E384G3335381U352934R2350S384M32BD37Y9381Z37YD33L0384T33MQ33UB2FR33ZT37YI27E384Y37643850382F36WU350O33TX294382K342P385934TR382P335R385C33WI382T37Z136EI382W385H37Z637GC385L32KP37OQ383337ZB32J2385P37QU385R37AW32N832N337ZJ385W37ZL348G37VN386037ZR37VQ37RB383K35PR32OO386737RG3869383R386B37W336I8389Q330D32Z037LK335S387O37PO387Q381A387T351X387V3568387X37PW33W23880361X373L35Q7381O3885381Q33XM37TV381T33ND381V384K381X37Y7388G384O365Z33KH388L382635G6388O36RI37GD37YJ35GI32BD388U37YO388W382H37YR33YX37YT385I330S385A37UW36DD3898385F389B37MK38BP33O937GC2BB34D229D23K32JM24G32MK389Q383U27D22Z389Q37NJ37NL33IL34PJ38AF381837TA387S384227C37UD33WC34NN37NY35WM372K37FN330D334P37QB359035NC36SV37MG37OI340K382Y348F34KN38C137V838C338C532MT38C8380532J932NA368636IR346E32RJ383Y37T938AH384137FC384U34AS38CP336P34VQ37Q0338I38CV37G134WJ379R35WJ34YO3899371E376Y38BX389D35U538D635DS2ES38C429Y36I838DE38C927A24R38DE35JL35DL34BE34B332L6347237HX24K257332S387E332W33FX27M33F735K335WD254349738CH383Z38CJ36GQ381B37NT38CM34WJ38DQ33WZ34RB38DT38CU37MB38DW34AS38DY359Q38D037V134H538D337DL38C034LI34FU38E938D932PO38ED38DC367I38DE35E6378K347D32X024I332X32X334B237I935PI38CG35TT37NP38DL37PQ38AJ35HF38DO356838F938AO374I38CT36WS38CW37G236CR36G738FJ382V372525N38FM37ON332538E733B634EA38EA38C632OO32NG38A832OV38H3358832L233QO332J32LB332M34B438G4332R28738ES33RI34B638F038G9387P37CG38AI38CL38GF359738GH37FI38CS361F38DU38FE37JY359738FH36BW382U37DH38GS38GU37QK330838GX34UY38GZ38FS27E24R38H338EE32KQ38H3365B34JU34JW34JY32Y234K137HW34K532WX34K734K938G834TW37XE38F333XN38GD34G9340R38DP335T38DR35AK37CU38HV38FD33ZU38FF356838I034AM38I237Z238I437QJ385J34AW322338C227D38H032M338H32BB35D933FU32WB32MK35UH32MK35VQ32OE38IE38FV32KP32NK37PJ32JX27E34YY37T834SF38IW36FD38IY34TV35S8359735S838CQ38DS34RN21O35GI33C935XK34H337TP31SA357R31SA354J334I2BB35A934ZN372127E23Q36O9338938GM34WJ36K535WJ33JS38JD389A32ZC33CD38I538JH332538JJ38D738JL38IB36GQ38K138JP32XQ38JS35F438JU35F438JW38IC38K138IF22338K1358837HJ38IQ345Z346137SB32HL37IO37BG32JN32WR32I8332K37C638CF36ZP38DJ38K738GB37XH38KA36H834WJ38KE38J3357O38J5338A38KI35H338KK356Z38KN36PS34GK38KR381S38J436OK35AN36JQ38KX38KZ38HX37OE359738L333WI38L538E136V3348738L938JG348C35U538LD38E838D838EB367I38LI2AR38LK24M38JT35VP32O038LR38JZ27E32NO35PG32J138K438MB34AB38K837TC38F636QU34AS38MI38FA37O033JK38MN38HW360Y357938MR357038MT360S38MV38MK38MX35AC35H125N38KY35QA38N237QC356838N527938N738BV38L8389C382Z38NE38FP38IA38NI33IW38NU38LJ38JR38NN38LM38NP32NV38NU38LS38NU34CF29M35F9368927D38K538IV38MD38CK38DN35LD356838O538GI38HU38MM38KJ365T371O384B34GK38KP35A435HP38KT34U238KV38MZ27D38ON368Z38OP38CX34X336ES38OU38D138NB37V438ND38JI34LI34G038FR38P236R138P438NL38P638NO38JV32O038PB38NS29K2BS337A34J6337F34J9254337J32X134JD337O337Q337S337U34IY38PJ37LN38PL38F438MF38O338PP38J238O637PZ38KH38PU38OB360T38OD38PZ352933SE38Q2352438Q42IV335438Q735HZ38Q938GN36K236DD38QD38FK369Q38LA38QH38LC37OP38P138H133IW32NS328E38JQ24V38LL32KW38LN32KW38LP36E338SE38LS38SE37EQ37RZ37ES35JR35W437EW35JW37EY28035K033FC32XZ33FF37F338RA38NY33YU38O038F5387U38PO38KD38RI38PR37FM340A38O938J7362M357334LE34BT38KO33SP38KQ38OG357N38KU350Q38KW38Q638N138J838HY372C38QC38GQ38I3365Z38GT38NC38BZ35U534OO36XU2BH35JD35D232JI32JK32JM389T36HK38SE31K337KH37KJ37DW389O32OE32NU32OO2X12FG35SJ32OV38UR2VU32JJ33FU24F24K32JJ255344K38H433IW38UR3809335O380B346T380E37I9380H380S380K380Q380N32ZW380P380M37S7380J380U38IQ380W2GV380Y37IX381137J032XK37J235KQ38HL38AG38HN38DM37PS27A35GT3597381Y35LE37NY32YY38O738J638AT37Q237JF37JP38WA3633338I33XZ37FQ37PX37O638RK38GK38OL37O337JN37FK38N738FC38U338WQ37M334AA3390336L34UJ38L134AS32ZI36ES34ZY38OV34GD38OX38D437GC353633CM378132JF38UC25B38V132JL32JN32MK38UR38UJ37MV38UM36HU22Z32NX367I38UR330D38UT32PC38UV375135EA38UZ38XI32J238IF2BC23V34H338VY38CI38RD38IX38HP388E356838W638WE37TL38GJ38WB35GG37CX38WD37O535MZ38WN38YJ34Y938WW37Q337M438YP38WH37JT37M138WK37CR33M938WT37O1338I33CD38YS38YG2BM38WZ36J734WA38J9359738X4368T38X638D1385738U534KN383136S938UA38XF27D32LM38XI38UF36I832NZ319N38UK37OW383932QX32O235F438ZU38XV29M32O338ZU38UW38Y038V032JK32J22V033FX32K132J1378838V436R138ZU38SR35JO33EX38SU37EV35W637EX35JY38SZ35WA37F138T333FH34IY349A38K638NZ38YA38K938YC38W433WC38YF38YN36WS38TF38YW38WC38YZ37FJ38YU38YI391A35QE38YL391C38W834H53919366837Q837FP37O438WL2BM38Z238WO340E38Z6391737OJ36JK339A38X2356838ZE35RD355U38X734OX38X938FN35U538ZL37UE34EA35SD38ZO34MI38UD38V238ZS32OO32O538ZV38XO37ZG334J32O536I8392L3903380625N319R2BS390738UY390938V2390B35MF390E24U390G38LS392L38FY34JY38G033QO38G234B638EK38G638Y738IU38RC38W038GC391334WJ3916391R391838ML391N371R37JL391J37Q438WG393S3646391W393P36NJ38PS393Y38WP38YM394135C4391M35AB35H338Z5394638Z038Z837O7392038ZC33WC392335WJ392538D1389038QG38U634AW392B38GY38XE27U38XG38ZR38XK367I392L38XN37OV37GN38ZY32PC392Q32OO32O738US390432OV3958392Y24V38Y1390A28G390C27K3934393638QV35VO3958393932LI393B346S38G3393F346W38G7355Y38Y838F2391138O138TA3914333Q393O394E393Q38WU38YK394039663942394937Q9391H396A391D38WF38YV394433V3396G391K37643943394A38Z438YY391Q396B33NN391Z38S034WJ394K33WI394M38S538BN37QI394P38ZK38SA394U378638XH38UE394Y32KW3958395137KI38ZX385S32PO32O732M33958392T32MT395C38XZ392Z38Y2395H393337BK395L386D37L732KP32O925K38V7346Q346S32WX346U38VC32X637T138VF38VK347738VI347A347538VL347038VN398738VQ347N38VS347S381338VV3815395X393I36D138T838RF38YD38W536DD391X37FL393R396Q393T391I396T396H38WM391F396K38WJ3995396N340K396D37M938YX391P38WR35NH391T38YQ394C393V35NH37UB371X394H38TY333Q396Z34A537OH3972394O38BY38D535PN32ZD38ZN35OZ375137IQ25B38SH32W4390H32MB398037HH335O38LW32N9344W37HN379237HP29P33F637ID37HT28F34K232X8347537HZ37I137I334HG32XR37I632L432Y6346W38SS39AM37IE32WO37X837II26J37IK347W2BI39B832ZP37IQ37BG37IS37IU37IW3810398N37BJ347W27E33AM390Z38T7396038T938AK33MQ34AS34VI35RD398Z334P38S7333Q312W38GP399W38GR38FL38ZJ38FO34GV33OG35F735JD32BD37I229939A832W538LS3980349R32JM36SC35DQ39BN38T637F8342138HO38PN34VI359739BW35WJ39BY392834AS39C2368T38E0392638D239C738E635PN392D39CC39A539CF32HJ39CH395M1B3980398238V9398538VB347I398838VM38EN38VG332T380O398E380R3989398I39DM398K380Z37IY38VU39BM369Y39CP3840393L39CT34WJ39CW36J2394739BZ38NC39C138CZ39C438U2394238S7394Q38GW38P0397839CD39A639CG39AA27A32OJ34JR34JT34JV34JX32LI38IM344I34K332WR28T34K632LQ38IS36CR38F138DK393K38ME38YC39CU33WC39E938W737FK39EC38QG39EE39C335G038D1338939EJ39A034GV38QK39A332H739CE39A739DD39ER23V39ET38AB35SN39F7395Y39F937F939E638W239BU356839FF38Z736WS39C0335R39D136Z138L638E238JF397539C833XA37OQ39FT39EO39DC39A938LS39ET2IV28T28V37CA39G3398S38GA39FA38PM39G839FD333Q39GB39CY38E438QA34X639FL35TZ397239FO39D634AW31H037VT36S432OO34DT386832L4385N37VB31K337MS37GJ23U24V28T29H29D37VD27N389L37ZF395436R139ET383C389S32IG32KG331W383G35PF2BM34GI32M722726D33IF389Z312538IF21739GU27I34EE27E35B339G438MC39H238RE38YC333034AS39IX33SQ35LE36J4341E36OQ34MY279335P33YA334834PK364035WK38MY365R34LY336936KC34XG36KC360B35BO33W238TU33XN359Y37JF36DQ38N7358B369D362T37JL355B37XX29J2BB322332R7357A37GD338B2B539K035KQ34UG2VU338B33ML36V537UE3822384Q33NN39KB350U32OO33MO330E2FR32BD33JQ350Z3411388U27W322334NG339H34S134Y533ZE35RD33AM39GI38N9333A360D39FP389E34LI39HK32KP39HM38A439HO389I37MT39HR37QP39HU39HW2ES39HZ37VC383737VG39I332R632OQ389R38UB341Y346D39IB28G39ID2BP22339IG39II383J39IK395M23V39LR38H7332I24Z332K38HC332O38G538HG34BM38G339IQ39E4398U39IW34WJ39IZ3338379D33X735WP36EV330F36KT39J733TG34KW34PL341I36IY363M35GG34XO27H39JH33WC39JJ39JD33XM33MS35XI33SF39JP37FR36DQ36VQ34ZN36UK33ST35BP34UW39JZ365Z39K2356039K133MI2BB339T39K533YY2Y239KI31TH34WY33MI39JV37YC35KQ34YS35Z83435332139KN35TS34RS33IZ39KS33N039KV33WI34VI33ZD38BT38U138JE39E339H938XA35U539HI370N37ZM32J939LB37VW37QT39HP37KF39LG383432VS39HV35E239HY39OV39I1389N36HU22339LR39I639LT33ZF39LV37VP2F439IE366T39M137ZT39M4397X392U22Z39LR390K38ST37EU35JT390P38SX390R33FA37F038T235K4390W39MI39F839IT39G639FB38PN39IZ359739MN37J739MR371J33TX39J439MU341P39J927D39MY355H34UW338W33M52YQ39N436Q4372H351T338W35QS2TQ39JN36FD39ND33VF39JR36UI350Q34UG394C39JX39NL33BR39K13689356039NW39NR37K439K833YY39KA33NC31TH39O539R3382339KH34NF373X39KK35LA32KP39O838OL33NC382A25N39OC39KU37UT39OF39KY36DD39L138N836WB39L439CZ38I632Z639OP392C37R439LA34EA37VX39OW32J239OY389J25539LI39P2383639HO39P539LO397I32PC39P9385V39PB33T339PD389X39PF39LZ39PI39IJ39ER34RZ36IO36IQ346D39Q139IS391039IU38YB39Q639MM362Z39J135WQ39J335KK39QF33V2330H39QJ35BB39JK39JE34TI39QP36OZ39N739N137O839QV38Q539JO36GS33MS39R036Y639NH39KF39JW39NK36V339NM37OJ39NO33LO39RB33LI39K7355Y39K939O333LO39RJ39U538B839UI34NY39RP355E384U39KO32OO39KQ39L437UK39KT365Z33BY39KX34XG39KZ35WJ39S339D439L539HG332539SA38GY39SC332Z39SE39OV39LE39HQ37QO39OZ39SK39P139HX39SN39I039VM39I239SR36GQ32OX39LS392F39SW39IA39PE39LY32KW39T139M339ER24R39VS39G138AD39IR39H038HM39Q439H337XJ25N39Q733WC39Q937DK39J239QD39TJ330R39MV33VP34AM39TN33LY39TP354139QO39QR39JI362R39QT33VF39QW32JR39QY33W239U2350D39R239U538YL39R539U839R7334J39R939UC39RE39UF35GH39UH355Y39KC392739KE39O133NC39NQ34UK39RO32KP39KL330839RS353T39UU32ZC39RX39UY39KW39G939OH36ES39V438D139V639GL39OO38SA39VB27D39OT37ZY39LD39VH39SJ319N39HS344X39SL39VL27A39LL39SP392O27A22Z39VS39PA39VU39I924G39LW39SZ39VZ39IH39PJ39ER1B39VS31D034AZ34B134BF34B532K434B8337M2AK34BB29L32WQ38G534BG29734BI38HC39MF345N3447386M34BQ33RP39T839W838VZ39WA39IV39TD39IY39TF333A39WI33SQ39QE39WL39QG39WO39JB39N039QM334239WT39N5333Q39TU39WX39JM39TY39QX39U033UI2IV39JS39U439JV39X739U7351T39U939KH39XC31TH39UD39K639RD39UG39RF39UI39RI38BD39XM388K39UN39XQ27E39XS32Z639XU39KP38BE382E39UX33W439UZ39Y133YJ39S239OJ38L738IT39L635U52IV37QN37KD39VI39ER26332P338DF346D2BM334X330D35MA32HW32OO3A1W32BD23U280346C32JY27F2BB32IW366Y322832LM37OX34CQ34AY379Z39Z734B3332O34B639ZB32WX39ZD32WH39ZF393F39ZI345932YI38ER39MG37S0386N34HL37PL36XA39ZT32OV38MJ358W35N337JV33YT396G33M638OT34WJ330Q26Z31AW379P353736KR38AP39JL27A379K39QC335L37JE36C734PJ34V735AT32KP336L34QY32Z6342O341L33LY36EA34LD36ED34LG35NM34UR39BP39CQ341J387R39ZW39G839D1359739D1340T39QK341939A1352O3325336L37MH33513310342O34872BP353S33813A0D36DD37CT39D4330H3A1O34AW3A1Q37V839VF37KF38IF23V3A1W29D32YT32J13A1Z2N83A2135MB35NL3A2532WM3A2829632VW3A2B3673370C3A2F29M3A2H29P34J437H0337D38R0337H38R234JB38R432WX34JE38R734JH34IY3A4934993A3737O035ZQ3995399435KU3A3D35BK35973A3G3A3I37JK35RD379T33C5334H3A3P36J7379N32HX3A3T38DI3A3V34AW3A3Y379Y3A4138BP3A44374F3A47377W25M3A69393J39ZV39TC3A4F34WJ3A4I337Y34PN3A4L35U53A4N33083A4P38Z338CR3A4T38BY3A4W330E3A4Y36ES3A5038D13A5239V738I739D8313B390D37BK25733RE254390G3A5738Y3395M2573A1W38LV34B928E39DK38M025538M232LV38M4344N29W32LB38M83A5F27F3A5H3A2338IC3A5K374B3A5M3A2A32ZD3A2C3A5R2Y23A2G37KL3A2I337238K3361H39Q2399635TY375H38YQ33103A3C35C9340J333Q3A6K36GG3A3K35KN37XP3A3N36LB379L33083A6T3382359737UV33YU3A3W33C63A3Z32OO3A71348B3A7336P83A7537AH362J3A4A39E539Q533IZ39BX35942793A9U33WC37UV3A4J3A7G2AD3A4M39A13A7L33SK371X388638OA37QI3A4U27E3A7Q3308333Q333K39GH39S436YS39C639Y73A5439EM3A8728G38IF22Z3A1W39AD26H39AF37HL25B39AI34K337HQ39B339AO37HV39F139AS24U37I037I237ER37I534IE37I739B033R337IB37HS37IF37T228F37IJ32K439BA37IN39BD37IR32K739BH398M381239BL27L3A8P32ZD3A8R32HX22J3A8U36M03A8W3A5O3A8Y3A5Q3A2E3A913A5T3A933A5V37LA3A3135TH37LD35TK32ZV35TN37LI348S38AD3A7835TW33X53A6C3A9C396S3A6G3A9F3A3F330R3A3H3A9J36F63A3L391D331J3A6Q3A9P34RW3A3S35683A9U33SJ3A7K339M34OL3AA03A4336BD3A4533WC3AA434143A7739MJ39BR398V3A4G33WC3A7E3A4K3AAJ3A7I3AAL381I391N3A7N35KM3A4V35S43A7S368T3A7U39723A7W3AB233253A5537MP39SG3AB6395M1R3A5B27D3A5D37ZL3A2034JT3A5I32Q43ACI3A272B33A5N36ZO33EN3A9038ZP3ACQ35M63A2I361134HC37RW32LX37SY345U33RH33RJ37WC3ACU37LC33QQ33QS35DD39ZQ344E32GS33RC24N32WX345K32W232LP378V32WF337R23Y24T37IO345U36CS3A3532OH3A6B38RK3A6D35KU3A6F37PS3A3E34AS3A9I3A3J3ADF3A9L3A6P379J3ADK3A3R3A6U3ADN34083A9W27D3A6Z3ADS33973AA13ADV3A7434AV32ZA3AE03A9839BQ39TB391238PN3AE439FK34153AE7341C3AE935U53AAM38HV3AED3AAS27D3AAU33YI33V93A7T3A1L39GJ35Q73A533AEN39773AB539T332PH25K37BV37BX348N37LH378Y348T348V37C335J13794379637C93ACD2FG3A2232HX21N3AF23ACK3AF63A8Z3ACO3AF938XP3A2I34G523U33R2392I33QS337M33QS29O32GV32GX3AG7390Z38KF348F3A9B391G339N3A9E38N63ADB2793ADD3AGJ368T3A6O3ADI3AGN3A3Q33AT3ADM3A9T3AGS3A6Y3ADR33083ADT354X3AGZ3AA33AH135PR3AD339H13A7A3AH73A7C39D0340S3A7F36WT34LR34W73AEA3A4Q38HT3A7O35LC3AHL35NB3AHN3AEI3AHP39L3379I39OM392934AW32BD34D232233AI936RD397835SF35SH38XW334J3AHX38IF26Z3AHX31TH331T38PG37993AH43A4B343438W139WC37A4379Q398Y35373A3Q37TK3AKF38AR381L34H534AO35BZ25N22F38RJ354U35MY39HA38PO35RD34QV39D4343Q3A7X33JR39L832I03AKL37C73797370339FT3AKP25B35SI395A36703AKT395M24R3AHX39PP35JP37ET35JS35W533F539PU346039PW38T138EX38T43AL039T93AH53AJV396139BT3AL638CY36ES35Q333IR3ALA3A9M3ALC34M538823ALF335N341B3ALJ38PR34PL35KE38RH36ES3ALQ38D13ALS3AEM33083AKJ36S93ALX37C83AKN3AM137N83AKQ3AM532M73AM739PL3ACG3AHX3A5C35PH3AMN3AG839G539CR3AL4381C38GO38JA3AL836F63AMY35KM38E03849356V340K3ALG3AN53ALK35B93AN938TC3ANB3AKD39S532ZC3ANE399Z37GC3ANH392C32IG3AKM3AM032JD32JF3AM23AM4392U23F3ANR370B37HE32Q43AHX38CD39IP34UY3AE13AH63AMR38GE350X38FG3AO533YA3AO735L538483AN239423AOD33083AN638HT3AN839QK3AOI368T3ANC39723AON38E53AKI38QJ2BS3ANJ3ALZ35UA3ANM33ES3ANO392U2173AP138EU392U21N3ANU3AEV3ANW3AP83AL13AA839WB3AO23APD3AO43AMV3AL935Q53AMZ35Q7381K353Z36JS3APM32Z63APO38CR3APQ35BB333Q35S83ALP3AOK3AB038OL3AHS3ANG39773AQ137C93AKO3ANN3AM33AKR32RJ32PV39ER34JW2BS3ACT3AFR35TI37LE35TL32ZW3AI237LJ3ANX3AA739MK38PN3AMT39E33AQN3AO63AQP3AO83APJ38AS3APL3AN43APN3AOF3AQZ3ALN3AR235WJ3APU39C53AR63ALT38BD35U53AOS3ALY3ARB3AQ435JM3AQ636I83ARH38IF24B3ARH34FF34FH32ZS25734FK28U34593ART38PK3APA39BS3APC3ARX3AO33AAB3AS0333X3AQQ38YK3AQS35B03AQU3AS63AQW3AS83ALM38S13ASB33WI3ASD39EH342N3ASG39KE39C93ALW34C93ASK3ANL3AOV27U3AOX3ARF3AP235PC3AP2386E32M73ARH38II39EW38IL34K039F034K439F338VO34K83AT13A793AO039G73AL538DX3APF33M33APH35KK3AS33ALE3AS537TR32KP3AQX33YT3AS93ATK36DD3ATN39OK3ASF3ANF3ALU35LG3AQ03ATU3ANK3AOU39CB3AOW3ARD3AOY32O33ASQ395M23F3ARH39W53AUG398T3AE238YC3AT63AQL3AT83APG3AS13API38813AS43AOC3ATG32OO3AUV34313AUX38MH3AUZ3AR437G73AOM39S738LB3AR834GV38FQ3ARA3ATW3AVA3ATY3AVC3AU01R3AVF3ANS32OE3ARH39M838H939MA38HB332N33RG39ME34BL39ZN38HI332Y3AQG3AMO3AL2341E3AO138O23AQL38HZ3AUM3AMX3AVS3AUP3AVU3AUR3AVW3AUT27E3AVZ339N3AW138O43AW339EG3AV13ATP3AV33ASH33XA38QK3AWC3AV936OX37823AQ53ARE3ANP2AH3AU23AQA32HX26332Q939EU34AZ3AU839EY3AUA39AQ39F2348K3AUE39F634LH3AQH3ARV39G83AVO38JB3AMW3AGO3ALB3AQR36PC3AQT374Y3AQV3AVY3ATI3AOH33WC3ATL330L3AW437MI3AXM3AOO35U53AOQ34G43AV627A3AOT3AQ33ATX2NW35SG3AXW392U26Z3AY33A593AY33AIO3AIQ32JL3AIS32WX3AIU32GU32GW24Y3AVK3AJU3AUI3AA93AUK3APE3ARZ3AVR3ATA3AS23AXA3AYP36PV33NO3AVX3AUU3AYT3APR3AYV3AXJ39FM3APV3AW738S83AW937AJ3AXR3AZ83AWE3AZA3ASO32QX3AZF3A893AY338EI32LV393F38EM32XT32J538EQ39ZM34IL38ET33PR38EW37F233FH3AZR39W93AZT3AQJ3AX33AYI3AX63AYL3ATB38JC3AYO3ATE3AYQ3B053AXE3B073AR0335R3AYW34Y939L23AOL39O93AR73AV433XA331R3B0H35P33ASM3AZB3AVD32Q13B0N3AWK27E22Z3AY339Z53A2K3A2U39Z934B739ZN34B93A2R34BC39ZG39Z832X334BH3A2X3B0X3AFJ3A303ARM3B1439ZU3B163A4E3AZV3AQM368T3AYK3AUO3AN03ATD36MZ3B1G3AXD27D3AXF33103AXH3ANA3APT3AYY34873APW38OY3APY3AV53ASJ3AV83B0I3AXT3AVB3AXV3B1Z32Q43B213AU3397Y2WB3AY33AKX38PF36883B2O38Y93AT3398V3B193AZX3AUN3AX83B2X3B1E3B2Z3B0334AN3B1H3B323B1J3ASA3B0A39HD3ASE3AZ03APX33253AZ3367B3B3E3AQ23B1W3AZ93ATZ3AXX32S33B3M3AY032OO32QJ2NW35F83B3T3AWY3ANY39Q33B2Q3A7B3B2S3AX53B3Z3AX73AZZ3AVT3ALD3B023AN33B3127A3B3339JA3AYU3AR13B4B3B1O3AR53B4E3B3B3B4G3APZ3B4J3ASL3B4M3AWG3B4O32WY3AXZ3AP3336T3B4T3AZI344X3AZK380C3AZN3AIW3AZQ3B4X3ARU3AVM3ARW3AUL3B543B1B3B003B583B1F3B453AYR3B063AN73ATJ3AW23AOJ3AXK3A1M3AV23AZ13B3C39GN3AZ525N3AZ73B4L3B0J3B4N392U24B3B4T38IF24R3B5X32WM3AZJ32YO3B6139B83AZO3AIX3B653AT23AMQ3AT438IZ3B3Y3B2U3AQO3B563AX93B6D3B443B5A3ALH3B5D39QI3B6J3AXI3B6L3B0B3B4D3B3A39ON3B6Q3AKK3AV73B4K28X3B5Q3B3J3AU02233B70395M22J3B872A13AP7375X3AWZ3AQI3B2R3AQK3B7G3AVQ3B403B7J3B423AOA3ATF3B5B3ALI3B493AUY3B7T3B4C3ATO3B7W3AKH3B5M3ATS3B5O3AWD3B3H3AWF3B843B4O23F3B8A3B3N392U1B3B73374B3B753AZL32WT3B783B633B3U395Z3B3W3AVN3B693B7H3AT933VF3B573AN13AVV33893B6G3B1I3B6I3B5F3B1L3B5H3AAZ3AW53B1Q3ATQ34KA3B3D3B1V3B823B6W3B5R3AQ73B973B4R33FQ3B4T3AWN37S53AWP332L3AWR38HE34B33B2K332W38HJ3B7B3AUH3A4C39CS3AYH3B9M3B8J3B553B9P3B7K3B9R3AXB3B9T3B473B5C3B8R3B6K3B373B6M3AHQ3B6O3B4F3B0F37VN3BA63ARC3B94392U26332703ARI3BBI33FW3B8C3AYE3B8E3AYG3B5237A53B1A3B2W3AYN3B8N3B303B7O3BB43B7S3BB63B7U3B8V3B0D39EK3BBB385M3BBD3B1X3B0L33IW3BBK395M24B3BBI3B5Y38UE3B9E3B623AZP3B9I3ANZ3BAR3AX238TA3B8I39CX3B7I3BAX3B8M3APK3AXC3BBX3B9W3B083B5G3B8T3B5I3BA13BB93B5L3BC5389G3B6S3B6U3BA73B923B0K3AZC32PL3BCB3B2232M73BBI3AFD37RV33R33AFG387H3AFJ33QZ3AFL3ARM33QP33QR33QT3ARM32WQ33RB33RD3AFW32WF35DW32J13AG028626J3AG33AG538EZ3BAP3AVL3B9K3B683AZW3B9N3AZY3BCS3BBU3BCU3BB13B8P3B7P3ALL3B9X361H3BD03BA03AYZ3B8W38GV3BD536OP3BC73B833ASN3BDC32PO3BDE3B9832HX23F3BBI39CK349T36SD395W3BBN3B4Y39TA3B7D3B3X3BAU3BCQ3B9O3A3M3BCT3B9S33UM3BEJ3BBY3B363AR33BB73AKE3BA23AXN3ATR3B1T3ATT3AZ63ATV3AXS392E3B933BEX3B3K2WB3BF03BAC27D2173BBI35AE37MR32WB27Z38ER32X934I8344P398434JF34JW32KH3472337R32YE34HG2803BF835K83B663BEA3BAT3BEC3BAV3B6B3B9Q3B2Y36O63BBW3AOE3BCX3B1K3BEN3BC03B8U3AXL3BER39S83AXO37Z93BEV3BA83BBF32J932R83A1U3BHH3B3R331U36IS3BE83AZS3BCM3AUJ3B8H3BFE39EA3BFG3ADH3BAY3BGZ375K3BH13AS73BH33B4A3BEO3ALR3BC334KN3B4H33LC3BD73BFX3B3G3BFZ3BDB3BG233WK3BHH3A593BHH3BG935NQ24M3BGC38HG3BGE27L3BGG337N3BGI29729Y32ZV3BGN33F93BGQ3AP93BFC3B9L3BGV3BFF3BEE3BFH3BEG3BFJ35CR3BFL3BI13B8S3BH63BD13BEQ3BI53AOP3B5N3BHD3BDA3B6X32NV3BIG3A893BJM28S28U28W3BCK3B4Z3BHP3AZU3BHR3BJ23BHT3BJ43BHV3BFI3BB03BFK3BCW3APP3B7R3BFN3ASC3B3835QG3BJF35U531TH35V03BI93B3F3B6V3BJJ3BA93ACG3BJO3BF132PO32R83BJS3BFB3B503AJW3BBQ3AL73B6A3BBT3ATC3B433BH03B6F3BB23B8Q3BJA3BB53BFO3BC13BH83BKB3B7Y36WO3AHV318O37N937L0249331V25B24B39AP32H723Q35W627T32WG27B39Z23BHJ2AH3B3S35FA39OL3BBO3B6739H439E8384535GA37FH38W933WK31AW36AG374239HB3BJC3BEP3B393BL833253BKD3A5639YF37MT3BLC37KZ33003BLF380E3BLI2BF3BLK3BLM32WF38EZ35WT39IL3BKO3BLV3BFA3AMP3BKR3APB38IZ39H5335R34VI37TI33MR3BM235FN3ADD3BM6356839GG3BK83BFP3B1P3BD33B7X3B8Y37GE3AEQ319D3BLD3BMK3BLG3BMN27N32BD3BLL32WG3BLN3BMS39T332RL3A2J34B03B2832XT39ZA3B2B39ZC3BMR3B2E3BO037SB39ZJ3B2J3AWU3B0Y37WB38EQ37WD3A3339BO3B7C3BMZ3B7E34TV3BN239RD37PV37NX3BN736WU3BN9373Z3AHA3BL53BH73B6N3B5K3BNH3BET3B4I3BLB37N83BMJ24V3BML3BLH3BLJ3BNR3BMQ3BLO3BMT395M37T23AXZ3BBM3BOH3BAQ3AL33BHQ3AX33BOM34NK3BOO37TJ3BOQ338I3BOS3B033BOU3BND3BL63BOX3BH93AW83B1S34FZ37MQ39YI32J23BMI37PA3BNN3BMM3BP838Q63BPA3BNV3A593BNX38QY3A5Y34J83A6038R3337L3A6438R634JG38R939CO3AYF3BLX39WC3BPM39G93BN53BM13B6J330D3BPS376133AJ3BI33AND3BMC3BP0333J3BQ237QP3BNL3BP43BP63BNP3BMP3BNT3BMR3BLP3B713BNX339T23P38UF386L32I83BQP3BLW3BGT3BQS3BLZ3BPO3BN63BQX336T3BM53BOT39GF3B9Z3BI43AKG3BES3BQ03BLA3BMG37VB3BQ537ED3BP53BNO3BQ9360M3BQB27F38LS3BNX3A9528F3BRO3BMX3AX033TX3BCN39BT3BQT3BN437XN3BRU37PY33O93BRX3BPT3BRZ3BR23B0C3BS23BHA3BFT37DO3BS637KF3BS837H53BRB3BSC38OM3BSE32ZD3AB73BNX38PE36873BLU39GZ3BGS3BJ039E739BV3BM037TS3BRV3BM434PR3BR03BNC3ATM3BK93AW63BT13BPZ3BHB36S93BP233ES3BRA3BSB3BMO3BP93BRE3BLO3BTD39DF3BNX3AMB390M39PR3AMF35W735JX3AMI38T035WB390V35WE3BMW3BTK3BOJ398V3BSQ3BTO37XX3BSU3BQZ36NJ3BPU3BTV3BNE3B5J3BPY3B0E3BS43AOR3BU235JM3BU43BQ83BU63BQA3BU83BE739ER2173BNX3A8C337M3A8E380D3A8G3A8I3BGP38M53A8M337R32HI38M935CQ3BRP3BTL3BLY3BTN3BRT3BQW3BUV3BSW3BTT3BS03BR33BTY3BV33BU03AEP3BV63BNM3BSA3BV93BNQ3BVB2543BNU3BSF395M32TI3AU239GW3BJR3BUO3BOI3BJU3B1738TA3BUS3BVY3BTP3BW03BTS3BUX3BSY3BM93BS139743B6P3BNI3BKE3BNK3BT73BLE3BU53BWD3BSD3BVC3BWH3BDF32R632S73BNY3A2L38HD38G33A2P34BA3A2S34BD39ZH33RG3B2I34BJ3A2Y3AWV3BRM3BOE3AFM39ZR3BWN3BPI3AX13BPK3BWR3BRS35RV3BOP3BTQ3BSV3BWW36OR3BWY3BOV3BJD3BMB3BW53BC434GY3ASI3A593BXF3ARL386O33RP3ACW35DG3ARP3ACZ3AI338AD33053BUP3BWP3B8G3AX33A9G335R330Q333Q33TK34AU3AZX3BOW3BB834KW3B1R35HP3B8Z3B713BXF3BAF33F83BAH39MC3AWS38HF3BOB3AFJ3BAO39XK3BVU3BUQ38YC3BYY34US34XG3BZ234A73APF3BZ53BFQ36XY3BZ835A73B3D38LS3BXF3AU738IK3AY734IL38IN39F138IP37HT3AUF39KD3BZN3BYV3B513AQK3BZQ33MI3BZS34Y534A83BJ33BZW3BNF3BZ73BA334BT37VN3AB73BXF3BHK3AKZ3C0D3BSL3B8F3C0G3BYX3AJ733WC3BZT38X83BZ43BYC36UB3BZZ362M39FR3B5U3AU427A1B3BXF33QH35IS33QK33QM34I03BDR3AFP33QU3BYL378G24L3AFK33R1344X33R42AS33R733R93AFT33RD37HN332W3BDO3BXV3B2N3C0Y3BYU3BPJ3BJV3C123AGH34Y53C1536B93C173BMA3C193C0R35GG3BX439IL3BXF3BF539CM36SE3BZM3C0Z3BBP3C0H3C133BZ13C0L3BZV3C1836AQ38U43BFS33RR39A13B4U29M34CQ29R31TH2AS25635D42AS3978394W397B38UG25N24Y32JU344223M23T32HI24Z3AY13C3J2AZ3BLF332K34CK32ZZ392U332P37MQ24C29624G32W234EP32H73BLI29Y34BC28Q34VM3BLF27S24K24Z35J625724E3C3M3C3O35NQ34CI24I32J835NL3C3R339T3C4B3C3O35D335DX31TH23Q37WR25A3BLN328E3AFO3C4F32IG3BIK3ASX32IJ33FH32IG3C4W28T35D932XX319D3C5932HL32YP27Z3ASS32WB345T36I83C3R2IV347U24Y2AO2BB345139ZD35P423Z28F24G3C5S38UG24B3C5M35UG32H428Q2BB23W380E28E38P738IC3C3R318O3C4R3C4D3C4F32KG2A332WF311K3C6G38VV24X3C5G37U532RR3C3R34G53C6K32L63C6M32XX3C5I32JL3C5A35P437883C4T319D37B037HU32VT24N3A5U32W535O235D535O435IH3C4V34I83C7131TH35F135JJ34GG2233C6136R53780339T2583C413C4332JN3A5S3AIM3A5V3BBL33IK39HN35CY22922A3C813C811233CN38LF38QM36GX3C3R32233C7328F23Y34CP29637Z932BD32W939PZ3C7S39IJ32O33C3R31K323M24S34612AS3C4T3C8I29M3BLP2BB3BMN32K53BF23C3J32M33C3R317O378W3C5A24824I24X393524I24Z32LQ2ES3C973C992AZ24E23Z344N34NC37V8318O23T34ER344V29833FU35P837ZS37R035PE37VQ39GV32LQ32GM25M3C803C8222A236386C3BKM33B632SN25K3BIJ3BGB3C1S3BIN32WI3BGF37SA3A65337R3BIT3BGL32ZS32YN3BIX35KU2NW3AFX28732GX2FG337039TQ3C2S3AD435UF342O34113BS3357C27F3C9N3C9P29729U24V3C9T37VQ3C9V35NS35NU31TH35NW32WB24923W23T32JP2BS3CAB3BIL3CAD344L3CAF3BIP3CAH3BQM3BGJ3BIU3BGM3CAN3BGP3A1827E23E34KR33RZ36T3355Y3BSU35Q4338M33413CC938TL33OE29D39XX37UK343Y3CB235NL2N82V03ABD24U23Y27T2AK27M2AZ2863C5P394V2AH32ZU29P3C9F27U3C7O3C7Q3A8M27U2V023S33RF34CQ35IM2AK35D9311K24D34HG2583ASX2BF3CCZ37VO389X2LC3C8L32OO22D32O022J2BS31H03BIL3C5A3C6N345K27Q3BDX35IR370B29U32L724J3CCQ25B37H83AFX32YF32IW32XX32HX1R3C4P3AEV24U24S27L3C5V37E732BD3CEI37BL34HT31BE27A3CBG24M24E32ZZ24Z24F34HT35K432I823Q33RD32LR37VR32HJ324Y3CES3C9B3CEV39ZD27Q3CEY3CF032L738SF38NM39YA36ZP34DO35VU32MW21W37MQ38UZ35MA24K3CEL32KZ2AR348K378F393423U24O27Y29U25B3CFV29A393437CH2W132YH24V24E345R38JQ32JN28Q2V03B2D29L38UZ34HD32MT3C8N27P32HL24M32LE3CFT37BK29H365B27Y2ZW3CE132K73C4T28T34CS3CGM3CG13CGO32CM36IP25A3A8A296389M37II3CG024I3CG2319N32HI32XA29932LU2A432YH29Y319N24S32HI32YH24N3C8T32XV29M2FG3B0V36HJ21N3C3R2VU32HI2A33C983C6N2ES3BIL3CHI3C5N32K72AO32BD3C6W348R3AER3C1J32GU37H937QV3CCR2IV3BIL3CFY3C3E3AIL394X3C3H3CA93CBN3BIM3CBQ35SD3CBS32WS3CAI3CBV3CAL3BIW3BGP37UM34JO3AZ939GQ39FW39A93CIO3CBP332N3CIR24L3BIQ3CIU3CAK3BIV3CBY32JN3CAW390Z33M335SS36Z7339N3CB03BX236WO2N839GP39DB3CJ332W5386H37RW37W93B2L39ZP3BYL37WE37S4344J34HR386T34HU386V34HW386X34I0386Z37WP34I532X3387337SM387637SP387937WZ387C37SU345N33IK387G34IQ387I345X387K37T534H53CJH35SR35WK3CJK3A4S33IZ3CCI37403CJP3CJ13CJR39EQ3BYK3A323BYN37LF3ARQ378X3ARS3CKU35SQ348D35ST3AK63CL03BT23CL23CJ03B0J3CJ239EQ3ANV38NW3CLE35WI3CLG3CKY37DJ3CB13CLK35FN39EN3CL539FX3BDI386I3BDL3CKP3BDN3CJY3CL83AFO3BDT3CJZ3A623BDW3AFV33QY3BDZ3AFZ35DN3BE33BE53CH53BE739423CKV3CLU346J3CLW3CJN32Z63BVS25T368G3499386535S635SU384V38ZA318835L333S035HX35GI35ZA2AQ3AAE333Q37UV36JK336B3A3A36NJ37O935N53A0A333937DD34XG37K0371X37OB37UI33XB33N0384H339033BL2AQ34VC382E3A3Q334P26635Y23CAW334I38TK34M92V031882AQ36LG33VX28C317O35GK374L33VX27H3COE38MS36DJ357G39QL38TO27E331X35AR3579340D31BT31SA29J34G533KF362J3574358G32RJ362Q27W35LZ35QS336H340D35TX32WL39NB38F435XK37FR34M934YY32JR3CPD382E2AQ31K329D26Z25Z35Y235E6364M35QK38F02AQ339638YK3CO538PW29D365Q3CO925N365B29D3CN437GD334E34VE335138BI25N337A3CQ7393R3CQA35TE3CQD36OQ3CQA34833CQH338I3CQA36HC34ZE35Y23CQ423J331E357T33C933512BM34QF2AQ26G39YB38CG28N358833ZP35FJ36YP32OV21135NH32J935I4379H27D358E3A9S3321351S3COF3387356Y35BJ3567357734W9338B3560378R354K39OB39UW36SQ33V334EF35B83BA435BL35C232KP29434PF39KI339T3BG93CS627D39W737OJ34GV33AP336S2AG354T31882FR35FC39NZ33BA33U13CSI36LB38X838DI33MQ32ZC33AS38CN32Z63CSL32OO2FR38XC3B0437UO32KP33X433B82BP33KY35Z13ATH38TE36Z33BZX25N34C23AGU39MS341J33IR28C339Y33W234M934IY33SA34ZB340D35JL3B46357N32KP33L2331J3CL127D34GX3BQQ3BRQ3AQK1R34WJ3CU33BZ434N436TY37CP3BM33AVR336B3B1C33893BHX37TO342333XZ384D3C0P342Y3BJY3B2V339N34N436A337XX3CN5371X3CUC3CN838Q338TT33SP33JS3CNW33SP3AAP330D33CD32JR368J37FY394F36F638KL35AI36WE37XT35SB353739QH391D35X133XQ35CJ39R63A0V37M1354Q3CON2IV39KA38MY2IV35RX38OK35ZO379K28C34OL33L23CQW37O7357E3CTG3CV2382G3AOB33MS36JS3ADP353Z340D33BK34TR38RT3CUG3CQ4334J33RQ34M931H03CRJ33VX35GH375L35QX342334G53CWM36FM37243AAA3CTI3CUO354B3BQW34M9385333SG3CUU3CVI359B350Q3560363133BL3CVO36V335YO3CVP3C0D39JK376V33SF3CPI3BHY29D2S63CVD372F36F639JP25N357V36SP3CXG3CW635X739QZ33BR3CUE33C439X532BD3CPR39NJ3CP136GJ2BB3CVR35863CXF340C33BR35TX39X039U03CVS27D3CPV39QS33SP365B35543CW335AT37XX340D3CX2358P391D35603CXZ34UV36V334YS365Q38YL359K39JY33LO3CY835603CVU3560366632JR3A423BQW340D35TE36AV3CW335AZ3CZ2334X37UN35H42TQ34UG3CXZ39FD35AB34VK398R34VO34UT39JU3CSQ375332BD3CVU34UG35TE36UL3CYF36ZE357T36JY387N391D34UG3CR038BO348B34WE357K3CZW3CRE3BRW33LI359E36BE3CZJ3CUU3CZM33XQ3CZO34UW3CZQ33Z937M134WC37JF3D0837DJ37YU3CZJ39IR33M329435FC33MS34YS35CM3A3O34ND33ZT335X33CG3A0Y33WC37AC33YA2OM3CTE3AHB38ZL33C23CZV32KP342O2OM3AK837GD36H233LI223374F3D1S34ZA36DV33YY3CTK37UP34IY38583CJJ35LA3CTR3D21384I37U33D0L34VB3D0N34ZN3D0Q351K38YL3D0T37FR34UG26Y3D0W38BY36CF3D1W32BD3D1Y33NM36AB3D0A34SK37U334PC36V334UG273350P34VS33N035YG38F4343S32ZC3ADD2B535G327A37LK3D103CZK39XP396C34PM34M734SC26Q37M139XW382E2B526R38B724433L03D2U35GH34YS3D2X39XR36DH3D0Q36MS3CS336GS3ADD29434PQ34WD312W2HU26U35KQ3D0Q3D3T34GK2FR33M835G634OT31SA2OM3D4C34GK3AE439RD31K33CCF33L0343W391Y356O2HU38Y6355Y3D4838273D4H31SA2AG3D4W39273D4H39RD2V03D4M29433JG37OJ388U2943D3M396O34W834ZB3D0Q36LX33TX2FR33UY352G334A34A2352O364O34OM353533OD3D5C34VJ33NN3D5F342425N3D2Q3AHB2AG35G1327L352O33X2352O33ZP3AK2340Z36WS33J339O93D69391H3D6B361Y3CPS33ZF375Z38J83D5P348F3AK9336A335R1V36DD33IN3BV03BD2361L3BR432Z633RS3B8Z3BTG3C372NW3C3A3C3C37H93BIC3C3F392I397C336T3CA936783C4I3C4D36I83CA92IV3C3T32LB3C3V34DL3D1L3CA9339T3C402553C423CD33C4534ER3C4832F43C6D3C4E3A8A3C4H3C3N3C4D3C4K29F3C4N38IC3D7L27D3D7V3C7F38Q63C4X3C4Z2BB3C513A8A3C533C5J27Z32K528Q32233C5E3C5B3C1R3C5D37WR3C5F3C6V35NX3C5K32RR3D7E37513CI533OJ33QI32X23C5T339T3C5V3D7O3C5Y32MK3D8V27A3CIE345U328E3C66346Z3C6927D22J3CA93C6C34593C3O3C6F32KH32XK3C6I2VU3C6S3CHZ3CEA32PO3CA93C6R3D9M3C6T3C6N3CI83C6Y339T3C7035D43C7227T28F3C753C7735ID3C7A35IG35O63C7D27L3D8837H035JI27T36ZO3BF23D97370B3A2E3CD13D7O3C7R27U3ACP3C7U39DE3B8B3C7X39LC3C7Z3CA322A3C8438QL38SC36R13CA93C8A3DA52553C8D29734CC38E83C8H390V3C8K39M33CEB3CA93C8O3C8Q3A5N3CHO331T3C8W378332YB3B3O27A21732SN3AIE3CA93C942963C963C983C9A3C9C34EF36WO29D3CDI2IV3C9I3C9K319D3C9O29Y3C9Q3CB83CBA35NU3CBC37ZS3C9Y32KB34RE3CA23C823CA539FY32SP3A5W337B3BQG337G32XT3BQJ34B93CIU3A673CAP31TH3CAR29732K8395P32LJ380S393D32K4395U32HL3BF833893C2833VF3CAZ3CLJ3BTZ356Y3CB427D3DCB24G3DCD3C9S3C9W3DCG37GG3DDQ35NV35NX3CBI3CBK32OO32JQ25K3CJU344435E9386K3B2M3CMC386Q37WG3CK337S83CK53BO837WL344U386Y37SG34I337SI3D8P37SK37WT387537SO37WX3CKI37SS3CKK37X13CKM37SW345R3CKP34IS3CKR34IV387L32Y534IY33903CC23CC333V738W733523CUA3CC833VX36BT3COC34SE36AG3D4M3CCH3CLY33WK3CCK27X386Y3CCO3CIC3CIF2AH3D8X32IG32YE2AS3CCY3DC035P43C7P3DAP3D7Q3CD53CD732K532LU3CDA2I42VU3CDD32IK3CDG38XH3DFW389W33RP3CDL3DBG3CDN3CDP3CDR28I3D8P3D8M27Z3CDW3AFU28Q35E62573CE132JW3CE43CE632WF3CE8345T3C1R32J93DCQ339T32XH3CEG24L3CFP3CEK37BK3CF727U32DK3CEQ3CF53CEU3CEW3CF92573CEZ2A43CFC37RB3CF331BT3DHE3DHA3CEX3DHI3CFB3C6438QP38SH3D9E389U36RO32OO3CFI33IW3CFK35P43CFM37923CFP364M33QN3CGN32J13CFV3CFX27M3CH83CG23BLP2V03CG53CG7344X3A8J3C6I3CGC3BO53CGE24K3CGG370X3DCQ31K3344X3CGL3DIF3CH03CGQ32WB24M3CGT24Y3CGV37IL32WF3DIY33FC3CH12BJ3CH42BF37VF24M3DJ835E231K33CHC34K13CHF24N3CHH29231K33CHK3A2W3CHN35D43C8U27N330D3CHS386526J3DCQ3CHW3D9W3D9R3D8N29D3CI234ES35OQ3DFR3CI734HW3CI92AZ3C5Y2ES3D992AZ3CIH3CCR39FT3D7538XJ38UG26Z3DIU3D863ASV34FJ37B734FM3CIZ39A23CL435OQ39EP39FX3B0Q3C1S38G53B0T38EO3B0W3BZJ3B0Z33FY3B113BUM3CMN340K3CMP3D2235SU3CJM3BBA36XU3CL33CLN3CM139A93BVH38LX3A8F32K33A8H29638M332YC38M63A8N3BVR3CJG3CLF3DLF3CLI3CLX3DDI3CLL3DKW3DLL3DKY39GR32W53ABA3ABC39AH34B53ABG39AL37IC32XC32X239AP37HW3ABM3ABO39AV3ABR32XR3ABT37I939B23DMH379539B53ABZ39B739B92B93AC437IP3AC637IT347M39BI39E0398O39E23CMO3DM03CKX3CMR37G93DM33BW63CRG3CM03DM83CJS38K23BSJ3CLS36IW3CKW33AC3CLV3DNE3CMT36Z43CLM3BDA3CLO39FX3BCF3AIR3B773AIV3BCJ3DNN371C3DNP3DDF3DM23DNT397Z27E3CMW3DF538VX349B3DF834KH3D3Y3CRG367S36GE35G63DFC36C138RZ35G53CNA34WJ3CND3CUT396E35KN3CNG33BR34XO2AQ3CNM33WC3CNO35Y23CNQ37YL34U03CNT388A38283CV03CNY37YM331E38TI36P23CO33D6H38KL35R436LR38CG3COA38TM334I3COJ3CCC39RW3COH3BVT36OL33SP3COL3CVC3CYG35G627A3COQ350E362H33BR3COU338H3COX33MI3COZ33JX39OB3CP325N3CP5334J3CP73CYC32U838OE334H3CPH3A0J3DPR3CPG359T3CRU33393CPL336T3CPO36JF27D3CPR3CPW3CPT364R34SE3DPJ3CWQ3CPZ3DPM3CQ234BT3CQ52Y23CQL33B638513CQC3CQP35HL3CQF35FN34VD37XY3CNZ35U63CQL330D3CQN3DRI3CQ8374L3CQS28N3CQU3DNU33LY3CQY25N3D0939WD3CR238AE36J73CR637JE32OH3CR93AYU34KU368I333A3CRF3DM53A7R35XF34M932J93CVG36FP3DOF3AJL35793CRR33MP36SP39OC3D0I33543CRY332639UQ39NU3BI733VY360T34YS3CS839RN27A3CSB382833XA3CSE32OO3CSG32Z63CSO3CSK3DT939RQ3DPS340R3D152VU31882HU3CST3CSY360R3CSX39RR34OR3CT633C434XB25N3CT4349B3CT7353T3BB33CTA35SW3D6S3D1G343L36QT360O3D1Y3CW834233CTN34093CWB33BR3CTR3DTY35833CTV349B34KN3CTZ3C0E3C293BWQ39BT3CU535683DUQ3AVQ3CXR35Q235MM38YH3B403CUU35L73AUQ3B59396F3AVX3CUR3BKA38F4371H3AS03CW33CUQ3BZ63CX23DON391D38OO38RU3CUX3A0L37M13CNX3BRU394B33SF3CV637M93CV833YA3CVA3CWZ3BTP3CX13CVF3D3B3CX534AB3CVK39X93CVM35B43CXB3CYJ3CVQ3CXE3BZM3CXU34X627D3CVX379Y3CW033WB36JK3CW336QJ3DOV3CX234M93DU93B453CWA35B03CWC37M138TR3BKZ38G834JW3DPR3CWL35R736E63CWT36XA3DX13CWS3DWZ3DQA36OQ3AYK3DVT35WX37XX3DVW3CXP3DVY33SP3CXZ3DW13A0R33LO3CX935B53BRU3CXD3CXC33SP3CVU357R3CYD3DQQ3CX034233CXM384A29D35E639MW3CW33COM3DXO3DKV35543CUU340D3CXZ39JT3D2V33YY3CY337A13CYP33BR3CY8340D3CVU3CP839NC3D02357R3CYI3DWA3DR736F63CZA357U33WJ3CZB33BR3CYR3D3B3CYU3D2Y353Z3CYY37M13CZ13CVL3CZV34AE3CZ53DZ427A3CZ83DUC3BTP3CZC353736DY3DUU3CZG3DZ8338I34WE3D2833JV3D2A350Q3D0Q349A3CZS33Y136Y83DZ536FB3DW93DZV25N3D0036VU3BRU35603D0434VA3D0633MS3D0V3D2R350433C43D0D3DZT27A3DSD3D353CRW378R3DZK33VF3D0M34SF3D0O36V33D0Q3BG93D2E3CZT33W23E0737QI3D0X36F633A035373D11350T339T3D153A9O38243A3R33KM339F335R3D1D33M33D1F3342337Y3D1I3D6G36B93A4033YX3D1O3DTU36NY2B53D1U36ZV3E1N369B36UJ3D1X38BM3D2038913D2233KM3D243E1V3D2633C43DZL391L34RY3DZO33NN3D2D3DZR37M33D2H3D2J35LC3D2L36GO3E1S388Y3D5W3E2B3D2S33C43D3Q3E0C25N3D4934YZ3D2Z339T3D3133XN3D333D0G3D3632ZJ3E0Y3D3B34YS3CXZ3CSV34UW3D3G3D3I3A1D3DPD3D3L3D3N3D3P3A1627A3E2O3BPN34NO3D3W39UT3D3Z31AW3D4133MY33NL3D4425N3D4H338B3D4U38BB384I36B93D4O34GK34LG3D4I34AN39RP3D4L382E2943D463D4P34RY3D4S35GH3E3R3D4A3E3T33BA37U93E3X3D523DQR3D553D1B3D5825N3D5A394834RY3D5D3D5T34X734Q13E1C3E4C35NA3D5M330833ZV3D6J355C3E4N3D5S32233D5U33382FR3D5X3A4J3D5Z34Z733T336ZR3E1F36J73D6634123D68341Y3D6A3E5H3D6C3E5J3D6E3DQZ3E5C35343DTR3AAT3AEG3D6N3D6P3BTW361O3D6U32OO3D6W3BNJ3D6Y36883D7024U3C3B33R53CIJ392G397A3D7638UG24R3DCQ3D7A3D7Z3C3P32RR3DCQ3D7F37C73D7H34FQ3C3W32MK3DH232L13CD23C443CI73D7S29L3C493D863D9J3C6E3D7X3D7B24Z3D813C4M3ACG3E6P27A3D873DA33C4V3D8A3C6I3D8C33QR3C523C8A3D8G3C563D9A3D8K3DGL3CI0318O3D8L3D9Y3D8S39PM3E6I3D8W3CCU328E3C5Y28Q3D923C5W3D9532P93E7S3D983C633D9B3C6732JE32M33DCQ3D9I3C4C3D7W2573C6S3D9O39LU3CHY3C6U3DH032KP1R3DCQ3D9V3E8H3E7P344S3DKC3DA13DCK32HL3C71318O3C8B39SK2A43DA83C7935IF35O532K83DAD24L3DAF337B3DAH3ACL32MT3E823DAM3C7N37VW3E6R3C7S3DAS3DA83C7W2A43C7Y3CA13DAZ3DB138NH3DB332HY3DCQ3DB637HU3DB935PF3DBD3C8J27U3CDM32KP32SR319N3C8P3C8R24U3DBM3C8V35WT3C8X3DBQ3BBG32SR32N83EA33DBX2553DBZ3C9924B3C9B32LQ38JK35OQ3DFW3DC73C9J24M3C9L38XD3CB53DCC3CB73DDP3CBD35NP3DDT3DCJ3CA03DCM3C813DCO38IF2573EA339DI3984380D380F346X38VE380U380L398F398C34793EBI39DU39DO380V346X37IU39DZ38VT3DN827L3DD037ND33FN3CAT3DL13B0S24I38EN34753DL638HH3BO83DL93BUI3AML3B133DO43B153A3638A13DNS3DLI3CB332ZD3EAW3DDN3EAY3CB93DDT3DCH37VQ3CBF3DDV3CBJ3CBL37W33CC027D3DF43DOD34GK3DF737JG33VX37TR3CN63CCB34M933273CCE382E3DFH3DM436UE27F3CCL3DFM3CCP32K53CCS3DFR32233DFT32K424L3CDI3DAO3D7P3C443DG134CP3DG335EU3CDB3DG73CDE3DGA3CDI3DGD2963DGF386338A027E3CDO32MT3CDQ313B3CDT3D8Q3C1R3DGO3CDY3DGR3DGT3CE332K53DGW3DFT3CE93E8J331K3EA33DH33CEF3CEH37N53DH832J13DHA3CEO29E35NX3DHP3DHG32JE3DHS3DHK28Q3DHM31253DHO3CET3DHQ3DHH3DHJ3CF138P53DHW3CFF369K3CFH32PI3DI3339T3DI53CFO37N53DI83CFS3CGZ3DIB3CFW3C9R3CFZ3DIA3A5O35WT3DII34923DIK3C5F3BGP3CGB28I3DIP37BL3DIR32M232MW3EA33DIV3CGK3CGY3CH93DIZ2953CGS3C3W3DJ435D43CGW29B3EGF3CHA34G53DJB3DGA3DJE3DJG29H3DJI24K3CHD35IM3CHG34ER3CHJ3CHL32XK3EA83DJV2B639PG3DOF24B3EA33DK13E8O3C5C3DK53BGK2AZ3C5O3CI637833DKB3C6Y2IV3DKE29D3DKG3CIG3EFV3E6725N38ZQ3C3G32NV3EA33BTG38PG3DKV3DNI25N39FV39EQ3B263BNZ3BXO3BO13B2A3B0Y3B2C3EG73B2F3A2M3BXP3BO93BXR3BAM3BOD34BP3CMC3DLZ3CLT3DM13AED3DNF3BYF3DRW3EI33EI539FX3BHK38DG3EIO3DNO3CMQ3DLG3DDH3DNG3DM53EIV3DKZ39A93EI03B4W3DNA3EIP3DNC3EJ33EIS34KN38CU3CJQ3DNJ39EQ3AP633IK3EJ03DO53EJ23DO83ECH3DNH3EJJ3EI43EJ832W53ASU2B33ASW3ASY34FM3EJO34A03EJQ3EIR3DO927E3CMV3CMX3321349A35TY3DOG330E331J35CT34NJ3CQ536AQ3ED536AL3DOP33BI3DOR34AS3DOT3CQQ3DOV334T3DOX379V2YQ3DP039QQ3DP32AQ3DP5382D3CNS33UK27H3CNV35Y23DPC39RW38513DPF3CO2335135X238MQ3DPL3CSR3DPN35GG35QV3DPU3DWZ318O38TN3DPQ374W35QZ3DXM3COO27D3DQ233J53DQ42BB3DQ6339M3DQ833LI3DQA39X839RW3DQD3DQF32R63DQH2BB3CP93DQK3CXI3DQN3CPF3EME34AG388U3CPK34BT3CPN3CPP3DQX3BZ93DTB33413CYI35WW3ELG3DR53ELI3DYP3COG331E3DRA3DRF370X3DRD3DRQ3CQE38513CQG3EN13D4M28N3CQK3EN13DRO38513CQO32ZB3DRR3CQR3CQT3E5G3CW13DFJ33393DS03D0D3CQ53CR434GQ34VQ35KC3DS83B083DSA357934873DSD3E5G3EMP38OC34233DSI3ALH3D6C32J93A9Y34H33DSO3CRO3DSQ3CRV3DSS3EK833KZ33223DSW39O034LI3CS434NO3DT13E3B25N3DT533YQ32J93DT8366M3DTZ3DTC3D1K36B93CSN384U3DTI38CG3DTL35HS3DTN33AI3DTP27E3CSZ33OD33KY3CT227E3DTW35TY3DTY35B83BEK35TZ35Y134873DU438X034143DU733VF3CTM35C33CTP3DUE33UM3CTT34P83CTW3DFI25N3DUL3CAX3CU13AX33DUQ35973DUS3C0N3CU73DPY3BY63DUY3BEF3D3D3BBV34FO38843ED93CTC3CUL3DV83AVR3DVA3EQB3CUS3EKS33W23DVG34AB38OJ357R3CUZ3EL83DVM396R38F43DVP37Q73DVR360O3CW33DXA3DWU38BK3CX339WY3DXF3CVJ359C39XD3DW4357D3DW835RE3DPZ39733DYO33B03DWD3CVZ3DPH3E0936QG377G3CXT3DOX3DWL3D3B3CW935BA34M73DWR35B43DWT3CXK3DWV3CWJ34233DWY3DPR34SS3DWZ31BT3DX33DPK29D3DX636GS3ER535WF3DVU3DXB34233CX23CVG39NA3ERC3CX6355W3DXJ3CVN3ERH3DY33DZU3CVV3DXQ33SP3DXS3CXJ3CWG38PI3ER825N3DXZ39WN3DY13EQB357R3CX23CXW39X23CXY39R13D2M3EMO35B43EM536T73CY734UW3DYH3ETN3DQI38F439X13DW63CYH3ERI3CYL33L63CYN3EQB3CYQ3DZE3DYX33LO3CYV34ZN3DZ135B43DZ33DW23ESX3DZ73EU93DZ933SF3DYR3DYE2BB3CZD36DS3CZF3EQB35603CX2338L3E0J3D293E0L3D2B39RM35B43D2F3CZU3E1G3D0E3DZW381Z3DZZ36FE3BQW3E02369D3E053CZL33YY3DS038U43E0V33YA2B53E0B3DZX3E0E31AW2B53D0I3E0H3D273EUP3DZM3EUR3E2532233E0P3E2838YT3E0T3EVA38BP34WE3D0Z33IR3E0Z33W23D143AGN3E143AJG3E1635683E1933IR3E1B352G3E1E3E5A3EUX3D1L3E1I33OD353S3E1K34003E1M3D1T340836Y73DZX3D2O33MW3E1U3EVB3E0632KP3E1Y3EVB3E0I3E0S3EUQ34AB3E0M351T3D2C3D0S3E0R3D0733YY3D2I3E083E4Z3EWO381Z3EWQ33L02BP3D2533N42B53D5X3E2M3D3Q3E2P3DZ033N03E2O34ZI33IZ3E0F3E2S3D3733YA34W63EW133N03E31353B37GD3E4L38YL3D3J3E3735TF3E392943EXK3DT325N3EXM3E3E35793D0Q3D3H3D3Y34AG3D40374G34PP3E3M33MQ3E443E4833NN3D3Q37UC3E3O33VX2AG3D423E3W3EYU35G6312W3EYX3D4K3E4G3E3Z3E453D4R3D473EYR3D4V3EYV3EYZ3EYY3D5134NK3D533E4233K33E4I37UK29437LK38N73EP4353Z3D5E3E4Q3D5I3D5Y33RV3D1J369Q38FE3E4Y358W3EZO35B03EZQ3D5G33M93E57368H3D613E5B3EWD3E5D39A1352M3AK339RT3E5L35833A7J358Q3D6F3F093E5P3CT025N3D6L330I3E5T36ES3D6Q3BPW3BZ634QB3BYE34KN3C1I33XA38FQ3E6129Q3E633E653C3D3DKK3CIK3EHX32Q13EA33E6E3C3O32O33EA33E6J3C3U3E6M3D7J27E23F3EEQ3E6Q3DFZ3E6S3DBP3C473E6V3D7U3E6Y3E8C3D7Y3C4J27Z3D8232M33F1L3E773F1T3E973C593C4Y3E7C341Y3E7E3D8E3E7G32I83D8H3C573E7K3CDU3C5C3E7N3E7L3D8R3C5J392U1R3F1E3E7T3C5Q3D8Z3CIC3E7X361O3E7Z3D9038UG2173F2N3E833C573C653E863DHX32S33EA33E8A3D9K3A8A3E8E28Q3D9P3DK23E8I27Z32J932SU3CH13D9Q3F3D24L3D9Z32J23E8S32KK3E8V37GG3DB73DA73ACR3C7838ZP35O33DAB3E943BQA3DAE3E7937BB35F234GG2633F3G377Z32IY3EDQ3DAQ3C7T3E9J39IO3DAW39OU34DL3EB53DB03C8527A38JM32OV3F3G3E9U3C8C3C8E3DBB32MW32H73C8I33FG3DBF3EE537RD35NL3F3G3DBJ3EA63EH63DBO37OK3EAC36I832SU32RO3F3G3EAH3EAJ3DC13EAN3DC437513EAQ34423EAS3EAU37ZM3DCA3CB63C9R3ECN3EB03ECP35NU3EB33DCL3DAZ3EB7395M22Z3F3G3CM33AFF3DEV37SZ3CM73BDP3CMC3C1N3CMB3A323BDV3DGP3CMG3AFY3BE13CMJ3AG23AG43CMM3EBW38663AG13DD33CAA3DDS3CBO3BGD3CBR3CJ93CBT3BIS3BGK3CJD3BGO3CJF3ECC3B2P3ECE3DDG3EJG37GC336F3ECK3DDO3F5P3C9U3DDS3EB03ECR3CBH3ECT3DDY3ARK32ZJ3BXW32ZP35TJ3BYO3ACY3ARR3AD13ECW27A3ECY3DOD379C35AU3EKE3DZJ334Z3CCB3DVE3ELL33843DFF3EDA3ENW34KN351K2W13CCM3DFN3CE43EDJ3E7U3EDL3CCX3EDO3DFW3F493DG037GG3DG227M3DG43C5F3CDC3EDZ3CH53EE127D39LW3EE432OP3EE627D3EE832OE3EEA3CDS3F2I3EEE2AL3EEG27I3EEI3DGV33OI3CE727K3DGZ3F3E32QX3F3G3EER3DH53DH73F2T3EEW3CEN3DHC3EF03EFA3EF23CFA3EF53CF23EF834423F9O3CF83EF33EFD3CFC3EFF38SI39OR3DHZ32KP3DI136GQ3EFL33QI24K3CFN3DI73CFR332K3EGG3EFT3DID3EFW3EFS3EFY3CG43EG13CG83DIM3EG539ES3EG73CGF3EGA27E2573F503CGJ37II3EGP3EGH27A3CGR3DJ23EGK3DJ53CGX3EGV3DJA3CH33EGT3DLT3FB63EGX3EGZ3DJL3DJN3EH33DJR3EH63CHR38EP36HJ2233F3G3EHD3C6L3CI03EHG3CI33F2O39A437OK3EHM3A883CIB32JF3EHQ32H43DKH3EHT3F163E683CIL3ACG3FAV3E773DKR3C5534FL34593EI23EJU3EIW39A93AVJ3F6Z3CTH3EK533YT3DLH3BD43DLJ3DNV3BIC3DNX39A93BQF34J73DCU34JA34JC3BQL3BGI3A673EK333RZ3DO633W23EJF3EK73CLZ3FCF3EJW3CH13AIP3B5Z3B763AIT3B9G3DO33EJC3EJ13EIQ3FCM3EJ43EIT3EJT3DKX3EJV3DM9328E37NK3BBM3DDD3DNB3DNQ3DND37QI3F733ASI3DLK3DNW3DLM3DAU34EB3BJQ39GY3DLD3FDW3DO73EK63EJS3EK83DOB3EKA35XF35UF3F7V3FDY3EZW3CN33DOL34GK3DVE36T03CN93DPS3EKQ341P3FEP3DOX3EKU36O93EKW3CNL3EKZ3FEU37Y83DOX3436333V3EL53DPA3EQY39KR3ELB36WS3ELD3DDJ38TJ3CPY3C0D3CQ13COB35G63COD3ESE38G83ELP35KQ3ELR356Y3ERU3CVV361D3ELW34NO3COT33VX3COW33VX2B53EM43A0Q2633EM7360Z26J3EMA34X327D3CPA36GK36FD3ET23DWN3ET43CPC36GS3EMJ35613CPM3DQV3ET63ETI3C1B3EMQ33393EMS38PV3EO33EMV3DTG2AQ3CQ33DS23EN03ENG3ERQ3ELA331E3DRE3FH13DRG3EN63EN43CQI38513ENB3FH63CQM3ENE3FH93DRS3ENJ36XY3FHJ3CQX33413ENO3DS23ENR3FDY34RB3ENU3CRA36XX360T3ENZ3DRW3DSF35Z63DSH357C3CRM3DSL3EO935KQ3EOB34963EOD33973EOF34C93EOH358A35XF34UG32J93EOM35793EOO39XI33N03EOR3DSL3EOU27E3DTA3DOK340R3DTD3EOV3EP03DTH3CZV3DTK333A3CSU3DTO33263EPA348F3EPC3D1P3EPE352P3DTS3CT83AYS3DU1356T3DU333C63DU63CWX3DU82TQ3EPS358236AY3CTQ3EPW38OG33WU3EPZ3EDC27A3EQ23DDE3BSN3BY13DUP3CU43BZV3EQA3FFS3CC73AX73DUZ38E33B7L3ET53CUI38AV3EQK371G3ESH3AX73EQO3FFS3EQQ3FEP2TQ3EQT34YA38RV36FC3DPB3EQZ3CV33DVO3D0235HL399P3DXT3DYS3ER73ES43ER93ESO39TX2IV3DXG3ERE3DW337JL3DW53DYO3CY8357R3ESZ2IV3ERN34TR3ERP3ENL36KU3DWI3EQB38MO35373DWM3FJJ374Y3DWP35AB3ES137JL3ES33ET33CSR34AH3ES629D3ES834M93ESA3DPR3ESC3DWZ3DX43DPR3ESG36J33CWX3ER63EQB3DXC39J83DXE3FL23ERD3CX73EST3ERG35B63ERI3FL93DXP3ERI3ET13D023EMG3FKY3FGN3DXD3ET93FFS3ETB35373ETD391D3DY73ETG3E2E3CY237M13ETK3CYB3ETM36V33ETO3FN93ETQ39TZ34ZJ3ERK3DYN3ERK3ETW3DZB3DUU3CYO3ETP334O3EU13CUU3DYY34SF3CYW351T3EU637JL3EU83DXI39NY3DZI3CZ633LO3DZA3EUF3FNM354N3EU13EUK3FFS3EUM3D0K3EVM3E233EX234AE3DZP3EX53DZS3DZX3CY834UG3CZY33YY3EV136YB3EUC357S3EV538163EWZ32BD3EV93EXH3CZJ3EVE381Z3EVG3D0H36BH3E0W3D3B3E0K3EX13EUS3EVQ3FOG3E293EV83E2I3E093E0X36F63EW0391D3EW23DWC3D173A9Q3D1A37OJ333Q3EW833BQ3D1G3A4J3EWC352O3DTP3D1M3A7P3FJ636TO3D1R3EWM3D1V3FN327D3EXE2943EWS38BP3EWU27E3EWW3EVW3EVL3FOT3FOC3FP73EDD37JL3EUV3FQE354U3FPC3EXB3E1R3D2N38BM3D5X3EVV3D0B3D2T3EUW3E2N3DYZ35B034YS3E2S36FD3E2U3BTR3E2W3D383E2Y3CUU3E3033XQ3E3236V33E3435B43EY53FH33E3835QU3D3O2943E2L3EYB3E3D39G93EYF33NN3D3X337Z3E3I33L03EYX3E3V2613E3N3E3P37YE3E3C38273D5634GK2AG3FRV39273FS231SA312W3E3V3EZ33FFA33L03EYP37UB3D4Q36M03EZ832233D493EYT3FS736B93FSM33YX3FS23E4F3FSC2943E4732233E4J3E4L3EZN36AY3D0Q3EZS3E5437MR3E4S3D5K33JH38U33EZX3E5Q3EUR3E4O32233FT1350W3E56337Y3E58342E3E5C3D633EO13AHD34AW3F0C3F0I3F0E3E5C3F0G3AAK3E5N3F0K3E4W33MQ3F0M3F0O35683D6O36ES3F0V3F0T3CTC3E5Z3C313FD73D983B5N3F113C383CFR3F143D7339SV3EHW3E6A32M33F3G3F1B3D7C3E8K3F463E6X3F1G36733E6N32OE3F9F3F1M3EDR3C7S3E6T3F1Q3C6I3C4A3F1T3C4F3F1V3D803F1X3E7433783FUU3F213E8B3F233E7B3DHU33ZF3F282AU3F2A3C553D8I3C583F9227Z3D8O3F2F3C1R3C5I34IQ32J932SW3EHI3DFR3C5R3F2V3F2S38663F2U3CIC3AY13FVU2IV3D993FVE3EHV3F3232N83FVU3F363E6Z3E8D3D9W3E8F39PC3EHE3EEO336T3FVU3E8N3FBP3F2J3C6X3F3M37833E8T2553F3P33TB3F3R3E8Z3F3T3DA93E923C7C3F3Z3E963F413DAG3F4333WZ23V3FW436HO3E9E34E13E9G3DAR3AIL3F4C3DAV3E9L3DAX3E9N3CA33E9P3C863E9R38GT3FVU3F4O3DB83F4Q3C8G34JT3DBE3EA03DGG38IC3FVU3F513DBL3DJT3CHP364Y328E3C8Y3DBR370B32SW32MK3FVU3F5B32HL3CCZ3EAL3DC23EAO3EI43F5H34HC3F5J349M3F763ECM3DCF3EB13EB03F5T3FXK3DCN3CA63BG532S03FVU3EIY346D3F6J37HA3EBY32K83CLQ3DDC3BIZ338A3CJK3EXG3FDM34KN3F753DDL3F5N3DCE3ECO3F7A37ZS3F7C24M3DDW3ECU3E9K3BVS3DF33ECZ35G63ED13CC73F7X3DFB34233F80343Z3EQJ3FH33EDB3EJ53FQH3F873EDG3DFO27N32W13EDK3CCW3DFU3F8F3C9G3F8H3EDS3F8J3EDU3F8L3EDW3DG63F8S3F8P3CDH3DGC3F8S37VP3F8U386432KP3F8Y32PC3F903DGK3FVP3DGN3F943AFV3CDZ3DGS32ZZ3DGU3EEK3F993DGX3F9B3D9S32RU3FVU3F9G3EET3CEJ3F9J3CEM32JF3F9M32WB3EF13F9W3F9Q3CF13EF73CF43F9V3AG13F9X3DHT3CFD38QQ385Y32KP34DD35VR3EFK3CFL3FA93DI63EFP3FAC3EFX3DIC3EFV3EGV3DIH3AEV3FAL3DIL3EG42W13CGD3EG83DIS3B233FY03FAW3DIX3EFX3CGP3EGI3FB237IS3FB43EGO3FB63EGR3FB83CH53EGU3G2Q3CHB3EGY3DJK33IK3FBF3DJP3EH43DJS24I3DJU3FBJ3EH93EKD23F3FVU3FBO3D9X3EHF3DGK3FBS3DK83E7U3DKA3E8Q3EHN3F2Q3FBZ3C623DFP39ES3FC33AZ93DKL392J32Q43FVU3DD5395R32WR395T38G5395V3FCE3FDP3FCG32W53BUD35W23AME38SW35W8390S39PX3ECA3BUN3FDI3EJP3FDK34313FCN3BOZ3FCP3DM63FE33EJK3EIX34FW3C0X3G4M3EK43G4O3CJL3FZC37GC3EJI3G4A3FDA3FZ63FD23FCK3G513CKZ3FE037AJ3FE23FCR3FE43DNL3A333FDV3EJD3FDX3FD63FED3FD83G563FDR3C0W3EJB3FE93G5L3FEB3FDL3G5D33253EK93FZS3EKC36SJ360R3EKG3FHX370X3FEN3EKL3DOO354133413CNB335R3EKR3FEV38TW37Q73CNJ39JF3EKY36OZ3EL03FF337OC38883DP833693EL73DVL3FSC3CO027E3FFD3CO4366I3FFG3BZM3FFI3DPO333V3DPQ36N03DPT3ELQ3DPW3ELS3BQW38RQ3DQ133973ELX38Q036QU35G63FFZ35G63FG1358F3DQC33973EM834AH3FG836PT27A3FGB362L3FGD3EMF3DXV3EMH3DQR3EMK35GG3EMM3DQW34ZP3EO23G673FGR3CPS3DR33CWO34233CQ033413FGY3CSR28N3FH033143DRR3DRC3FH43FHG2BM3DRH36WU3DRJ3FHA331E3FHC3G8K36O93DRP3G8R3ENH32PF3DRT3FOQ3FHJ34MS3FHL3ENN3CR13G8H3DS33CR53ENT356T3ENV35BB3ENX3FHV3DSC3G663BYG3G7133XA3DSJ35Z534LI3FI4355Y3FI63CRT3FSC27W3FIA3AZ63FIC33JT3FIE3CS23FRR3CS53EYB3DT23D3C3EOQ39RP3EKD3FJ63CSF3EOW384U3FIT3FIP3DTF3CSO3EP23CSR3F003FJ03EP73FJ23FT93CT13FPY311B3FJ83FJO3EPI3AOF36FW3EPL333A3EPN3CTG33093FJH3EPR3DUA3EPT3ES03EPV35CR3EPX35CU36WN3CTX3FJT3FZ83C0F3BKS3CU23FJZ3CU63DUV36V33FK33AVX3AYM3EQF3BCU3FK93G013BV13FKC3FM83AYZ3DUU3DVB3CTC3DVD3D3B3FKK34MR3DVI3FKN3FF93BTP3DVN3ER13FKS33M93FKU3DX93FMB3ESM3DVX3CX43ESQ3DW03FL43EP53FMJ3ELT3DW73ESW3EUZ357R3FLD3CVY33LW3FLG3DWH3ESJ3DWJ399F3CW63FLM3DPR3CXZ3AGT3CY63BMW357M35A83ET5318O3DWW3CWK3FFM3DQ03DX13FM33DPR3FM534M93FM73CWW3FKV3DUU3FKX3FLU3DZJ39WN3GCH3FMF3ESR353Z3CX83ESU3FMK3GCP3ERJ3ESY3FMO3G803DXU3CXL3ET53ET733SG3FMV3GCN3CXV3D3B3FN139U33CY13FGO3A0P3CY53ETL3ESX3FNA3GD53G7T3A0I3FNE3CVV3FNG3CVV3FNI3DYR3FNK3ETZ3DYV3FNO33VF3FNQ364N3EU533N03CYZ33BL3FNW3DZ63CZ33FNZ3DZI3FO23D023DZD36F63DZF34N43DZH3FOP3EUN3FP43EX033YU3FOD34NV3EUT3FQI3EX63E2M3FOJ33YY3FOL32BD3FON3D023EV43DYA3EV633LI3FOU3FQM3EXI3DS13DYA32BD3FP03EVI3FP23EVC3GFK3EVN3FP63EVP35AD3FP93EVT3FPB3EXA3GG53EVY34ND3D122TQ3FPI3D163EW4349X3FPM33NN3FPO341P3EWA3D1H36SO3E5C3FPV3EWG3D6K3GAQ36W33EWL36P83E1P3E2D36TC3E2F3D1Z3GG43EUP3FQA3GHF3FP33E223D3D3GFN34RY32233E2733C43DZS3EV732BD3EX93E0U3D2K36TB35AB34UG3FQ53E2H3GGL3CZJ3E2L3DZX3E2O34YP350Q3FQZ341V3FRS3FR43EY73FPF3E2Z3EXZ3FR93EY12Y23EYH37JL3FRE388U3FRG3CNT3FRI3EYC3EOP3FRM3FOD3FRZ3EYL3EYI3EXS3E3J25N3FRU3EYN2HU3FRY37UA27D3FSK384U3FSO3FS433VX2OM3FSO3FS93E403EZ43FSE33NL3FSG3D5U3E3Q33NN3GJ7340R3GJ93EZI35G63GJC39RP3EZG3DPD3FST3EZJ33L03FSX3D2A3FTB3DDL3E4Q3F0S3F0533IT3EZV3CN238ZB3EZY3GK03E513GK23F033FTF33BA3D603FTJ3F0D3F0A35U53FTO36573E5I3FTR3GKJ34LS3F0J352O3F0L3EWH3E5S27D3FU1368T3FU33C0O3B5J3FU63C1A35UG39773FUB3F133D723EHU3FUH3DKM3AIE3FVU3FUL3E6G32KP2503AU23D7G32I42AD3FUS33B63GLI35P43D7N3FUW3FBU38GT3E6U3FV03E6X3E8B3FV33E713E733D83334J3GLP3C4Q3F223FX438OM3FVD3C503FVG3D8F3F2B3E7I3D8J3D893G1032W53F2H3GMH3FVR3D8T331K3GLP3CI43E7U3FVX3F2R3C5U3FW1385X33IW3GMO3G3U3D9A3F313D9D32RO3GLP3FWC3E8C3F393C6J3F3C3C6N32NV3GLP3FWM3G3J3FVQ3FBW28G3F3N32VR3FWT3DA33E8W3FWW3C763FWY3E913C7B3DAC3FX23E973C7H3DAI34GG2573GMX3C7M3F483E9F3F1N3E9H3FXF3FWY3FZP3E9M3F4H3FXM3F4K38LG366T3GLP3FXR3E9W3F4R33IW3F4T3FXW39PJ3ACG3GLP3FY13C8S3FY33DBN3EAA3DBP3CD832O33GLI3BF23GLP3FYD2553FYF3EAM3DC338U93F5G3C9G3EAR3C9K3FYN3FZF3EAX3F5O3FYQ3F5R2AZ3CGW3EB43F5V3FYW3B5V32M73BWK3FE73FZ23DD23CAT3C0439EX34JZ3C073AUB3AYA39F43C0C3G4Z3F703AG93ECF3FDZ3FU838523FYO3GPB3FZI35PD3F7B27D3CEQ3FZN3F7F25K3BZD38HA3BAI3BXI3AWT3EC63BZL38283F7R3DF53F7T379F3FZV35ZZ3FZX3ED63DFE3FKA3G023F8437GC3F863EDF3CK93F893EDI3G0A3F8C3G0C3EDN3EDP3GO13GLS32LT3F8K3CD93F8N3EDY3DG93F8Q3G0Q27A3F8T3GOK3DGH3EE93DGJ3G3W3GMH3EEF3G133EEH3G163EEJ27M3EEL3DGY3G1C36R13GM43CEE3F9H3EEU3G1I3EEX3G1L3CER3G1T3DHR3F9Y3EF634TJ3DHN3F9U3CF63F9P3EF43EFE3DHV3FA13DHY3G203EFJ36I83FA735IS3G253EFO37E73EFQ3FAD3CFU3EFU3CFY3G2C3EFZ3G2E3CG63FAM3G2H3DIO39ZE3G2K3FAS2WB3GOM3G2O3FAY3DJ93DJ03EGJ3G2U3EGM3DJ63GTE35E23G2Y3DJC3CH63DJF3G323FBC3G353EH13CHI3G383FBH3GOP3CHQ3DJW3FBK38652173GLP3G3I3DK33FVN3FBR3DK73EI43DK93EHL3G3Q3FBX35P53F2V3DKF3FC13EHS3CII3FC43EHV392H3GLC33783GLP3G433DD73G46332R3G483G5P3DM73FDQ3DNK37NF3G593GB13FCL3G4P3G533FE13FCQ39DA3G4V39GS32I53FE73GV135373G5B3CMS3G5O36WU3EJ73G5R3BLS3BTH38PH3GPY3G5A3EJE3EJR3FCO3EIU3FD93FDR3C9Y39GX3GVD36F63GVF3ECG3GVS3FDO3GUX3G4B3GQE332H3AWO39MB3BAJ393F3EIK39MH3FCJ3GV23GW03GQ23GVH3B6T3FEF3G613CMZ37AD38HT3CN23EKI3G683CCA3EKM3G6B33393G6D3A3U36KU3CNF3G6H3CNI360Z3DOZ36P23FF136NA3EL236B034AL3FF73G6T3CV13DRL3ELC3FH23ELF3CO63ELH3FGW34OR3GQU3G763EMY38PY3ELM38OE3DPX3FMW3ELU3G7E3COR360T3FFX3G7J3BBN3COY3G7N39KR3FG535QE3FG735293EMC3CPB33XN3FGE3FLN3GE53FGH3EMI37UK3G8234233G843FMT364L3G873DR03FGS38RN38KM3G8D3DR63G8G3DTG3G8I3FHG3G8M28N3FH53G8W3FH7331E3EN73FHD3EN93DRM3ENC3DRL3ENF3GYZ3FHH3DRU3ENK33WB3DRY3FHN3G993FHP35PO3FHR3G9D3FHT34H638TK3FHW3DOJ3AAV3DSG3EO43FI1362F3FI33CRP338H31TH3CRS338H3FI83G9V39O93DSU3EOI3GA03DSY3FIH3DT033N03GA534YS3FIM3GA93FIO38X83CSH3GAD3EOY3CSM3FGQ2FR3GAI3DTG3GAK3EP633213EP83EP53F0M3FJ53DTU3EPF3EPB34TR3GAU3FJC3GAX32ZC3GAZ3FJG34TR3FJI3DPR3DUB3GEU3FO427A3DUF3CWE33LW3FJR3G043GBD3CU03BVV39WC3EQ633WC3EQ83BJY3DUU3CU83BPQ3CX237TR3GBO399D3BKY3FMS3GBR3BRU3BYD35WN3FKD3GBW3CUP3EQP36F13CNE33VF3GC239JB35AB3EQW3DVK3GXC3GCZ369Q3CV53GCA3ER43FM93ESJ3GDO3CXN3FKZ3FME3E233DXH3GF73FL538YL3FL73ERK3FMM3CVT3ERI3GCS3DWE3FH233N43ERS3CW43DWK3FLL3ERX3FLO3ERZ3DUD2BB3CWD3FLT3H2O3DTG3FLW3DWX3GDD3DX03ESB3H3K3GDI34233GDK34113ESI27D3CVB3FFS3FMC39MW3GDS3H2R3GCK37PM3GCM3G7C33SP3H2Y3CYA3CVV3FMP3GEP3FMR3GDP3GE73CXQ3CXS3GEA3ER93FMZ39U13ETF3GEE3ETH3G863ETJ3A0Q3GEJ3EUX3H4P3ERL3FN73FG93FND3H4F3DR13DYO3GET3CWY3FNL3FNB3FNN3GFE3EU231TH3EU43GI83GF33DZ233VE3FOP3CZ439UJ3GFA3EUE3GFC33BR3EUI3EV23DYS3GFH3FNX3CW63EUO3FQK3H1W3GHM3FOF3EUU3GFR3FOI3FQV3GFV3FO538F43FOO3H5N27A3E033GGV35883EWU3GG33GI23FP33FOY358D3E2V3E0G3FOA3H5Q3CZN3FQG27A3EVR3GHQ3FPA3H683GHV3FQT33C43GGN3FPG3D1333N03E12379K3GGT373X3GGV3E1727D3FPP3GGZ3FPS3GH13F093GH33D1N3GKV3EWJ33133GH83E1O3EWN3FQO3FQ43E1T3GHI3EX73GHH3H693GGC3GHK3H5R3H6I33XF3H5U3GHR3GG239QI3H7I3E1Q36ZG3H7G3E2G3FQR3FOW3FP33GI4381Z3GI634VR3EXO3E2R3GIA3EYJ3EVH25N3EXV3D393EVZ3GIF34RG3GIH350Q3FRC3GIL3E363FRF3E4K3EY83GIR3FIK339T3GIT3D3V3FRP3E3H3H8A3FRT3E3L33KJ3FRX3FSI3GJ63FS13EZB3FS53FSP33VX3GJE3D3U3E413GJV32JA3D1B2613GJJ3H923FS03E3S3GJP3FSO3GJS3D3U3GJU3FH33GJW3D573EZK3H8O3D5B3E503EZP33NN3FTD340R3GK43FTG3EZU3E5C3D5N3E4X3GAO3GFM3FSZ3H9X3E4Q3GKF3FTH33LP3D623GKJ3D653F0B3FTL352O35B8352O3FTS3AHE3ALH3GKT3FTW3GKA3AHK3GKW32DB36DD3GL03C2Z34J53E5X32KP35TE3B7Z34MI3F3W3E9335O735EP345U35IL35OB35DO35OD32F423U29924K3C9O24L24G23O3F9C32XV37S437HY35OH35J73C7G3E9929H2VU38UZ24S3CHK24U3HBN3GU73F4F392U32S33FYW3A2E2VU32XH24V37IH254347U3A5N3G332A332W932XF27M347635P427L3HCG347C2AZ32LP3CGL2NW3HC73HC932LT32L632K532GO33FU27T28G392T319N23Z297257346R32GU24932GU380E3CCV33TB33IK397S34CK34IP2ES32J535NR328E32JE3G3X32TF28W37ZL21J2201S22K33IF39YT3CD03BT53BQ43BP33BQ63BWB3BP73BMO3DD13F6L3CAT38IF26332SZ3AHY348J380U3AI13CLC37C13AI5379237C43AI83BIA28927E34MJ3H1J3BZO38PN33V135683HEQ3AVQ26J1E3ED23CC633UZ35KQ396I35GH34AA379V3352369L36943APF3DJZ3HEW3HF13HEY3HEX38YO3HFA3ACD3F0833WW3E2C3B6J35AB34AA3FF533O13B0D35RD37UB244335N39UD348739RG35KM34OY35L936C336C6356836ML33L63COE3H4T3FLV3H4I2BB31H034WE3HG4381Z361D3CY437M33GXX27A33WY33KM33KP25A34ND2IV34VM31882B534G539NT33NC2IV363134NK38TK3D0Q32DK2842943D2I39KX333Q3HH23FNT33SP3CP52YQ3EY939QQ36U433MW2S63GIN3DQE38WV3DYD359427W343W34AS3HHL3GCJ3ELX26J36ZE364M3CRQ33LO3DYN3GZX3CXO3DTG27W35E631TH330H36MF33ZJ3A9Y34VM33MS3560365B38U436DY33ZZ36BD38ZE36ED38ZE333Q33QH36ES3CYZ36FW33B53B5J36663GL43EUD3B8Z3GNP3F3X3HB635EY35DI35OA35IN3HBB35IQ34VM3HBE32J53HBH3HBJ3HBL2543HBZ32W535J53HBQ3F4235JJ311K3HBV3HBX3HJ83C7Y35UL37803HC632VW3HC93HCB3C3D3EGX3HCE29Q32K53HCI339T3HCK3HJT35O62IV3HCO28Q31TH3HCR32WW3HCT3BGO25B3HCW24V3HCY395927N31K33HD238EP3HD53FZM3HD837E73C8A3HDC395G3HDE32GU3HDG331V2A52BB3HDK3GUK27D37IQ29L2BM3HDP3HDR3HDT39SU32JF3BW93BV83HE127N3HE33FZ43ARI3HE83CJ53F6Q3CJ83CJA3CBU3CJC3CBX3F6X3BF83HEM3DUM3BY03C2A38TA3HEQ35973HES3BJ33HEU3HF935KD3HFB3HFE39N93F7V3HF3330R3HF533WC369O3HLT377435FN3HLW333H3HEZ39973HM93E5I36EU394P36TT350Q3HFL371I33V638S737K133NL3HFR35XY36SM3DTM35KJ33FJ3HMR3C0Y3CC536Y0374333S627W31K33H4R3COE379U3FFN37U33HN23DZX34RR3HGE38YT340D361D3HGI37NX3HGL338O3AWY3HGP36XA3HGS33XV37G33D3U3HGX33NN3EM83HH1330R34S2335R3HH535ZG3HGN3CNK3HHA36OZ3HHC33L032DK3HHF34VM39R43A0Q33M63HHK34WJ3HHN340F3DQ33HHQ356035E63HHT31TH3HHS3HHW38MA3CSR27W2S63HI127E3HI333KZ2IV3CWS33NJ3ETU37G93HIB36YK2793HIE394J34Y53HII368T3HI93HIL3B4D3CYZ3HIP3DZY3A7Z3HIS3HB535DC35O83HB83HIX35DM3HIZ35E23HJ13HBF3HJ43HBK32XX3HJ72993HBO3HJA3C4U3HJC3DAI3HJE3EGY3HJG3HPU3HC039YD3HC2331R3F473F3A3CEE3HC832WW3HJO27U3HJQ32XK3HCF3HJX32K83HJV3HJS3HCH3HJY367334IP3HK13HQA3HCS3CD53HCU27M3HK83HKA3HD03HKD3HD33HKG3HD73BIL3HKJ37GG3HKL393132HM3HQO3HKO33CO3HKQ3HDJ3DKI3GLL25N3HKW3HDO3HDQ3HDS39VT3HDV3A1S39YG3BX63BQ73HL63CAQ3HE432K83AKU3HE83FZP3HEL3GBE3DUN3BYW3HLP34WJ3HLS3BJY3HLU3BSU3HMD35GG3HS835KN3HM0360X2793HM3369N3HF73HM736WU3HSA35KL3HF03HSA33JQ3HMF3GHW3GWN3BY4391S3HMK38QF3FQC39S033KJ3HMP39K435L93HFV36BM3HMV3DWB3HFH36ZA3EZI3HN03DPU3HG53H3H3HG733M03CZJ3HGB34UG3HGD3HHI3ETE3ELZ33WX35LA3HGK3HGM3HNO3DTG3HGQ39NN3HGT37CB39RP3HNQ32233HGZ33NC3HH53HNV3H7U36963HNI3H4134TI3HO134Y53HO32943HHE37UK33C03HHH3EM53HOA3E3Z3HHM3408340G32OV3HOG33LO3HOL39K33HHV39K335E631883HHZ35TS3HI2362R3HI53GEZ33LO3HI9342O3HP036ZS3HPD36P83HIG335R3HP635RD3HIK3BB23HIN3HAZ27E3HB137R53HPF35IH3HPH3HB73HIW35DK3HIY35IP3HPN32WM3HPP32LV3HJ53HPS3HJH3HPW35DY3HBS3HQ03HBW27T3HJH3FXJ37V83HQ8311K3HK332IS3HQD3HCD3HQG3HQL3HCM3HQK3HCL3HCI3HJZ3HQP3HCQ3HJM3HK43HQT3HK63HQW32J23HQY361O3HR034IP3HR23HD93C533HR638V334FQ3HDF3HRB3HDI3HKS3HRE2ES3HRH3HKY3HRJ3HL133TB37ZK3BX53HDY3BS93BT93HE23EBX3CAS3HRU39M53HE83DMB34B93ABD3ABF39AK37HR39AN3DMJ3ABK39AR37HY3ABN39AU3ABQ39AX3ABS39AZ3DMS3ABW39AN3ABY37IH3AC137IL39BB37IO32XD3DN33AC839BJ3ACA38143HRY3HEN3GBF3BN034TV3HLQ33WC3HS438W73HEV3HS73F7V3HSL3HMC3HSC35G53HSE34WJ3HM53HS53HSI35Q53HYV3HMB3HFD3HSN3CN138A13HFI3HSR3CU93GX833X73HSV3H6P39KX3HSY3HFS3HT435RE35L93HFX35KM3HFZ36F136ME341P27W3HGB340D3GDA3HN534RQ3HTF3FQV3HTI3ETK3HZZ3A343HNF37TJ3HNH33SP3HGO33MI3HGR39UI3HGU3HTW3E3F33NN3HTZ33L03HU133WC3HNX34Z13I0F39JF3HU834XG3HUA36TH3EY635LZ3HO83CY53HUH3HOD33WC3HOD35AY3HOF3HHR3FI53HHU3I1631TH3HUT35743HI035Q73HOT3HUZ35CN27D3HV233MG3AJO330R3HP3399T3HP536DD3HVC3B5B3HVE3F0W37GC3HVH3AEP3HVJ35O63HVL3HIV3HB93HVP3HBC3HPO3HJ33HVU3HPR3C1R3HPT32LY3FVN3HVY3HBR35F23HW13HQ23I2A32W53HW538XD3HW73HJL3HQB3HWA33RP3HQE3ATU3HJR3HWH35O63HWG3HQI3HCN3HWK3HK23HWM32IY3HWO3HCV32XQ3HQX3AIL3HD13HWU3HD63HKI3HDA37MR3HWZ32J23HX13HRA2B63HX427D3HKT3DKJ3HKV3HDN3HX93HL03HRL3HXE3BU33HDZ3HXH3HL73HXJ3F6M3ASR3HE83DNZ3B603FDF3DO23B7A34MI3HRZ3HLN3DUO3APC3HYP33V03HF73HYT38YH3HSK3HZ73HLZ35NH3HM13HZ034AS3HZ238W73HZ4334Y35NH3HYW3HZ83F7V3HSO33283HSQ34ZN3HMJ33TX3HFN3BW53HFP3HMO3HZL3HMT3DZ53HZO3HZM3HZR36DM335R3HG233K23HZW33BR3HZY360U3I013GG73CWN3GEH3HGF3DQ53HTM3HGJ334J3I093HNZ3CSR3HTS33W439KI3I0P3CC03HTX3H4U3HH0355F3HNU3I0M364B3HH73HO03E2H3HO2362Z3HUB3D3K3HHG369Q3HNB381C3HOB3HUJ34V73HUL32OH3HUN3HOK3I183HOY35GH3HOH38CG3HUV35H13HUX36963I1F3CYT3HV137DJ3HV436NY3HP2374F3HV83GL53HIJ38D03HIM3D6S3HIO3C2J3HPD34GV37OQ3I1X35DB27D35J93HVN35IM3HPL3HVQ29H3I243HBG3I263HJ63HVX35DV3HPX3FX53HJD3HBU3HQ13HW33HQ33I2I3HC1349M3I2L3HQR3HQC3I2P3HWC24N3HQH3HQM3HQJ3FUR3I2T3HXL2AD3I2Y3I863I313F3Q3HWP3I343HWR3I363HQZ3HKF3HWV3I3A3HWY2A43HDD3I3F37H23HX33HKR3I3J3HX629D3HX827D3HKZ3HRK3HDU3I3R3BV73I3T3BX83HRS3HL93B713HE8336Z2AX3HYK3HLM3FJW3HLO39BT3I4A335R3HYR35AU3I4D3CUA3I4F3HFC3I4H3HF23HSD36TK35683I4M35AU3I4O3I4G3HS93F7V35L835NH3I4U349E3I4W3HMI38Z13HSU3HFO35WJ3HFQ3I543CRD3H4Q3I573I553HT536XZ3A6V3HT835CA3HTA3CY93HG63I053HG937U33HTG33YY3I033H4O3I0534UR3I0733MR3I5R3HTQ3HNK3I0D3FIK3I5X39RD3I5Z3G7T3I613I0L3HH43I653I5X34XO3I0R33WC3I0T3HUC33LI3I0W3FN53HO9355N3HUI35683I1233KZ3HHP3I153G9R3I173IC03I193I6S3GYJ3HOR3HMZ3DXI3I5S3I6Y31TH3I1I3I7136EA3I1M335R3I753FU93I7737OH3I793AYZ3I7B3C32360Z3HB23EHV3HB435IH390724N24T3DD232YM3G093A893HE83GQF3BZF3GWA3GQJ39MG3GQL3BPH3BE93H1K3AQK3BWS3BED3HZE36XY3B353A4H39EF3FU43C0P39HF3ICO35QE349M3I7G311K32JJ3ICV3ICX3D7H38LS3HRW3F4D37NM3BXY3ID93HEO3BVW39GA3HF73H1S3B5E3BCY3BYA38DZ3E5V39EI3I7C38I836GQ3FWZ3GNQ32LK38XZ3IDS3F6L3ICY39ER22J3HE83EC03DL33EC23B0U38EP3BXS3BOC3EC738EV3EC93B123AG63IDZ3BHO3HS03C113BY23BVX3IDD3IE53B7Q3BEM3BM83AAY39D43IDL3GQ33IED339Z3B6S3C4T3FX035O63ICU3ICW3IEK3IDU3F5X3IDW3FXH3BVS3ID83IF23I473HS13BSP3BY33HET3IF83BEL3IE739RO39HC3HAX3IEB3IDM33BR3BQ13IEF3HIT3IFM3IDT3ICZ3BXD25N23F3HE83F603BDK3F623AFI3C233CM83ACV3CMA3AFQ3DE63C203CMF3AFX3BE032X33F6F3BE43F6H2BF3DLC3IFU3ECD3IF33GBG3BPL3IFZ3HLT3IG13AOG3IG33IFB3IE93D6R3AYZ3IFE3GWI3IFG3I7F3F3V3DAA3HB53IGD3IFO3IGF3CA736R13IFR3FE63GVX3IF13IH53IFW3IF43IFY3IF63IG03BY63IHC3BH43IHE38FI3IHG3DV03I1T392A39A13I843FXA32IY3IDP3I1Z35O93HVO3I7M3HBC29D37H83CEB3IHU34CA32HL32HX1J3I9G3I7U3I2F3I803I2H3BVE3IEO37N837ER3AMC390N39PS3AMG3G4H3AMJ3BUL39PZ3G4L25N3D1Y3C0Z35RC33X737XH3EQM3A6H33ZE35973IJL3DZF33AT34O028N35ZY36ED35ZY25N35I333O536JK3ERW3GWZ36JS34JS3887359735PX36Q03B1N3H863FQY33N031TH36K135PX34W034QG35ZF3EV72BB36CI3FR23HH6381H34YS36CI34ZG34VQ3H5S33NN33CD38KY34YS32233IKC34Z7333Q35PX343L28N354T333Q39J736LJ36TQ3BBR356M3IJR34WJ35ZY37O932ZC39K13DOX339A34PL35HL34AS35ZY3B40355U3968397338U43AHJ3H1H33BQ3BZA3IIF3GMF3HB33IHN3HVK3I7I3HPI3I7K3HBA3I7N2ES3IIO33783IIQ32VV3GOG25N21F3IIV374B35J73I7Y3HW23HBY3I8139T332TY35P43BRK38M4346M35T239E43IJG3AEB36FD3IJJ35C93IJL33WC3IJN33WT34RX2793IJS33WC3IJU3IJW33KE3AAO3H38333X3DXX35Q73IK23FK63IKZ37633H1W3FNS35ZG352T36OW3IKD33WC3IK53IKH39O93EXR3BQW33NQ3FDX34YS3CUL3IKP38J43IKR322333JS3IKU33N03IKW36LA3INM3INF339L3IL23AHM356W372G3IL73BKU35HF3ILA3ILK362R36OQ39NT3DOX33903ILI3IHD3CTD341P3GYU396J39923D1K3AK73GW232YX394S38CK3F5L3HW73IIH3IM03HVM3I213IIL35IQ3IIN33OI3AY13IML32HH3IM932HX25V3IML3HVY3IMG3I2G3HBO38IF26J3IPB3IDX3BVS3IJE3AA73IMS36EH35RI37FC2793IMX39Y2338H34GR34RX3IOG36ZV3IN535KM3GV235H3360O3IK0374Y3IND37253IO737533IKB3FQX35AB3INV3INL3IKY335R3INO39UE36FC3INR3BTP33NQ37FR3IKN33SF3INX38MK3INZ38U33IO2339T3IO433C43IO63IQL366H3IO93AKA3IOB35Y633393IOD3AMU3IOF3IOP3IOH369636OQ3ILF36O93ILH393R3IRF3AVR3ILN38Z3330D38903ILR3FDN3IOX38P03IIE3GNZ3ILW3ICR3ILY3I1Y3IP33I203HPK35OC3IP733QI3IP935NL3IPN3BFW34CB32HX26R3IPG3IIW3IPI3IIY3IPK39M53IML3AHZ3HEB378V3F7N378Z3HEF379334903HEJ3FE83IPQ37XE3IPS37PQ3IMV33WI3IPX3A1J27C3IJO349X3IJQ3IRE3IQ3336V3IN63EK43IQ73CWX3IQ93B453IQB3BR03IK53771391H3GI73E2Q35TS3IKX3FTI3IQD3EWU3IKI3H893BRU3IQR3E103IQO34RC3IKQ3H7P3IKT350R3IR12B53IR335FQ3IO83DTZ3IL43IOC374F369W35GP3IT835973ILC37TT3D1B3GX1384U3B7Q3ILJ35683ILL3AX73IRO391U3IRR3FU825M3IOY32RJ36S33HC437803IP227A3I7J3IP53IS539SM35IS3IS836703ISA3B6T3IPD36S13ISF3IME35DX3ISH3IMI3IIZ3B713IML3GPQ3AU93GPT3AY93C0A38IR3IMQ3AQH3ISY3IJI38CL3IPW34WJ3IMZ3IQ03IT73IN3360027C3ITB3FD336O93IQ83ET533893ITH3BWX3IU73IQE36463ITM3H873ITO3IO53IQK3IWD3ITS3ITY3IKK35ZG3IKM33N03IKO36SN34W83GGG369Q3IQZ3D1B3ITP34ZU3IWD3IL13IU9335R3IL536MQ3AQL36TR340S33K13IQ23IUG3IOI37QH3IUK3D1P3ION3II63IT83ILM393X3IOT3C2R3IOV3G4R33NT3IUW333R3IUY3HJJ3IIG3IHM3IFK3I7H3IV23IM13IV43HPM39YL35P53IV827I3IVA3IIR3IMA24Z3IVE36M03IMF3FA83IMH3HJH38LS3IML3BRJ3BRL3IMP3H7Y3B8E3IVU3GBU3AGF3D0R34AS3IVZ330E3IQ13IT83IJT3ITA3IQ537O73IJZ3IW9352Q36QV3BY93IWL3ITK3IK73INI34Z134UL3IQJ3ITQ3IR43IKG3IQN396O3IQP37XX3ITW3EXY339T3IWS3DS53IQX3IWW3IU33IZC3IX03IKF335J3IR63D6M38163IR92AQ3IRB3ARY3IRD3IJU3IN43IXD3ILE3DOV3IRK3IUN3IXC35KZ34SM399E3G6I3C0Y3IXO3B8X35PR339T34D231TH32L732VT3CH93HRM25N37PK37MT35LJ3BP42FG3C973FY538IF22J3IML3FZ03BHM3B8D3EQ33IDA3B183B9M36D03IAC36SP3A6H38KC3B0934V73HZD3IG13IDE3GYH3BRX362L3BCZ368T36TA3CRC3B5J33JS3HPC3J0K37V83J0M32LE32L632XF35P43J0S37VB3J0U3HDZ3J0W32L43BRG3F5X3J113G4X3G5T3BGR3BWO3IH63HYN27C3B7G3J1934M736TY3J1C3BB53J2H353Z3HS73BPQ3CPM3J1K360Z3J1M35RD3J1O36AY34873J1R3I7C3J1T38E83J1V3J0O3J1Y339T3J2037KF3J223BS93J243J0Y3AVG3IML3F0Y34I43C1L33QO3IGR3C1P33QW3C1R3C1T3AIQ3C1W37943C1Z3CME3C2233RI3C243EIM3A323BKP3BMY3HYM3BOK3J2F3J183HMH3J2I377H35C93J1D3J1M3J2M35MK3I4E3J2P3D0G3ADG362O3BH53J2U38D034ZB3J2X3HVF365Z389V36733J1W3J0P3J1Z3BR83J3837H53J3A3J263IGG1B3IML3BSI3A333J2B3BXZ3I9L3I483B7F3J423HFJ3DUW3J1B3J463J2L3J433J2N3J4B3B6J3J2Q36N735QE3J2T35WJ3J2V3J4J333A3J2Y3IG83J30394T3J323J1X3J0Q3J3632J23J4T37L03J4V3BPC3IGG1R3IML3GUR37T13DD83BAK393G3BHN3IHY3J543IFX3AT53J573J1G3B6J38F62793J473B9Y3J1F3I4X3J5F34AA3J5H3J4E3BK733WI3J5M3B4D3J5P3GQ33J5R38I92NW3J0N3J5U3J4R3A1T3J5Y35LO330D3J0X3J4W3IHS3DBS3J6435UG393A3GUS393E3G473DDB3J3X3BSM39J03FJX3J6E3BEC3J493HFK3J4533WI3J6K3BH53J7P3J593HM83J4C3BTR3J6R3APS3J4H37OH3J5N32ZC3J6W3GWI3J6Y37403J5T3J4Q3J353J4S3HXF3J4U3J773J253BUA3IGG21N3IVA3BWL3FE83J523IE03J3Z3BFD3J7O3J5D3J4A3J5A3J7S3J5C3J583GBL3J6O3HLX3BOS3J1L3J6L3J1N3J4I3J6V3J4L33W4383E3J4O3J333J5V3J8D3I3S3J393J8G364V3J8I3J7A27A32UT3G5I3J7J3C103IH73BCO3J6F3J6N3J8V3J6J3J8X3J6G3J2O3J5G3J4D36GK3J5K3J6T3J963ATO3J863IOW3J4M36S93J8A3J3428D3J743J8E3J5Z3J9H3BXC3J9K2633J9M3HLC3CAE3HLE3F6T38R73HLH3CAM3HLJ3J9O3C2T3J173J8S3J8Y3HSS3IYQ3J7T38RG3J7V3J8Z3I9T3J7Y3BY73J803J1E3J953J833J973IIB34AW3J883IFH3J703J4P3JAB3FB03J9E3I9A3J9G3F5G3J9I3ARI3J9M3IVM3C0632OW3GPU3IVQ39F53JAT3BQR3BJW3B2T3JB23JAY37LR3J9V3BBZ3JC13J1I3INA3J9Z3J7Z3JA13J943J8239FM3J8436FC3J1S3FUA3J9B3J723J8C3JAD3J9F3J8F3JBN3JAH3FYX33O93J9M3J6538G13GUT34B3395V3JBX3EQ43J9R3JAW3J9X3J7R3JC43B363JC63J1H3JB53J923J2S3JCC3J5L3JA43AXL3JA63IXP3DOI3B6R3JBG3J9C3J7339YG3J7529H3JAG3J9J3JCR23V3J9M3IGK34HE3CM53F633IGO3F653CM93BDS3IGS3F693IGU3BDY3F6D3IGY3AG13IH03BE63JCZ3J163JD13JC03J8T3J7Q3J9U38TB3JB83JD73BY63J1I3J6Q3JCB3J4G3JDD3JBA3JA53J9837GD3J0L3JCJ3J8B3JAC3JDN3JAE35LO37P337GX37KU37P737KW37P93BS937PC3BG024B24J24Y38R224O28Q3ASR3J9M3I9H36DA3FGG3I9K3J7L3I9M3APC3JB038TB3JEG3J7W3JC338S234AS336P3JFT3JB33J7X3JC939963HFD37D33IXF3GX7396O392138N437OG3JCE3B4D37K53I7C37MO3F5L3JAA3J9D3JCM3JBL3J4U3JF337N437E73JF637N73JCN37PB37L233CQ31TH3JFC3JFE32JM3JFH3AM83J9M3EJA3BTI3I0U3JFN39MO3J7M38IZ3JFR38KC3JFZ3JC2381C27938DR336O36EF3J1A3JG13J6P394737Q537O83DOX3JG735C43JG938TZ37DE3JDE3BOX3JGE3IG83JGG3GOH3JGI3JDM3J0T3JF129H3JGN37P53JGP37BB3JGR3JGL3JGT3DH937BN3JGW3JFD3JFF3JH03IGG2573J9M3EBB380C398639DX3EBG39DP398B39DS3EBM34763JIQ3EBP380H3EBR3AC939E138VW3HON3JH63A4D3II03JFQ3J9W3J9T3IYQ3JHG36JW3JHI3J443JB43JG2399C3JHN37FV36O93JHQ37OD38OQ3JGA37QE3JHV3BZ63JHX3GQ33JHZ3BI83JDK3JCK3JEZ3JI33JGS3JF239VH3JF437P63JI937KX3JI43JFA32K93JIG3JGZ39ER2233J9M3J5038NX3HYL3J2D3J403JB13JEK3JHC3J1I3J6I3JFW38OR3JJD3J5E3JJF3JHL396U3JJI3DOV3JJL396X3JFX3JGB35TZ3JCF3CSC3HPC3JJU39RW36IO3J713JEY3JBJ3JGK3BWA37N23JK33JI83DAG3JIA3BWA3JK83JIF3JGY3JFG3IEM3J9M3I403FDE3AZM3FDG3I443JH53J153IE139WC3JHA3JKR3J8U3JJA38L23JM03JEH3JHK3HLX3JJH37O73JJJ37M83J0F3JG8394I3JHH3JJP3JES3AXL3JJS3GWI3JL637OQ3JI13JCL3JF03JK03JI53JK23JGO37H937P837KY3HDZ3JLK37833JKA3JLN3AB73J9M3EI73BXH3A2N3BO23EIC3BO43GT83EIF3BXI3BXQ39ZL3DL73EIL3BOF3JKG3JJ43BAS3JLY3JJ83JHJ3JFV3JJB38QB34AB3JD33JKT3JM7393W36F637Q63JG63DOV3JJM3ALN38OS340E36FW3JL338283HPC38U836OP3GUL3GLB3G4032RX3JKE3I8326E23S25Z1W21527125T32I035E637AL25B32W93DGS25B3C9O37VG3FV624S33RF3CI031H035IT25534CG35IY37AU32LV32IJ2A5339T38UX24V3AIP24Y28032HX2373J9M38IF1B3J9M3CL73ACV3F7K3CLA3BYQ3CLD3H4M3JNJ3BSO3APC37DD35973DP339FG3HF9396P3DOV381N394D3AVR33Z137Q63ILQ3FQ837G73ACD3J1Q3EQE3JO33H1X3GDP339033ZV37TR34AS371W33WI38ZG397238ZI3IG83JO8348G3GLA3GUN3JOC32S03JOE3HQ525M3JOG3JOI3JOK3JOM3CDZ3JOP3JOR2993JOU3GM13JOY3C5C3JP035IU29M3JP437B63JP735P43JPA3JPC3JPE32KP1J3JPH395M2173JRN3BJP3IHW3JPR3JLW3J8Q38YC3JPV3DP23HF739FH3IXL3JQ13AD83GDL38BJ3A0234Y93J0H39N036A337OB3J4K3BJ5369Q3CUF3H3G3JQG3GQS38S13JQK2793JQM3B4D3JQO3GQ33JQQ3IEE3JOA3JQT3D7732HY3JQW383O37ZZ3JQZ3JOJ3JOL3JON39VH3JOQ29V3JR628F3JR83DGM32W53JRB3JP23JRD35EF3JRF3C9D3JP935EA3JRJ24O32HX21F3JRQ3J9K25N32VN3G583GEG3FJV3JFO3J5534TV3JRX333Q3JPX39GC381J39913JS2399H3JS438TO33353JQ63JS838E23JQA3D6S388G3B1C37DF3EQG3D1B34OM3JQI35683JSK3D1P3IG637UQ3I7C3JSQ3JBF3JSS3E693GUO33B63JTQ3JOF3JOH3JT03JR23JOO32I33JR53JOT3JT73JOW3JR93D8N3JTB3JP33JTE37GW3JRG3JTH33FU3JTJ3IPE32W03BPD32VN3C2O349U3C2Q3GYK3JKH3IHZ3J9Q39BT3JTX33UR3JRZ3JPZ3J0E3IXF3JQ2391C3B403JQ53JS73AEE3JUA35TS3JQB3JSD3JQD3JUG3CSC3JQH3GZS35973JUL3JSM3ATO3JSO3GWI3JUQ39FS3G3Y3F173FUI35NL3JUW3JQX3JSZ3JR13JT23A1S3JT43JOS3JR73JV63JT9313B3JP13JVA35IZ3JVC3JTG397Q3JPB2543JPD3JTK32T63JVI3IGG23V32VN3JFK3DOB3I463J6C3JJ638IZ3JVT37G33AZX399C37JH3IRP391B39953JW139TI334H3JU939L33JUB3AYZ3JUD35KM3JUF3BCU3JSH3JUJ3JWE36DD3JWG3AXL3JWI3JA73BZM3BX43JUS3FC63D1L3JWQ3JSX34DL3JWS3JT13JR33JV23JT53JV43JOV3C4L3JOX3JX03JV93JTD3JX43JP63JX635OQ3JTI3JX93JRK27E2433JXD3J9K24R3JVK28I39CL3JVM3BF83CPR3JTT3JH73JFP3JXM34WJ3JTZ39H839983IXM34AM396G3JXV39WJ3JXX3JW43JXZ3JW63JUC3JQC3JY43AVV3JY63JWD371V3JY93IEA3JUO3IG832YY3JN43BO73A2O3BO33A2Q3EIE3BO73JND34BK3EC63DE53J3W35Q739BP33O4332236W23H1H3BBN3HJI3HW73ASM37883IRY32LM3K0V35IB33FU32LT32LV3AFG34ER34HD3JYO2823JV33JWY3JYT3JV73FVN3JYW3CE53JVB3JYZ2A53G3Z3JSU370B32VN31K3337C3DLR3HLJ3JOP322832LO32W232HL3K1Q2VU3HCF331W35DO3HKM367837053JRH3JZ23JXA32HX24Z32VN3A2C3CHP2BF349M3J3E3C1K344W3F673JE333RO3J3L3C243J3N37AS3J3P33RA3AFU3J3S3C1T3J3V35TH27E3D513JTT34AE35UF34PL3G033CJI3A0035WJ3JC83JKU3JG334H5379K37AF3H6Y35PO333Q3D3M34V73EQV3FGC3CTO3ADQ3CYS32KP3CXA3ESV35HF27H3JLZ27C34J239MW3354336L3FMZ33913ETS39N33H8O36OZ3K3D3EQU3DQ33ERK388G3ERK33KU33L63AZZ340D35XZ3E213H4L3D1P3I6F3EUG3GEK33BR34OY3I053HN83K4C39GZ3K4F3HV02BB360D34YP3ICL34YS34RR33ZV359K358W3H2S24H36ZE361D33MI34KV3HU5330833XY39O73DTZ38X835BJ29J3F0M3I1335Y1356037Y12B534UR3HV33GHW3I6K3DZI38BH37UK359K33M5331338GF36ED37UD3K0N335534TV3J6P335R34A234KN37PL3GOI3E9Z3GRM32KW32VN32233JP4248379336HD3ARB3K2136RG37HC3E9D32IY3K0U3FWS3K0W37873K6L3CFQ39YM32L3378C32L832LA3HPS378I38FZ378M29M378O32LR27N3CD53K1232LY3K142BE3IM535EF3K0Z36HU21V32VN31BT37IH3GPS23P380E24I29F3K2I3F9D32RU3JYJ35ET3GMV32UB32VL3DI03C3K3GLM2BE39PM3JZ73IY832HX22R3K683EHL32XI3CF635EF3BF23K7S27E2373K8836R132VN2Y23C9J32W23DCK3K7P24U25L32HX133K8B32S03K8N25N1J3K8P2173K8P1Z3K8P21N3K8P21F3K8P25N22732SX3K923AY13K943G203K9632OH3K9835AD3K9A33WK3K9C3E4K3K9E23V3K9E23N3K9E24B3K9E2433K9E24R3K9E24J3K9E2573K9E24Z3K9E39M03K7U35K92BE35LO2IV27Y35P932KP21V3K923CHR32WI3ACG3K9E22B3K9E22Z3K9E22R3K9E23F3KA738IF2373K9E37073K9E133K9E1R3K9E1J3K9E2173K9E1Z3K9E21N3K9E21F3KAM22632SX3KB33AY13KB32LS36HT3IPE3KB532OV3KBB27E26B3KBD3FA2331K3KBG27A26R3KBJ35VO3KBM23N3KBM24B3KBM38YB32TC3KBM24R3KBM24J3KBM2573KBM24Z3KBS36RJ32KW3KBM21V3KBM22J3KBM22B3KBM22Z3KBS370Y32Z43KBM23F3KBM2373KBM1B3KBM133KBS367Z32PR3KBM1J3KBM2173KBM1Z3KBM21N3KBS36853G4D3AMD38SV39PT3IJ83BUK390U3IJB37F427D26T32ZC273379B3F7V3HSA336S35SW3FEN36XZ33103A7L3A6D3FGP33M62AQ26V3K8K3IBV3KDT3IJV35GI3GV23GCT3DXO3FGP3DYO3DQL3FKV3AYK37TY33L63K453IAT33N03HTD3CSC379K357Y3ADL338W3HI13363341P339W3E3333N03KE33F00342B2HU3364330G3KEI339L364Q3F0P3FO53IR927H33C136ZV3KF039MW39NW3FL13D1K3A6Z33ZP37A033VQ33LG37U33305336L33C833083IZI35942B538Y634AS3KFK39X436FP33442AQ3KFM350L35VO36OU37V23H5Q39S33D183E0N33NN360D3EVS381C3KFJ34WJ3KFM34WE34RR31MQ3D5N3D3R3CNT3EZ8330D34UR3IUL34NO34SC36EY3GJ53KGG3FT2362J34WB3JEV36X03K4D363134YP3ELX3GFO3G6J38ZB3D0T39N0343S3HN23GHS3BMW34W835Y13HGY3GGI362N2YQ2B537OL34XG37OL36JY3KFV3EX732BD3DQP3IWO3KH239GZ3KH43GKC36JI3KH738F62B5346O34AS3KHS350D35Y134UG3CYI388U368O36FC35S83IN733C436TA3EXX32OO352R37QH333Q368B33S634OK33C6312W3DTU32JR3H783H3R33IR33Z034UW2G43KHF36FD312W3DS533AM35B02G4317O3HI938KY312W31K3317O354Y2OM36FK312W36FJ3GGY340K336L3KIF3KFG33BQ3GBV3KIL36V33KIN3A173KIP3IWT33BH35Y13KIU27D3HVC3AAE35AB2UM318O36663KIX3561318O3KJ132TI330R3KJ436Y13KJ633893KJ83GH63KIH3H233KJD351T3KJF3IAN32JR3KIQ36FF2OM3KIB33AJ3KIA3IYY2OM39O533YA312W3KFB33BH3KE83KJL3I5V2TQ3KKQ3828379K2G4360D3GGU34P7318O333Q36ZU33M337A736V33191322Q3KE333O736B33AE036ZU3KES27D36ZX33ZR36X9356821U36P5312W3E1N36ED3E1N36022OM366E32ZI333Q366E333Q35GX33S6312W3KFD350X3KKK3KJH36CK2YQ312W3KLW34Y53KM6343L312W3DTP34PL3AE434AS3KM63EWK2U5374F243336V3IB43CSC3KEV3H093HNM3F7P3FRO322335A133MI3IR03E3H35Z634YS35BH3DT634H33D0Q3EV93KMU3JUH3FEL3EOP3D0D3KN53KN133NN3EO03KN43CSC3KN63H8R36LM3D3U35Z63D0Q3GZZ33LI3KMV3JDI3FII3H0A3GA83I0H32233DT52B53KNN3FRR3KMX33N035FC3KN93H9H3CSP39KE3KNW3FT734H334YS3DU43KNE3KNA32233IJE3KND3KN03KGA3CS927A34IY3KOA3KO23CTR3KOE33ZT3KOG3EYB3D2D3KOK3D4T33NN3GHU34US3KO53KNF3KGB339T3FQR3KOS3EYQ32233EYD3KNM3H9E33NC39O534RI330E3IQV38F629421P34WJ3KPF34V73FNS354Y2AQ3KPH3IZT25N3KPM35ZG3KHF3H6T35ZS3GIH35Y134SC3E2O343C3H8M33M63KPE3KPG341P2943KG83KN03KO23E2S34RO338I3KGF34SM360T34P03EXV3EP52Y2382I33352AG3KGN33L03K5D3ITZ3IWH3HU63HA73KGU33Z83KGW34OM39UU358W3IQV32OH123GA63HGV33MQ35WZ3GH635GH34SC38AD3GIV3FJ03DM533AD38WI38CG2FR3E4L3CSL3EP83KRC2VU3FRQ3CSO3GIK3KRH35XF34P03E3V3CSO3EYX3CSL3KQW34UW3IQV3KH13GA63DQP3KPC3ITX3KHL37AI353Z34SC3EYP3EY43KPZ3HH9339Z3ALM3A9H33WI3KPQ3A173KPS3JFM36FD3KS13IZL3KH33KS435B034SC3D513KPY39RV3KQ033Z235CE33BJ359S3KOG2R834YS3FS231883KI03FEL3KOP3GA63E47360D31K335CT3K393EXW36DT34S2330834JS3IQV35Y4335R333D3KLX3KJ7350X3DTP3KKB3H232G43FEX2UM3KIO32JR3KK936DZ3IUV374G33WI33B43KTJ33WV331D3KIY3EK42G43KKN2UM3KE83KJQ39NN2TQ3KUB3KEC35NN25N36DJ3D193KIS31H0333Q26935CG31913FEX2H631BT3KE3319136ZJ31913KUN33613KUM33WV3KK33KQB3IN43ATM33132G433L236P83KV736WF3FS933WI3KLS335R33KY34V737A43311330N312W34NC369V3IBM359Q3KVE35CG2G43KLZ2UM36C333XN3KTW33JZ2YQ2G43KVF34Y53KW0343L3KVR357Z33BH3IXI3KW0340029426039EA3AR13KSE34Z13JXI32RJ24F33WI364M388J2943GJK3HGW3KJG3KGG357934SC3EZS3K5A332137YS384I33MW3F0S25N22Y3KQ63DTQ3G7G33BA3KQU384U3KQH3KNH2FR33A83I73343J359S3E1K26J36G434SC3GL03EWE3KQD34OR3FU63EOZ3H0J3KM135GH3KKJ3GL5355Y34P73DQY34NP3A173KHZ3JVO3D1P31913EX238PO3D6333Z834OL34OH35Y134P03HLL360E33ZK3CZV360I2FR2533KVC33WC3KYH33S62FR362D2AG3KR43KXQ338B3KXS33ES3DTE2VU39O533ZH3973333Q24X3KWE3KUG317O3E4L343F2UM3KZ03KUY335R3KZ735S53GHM2UM317O3GIK3KYC3KU938G834XO2UM24K3KSC335R3KZL34V73KKX3KJP3H3H31IF33BG3KZH3FLV33YU3KUI32R63D2I2GM31H03B2633V93KZQ3AG7360T31A731BT3BDI338B3191317O3EZ23CWU35Z62H634VM352O338B3KF03JRT3I0031H035LZ3KXZ364M31H034002FR32VX36P83L0V34AB343838183KRI34SQ2VU360433BG34SC2VU3KYF3ALI3KYI333Q22F35CG3KYM363Z3KYO33213KYQ39272V034O83EOV3KYV3DTN32ZC33BX335R2293KZ13KZD3I7I33Z72UM3L1S3KZ827D3L1Y34TI2HU22A3KZM3H3T33WV3KY234AW364V3L05355Y3KUE38U432KP3KZY35GH3L0127D2J33L2F33YY36DJ3K5234H33154322Q24935KQ3KGF3KXW3L2D31BT3L0Q3FFN33MW36NL36W32FR21U3KWC335R3L3434V73L0Z383Z3L1133OC3HBU33T63L16375O2FR23B3L1A335R3L3I3KYL360P35333L1H35XF3KYS36N53KYU3HMW340R3L1P35682353L1T3BVT23O3L1W25N3L3Y3L1Z27A3L443L2225N2363L2527A3L4A27C3L2833253L2A35XF3L2D24D33B935Z63L2I39YM33B932BD3L2N35XF3L2Q32TC3L2T32KP3L2V3H3H3L2X37UK3KT33H3H33NM33WN3L323DTV3L3533X33KXE379Y3KY834M734P02413L3E37GD3L1735YG2FR1N3L3J2GN3L1D3L3N3L1G330E3L1I33YX2V02403L3T3C2R384U3L3W35971H3L3Z317O3L4134Z42UM3L603L4534YI3ATM2YQ2HU1I3L4B25N3L6C3L4E3FRN3B4S3H3H35793L2D33A33L2L3L4M3KUH27D2463L4P3HTE341J3L4S36E62453L4V3KWG3497318O3L4Z36SR3L2Z33L03D3O3L55123L5727A3L783L383L5A33OC3KY934OR34Q03KYC3L3F36A92FR21J3L5L27A3L7M3L3M3KYN379Y3L5W34H33L3R24Q3L5V3ILP3L5X3C0D333Q21D3L613L1V3L642F538FI3L813L6933MQ21E3L6D3L8B3L6G3KY33L4H35Z63L2D3JFL35MH35XF3L4N3J0R3L6S3I003L6U35Z63L4T28S3L6Y3GEG38DI3L71382E3L513ELO33MW395W3L0T25N1Y3L793L943L593KY73L7E3L5C34OR35N93L153L5G3L3G3CQ23KDT3KVD3I1H3KDT34SL3L7R3KYP3L3Q39733FE836B93L1N3DTQ3L5Y33WC25T3KDT34AE3L1U3IV23L423L9X3L673LA33L4825U3KDT34XG3LA73L8E3L293L6J360T3L2D33GS3L8K3L6O31H0352K3I003L4Q3CC43L8R36E624H3L8U3L0M3DPS3L8X3DPD3L8Z38BM38DH3L9325E3KDT36ED3LB03L7C3L993L3B34P03BVS32KL3L7J36WF2FR3KDS3KXC3KVE3L9L34OQ3L9N3L3P35Z63L3R24M3L7X3KYW333A3L1Q27D26P3L9Y33ZJ3LA025N3L6336602UM3LBS3L673LC03L4826Q3LA833WC3LC43LAB3L4G3LAD34H33L2D398Q3L6T34NO3L8M34R43L2L3LAM3L8Q34NO3L8S370B3LAR3KY034PJ3LAU3FH33LAW3E2G36J63L5526A3LB133WC3LCX38MG3KTB3IRT331M26P31BT2283FZS36X937U939J135HY3HZM3CCE3G8L33NL25U3FLE3H3K37TW357135QH355B3COV3ELU3KNV39RL34AK3GIV3EYT33UB3E5833AG35XF312W339T350734X6372B3JMF3G8W3AE43E4J2VU35RO3E1D368H3GK734GQ34VE2G435N5337Y2UM34L634LM3GKO3F093KIS3E5L33X22173L6P3KVU33M331542V034XO31543CR036OZ3LEY351T315434NG353731A735RO2YQ31A735FZ34XG35FZ34AE31A739UO3KL533N0338M33IR2H63HGB2LX3IQF36V33EV73FLV34XO2TQ336H36OZ3LFS351T3LFO3L6P36F62I634SS2293FGN31TH3GDG32L031TH3FM5339631TH3HI627A34JS3LG933VX32FN35LZ338B32BL339T32DK338B32ZI31TH34YY3I003I1V3DBS33BE3L0E27D2223AE03L0531SA31913DXZ3CWU364M31SA2LX3CYI361H35LZ3KDM34LH3LGX33352H63CYL33352LX3LH233352TQ3LH533BL319132DK3LH82H63LHA3HHG365Q33382TQ3LHG36TH3LHJ25M2H62S63LH82LX3LHP2TQ3LHR33352I63LHU2R83LHW2LX35E63LH83KUD35282I6337A33382R83LHU32L03LHW3LHT33YT336L2I63LHP2R83DXZ333532L03LHU33963LHW2I63CYI3LH82R83LHP32L03LI4350S3LHU34JS3LHW2R8365B3LH832L03LHP33963LIS3DR73LHU32FN3LHW3LJ33LIN350S3LHP34JS3CZD333532FN3LHU32BL3LHW3396337A3LH834JS3LHP32FN3483333832BL3LHU32ZI3LHW3LJO3LJL32FN3LHP32BL3LJP3HPD3LHU334U3LHW3LK03LJL32BL3LHP32ZI3LK13335334U3LHU356E3LHW32BL357T3LH832ZI3LHP334U3LJF356E3LHU332G3LHW32ZI35883LH8334U3LHP356E357T3338332G3LHU3CR03LHW334U3DS03LH8356E3LHP332G3LL933353CR03LHU33303LHW356E3D0D3LH8332G3LHP3CR03LJF33303LHU358E3LHW332G3DSD3LH83CR03LHP33303LJF358E3LHU33NW3LHW3CR03D0I3LH833303LHP358E3LJ433NW3LHU348I3LHW3330378R3LH8358E3LHP33NW3LJF348I3LHU33YK3LHW358E3BG93LH833NW3LHP348I3588333833YK3LHU33A13LHW33NW39IR3LH8348I3LHP33YK3DS0333833A13LHU33WE3LHW348I35FC3LH833YK3LHP33A13LNH333533WE3LHU2WA3LHW33YK3D153LH833A13LHP33WE3LJF2WA3LHU34C23LHW33A13D1G3LH833WE3LHP2WA3LN5333534C23LHU339Y3LHW33WE3D1Y3LH82WA3LHP34C23D0D3338339Y3LHU336H3LHW2WA34643LH834C23LHP339Y3LNT25N336H3LHU337Y3LHW34C235JL3LH8339Y3LHP336H3LP4337Y3LHU34073LHW339Y351K3LH8336H3LHP337Y3LJF34073LHU3D2I3LHW336H3GHU3LH83LEH352834073LJF3D2I3LHU36AB3LHW337Y3D5X3LH834073LHP3D2I3DSD333836AB3LHU34PC3LHW34073D3Q3LH83D2I3LHP36AB3D0I333834PC3LHU3D2X3LHW3D2I3D493LH836AB3LHP34PC3E0H33353D2X3LHU35YG3LHW36AB3E2S3LH834PC3LHP3D2X3BG9333835YG3LHU35G33LHW34PC3EXV3LH83D2X3LHP35YG3D0Z333535G33LHU33033LHW3D2X37LK3LH835YG3LHP35G335FC333833033LHU3D3M3LHW35YG3E4L3LH835G33LHP33033LS133353D3M3LHU3D3H3LHW35G33GIK3LH833033LHP3D3M3LSD25N3D3H3LHU36MS3LHW33033FRQ3LH83D3M3LHP3D3H3D15333836MS3LHU34PQ3LHW3D3M3EYX3LH83D3H3LHP36MS3D1G333834PQ3LHU343W3LHW3D3H3E3V3LH836MS3LHP34PQ3EXE343W3LHU3D463LHW36MS3EYP3LH834PQ3LHP343W346433383D463LHU33M83LHW34PQ3D4H3LH8343W3LHP3D4635JL333833M83LHU33JG3LHW343W3FS23LH83D463LHP33M8351K333833JG3LHU38Y63LHW3D463E473LH833M83LHP33JG3GHU333838Y63LHU36LX3LHW33M83D5U3LH833JG3LHP38Y63D5X333836LX3LHU33UY3LHW33JG3EZS3LH838Y63LHP36LX3LVC333533UY3LHU33IN3LHW38Y63F0S3LH836LX3LHP33UY3LVO3FT33LHU34QB3LHW36LX3FU33LH833UY3LHP33IN3EYS333534QB3LHU33RS3LHW33UY3E5Z3LH833IN3LHP34QB3LWB337B3KY0333833QH3LHW33IN3F0Y3LH834QB3LHP33RS3LWN33QH3LHU34MJ3LHW34QB3HLL3310344131543FU32BP336L31A73LHP31913FSK3LHB3LWP3LHE3DR138YL31A73LH733C631913LHP2H63LXF3HHG3LHU3LHI37M13LHL3LJL3LHO35282LX3LXR3LIM33TX3LIY37M13LHY3LJL3LI135282TQ3E2S33383LI6341E3LI837M13LIA3LJL3LID39CR2I63LYB33353LII341E3LIK37M13LY2339N3LIO3LCA33SQ2R83LYM3GYK3LIV3LXJ33BL3LY43431336L3LJ1352832L03EXV333833963LJ63LZ125M3LJ93LJL3LJC352833963LZ9333534JS3LJH3LZD3LJK3LZ43LJM352834JS3LZK35433LXH3CQB3LZD3LJV3LJL3LJY352832FN3D3933353LK3341E3LK537M13LK73LZQ3LK9352832BL3M043LKD341E3LKF37M13LKH3LZQ3LKJ352832ZI3M0F3LKO341E3LKQ37M13LKS3LJL3LKV3528334U3LYY3LKZ341E3LL137M13LL33LJL3LL63528356E3LYY3LLB341E3LLD37M13LLF3LJL3LLI3528332G3M0F3LLN341E3LLP37M13LLR3LJL3LLU35283CR03M0F3LLY341E3LM037M13LM23LJL3LM5352833303LZU3LM9341E3LMB37M13LMD3LJL3LMG3528358E3LZU3LMK341E3LMM37M13LMO3LJL3LMR352833NW3LXR3LMV341E3LMX37M13LMZ3LJL3LN23528348I3LXR3LN7341E3LN937M13LNB3LJL3LNE352833YK3LWN3LNJ341E3LNL37M13LNN3LJL3LNQ352833A13LWN3LNV341E3LNX37M13LNZ3LJL3LO2352833WE3LW03LO6341E3LO837M13LOA3LJL3LOD35282WA3LW03LOI341E3LOK37M13LOM3LJL3LOP352834C23M0F3LOU341E3LOW37M13LOY3LJL3LP13528339Y3M0F3LP6341E3LP837M13LPA3LJL3LPD3528336H3LZU3LPH341E3LPJ37M13LPL3LJL3LPO3528337Y3LZU3LPS341E3LPU37M13LPW3LJL3LPZ39CR34073LYY3LQ3341E3LQ537M13LQ73LJL3LQA35283D2I3LYY3LQF341E3LQH37M13LQJ3LJL3LQM352836AB3LXR3LQR341E3LQT37M13LQV3LJL3LQY352834PC3LXR3LR3341E3LR537M13LR73LJL3LRA35283D2X3LWN3LRF341E3LRH37M13LRJ3LJL3LRM352835YG3LWN3LRR341E3LRT37M13LRV3LJL3LRY352835G33LW03LS3341E3LS537M13LS73LJL3LSA352833033LW03LSF341E3LSH37M13LSJ3LJL3LSM35283D3M3LYY3LSR341E3LST37M13LSV3LJL3LSY35283D3H3LYY3LT3341E3LT537M13LT73LJL3LTA352836MS3LW03LTF341E3LTH37M13LTJ3LJL3LTM352834PQ3LW03LTQ341E3LTS37M13LTU3LJL3LTX3528343W3LWN3LU2341E3LU437M13LU63LJL3LU935283D463LWN3LUE341E3LUG37M13LUI3LJL3LUL352833M83LXR3LUQ341E3LUS37M13LUU3LJL3LUX352833JG3LXR3LV2341E3LV437M13LV63LJL3LV9352838Y63M0F3LVE341E3LVG37M13LVI3LJL3LVL352836LX3M0F3LVQ341E3LVS37M13LVU3LJL3LVX352833UY3LZU33IN3LW23LZD3LW53LJL3LW8352833IN3LZU3LWD341E3LWF37M13LWH3LJL3LWK352834QB3M0F33RS3LHU3LWR37M13LWT3LJL3LWW352833RS3M0F3LX0341E3LX237M13LX433YT3LX73D6T3LZQ3LXC352831913LZU2H63LHU3LH437M13LXL3LJL3LXO35282H63LZU3LHF341E3LXU35B43LXW3LZQ3LXY39CR2LX3LYY3LYS3LYC3LZD3LY63LZQ3LY839CR3LYA341E3LYD33TX3LYF35B43LYH3LZQ3LYJ3BAR2I63LXR3LYO33TX3LYQ35B43LYS3LH83LIP35282R83LXR3LIU341E3LIW37M13LZ33LYT3FGN3LJ23H8Q33SQ3LZB341E3LJ737M13LZF3LZQ3LZH39CR33963LWN3LZM341E3LJI37M13LZP3MD433963LJN3GI133SQ3LJR341E3LJT37M13LZZ3LZQ3M0139CR32FN3LW03M0633TX3M0835B43M0A3MD43M0C39CR32BL3E4L333832ZI3LKE3LZD3M0K3MD43M0M39CR32ZI3GIK33383M0Q33TX3M0S35B43M0U3LZQ3M0W39CR334U3FRQ33383M1033TX3M1235B43M143LZQ3M1639CR356E3EYX3LLA3LZW3M1C35B43M1E3LZQ3M1G39CR332G3MEM3LLM3LZW3M1M35B43M1O3LZQ3M1Q39CR3CR03FRV33353M1U33TX3M1W35B43M1Y3LZQ3M2039CR33303EYP33383M2433TX3M2635B43M283LZQ3M2A39CR358E3MFI36LK3LML3LZD3M2I3LZQ3M2K39CR33NW3D4W33353M2O33TX3M2Q35B43M2S3LZQ3M2U39CR348I3FS733353M2Y33TX3M3035B43M323LZQ3M3439CR33YK3MGE3M3833TX3M3A35B43M3C3LZQ3M3E39CR33A13E4733383M3I33TX3M3K35B43M3M3LZQ3M3O39CR33WE3E5333353M3S33TX3M3U35B43M3W3LZQ3M3Y39CR2WA3MGE3M4233TX3M4435B43M463LZQ3M4839CR34C23H9Y3M4C33TX3M4E35B43M4G3LZQ3M4I39CR339Y3F0S33383M4M33TX3M4O35B43M4Q3LZQ3M4S39CR336H3MGE3M4W33TX3M4Y35B43M503LZQ3M5239CR337Y3FU333383M5633TX3M5835B43M5A3LZQ3M5C3BAR34073E5Z33383M5G33TX3M5I35B43M5K3LZQ3M5M39CR3D2I3F0Y3LQE3LZW3M5S35B43M5U3LZQ3M5W39CR36AB3MEX33353M6033TX3M6235B43M643LZQ3M6639CR34PC3HLL33383M6A33TX3M6C35B43M6E3LZQ3M6G39CR3D2X3MJW33353M6K33TX3M6M35B43M6O3LZQ3M6Q39CR35YG3MFS3H8C3LZW3M6W35B43M6Y3LZQ3M7039CR35G331N133TX3M7433TX3M7635B43M783LZQ3M7A39CR33033MKS3H8O3LSG3LZD3M7I3LZQ3M7K39CR3D3M3MGN3LSQ3LZW3M7Q35B43M7S3LZQ3M7U39CR3D3H3KZT33SQ3M7Y33TX3M8035B43M823LZQ3M8439CR36MS3MLO3M8833TX3M8A35B43M8C3LZQ3M8E39CR34PQ3MHJ33353M8I33TX3M8K35B43M8M3LZQ3M8O39CR343W3B263LU13LZW3M8U35B43M8W3LZQ3M8Y39CR3D463MLO3M9233TX3M9435B43M963LZQ3M9839CR33M83H9Y3M9C33TX3M9E35B43M9G3LZQ3M9I39CR33JG3BDI3LV13LZW3M9O35B43M9Q3LZQ3M9S39CR38Y63MLO3M9W33TX3M9Y35B43MA03LZQ3MA239CR3MAJ3MO93LZW3MA835B43MAA3LZQ3MAC39CR33UY352O33383MAG341E3LW337M13MOG3MD43MAL39CR33IN3L1433SQ3MAP33TX3MAR35B43MAT3LZQ3MAV39CR34QB3MK63LWO3MB03LZD3MB33LZQ3MB539CR33RS3L1L33SQ3MB933TX3MBB35B43MBD34313MBF3FU333YO3MBI39CR31913MP133383MBM341E3MBO35B43MBQ3LZQ3MBS39CR2H63ML33MBW33TX3MBY37JL3MC03MD43MC23BAR2LX3LBX3LHS3LZW3MD338YL3MC93MD43MCB3BAR2TQ3MPZ3LI53LZW3MCH37JL3MCJ3MD43MCL34342I63MLX3MCP33SQ3MCR37JL3MCT33C63MCV39CR2R83CJM33383MCZ33TX3MD135B43MD33LJ03LYV3MRF38OM3MD03LZW3MDB35B43MDD3MD43MDF3BAR33963MMS3LJG3MDK3LZO3LZV3LZQ3MDP3LZS25N3L2K3MDS3LZW3MDV35B43MDX3MD43MDZ3BAR32FN3MQU3LZX3LK43LZD3ME73LH83ME93BAR32BL3H9Y3MEE3M0H3MEG35U63LH83MEJ3BAR32ZI3L2S33TX3MEO33SQ3MEQ37JL3MES3MD43MEU3BAR334U3MSH3MEZ33SQ3MF137JL3MF33MD43MF53BAR356E3MJA33353M1A33TX3MFB37JL3MFD3MD43MFF3BAR332G3L3133SQ3M1K33TX3MFL37JL3MFN3MD43MFP3BAR3CR038V733383MFU33SQ3MFW37JL3MFY3MD43MG03BAR333036N63MFV3LZW3MG737JL3MG93MD43MGB3BAR358E3MPC3M2E33TX3M2G35B43MGI3MD43MGK3BAR33NW3L4K3MUT3LZW3MGR37JL3MGT3MD43MGV3BAR348I3MU63MGZ3LZW3MH237JL3MH43MD43MH63BAR33YK3MUH33SQ3MHA33SQ3MHC37JL3MHE3MD43MHG3BAR33A13ML33MHL33SQ3MHN37JL3MHP3MD43MHR3BAR33WE341O3MHM3LZW3MHY37JL3MI03MD43MI23BAR2WA3MVB3IOP3LOJ3LZD3MIA3MD43MIC3BAR34C23MVL3LOT3LZW3MII37JL3MIK3MD43MIM3BAR339Y3MLX3MIR33SQ3MIT37JL3MIV3MD43MIX3BAR336H3KMJ3MIS3LZW3MJ337JL3MJ53MD43MJ73BAR337Y3MWG3MJC33SQ3MJE37JL3MJG3MD43MJI343434073MWP33353MJN33SQ3MJP37JL3MJR3MD43MJT3BAR3D2I3MRY3M5Q33TX3MJZ37JL3MK13MD43MK33BAR36AB3L5433SQ3MK833SQ3MKA37JL3MKC3MD43MKE3BAR34PC3MWG3MKJ33SQ3MKL37JL3MKN3MD43MKP3BAR3D2X3MXT25N3MKU33SQ3MKW37JL3MKY3MD43ML03BAR35YG3H9Y3M6U3MLE3LZD3ML83MD43MLA3BAR35G33L5E3MZC3LS43LZD3MLJ3MD43MLL3BAR33033MWG3M7E33TX3M7G35B43MLS3MD43MLU3BAR3D3M3MYZ3M7O33TX3MM037JL3MM23MD43MM43BAR3D3H3MTK3EYL3LT43LZD3MMD3MD43MMF3BAR36MS3L5U3MMA3LZW3MML37JL3MMN3MD43MMP3BAR34PQ3L6M33SQ3MMU33SQ3MMW37JL3MMY3MD43MN03BAR343W3L6R3MMV3MN53LZD3MN83MD43MNA3BAR3D463L6X33TX3MNE33SQ3MNG37JL3MNI3MD43MNK3BAR33M83L763N1I3LZW3MNQ37JL3MNS3MD43MNU3BAR33JG3MPC3M9M33TX3MO037JL3MO23MD43MO43BAR38Y634Q03LVD3LZW3MOA37JL3MOC3MD43MOE3BAR36LX3N0V33383MA633TX3MOJ37JL3MOL3MD43MON3BAR33UY3N1633SQ3MOS33TX3MOU35B43MOW3LW73MRM333533IN3N1F3MP23LZW3MP537JL3MP73MD43MP93BAR34QB3N1Q33383MAZ341E3MB135B43MPG3MD43MPI3BAR33RS3ML33MPN33SQ3MPP37JL3MPR339N3MPT35Q73LXB3N3334LH3L7W33TX3MQ133TX3MQ337JL3MQ53MD43MQ73BAR2H63N2K3LXI3LXT3LZD3MQF3LHN3N412LX3N2V3MQL3LHU3MQN33BL3MQP3LI03N412TQ3N363MC73LI73LZD3MQZ3LIC3N412I63N3G3LYN3LZW3MR738YL3MR93CTF3MRB3BAR2R83MLX3MRG3MD83LZD3MRK33C63LZ639CR32L03L8J3LZA3MRQ3LZD3MRT3LJB3N4133963N4E3MRZ33TX3MDL35B43MDN3LH83MS439CR34JS3N4M3LJQ3MS93LZY3LZX3MDY3N4132FN3N4V3M053LZW3ME537JL3MSL33C63MSN343432BL3N533M0G3MT03MST34833MSV3N4132ZI3MRY3MT13MEY3LZD3MT53LKU3N41334U362Q3MEP3LZW3MTD38YL3MTF3LL53N41356E3N5U3MTM3MTW3LZD3MTQ3LLH3N41332G3N643DRZ3MFK3LZD3MU13LLT3N413CR03N6C3DS13LLZ3LZD3MUC3LM43N4133303N6M3MG533SQ3MUK38YL3MUM3LMF3N41358E3H9Y3MUS33SQ3MUU37JL3MUW3LMQ3N4133NW36ZO3N8A3MV33LZD3MV63LN13N41348I3N5U3MH03MVM3LZD3MVG3LND3N4133YK3N7J3MVN3MHK3LZD3MVR3LNP3N4133A13N7R3MVX33383MVZ38YL3MW13LO13N4133WE3N6M3MHW33SQ3MW938YL3MWB3LOC3N412WA3N0C3MI633SQ3MI837JL3MWK3LOO3N4134C2395W3MWQ3LOV3LZD3MWU3LP03N41339Y3MPC3MX033383MX238YL3MX43LPC3N41336H3L9D3MX13MXB3LZD3MXE3LPN3N41337Y3ML33MXK3MJM3LZD3MXO3LPY3N41340739GY3NAN3LQ43LZD3MXZ3LQ93N413D2I3MLX3MY53MYF3LZD3MY93LQL3N4136AB3LAG3LQQ3LZW3MYI38YL3MYK3LQX3N4134PC3MRY3MYQ3LRE3LZD3MYU3LR93N413D2X34133NBK3LRG3LZD3MZ53LRL3N413MZ93M6L3ML53MZD3GID3MZF3N4135G33LAQ3MZK3M753MZM3H9T3MZO3N4133033H9Y3MZT33SQ3MZV37JL3MZX3LSL3N413D3M38DH33383N033MM83LZD3N073LSX3N413D3H3MLO3MM933SQ3MMB37JL3N0G3LT93N4136MS3MPC3MMJ3N0W3LZD3N0Q3LTL3N4134PQ38M933383N0X3MN43LTT3H9D3MMZ3N41343W3MLO3M8S3N1G3N193EZC3LU83N413D463ML33N1H3LUP3LZD3N1L3LUK3N4133M83LBM3MNF3N1S3LZD3N1V3LUW3N4133JG3MLO3N2133SQ3N2338YL3N253LV83N4138Y63MLX3MO833SQ3N2D38YL3N2F3LVK3N4136LX398Q3N2L3MOI3LZD3N2Q3LVW3N4133UY3MLO3N2X3N373LW43MBG3MOX3N4133IN3MRY3MP333SQ3N3938YL3N3B3LWJ3N4134QB3LCH3NF93LZW3N3K37JL3N3M3LWV3N4133RS3MLO3N3S33383N3U38YL3N3W3LX633BE3FU33KK2336Q3LXD3E4R3N443LZW3N473LXK3I6D3N4A3N412H639F633383MQB33SQ3MQD38YL3N4I33C63MQH34342LX3MLO3MC63MQV3LHW3N4R33C63MQR34342TQ3N0C3MCF3LYW3N4Y3GYJ3N503LHP2I63LCV3NGW3LIJ3LZD3N58335J3N5A34342R837PL3MRN3LZ03LIX3DR13MRL3MD63MPC3MD933TX3MRR37JL3N5Q33C63MRV343433963CMN33383MDJ3N5W3MS1365Q3N603N4134JS3NHB3N653LJS3N673LJW33C63MSE343432FN3ML33ME333SQ3N6F38YL3N6H3CTF3N6J3MDU25N3J9I3NIC3LZW3M0I35B43MEH3N6R3LKK360E3MSS3LKP3N6X3G933MT63N703EZC3N6W3LL03LZD3N7733C63MTH3434356E35KA3MF03MFA3N7E3N7K3MFE3N7H3NIS3MTN3N7L3LLQ3GG63MU23N7P3KFT3MTY3LZW3MUA38YL3N7V33C63MUE343433303GVN3MG43MUJ3LZD3N8433C63MUO3434358E3NI13MGF3M2F3MGH3D0J3MGJ3N8F3NG13N8I3LMW3N8K3D0R3MGU3N8N383O3M2P3MVD3N8S3GA73MH53N8V3NJF3N8R3LNK3N9033WD3M3D3N933NF33N8Z3LNW3LZD3N9A33C63MW3343433WE36F33MW73LO73LZD3N9J33C63MWD34342WA3B643N9G3LZW3N9Q38YL3N9S33C63MWM343434C23MPC3MIG33SQ3MWS38YL3NA033C63MWW3434339Y39AD3MIQ3LZW3NA733BL3NA933C63MX63434336H3NLF3NA63NAF3LPK3H7Q3MXF3NAJ3EZ533SQ3NAM3MXU3NAO3I623MJH3NAR36Q33MJD3LZW3MXX38YL3NAX33C63MY134343D2I3NM933353NB23NBA3LQI3MD73NB63LQN3NIZ3MK73NBB3LZD3NBE33C63MYM343434PC2EN3MK93LZW3MYS38YL3NBM33C63MYW34343D2X3NMY3MZ03LZW3MZ338YL3NBU33C63MZ7343435YG3MRY3MZB33SQ3ML637JL3MZE3LRX3NC336PJ3NC63MLG3NC83LS833C63MZP343433033NNP3NCE3NCN3MLR3MLY3MLT3NCK3NKC3NOI3LSS3NCQ3GIW3N083NCT25N2513M7P3LZW3NCY38YL3ND033C63N0I343436MS3NNP3ND53NDD3ND73NMG3ND93LTN3NKX3MMT3LZW3N0Z38YL3N113LTW3NDJ35983M8J3N183LU53NDP33C63N1C34343D463D1S3NDN3LUF3NDW3GJQ3N1M3NDZ3NOR3NDV3LUR3NE43NJM3N1W3NE7318D3M9D3MNZ3LZD3NEE33C63N27343438Y63NPT3NEB3N2C3LZD3NEN33C63N2H343436LX3ML33N2M3N2W3NEU3FT33MOM3NEX377N3N2N3LZW3N2Z37JL3N3133C63MOY3BAR33IN3NQG33383NF83N3H3LZD3NFC33C63N3D343434QB3MLX3N3I33TX3NFJ38YL3NFL33C63N3O343433RS2203N3J3LZW3NFS33BL3NFU32RU3NFW36463N403NG03NR63LXG3MBN3LZD3N493LH83N4B34342H63MRY3NGC3MQL3LHW3NGG3CTF3NGI3MQ23K913MBX3MQM3MC83JH53N4S3LI232KQ3MCE3MQW3NGX3LIB33C63MR13NSQ3H9Y3MR53MRN3LIL3KY03MCU3N412R836IU3MR63LZW3MRI37JL3N5H3CTF3N5J3BAR32L03NS13LJ53MDA3N5P3EMX3N5R3LJD3NPC3N5V3MS83LJJ3MS23MDO3NHZ25N2253MS03NI33LJU3N683MSD3N6A36ZW3NII3MSJ3LK63I7D3ME83N4132BL3MPC3MSR3N6O3LKG3MSU33C63MSW343432ZI32WL3N6O3NIU3LKR3NIW3N6Z3LKW3NU13N733NJ13LL23DS33N783LL73NMG3MF93LLC3NJB3LLG33C63MTS3434332G3KLJ3NJG3LLO3N7M3NJJ3N7O3LLV3NUP33SQ3MU83NJX3LM125N3LM33NJS3N7X3NN63NVH3NJY3LMC3CRW3N853LMH31MR3M253LZW3N8B38YL3N8D33C63MUY343433NW36H43MV23NKE3LMY3NKG3MV73NKI3MRY3N8Q3LNI3NKM3LNC33C63MVI343433YK334L3MH13LZW3MVP38YL3N9133C63MVT343433A13NW23MVO3LZW3N9833BL3NL13CTF3NL33M393NON3MHV3MW83NL93IOP3MI13N9L25N34V23MHX3NLH3MWJ3IJD3M473N9U3NVC3N9X3M4D3N9Z3LP53M4H3NA23NTM3NA533353NM225M3NM43CTF3NM63NXI33443MXA3LPI3NAG3NMD3NAI3LPP2BN3M4X3LZW3MXM38YL3NAP33C63MXQ3NY43MPC3MXV3MJX3LQ63MDR3NAY3LQB25N21W3M5H3MJY3NB43NN333C63MYB343436AB21X3M5R3NN83LQU3FQW3MKD3NBG3NUW3LR23NNH3NBL3NNQ3MKO3NBO31AX3M6B3NNR3NBT3ML43MKZ3NBW3NY33MKV3NBZ3LRU3NC13NO53LRZ3NVL3MLF33SQ3MLH37JL3MZN3LS93NCB25N22I3NC73MLQ3LSI3NOK3MZY3NOM3NYT3MZU3MLZ3NOQ3LSW33C63N0934343D3H3MRY3NCW3LTE3N0F3GJ03M833ND236G33M7Z3N0N3NP83LTK33C63N0S343434PQ3O013ND63LTR3LZD3NPH33C63N133434343W3H9Y3NDM33SQ3MN637JL3N1A3NDQ3LUA33V43M8T3LZW3N1J38YL3NDX33C63N1N343433M83O0Q3NQ13NQ83LUT3NQ43NE63LUY3NTM3NEA3N2B3LV53FSH3MO33NEG2YV3M9N3NQI3LVH3NKC3NEO3LVM36513M9X3NET3LVT3NQT3N2R3NQV3MPC3NF03NR73MAI3NF33N323LW925N35GX3N2Y3N383NRA3LWO3MP83NFE3O223MP43NFI3MPF35E73MB43NFN3NZ03O2S3LX13LZD3NRV3D9F3NRX38OL3NRZ3MBJ25N22K341E3N4533SQ3NG433BL3NS53LXN3NG83O2O3O393LZW3NGE3LHK38S23MC13N4K3NVL3NGM3LHV3LY53NSM3NGQ3N4T25N22B3NSQ3N4X3LI93NGY3NSU3N513O3F3LIH3N553NH53NT13MRA3NT33NQ43NHC3MRP3NHE3LIZ3N5I3N4132L035WG3N5F3LZC3LJ83NTJ3NHO3N5S3O423LZL3LZW3N5X37JL3N5Z33C63N613BAR34JS3H9Y3MDT33TX3MSA37JL3MSC3LJX3NU03LG13O503N6E3MSK3NU53MSM3NU73O4O3N6N33SQ3NIN37JL3NIP3NUE3N6S3NX134QK3NUK3M0T3NUM33C63MT73434334U3LD73NUQ3M113NJ23NUT3NJ43N793NQ03MTL3NJA3LLE3NJC3MTR3NJE3ALJ3NV63M1L3NV83LLS33C63MU334343MFR3O6A3N7T3NVG3NVI3CTF3NJT3O6A33203MUI3LMA3NJZ3NVP3NK13N863NVL3N8933383NVV33BL3NVX3CTF3NVZ3NVT22D3NK73NW43M2R3NW63N8M3LN33O493MVC3LN83NWC3M333NKP34WI3NWJ3NKS3LNM3NKU3MHF3NKW3H9Y3N963NX23LNY3KO33MW23N9C25N22Z3M3J3NX33LO93NX53MWC3NX73N9N3NXB3LOL3NXD3MIB3NXF3KX13MI73MWR3NXJ3LOZ3NLV3NXM3NA43NM13LZD3NXS335J3NXU3MIH25N22X3M4N3NMB3M4Z3NY033C63MXG34343NAK3NY43LPT3NMK3LPX3NY93NMN34XQ3NMP3NAV3NYF3LQ83NMU3NAZ3NVL3NN03NN73NN23LQK3NYP3NB725N2333NYU3LQS3NN93NYX3MYL3NYZ3NBI3NZ23LR63NZ43MYV3NZ634XX3MKK3NZ93LRI3NZB3MZ63NZD3MZA3NZG3M6X3NZI33C63MZG343435G333WS3NO83NZN3NOA3M793NZS3N0C3NOH33353NCG38YL3NCI33C63MZZ34343D3M2303M7F3O033LSU3NOR3NCS3LSZ3O613N0D3O0I3LT63O0E3MME3O0G34663O0C3LTG3O0K3M8D3NDA3O2V3NDE33353NPF33BL3O0U3CTF3O0W3M893DTV3NPL3LU33NDO3LU73NPP3NDR3NVL3NDU33353O1A33BL3O1C3CTF3O1E3O1822P3M933NE33O1K3LUV33C63N1X343433JG3MRY3O1P33353NEC33BL3NQB3CTF3NQD3NQ8334C3N223O1X3M9Z3O1Z3NQL3NEP3O5L3NQQ3MOR3NQS3LVV33C63N2S343433UY368D3NQR3MAH3NF23LW63NR23NF53NTM3NR833353NFA33BL3NRB3CTF3NRD3MOT351L3MAQ3O2Q3LWS3O2S3MPH3O2U22T3NRR3O2X3LX33EHV3MBE3O3135C43O333MPX32DL3O373NG33NS43NG63NS63O3E3ODK3N463O3H3N4H3O3K3MQG3O3M22S3NSJ3N4O3NSL3LHZ3O3S3NSO3OE133SQ3NGV3O433O3Y3NST3CTF3NSV3LY33ODU3MCG3O443NT0364M3NT23LIQ3OEO3NT63NHD3MD23NHF3O4E3MD63OEF3N5N3O4J3MDC3O4L3CTF3NHP3MRP3OE83NHK3O4Q3NHW3LJL3O4V343434JS23F3NTV3NII3NTX3NI53CTF3NI73MS03ECY3LK23O583NU435TE3O5B3LKA25N3OFA3NIL3MEF3NUC3N6Q3O5J3NIR23D3NIT3M0R3NIV3LKT3O5Q3NIY23C3OG73NUR3M133O5Y3CTF3NJ53OG73CQS3NJ93NUY3O643NV03CTF3NV23O5W3OFQ3MFJ3NV73NJI3O6C3CTF3O6E3M1B3OFX3O6H3M1V3N7U3NVM3MFZ3NVK3MPC3N8033383N8233BL3NK03CTF3NK23OH223I3NVT3MGG3LMN3NK93MUX3NKB3OF23MGO3N8J3NW53LN033C63MV83434348I3OHN3D0R3O7D3LNA3NKN3MVH3NKP3OHW3N8Y3LNU3NKT3LNO3NWO3NKW3OFY3NKY3O7X3O7R3LO03NL23O7U3OHW3N9F33383N9H33BL3NLA3CTF3NLC3O7X3OHW3N9O3MWQ3O853LON3NLL3NXF3OHW3NLQ3NM03LOX3NXK3MIL3NXM3OHW3NXO33B13O8I3OJ63MIW3NAB3OH03NXX3NY43NMC3LPM3O8T3NMF3OFI3MJ23NY53O8Z3M5B3NMN3OGS3I623O953M5J3NYG3O983NYI3OIA3NMZ3NYM3O9D3M5V3O9G3OG53MY63NYV3M633O9M3NBF3LQZ25N3OGC3NNG3LR43NZ33LR83NNL3NZ63OGK3MYR3O9X3M6N3O9Z3NBV3LRN25N3OJO3NO03LS23NC03LRW3OA63NO63OJV3EY73MZL3LS63NC93NZR3LSB3O2V3OAH3MLY3NZX3LSK3OAM3NOM23H3OAR3NOP3OAT3O053CTF3O073OAR3OHW3O0B33353NOY33BL3NP03CTF3NP23NOW3OHW3NP63NPD3LTI3NP93O0M3OB93OHW3OBB3H9D3NDG3LTV3O0V3NPJ3OKV3O103LUD3OBM3M8X3OBP3OHW3OBR3EZI3LUH3NPX3NDY3LUM3OEV3O1I3MNP3NQ33OC33CTF3OC53OC03OHW3OC93FSH3O1R3LV73NQC3O1U3OHW3NEJ3NES3O1Y3LVJ3OCM3O213OKV3OCP3N343OCR3MAB3NQV3OJI3OCY3ODC3OD03MAK3OD33OJO3OD53LWO3LWG3O2L3N3C3O2N3OKV3NRH3MPM3O2R3LWU3NRM3O2U3OK13ONO3ODM3MBC3ODO3MPS3ODQ33CD3ODS3BAR31913OK933SQ3O383NGB3ODX3LXM3CTF3NS73ODV3OKG3OO73N4G3NSD3OE53N4J3LHP2LX3OJO3O3O3N4P3LHX3O3R3CTF3NGR3NSJ3OKV3OEH3N543OEJ3LYI3O413MR43OEQ3LYR3O463N593O4823G3LYP3NT73N5G3OEZ3NTB3O4F3OMH33353NHJ33SQ3NHL38YL3NHN3OF73O4N3OHW3NHU3NTO3MDM3NTQ3NHY3MDQ3OHW3O4Z33SQ3O5138YL3O533NI63NU03OKV3NIB3MED3O593OFU3N6I3O5C3OHW3NUA3O5F3N6P3LKI3O5K3OHW3N6V33353MT338YL3N6Y3OGA3NUO3OHW3MTB3MF93NUS3LL43O5Z3NUV3OHW3N7C33383MTO38YL3N7F3NV13NJE3OKV3MTX3NVD3O6B3M1P3NJL3ON93MU73NJO3OH33O6K335J3O6M3NJN3OJO3OH833353OHA25M3OHC335J3OHE3MUI3OKV3O6W3OHO3OHJ3LMP3NVY3NKB3ONT3O6X3OHP3O773OHR3CTF3OHT3NK73OO43LN63NKL3OHZ3NWD3CTF3NWF3NKK3OOD33353OI43NKU3O7K3OI73CTF3NWP3M2Z3OKN3NX03NKZ3OID3M3N3O7U3OKV3OII3LOH3NX43LOB3NLB3NX73MRY3OIR33353NLI33BL3NLK3CTF3NLM3M3T32UH3M433O8B3OJ03O8D3CTF3NLW3OT63OJ43O8H3LP93OJ83MX53OJA3OHW3MJ13NMH3NXZ3OJF3CTF3O8U3O8P3OHW3NMI3I623LPV3NML3MXP3NMN3OKV3NYD3OJW3O963M5L3O993OHW3O9B3GIR3OJY3MK23O9G3OHW3MYG3MKI3O9L3LQW3NNB3NYZ3OHW3NBJ3MKT3OKC3M6F3NZ63OHW3MZ133383NNS33BL3NNU3CTF3NNW3NZ83OKV3OKP33353NO238YL3NO43OKT3NZK3OR63OUY3LZW3NZO38YL3NZQ3NOC3NZS3OJO3OL33OAJ33BL3OAL3CTF3OAN3NC73OKV3NCO3LT23O043M7T3NOT3ORU33353OLI3O0E3OB03LT83NP13O0G3OS23OLJ3O0J3OLT3O0L3CTF3O0N3O0I3OSA3E3Z3O0S3OM03M8N3NPJ3OJO3OM533353O1238YL3O143OBO3O163OKV3OMB3OBT25M3OBV335J3OBX3NDN3MNN3OC13M9F3O1L3OC43NQ62363NQ83LV33NQA3O1S3N263OMV3O1W3LVF3NQJ3OCL3CTF3NQM3O1W3OHW3ON43FT33O253OCS3CTF3OCU3O233OHW3O2A3LWC3O2C3OD13CTF3NR3343433IN3OKV3ONG3OD725M3OD9335J3ODB3O2I3OHW3ONN3LWQ3ONP3O2T3LWX3OPC3O2W3MBA3O2Y3ONX3N3X3ODQ38Z93MPW3OO23OY73OO63LXI3LHW3O3C3OOA3OE03NSH3OOF3LXV3OOH3NGH3OE73OE93NSQ3NGO3OOP335J3OOR3MQC3IGH3O3W3LYE3NSS3OOX3NH03OSJ3OEP3NH43OER3LJL3NH83OZ33OKV3N5E3N5N3O4C3LJL3NTC343432L03OVQ3NTG3OFB3O4K3LJA3O4M3NTL3OVY3NTN33383O4R38YL3O4T3CTF3OFF3NTH3OW63OPT3OFR3OFL3M003NU03OJO3OQ133353NID33BL3NIF335J3NIH3O573OKV3OQ83MEN3OQA3M0L3O5K3N0C3OQE3FOQ3NUL3OG93CTF3O5R3MSS2353OGD3O5W3OQO3M153O603MPC3OQT3MFJ3OGN3M1F3NJE2343OGZ3OGU3M1N3NV93O6D3NJL3ML33NVE33353NJP33BL3NJR3O6L3NVK33ZV3O6P3NVT3NVO3LME3O6T3NVR3MLX3ORO3D0J3ORQ3M2J3NKB23A3O753NKK3OHQ3M2T3NW83NKK3OHY3M313OI03N8U3LNF25N35FE3O7I3NX03OSE3NKV3LNR3O5L3O7P3CSP3OSM3MHQ3O7U34KC3MVY3O7Y3M3V3O803N9K3LOE3NTM3OSX3NXD3OIT3NXE3LOQ36HK3OT63N9Y3OT83NXL3LP23OAX3OJ53NXQ3O8J343L3O8L3NLR2EO3O8P3NXY3OJE3M513NMF3NAL3OJK3OTU3O903CTF3NYA3OJJ193M573NMQ3NAW3OJS3CTF3NMV3P3S3NB13OJX3M5T3NYO3CTF3NYQ3NYL183O9J3M613OUD3M653O9O3P483OKB3O9R3OKD3CTF3NNM3P4835143O9W3NBS3O9Y3LRK3NNV3OA13NBY3LRS3OKR3M6Z3NO63HEV3OAB33383OV733BL3OV93CTF3NOD3M6V3NTM3OVD3NOJ3OL63OVH3NOM1D3OLA3NOW3OLC3OVO3OAW33JM3N043NOX3O0D3OVV3OLN3O0G3K5W3OB53OBI3OW13OB83NPB3MPC3OLY3OBD25M3OBF335J3OBH3MMK25N3KR03N173OBL3NPN3OBN3CTF3NPQ3NPL3P5G3O113O193NPW3LUJ3O1D3NPZ3P5N3OBS3OWT3MNR3OWV3OMM3NQ63ML33OMQ3OCB25M3OCD335J3OCF3OMJ335B3OCI3OX63OMZ3MA13OCN3P6A3NES3LVR3ON63NQU3LVY32BE3MA73NQY3OXN3OND3O2F3MLX3OXU3O2K3LWI3NRC3O2N103ODE3MPE3ODG3ONQ3CTF3NRN3ODE3P7233353NFQ33353NRT25M3O2Z36ZB3LX83GCL335J3OYF343431913P6H3GX43NS33OYK3ODY3O3D3LXP3O7B3LXS3NSJ3OOG3LHM3OYS3OOJ25N173OYU3OEN3OYW3OEC3OOQ3O3T3P7S36TH3O3X3LYG3O3Z3OEL3O413P863NSY3LIT3O453OES3O473OEU3H9Y3OZF3OPD3OP83O4D3OPA3MD635Q13MRH3N5O3OZP3LZG3O4N3P8S3OPM3OZV3OFD3MS33NTS3P863P033N6D3P053N693LJZ3NTM3P093HPD3OFT3LK83O5C153M073NIM3P0K3MEI3O5K3MPC3P0O3OQG33BL3OQI3P0S3NIY33073O5V3NJ93P0Y3MF43O603ML33P123N7K3P143NJD3LLJ25N3CU33O693NJN3OGV3OR43NVB3MLX3P1F3NVM3O6J3M1Z3NVK1Q3OH23O6Q3P1P3M293O6U3MRY3P1U3O6Y25M3O70335J3O723MG6343L3NW33P213ORX3P233O7A3H9Y3NWA3OSB3O7E3NKO3P2A333U3P2D3MHB3OI63P2G3M3F3NTM3P2J3NWV25M3NWX335J3NWZ3PBV3D6O3NL73OT43O7Z3OST3OIN3NX73MPC3P2W3OSZ25M3OT1335J3OT33NXA3DUL3NXH3O8M3P343OJ23P363ML33P383OJ73LPB3NM53OJA1T3P3F3OJD3O8R3OTN335J3OTP3MXA3MLX3OTS3NY633BL3NY83P3O3NMN351D3O943NYL3OU13MJS3O993MY43P403MK03P42335J3P443MJO3K8Q3P473NNG3NYW3OUE3CTF3NNC3NYU3H9Y3OUI3NNQ3P4E3OUL3LRB3L6E3NZ83P4L3OKJ3P4N3OUT3NZD3N0C3OUX3EY73NZH3OKS3CTF3OA73NBY34KQ3P4W3LSE3OAD3MLK3NZS3MPC3P553OL53M7J3NOM34MD3O023OLB3M7R3OAU3O063NOT3ML33OVS3OLK25M3OLM335J3OLO3P5H1N3O0I3OB63P5Q3MMO3OB93MLX3P5U3O0T3NDH3N123NPJ3A6L3MN43P643M8V3NPO3P673OBP3MRY3OWL3P6D3M973NPZ1L3OC03NQ23OC23M9H3NQ63H9Y3P6P3OX13OMT3OCE3O1U35HN3P6X3O233P6Z3MOD3OCN3N0C3OXD3N2O38YL3NEV3OCT3NQV3LEQ3NQX3OCZ3MOV3O2D3OD23O2F3LQP3OXM3LWE3P7G3MAU3O2N2163P7L3NRR3P7N3OY53MB63OAX3P7U3ODO3ODN3LX53NRW3P803EWE3OO13P8425N336D3NG23P883MBP3P8A3OYM3P8C3PGT3P8E3OZ03P8G3LXX3O3M3PGZ3OZ03OEA3P8O3LY73O3T3ML33OOU3FGN3OOW3MCK3O412143OZ33OZ93OP13P933OP33OEU3PHN3P97350S3OZH3LZQ3OZJ3OP63PHT3O4I3NTH3P9G3MDE3O4N3MLX3P9K3N653NTP3NHX3O4U3NTS31MQ3NHV3NTW3MDW3NTY3O543P9U3PHN3P9W3P0B25M3P0D343L3P0F3OPU25N3PIJ3OQ23OG03M0J3NUD3CTF3NUF3PA23N6U3LZW3PA925M3PAB335J3P0T3N6O2YU3PAF3MTC3O5X3OQP3OGH3O603PHN3PAL3OQV33BL3OQX3OGP3NJE3PJC3OGT3O6A3PAU3MFO3NJL3H9Y3PAY3P1H25M3P1J3ORB3NVK2193PB43P1O3M273O6S3OHD3O6U3PHN3PBA3NK83ORR3O713NKB3PK63D0J3O763MGS3O783OHS3NKI3N0C3PBO3GA73OS53O7F3P2A3PHN3OSC3NWL33BL3NWN3OSG3NKW2183OSK3OIC3M3L3O7S3N9B3LO325N32493PC83NXA3PCA3M3X3NX71Y3OT43MWI3P2Y3O873P303PLO3N9P3OT73M4F3OJ13MWV3NXM3K5S3P3D3LP73PCU3M4R3OJA353S3OJC3OJJ3P3H3MJ63NMF3PM03MJB3P3L3M593OTV3NAQ3LHP34072133P3S3OJQ3MJQ3P3V335J3P3X3NMP3LV03OJW3LQG3NYN3O9E3P433O9G2123PDR3MYH3P493NYY3OK73CR93OKA3NZ83PE13NZ53PE3318C3P4K3NBY3P4M3M6P3NZD353O3NZF3P4R3PEE3P4T3NZK32DY3PEK3H8O3OKY3NOB3P513NZS21L3NZV3OAR3PER3NOL3LSN25N21K3P5B3P5H3P5D3MM33NOT21R3NOW3N0E3OVU3O0F3LTB25N33WY3N0M3PFB3M8B3OLU3OW33OB93KPF3P603OW83M8L3PFI3NPI3LTY25N38KI3P633O183P653OM83O16353Q3NPU3OC03OMD3P6E3OBW3NPZ352V3NE23PFZ3OWU3OML335J3OMN3NE2352C3OMJ3OX03OMS3M9R3O1U351Z3PGA3MOH3PGC3N2G3OCN21J3O233P743OXF3ON73P77335R3OCQ3PGO3N303PGQ3OXP3OD32U43O2I3PGV3ONI3P7H3ODA3O2N21G3PH03NRI3OY43ODI3OY6336V3OY33ONV3MPQ3OYB3NFV3PHB3ILP3PHD341E333G27C3MQ03ODW3P893OO9335J3OOB3NG23KDV3OOE3P8F3OYQ3P8H3NSF3O3M3PMJ3LHH3NSK3PHW3MCA3O3T3PM73N4W3OZ33PI23MR03O412F13O433PI73MCS3OP23NH73O4825R3PQY3P913OEX3MRJ3OP9335J3PIH3MCQ3PO73MRP3OF43MRS3OF6335J3OF83P9E25Q3PRX3OZU3PIR3OPO3PIT3OZZ3NTS3PRD3LZV3PIY3MSB3PJ03OPY3P9U25P3PSE3PJ43OQ33P9Z3OFW3PMZ3O5E3P0J3OG13OQB3NIR3PSY3PA83OG83M0V3NIY3CKW3NJ03P0X3OGF3PJW335J3OGI3N73339H3OGL3OGZ3PAN3O663PAP3PO83PAS3OR23PK93NJK3NVB33803NJN3O6I3M1X3OH43MUD3NVK3PRW3P1N3PBG3PB63MGA3O6U3PU03N813NVU3PKS3P1X3LMS3PS53PBI3MGQ3NKF3ORY335J3OS03MV23PTH33SQ3PL43MVE38YL3N8T3NWE3NKP25D3PSE3PLA3PBW3O7M3P2H35WS3PBV3OSL3PLJ3OIE3NWY3O7U3M0F3OSQ3IOP3PLR3NX63P2U3M0F3PCF3NXC3OIU3OT23NXF3PUK3PCN3P3D3PCP3PM53P363PPD3PM83O8P3OTF3PCV3NXT3OJA366N3PME3OTL3PMG3NME3NY23M553PML3MJF3PMN3O913PMP3O9Z3NAU3PDF3OJR3O973P3W3O993PVH3PN03NYU3OU73MYA3O9G3PVN3NBA3O9K3PDT3P4A3OK725I3PSE3PDZ3NNI33BL3NNK3P4G3NZ63LYY3OUO3LRQ3NZA3PE8335J3OUU3O9W3LXR3PEC3OUZ33BL3OV13PEG3NO63PWD3OKW3NC73PNX3OAE3OL13PQ33PEL3NZW3M7H3NZY3NCJ3PO6379N3PEV3P5C3PEX3OLD335J3OLF3O023LXR3PF23P5J3POI3M853O9M3P5O3P603PFC3N0R3OB93PXC3PFG3OW93NDI3POY3PNI3N0Y3NPM3PFO3P66335J3P683N1733TA3P6B3NPV3PP93PFV3OMG3LWN3MNO33SQ3N1T38YL3NE53OWW3O1N3LWN3PG43PPO3O1T3LVA3KSB3PPS3NEK3OX73ON03OX93OCN3PNU3PZ63PPZ3MA93O2639MR3LVX2BM3LGV3OXQ33VX33IN3LVC38663LWP37H03LXJ27A3OXX343L3OXZ3N373LW03OY23P7T3PQK3N3N3O2U3PXC3PH63P7W3P7Y3NZ73PQT33B03PQV33TX31913PPR3OO53PR03PHJ3PR233383191355J3O30315434G533AM33O43KV233KJ2GM3KL63PQY3CWU3KWB32KP2H63LGD32KP2LX3KGJ3G6X36SN336L3OYZ3NGD3EMX3PRK3OEP3PRM342B2H6312V2792LX333Q3Q1E35S53J1D3GV22H63LEV2YQ2H625E3PXP34XG3Q1Q33S62H626727C33M63LHO3PXP3A9T3PXP3A4J2H6331B2A03FPU3GKJ3L2B3E4V3FTP3L7Y3E5L3L2O338J3D6O2H637XX2H638BH3CNK2H62653Q1R33WC3Q2N36963Q2J3LCE3Q1Y340L3Q2033WC23B3Q2233K131A724K3Q2W34S33PXP34AE3Q2S3L8P338J332G2LX336S3OEM34GK2I63CZD3KHO3LH23G863LH536353KXW3BB33COZ3NSN3LY935U63Q193NGW3Q1B33Z73MBU3PXP3Q1G335R2713PXP33M33Q2H35942H62723Q3335ZU3Q413LFI339N3LGV3Q1631SA2TQ3LH03P8T33VX3MQX3HTV3OEK391D2LX35LZ3COU3MQV3CO235CR2LX3LGO3GBA3COZ35FY3PXP333Q3Q4634QT3Q2M3A5F2LX3KUI3MQL35PL39MT3GX424M3Q3533ZJ2R83LCJ27A36F332L031H03Q4U3P0035G63ME731SA3P033EUD3Q3K350S36663B1I36443MRU3O4N3LKM3PSF3LZV3PIS36FF2R82433PXP32L0333Q3Q6336963Q5D3LCE3DRJ32L0334H31543Q5K34GK3Q5M37XK3Q3I3LZX3Q5Q3MSC3B063Q5U3NTK3LZI3Q3R3O4P3LZN3Q603KLA2R83Q5A3KI0333Q3Q6X33YA2R838F62R824T3Q473GQA3Q493LZE3Q4B25M3PSB34GK3LJE33VX3P9K37XK3Q5Q3OZY391D3N5E3Q4P3DR73Q4R3B0432L03HI934P83Q5U34AS3Q6733WC3Q7534XG3Q70351F34XN34Q024H25H34TE3Q80351H3AZ63Q84351G34XZ374G3PXP34TQ2H626P3Q4Y3L3K3Q413LXG3Q57338H3Q543Q3Q3Q8L34MY2H62343Q5B3Q793Q2K36F632L036J13Q723AAA3P912642BM38C63LIR3L8V3GYK3LGX38W33NIW31SA3Q7G3Q5Z32OO3Q7J343F2R821X3Q6433WC3Q9I33S63Q8Z351X2R821Y3Q7627A3Q9Q3Q9M3Q7A3Q7C31SA3Q7E3Q5L3PZP3Q9D3L4W3OPP33VF3Q7L3NTH3Q7O3B463Q7Q33LW3Q7T35682503Q8H27D3Q9T351T3Q693KZW32KL3Q5H3KSI32JR3Q9N3A003Q913Q933Q793CPQ3Q9E3MRM3Q993LL93LGB3QA03OZW3G863PSI36602R82313Q9J333Q3QB53Q6833YY318O3Q6B34YT3Q7936J33QAQ3ELV3QAS3Q963Q9W3QAW3Q7F3QAZ3PZR3GYK3QB23Q9G25N3Q8S3Q6Y335R3QBT3Q71381C2R823J3Q9R25N3QC03Q9U33103LGV3QBK350S3Q4G3Q9C3QB03QBP37M33QA53OFB3QA733KY3QA9353K3QAB35973QB833WC3QC333WC3QBW3Q8634Q927D2373Q8934Q434TG3QCS3L463QCV21G3Q8B2543Q8D351O2H63QD33Q51369K2BM32KL3Q0Y3HTQ3Q2U1H3QC13QDF3QD83Q8L339M3Q8N3MCC3DQE27C3Q8Q3L6E3Q782R83KJ03M4W330Q3LEK3FTQ3F093KZY352O3Q4U3QAY3QAO364M33M62R81J3QC13QE733S633963QC53PJ63QAV3LZV3Q4G3OQ127A3NID3QAY3OQ433W234JS365B3Q7M32BL3QCG3QED3Q5S3GBA3Q3K34AS173QAE2LF3Q20353S3QE1340P3OOO1F3Q8J3JEJ3A4J3191341T32Z3352O3Q0Q352O3Q123Q2339G93GK73Q2E3POK3NG632Z633WY3CJK27D33WY3QF23G8W2R8339A3L2S3DQY3LDK3QC832HX3MR73Q4G3LZB3QFZ3DR13QG1339B3QG33CYI3QG53CPO3QA23QG833VX339635443QGB3HHX3Q9X3CQB3QG73HHX3I6P34WD3QAY25X32HX3396365B3QC93KLH3LZV3KR227E3OPV3KI73NTY33N434JS361D336L32FN3QFO336L3QGY38J834JS337A3QH136X93QH43JLV3O5J3Q5Q38ZB3QHA3A43337Y34JS334A3F073QDX3MOQ3GKJ355E352O3QDZ3HTV3Q2B3Q3M3F093HAM35ZO3D6D3Q123PJ83EMX35C525M381E3AEF3Q0Q33SQ3J1D34O73I1H33TA31A7333Q25Z33TA3KL3381C31A725S3PYL39153QII33IR3KL933SQ319125W3QDA25M3KL63AWY33MS319134G53Q7M2LX3QER31913QGW3DRZ3AH33ALN26333TA39643QII3GKY3AYK31A73HHQ3NG235U12B03AE031BT34VM3PQZ26H3QIV2H6322Q362J3O3B3GX43KIJ3QIW34AH3PSE2LX3QJJ38NN3QJ03QHV3O3G33L233BG2LX322Q3DXK3QJ53GDL2H626N3PQY3ODK2LX26M32HX3L0H3QK43LH33QJY35G62TQ26L32HX3Q4N3H4U3Q4E36BE3QKR3NG632DK3QKU3QJH3Q3E35YS32HX2TQ32DK3Q4U2I63QE13A4J2R83ADW3F093QFJ3Q2A33VZ3M4W39D13GK7364O3A4J3396369W3QFI36FP3QHL3FES331F352O3Q5U3Q2D3EK432FN3QDT3LZX37CM3QLN32Z634JS32FN32ZC337A33M632FN2473QIN333Q3QM83IZF32ZI337A2S63N6W26B3QIV356E322Q3LLL335S26A3QIV332G322Q35AP33BL3NJ336F6334U3QLX3QMJ36VJ3QFC3GKJ3D003IZ3334U32ZC357T33M6334U24F3QM9335R3QN8339L2I63KMT35972413QIP3PKF3QAP3N7K3KUN33BG3CR0322Q3EV9336L33303QNE38ZB332G3D0D3GBC3F0N3NU53IR736D93QNH32ZI39MR334U379K33BG334U3FM1335J356E3QET38ZB32ZI357T3QNW33WY3QN137Y1334U35U33A4J356E3KI23E5C3QLD3KSI27E33963LKL33CA33NL3D6O32ZI26F3Q1X337Y32ZI333K3QDW3QHF3QLU3Q2B3QJ633WY3G623E4S356E37DD3QP33QF23QHQ3Q2B3QN133KJ3D6O356E26D3QOZ3FOQ3KF03QPD3GKJ3QOP3KQQ3HTM3KMZ3E4S3CR0335I3QPP3Q2B3QPR3NIW33093D6O3CR03QPL3FH13CR034YY33WY3KN83OI03NJX33B233BG358E322Q3DSD3A4J3LMT3QMY35CU3QPQ3308339633303DSD3PHN358E336U3KYC3QQF3D0F352G3M2E34H0352O3KN33QP532OO3QQO3PTX3QQR35B93QQE36E63QQH337Y3M263QQZ3QQL3QPZ3QQN3DS13QQQ3OH23F5K32KL3QQV3E0D3E4S33NW34JS3QRD357B3QRF32Z63QR43QRI3MUI26W3QIV3QRM3PTX3QQI3LZV3QRR3O6537CE3I5K3QOR3QRH3KNH3MU93E2N3QRZ3QR93QRO3LZX3QS43QR13QOO3QRG3QQP3QSA3NJX2723QSD3QQG3QSF3HP33F093QSI3QLC3QSK3QR53OH22713QSP3QQW3AHB33NW35PX3QFB3QRE3GKN3DQ032KP3QRV3QSM3P1G35TF3QT03QRN3QQX3FOQ3QSH3QQM3QRU3QS9371S3QSB26R3QTE3QS13QRB335S3QTI3QRT3QR33QTL3CRW3NJX26Q3QTP3QRA36LK3LF03QT53QRS3QT73QGU3Q993QSL3QTM3NJX333D3QR83QSQ3QTG39IZ3QU43QS53D6D3QFJ3QTA3QUA3QTC26O3QU03QSF358E3QTT3QU63QUK3QTW3QR633KY3QUD3QT13QS2373G3E5C3QSU3QPF3QTV3QU93QTX3QTC26U3QUP3QTG36UX3QST3QTJ3QV53QSX3MUI33ZJ3QUY3QTF3QT23IYR3QLR3QT63QS63QT83QS83QV63QR637ZN3QRL3QSE3QTG33A13QUS3QVP3QU7350S3QVS3OH232M63QVV3QUE3QVL35RU3QUH3QV33QS73ETU3QW33MUI3A8S3QQU3QVW3QVL33Y93QP33QWB3QVQ3E5L34OL3QUL3QV73NVM3DDX365C25M3QS03QU133NW35ZY3QWL3QVE3QW03QWP3QUV3OH223S3QVA3QVL36KT3QX03QTU3QX23QSW3QRW3QSB359P3QVJ3QTQ36LK3LFU3QXA3QUT3GKJ3QX33QWE3QSB23Y3QX73QS23AK03QXL3QW03QQ03QXO3QVG3QSB23X3QXS3QTR36UP3QXV3QUJ3QXN3QXD3QTB3NVM35853QXH3QWX3I623QVZ3QY63QTK3QXP3NJX23N3QY236LK36U13QWA3QX13QVR3QXZ3NJX37A03QYC3QSF35ZK3QYO3QXB3QYQ3QXE3NJX23L3QYL3M2M3QQK3QU53QXW3QY83QUM3NVM23K3QZ33NNQ3QYF3QR23QT93QX43MUI37CF3QW63QUZ3QTR35G33QZE3QSJ3QYH3QYR3QTC38KY3QYU3QTG33033QZO3QSV3QZQ3QZ03QTC23P3QZC3K413QYX3QXM3QZZ3QY9358E23O3QZC3D3H3QZX3QV43QZG3QYI3QTC356O3QZU3QVL374H3R053QZ73R073QZ9358E24A3QZC34PQ3R0D3QWC3QU83QZR3NVM2493QZC3HHN3R0M3QYG3QVF3R003NVM2483QZC3D463R0U3QWN3R0W3R15358E3KWI3R0J3QS233MC3QVN3QZ63R133R0F3R0X358E24E3QZC36W53QVD3QYY3QWD3R1N25N32HR3R1G3QTR3KFM3R123QZF3QYZ3R0836EB3QZC374C3R213QZP3R143R242433QZC3HEQ3R283QZY3R2A3R0P25N35MX3R1Y36LK33SZ3R2F3R0E3R233R2I2413QZC361P3R2O3R0V3QW23R1V33BL3R2L33NW34O33R2V3R1B3R2X3R1D36393QZC3HP63R333QW13QWQ3QR635YE3R303ODO3R1A3R3B3QZH3QSB2453QZC36CN3R3A3QUU3R0G3NVM3HFR3R3F31IF3R3H3R3P3R1V24R3QZC342H3R3O3QZ83QWR358E24Q3QZC361A3R413R0O3R4336D93QZC31UK3R3V3R423QR63JXB3QWU3QWW3QSF360K3R483R2H3R4A35UE3QZK3QVK3QS2375E3R1S3R063R4N3QR637ZL3R4Q3QXI33NW3L413R4E3R493QR624T3QZC38D33QR03QYP3R1U3R363GM23R4Z3QYD2J33R533R4W3OH224J3QZC3L2S3R5H3R1M3R3624I3QZC37523R4M3R5O3R243K503R3F3KHU3R5T3R2Q3R4A3DB33R5E3QSF36NX3R5Z3R5B3R243GP23QWH3QW73QS23L4K3R5N3R603QR63D9E3R633QTG36XD3R4U3R0N3R5I3MUI3C6O3R4I3QWI3QS23KMJ3R6E3R673R2I3KZL3R3F33WN3R6U3R1C3R2439PG3R6I3QVL3L5E3R703R353R242563QZC3L5U3R773R3C3OH23F4R3R743QS2363D3R663R713R2I366Z3R7H3QTR3L6R3R7D3R3J3NJX37W43R7O36LK3L6X3R7R3R3Q358E3HGL3R3F3D3O3R7Y3R1V35XC3R3F36DO3R7K3R783R2I3F4Y3R6Q3R6B3QTR3L7W3R843R363GLG3R6A3QZL36LK376E3QV23R5A3R7L3R4A34RE3R3F362W3R1J3QUI3R223R6V3R4A3KZ03R3F39QA3R8O3R1T3R8Q3QR634VE3R3F361W3R893R7E3MUI3KYH3R3F35N93R8H3R242523QZC37683R9A3R7S3QTC2513QZC2BU3R9G3R2I356I3R3F36OF3R9L3R7Z34KO3R3F3LAQ3R9R3R4A3LGV3R3F331X3RA13QR62213QZC33IL3RA63OH22203QZC3LBM3RAB3MUI2273QZC347X3RAG3QSB2263QZC36YM3R6L3R1L3R6F3OH22253QZC34QN3R8V3QWM3R3I3R9X2243QZC36J63RAL3NJX21V3QZC33RQ3RB43QTC3L343R3F3BMS3RAX3R8P3R8A3R4A21T3QZC364Y3RBE3R943RBG3QR621S3QZC35KA3RB93NVM21Z3QZC377B3R933R4V3R5U3R2I21Y3QZC34Y43RBS358E2BO3R3F36FK3R9W3R1V21W3QZC3AZQ35RA3R593RBM352O3KFY3HAP3R543OH222J3QZC36XN28Y3RCF3RBY3D6D3RCI3D6H3R953OH222I3QZC364J3RCP3QVO3RAR3E5L3RCT39423RAS3MUI22H3QZC2EN3RCE3RD13R8X3E5C3RD4379Y3R9B3QSB22G3QZC363U3RD03R1K3RDD3F093RDF3QXY3R3622N3QZC3NOV3RDB3RDN3R293QW03RDQ3R4F3OH222M3QZC2503J5I3RCQ3RDZ3QY73Q2B3QFO3R2P3R8Y3QR622L3QZC3E1N3Q263RDC3RDE3RE93QU63REB3R2W3RDH3NJX22K3QZC2223RE63REJ3RDP3REL3QW03REN3R343REP3QTC22B3QZC377L3REI3RDX3REW3Q2B3KY73H4U3R6M3RBZ3R4A3L243R3F3NRQ3A3L3RE73RCS3REX3D6D3REZ3RAZ3R1V3L1S3R3F2273REU3RF73RCH3RFL3E5L3RFN3R3W3R362283QZC3D1D3RC93R363L1C3R3F3NTU3RC425N22E3QZC36ZU3RG43R2422D3QZC32WL3RG922C3QZC3KLJ3RG922Z3QZC21T3QZ53R8W3RDY3RD63QSB22Y3QZC334L3RG922X3QZC366E3RGE3R2I22W3QZC33443RG92333QZC3NYT3RG92323QZC3NYK3RG92313QZC36GI3RH33R4A2303QZC3NZU35PS3RFJ3E5L3DQA3RGT3RED3OH222R3QZC36YX3QY53RHR3RBF3RF13NVM22Q3QZC36623RHZ3E5C3RHS3R2G3RFD3QR622P3QZC3KKF3RI73F093RI93REC3RCV3MUI22O3QZC365H3RIG352O3RII3REO3R9M3NVM22V3QZC3KM63RIP3HTQ3RFC3RGU3NJX22U3QZC3O363RHP3REV3RIQ3RI13RIT358E22T3QZC3O3V3RJ63RFU3RIZ3RD23RIK3QSB22S3QZC3EQA3RIY3L0F3RCR3RHU3MUI23F3QZC3LG13RJF3RGS3RIH3RJ93R9X2HO3R3F3LD73RJW3RAY3RIR3RF03RJA2V13QZC3APO3RJO3QJV3RJQ3RJJ3NJX23C3QZC33203RK43GKJ3RK63RFO3R3623J3QZC3O743RKK3Q2B3RKM3RFZ3R2423I3QZC34WT3RKC3RKU3RE13MUI23H3QZC3O7W3RKS3QU63RL13RCK3MUI23G3QZC3KX13RL73QW03RL93R6N3QSB2373QZC3O8O3RLF3D6D3RLH3RIB3OH23L4A3R3F34XQ3RG93L3Y3R3F3O9I3RG92343QZC34XX3RG93L3I3R3F34UB3RHK3QR623A3QZC3OAQ3RG92393QZC34TZ3RM73CQP358E33X43QPI3NVM2383PQY33IR358E3QL03ORV3QK13QWV3PTX3LR13D0J1B3QIV348I322Q3CRS33BL358E3PKT3HGH3CRW3ALU3KNL32OO3E0P33083DT532OO3KO033083E123L8Q34C21A32HX34C232233FPR337Y339Y3OBZ3A3E3RF83QU63D5N352O3D0I3QW03QI23RIJ3F093RN83F093RNA3E5L3RNC38U434C235LC33WY3KO93NLX25N193QPM336H334C3AYX3RIA3D6D3QJ63QLE3QW03ROA3E5C3QQA3E5L3QF23396358E3D1Y34IY34KN',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
